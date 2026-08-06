# flash linear attention
以 Retnet 为例
## Norm, ACT, FFN

+ fuse norm, activation
+ fuse cross entropy, fuse linear and cross entropy

## Pre-attention Conv

## Attention

```python
RetNetForCausalLM → RetNetModel → RetNetBlock → self.attn: MultiScaleRetention
mode = 'fused_recurrent' if q_len <= 64 else self.mode

```

mode: chunk/fused chunk/fused recurrent/parallel

### fused recurrent fwd

$$
Q(K^TV)
$$

单个 thread 计算单个序列/request 的单个 head，只处理一部分 channel；

输入形状 q `[B, T, H, K]`, k `[B, T, H, K]`, v `[B, T, H, V]`, h0 `[N, H, K, V]`

输出 o 形状为 [B, T, H, V]， final state ht 形状为 [N, H, K, V]；N 为 request 数量/batch 大小；B 在 VARLEN 时为 1，非 VARLEN 时为 batch 大小；T 在 VARLEN 时为所有序列的总长度，非 VARLEN 时为单个序列长度；H 为 head 数；K 和 V 分别为对应的维度

对于单个 head，我们将计算按 hidden dim 切分为若干块，即 BK、BV；Q 和 K 的维度一一对应，因此切分后必须是同一块（NK 索引相同），块计算的结果需要加和（最后的 `o = o.sum(0)`）；V 的维度和 Q、K 的维度解耦，块计算的结果需要拼接，所以只需要 store 到本地的 o 块即可（这里的思想是先 QK 相乘后和 V 相乘，实际代码是先 KV 相乘计算 state 后乘 Q）

这里的的 recurrent 体现在 `for i in range(T):`  循环中，每个循环会取下一个 q k v 的特定维度，kv 相乘加到已有的 state，然后 q 乘该 state 就得到了 o

## fused recurrent bwd

linear attention 总体形式是

$$
\mathbf{H_{t+1}=H_t \odot \exp(g_t) + k_tv_t^T} \\ 
$$

$$
\mathbf{o_t=H_t^Tq_t}
$$

其中各种 gate 可能是形状 [1], [k, 1], [v, 1]，对于这种 RNN 形式的反向传播推导如下：

对于 qkv，直接由 dht 可以求得

$$
\mathbf{dq_t=H_tdo_t} \\ \mathbf{dk_t=dH_tv_t} \\ \mathbf{dv_t=dH_t^Tk_t} \\ 
$$

对于 ht，一部分来自当前 ot 的梯度回传，另一部分来自未来的 o t+1, t+2, …，通过 H t+1, t+2, …传回来，又称 BPTT（Backpropagation Through Time）

$$
\mathbf{d H}_t^{\text{total}} = \mathbf{q}_t \mathbf{d o}_t^T + \mathbf{d H}_{t+1}^{\text{total}} \odot \exp(\mathbf{g}_{t+1})
$$

伪代码如下：

```python
# 进入时间步 t 的循环：

# 1. 把当前时刻输出 do_t 注入到累积的 dh 中
#    这里的 b_dh 在进入循环前继承了从 t+1 传过来的旧 b_dh！
b_dh += b_q * b_do 

# 2. 此时的 b_dh 已经是包含“未来回传 + 当前输出”的【完整 dH_t】！
#    用这个完整的 b_dh 去计算 dq_t, dk_t, dv_t 以及 dg_t：
b_dq = b_dh * b_o_or_do ...
b_dk = b_dh * b_v
b_dv = b_dh^T * b_k

# 3. 在迈向 t-1 时刻之前，将 b_dh 乘以当前步的门控衰减，传给上一时刻
b_dh *= exp(b_g)
```

对于 gate，先进行一般推导

$$
\begin{align} \mathbf{dg_t} &=\mathbf{\exp(g_t) \odot H_{t-1}\odot dH_t} \\ &=\mathbf{(H_t-k_tv_t^T)\odot dH_t} \\ &=\mathbf{H_t\odot dH_t-k_tv_t^T\odot dH_t} \\ &=\mathbf{H_t\odot (dH_{future}+q_tdo_t^T)-k_tv_t^T\odot dH_t} \\ &=\mathbf{H_t\odot dH_{future}+(H_t \odot q_tdo_t^T-k_tv_t^T\odot dH_t}) \end{align}
$$

第一部分继承之后时间步的累积，第二部分则是每个 timestep 需要加上的部分

这是不同形状的 gate 广播为[k,v]之后的形式

$$
\mathbf{dg_{i,j}} =\mathbf{H_{i,j} q_ido_j^T-k_iv_j^TdH_{i,j}}
$$

接下来对于不同形状的 gate，首先 gate 形状为 [1]

$$
\begin{align} \mathbf{dg_t} &=\sum\mathbf{H_t\odot (q_tdo_t^T)-\sum k_tv_t^T\odot dH_t} \\&=\mathbf{Tr(H_tdo_tq_t^T)-Tr(k_tv_t^TdH_t^T)} \\&=\mathbf{Tr(q_tq_t^T)-Tr(k_tk_t^T)} \\&=\mathbf{q_t\cdot q_t-k_t\cdot k_t}\end{align}
$$

其次形状为 [K,1]

$$
\begin{align} \mathbf{dg_i} &=\mathbf{\sum_{j=1}^{v}H_{i,j} q_ido_j^T - \sum_{j=1}^{v}k_iv_j^TdH_{i,j}} \\ &=\mathbf{q_i\sum_{j=1}^{v}H_{i,j} do_j^T - k_i\sum_{j=1}^{v}v_j^TdH_{i,j}} \\ &=\mathbf{q_idq_i - k_idk_i}\end{align}
$$

其次形状为 [V,1]

$$
\begin{align} \mathbf{dg_j} &=\mathbf{\sum_{i=1}^{k}H_{i,j} q_ido_j^T - \sum_{i=1}^{k}k_iv_j^TdH_{i,j}} \\ &=\mathbf{do_j^T\sum_{i=1}^{k}H_{i,j} q_i - v_j^T\sum_{i=1}^{k}k_idH_{i,j}} \\ &=\mathbf{do_j^To_j - v_j^T dv_j} \\ &=\mathbf{o_jdo_j - v_j dv_j}\end{align}
$$

## fused chunk fwd
将一个 chunk 的 fwd 分为 inter-chunk fwd 和 intra-chunk fwd，前者是 qt 乘 ht-1，后者是标准的 qkv attention