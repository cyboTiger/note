# 反向传播推导
由于写 triton kernel 时需要自定义 backward，很多分块反向传播求梯度的过程比较复杂。

本文尝试罗列不同算子的反向传播推导。约定：所有向量默认为列向量。对于标量 $L$（通常是 Loss），$\frac{\partial L}{\partial \mathbf{x}}$ 的形状与 $\mathbf{x}$ 保持一致。

## 标量积（内积）
假设有两个 $n$ 维向量 $\mathbf{w}$ 和 $\mathbf{x}$，它们的内积得到一个标量 $y$：

$$ y = \mathbf{w}^T \mathbf{x} = \sum_{i=1}^n w_i x_i $$

在神经网络中，假设下游传回来的梯度是 $\frac{\partial L}{\partial y}$（这是一个标量），我们需要求 $\frac{\partial L}{\partial \mathbf{x}}$：
根据链式法则，对 $\mathbf{x}$ 的第 $j$ 个分量有：

$$\frac{\partial L}{\partial x_j} = \frac{\partial L}{\partial y} \cdot \frac{\partial y}{\partial x_j} = \frac{\partial L}{\partial y} \cdot w_j$$

将所有分量拼回向量形式：$$ \frac{\partial L}{\partial \mathbf{x}} = \frac{\partial L}{\partial y} \cdot \mathbf{w} $$

同理可得：$$ \frac{\partial L}{\partial \mathbf{w}} = \frac{\partial L}{\partial y} \cdot \mathbf{x} $$
## 矩阵乘向量
考虑输入 $\mathbf{x} \in \mathbb{R}^{n}$ 经过权重矩阵 $W \in \mathbb{R}^{m \times n}$ 得到输出 $\mathbf{y} \in \mathbb{R}^{m}$：

$$\mathbf{y} = W\mathbf{x}$$

$$y_i = \sum_{k=1}^n W_{ik} x_k$$

注意到 $W_{ij}$ 只对 $y_i$ 有贡献（当 $k=i$ 时），所以：

$$\frac{\partial L}{\partial W_{ij}} = \frac{\partial L}{\partial y_i} \cdot \frac{\partial y_i}{\partial W_{ij}} = \frac{\partial L}{\partial y_i} \cdot x_j$$

这正是外积（Outer Product）的定义：$$ \frac{\partial L}{\partial W} = \frac{\partial L}{\partial \mathbf{y}} \mathbf{x}^T $$

## 矩阵与矩阵相乘

现在进入通用情况：$Y = A B$，其中 $A \in \mathbb{R}^{m \times k}, B \in \mathbb{R}^{k \times n}, Y \in \mathbb{R}^{m \times n}$。
已知 $\frac{\partial L}{\partial Y}$（大小为 $m \times n$），求 $\frac{\partial L}{\partial A}$

利用标量微分的和矩阵迹（Trace）的关系：$dL = \text{tr}\left( \left(\frac{\partial L}{\partial Y}\right)^T dY \right)$ ，也就是按元素乘 $dL = \text{sum}\left( \left(\frac{\partial L}{\partial Y}\right) \odot dY \right)$

由于 $Y = AB$，则 $dY = (dA)B$。代入上式：$$ dL = \text{tr}\left( \left(\frac{\partial L}{\partial Y}\right)^T (dA)B \right) $$

利用迹的循环移位性质 $\text{tr}(XYZ) = \text{tr}(ZXY)$：

$$ dL = \text{tr}\left( B \left(\frac{\partial L}{\partial Y}\right)^T dA \right) = \text{tr}\left( \left( \frac{\partial L}{\partial Y} B^T \right)^T dA \right) $$

根据定义 $dL = \text{tr}\left( \left(\frac{\partial L}{\partial A}\right)^T dA \right)$，直接对比得到：$$ \frac{\partial L}{\partial A} = \frac{\partial L}{\partial Y} B^T $$

同理，若求 $\frac{\partial L}{\partial B}$，令 $dY = A(dB)$：

$$dL = \text{tr}\left( \left(\frac{\partial L}{\partial Y}\right)^T A dB \right) = \text{tr}\left( \left( A^T \frac{\partial L}{\partial Y} \right)^T dB \right)$$

$$\frac{\partial L}{\partial B} = A^T \frac{\partial L}{\partial Y}$$

> 等式右边梯度=等式左边梯度x一个矩阵，该矩阵通过维度检查易得

## 激活函数
激活函数通常是 Element-wise（按元素）操作，因此对于：

$$Y=\sigma(X)$$

$$\frac{\partial L}{\partial X} = \frac{\partial L}{\partial Y} \odot \sigma'(X)$$

### ReLU
$$y=\max(0,x)$$

$$\frac{\partial L}{\partial X} = \frac{\partial L}{\partial Y} \odot \mathbf{1} \{X>0\}$$

### Sigmoid
$$y=\frac{1}{1+e^{-x}}$$

$$\frac{\partial y}{\partial x}=\frac{e^{-x}}{(1+e^{-x})^2}=x(1-x)$$

---

$$\frac{\partial L}{\partial X} = \frac{\partial L}{\partial Y} \odot X \odot (\mathbf{1}-X) $$

### SiLU
Swish 函数由 Google 提出，定义为：

$$ f(x) = x \cdot \sigma(\beta x) $$

其中 $\sigma(z) = \frac{1}{1+e^{-z}}$ 是 Sigmoid 函数。当 $\beta = 1$ 时，它被称为 SiLU。

令 $f(x) = x \cdot \sigma(x)$（以 SiLU 为例，即 $\beta=1$）

$$ f'(x) = 1 \cdot \sigma(x) + x \cdot \sigma(x)(1 - \sigma(x)) $$

$$ f'(x) = \sigma(x) + f(x)(1 - \sigma(x)) $$

$$ f'(x) = f(x) + \sigma(x)(1 - f(x)) $$

矩阵形式

$$ \frac{\partial L}{\partial X} = G \odot f'(X) = G \odot (\sigma(X) (1 + X(1 - \sigma(X)))) $$

### Swish
$$ \frac{\partial L}{\partial x} = g \cdot [\beta \cdot f(x) + \sigma(\beta x)(1 - \beta \cdot f(x))] $$

$$ \frac{\partial L}{\partial \beta} = g \cdot [x^2 \cdot \sigma(\beta x)(1 - \sigma(\beta x))] $$

## Normalization
### RMSNorm

公式：$y_i = \frac{x_i}{\text{rms}(x)} \cdot \gamma_i$，其中 $\text{rms}(x) = \sqrt{\frac{1}{n} \sum x_i^2 + \epsilon}$

为了简化，我们看向量形式 $\mathbf{y} = \gamma \odot \frac{\mathbf{x}}{s}$，其中 $s = \sqrt{\frac{1}{n} \|\mathbf{x}\|^2}$

微分： $d\mathbf{y} = \frac{\gamma}{s} \odot d\mathbf{x} - \frac{\gamma \odot \mathbf{x}}{s^2} ds$

求 $ds$： $s^2 = \frac{1}{n} \mathbf{x}^T \mathbf{x} \implies 2s ds = \frac{2}{n} \mathbf{x}^T d\mathbf{x} \implies ds = \frac{\mathbf{x}^T d\mathbf{x}}{ns}$

代入并整理：

$$d\mathbf{y} = \frac{\gamma}{s} \odot d\mathbf{x} - \frac{\gamma \odot \mathbf{x}}{n s^3} (\mathbf{x}^T d\mathbf{x})$$

利用 $dL = \mathbf{g}^T d\mathbf{y}$ 提取梯度：

$$
\begin{align}
dL &= \mathbf{g}^T d\mathbf{y} \\
&= \mathbf{g}^T \frac{\gamma}{s} \odot d\mathbf{x} - \mathbf{g}^T \frac{\gamma \odot \mathbf{x}}{n s^3} (\mathbf{x}^T d\mathbf{x}) \\
&= \frac{\mathbf{g}^T \odot \gamma^T}{s} d\mathbf{x} - \frac{\mathbf{g}^T \odot \gamma^T}{n s^3} \mathbf{x} (\mathbf{x}^T d\mathbf{x}) \\
&= ((\frac{\mathbf{g} \odot \gamma}{s})^T - (\mathbf{x}\mathbf{x}^T\frac{\mathbf{g}\odot \gamma}{n s^3})^T ) d\mathbf{x} \\
&= (\frac{\mathbf{g} \odot \gamma}{s} - \mathbf{x}\mathbf{x}^T\frac{\mathbf{g}\odot \gamma}{n s^3} )^T d\mathbf{x}
\end{align}
$$

$$\frac{\partial L}{\partial \mathbf{x}} = \frac{\gamma}{s} \odot \mathbf{g} - \frac{1}{ns^3} (\mathbf{g}^T (\gamma \odot \mathbf{x})) \mathbf{x}$$

### LayerNorm
定义：$\hat{\mathbf{x}} = \frac{\mathbf{x} - \mu}{\sigma}$，$\mathbf{y} = \gamma \hat{\mathbf{x}} + \beta$

$$
\frac{\partial L}{\partial \hat{\mathbf{x}}} = \frac{\gamma}{s} \odot \mathbf{g} - \frac{1}{ns^3} (\mathbf{g}^T (\gamma \odot \hat{\mathbf{x}})) \hat{\mathbf{x}}
$$

LayerNorm 的反向传播在几何上非常有美感：它实际上是将下游梯度 $\mathbf{g}$ 投影到了一个与全 1 向量 $\mathbf{1}$ 和输入向量 $\hat{\mathbf{x}}$ 都正交的子空间上。

$$ \frac{\partial L}{\partial \mathbf{x}} = \frac{\gamma}{\sigma} \left[ \mathbf{g} \odot \mathbf{1} - \text{mean}(\mathbf{g} \odot \mathbf{1}) - \text{mean}(\mathbf{g} \odot \hat{\mathbf{x}}) \hat{\mathbf{x}} \right] $$

第一项 $\mathbf{g}$： 原始梯度传回。

第二项 $-\text{mean}(\mathbf{g})$： 保证了梯度的均值为 0（对应 LayerNorm 强行抹除均值）。

第三项 $-\text{mean}(\mathbf{g} \odot \hat{\mathbf{x}}) \hat{\mathbf{x}}$： 保证了梯度与 $\hat{\mathbf{x}}$ 正交（对应 LayerNorm 强行缩放方差）。

### Softmax
Softmax 是最有趣的，因为它不是按元素的，每一项输出都取决于所有输入。

设 $\mathbf{y} = \text{softmax}(\mathbf{x})$，即 $y_i = \frac{e^{x_i}}{\sum e^{x_j}}$。

$$
\begin{align}
dy_i &= \frac{de^{x_i}}{\sum e^{x_j}} + \frac{-e^{x_i}}{(\sum e^{x_j})^2}d(\sum e^{x_j}) \\
&= \frac{e^{x_i}dx_i}{\sum e^{x_j}} + \frac{-e^{x_i}}{(\sum e^{x_j})^2}\sum e^{x_j}dx_j \\
&= y_idx_i - \sum y_iy_jdx_j
\end{align}
$$

关键结论： $dy_i = y_i (dx_i - \sum_j y_j dx_j)$。

写成矩阵形式：$d\mathbf{y} = \text{diag}(\mathbf{y}) d\mathbf{x} - \mathbf{y} (\mathbf{y}^T d\mathbf{x})$。

求梯度：$$ dL = \mathbf{g}^T d\mathbf{y} = \mathbf{g}^T \text{diag}(\mathbf{y}) d\mathbf{x} - \mathbf{g}^T \mathbf{y} \mathbf{y}^T d\mathbf{x} $$

提取 $d\mathbf{x}$ 的系数（左边转置）：$$ \frac{\partial L}{\partial \mathbf{x}} = \mathbf{y} \odot \mathbf{g} - (\mathbf{g}^T \mathbf{y}) \mathbf{y} $$

或者写成更常见的形式：$\frac{\partial L}{\partial \mathbf{x}} = \mathbf{y} \odot (\mathbf{g} - \text{sum}(\mathbf{g} \odot \mathbf{y}))$。