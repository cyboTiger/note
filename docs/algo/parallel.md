## FSDP (Fully Sharded Data Parallel)
!!! note "Gemini总结"
    **“常驻分片 + 瞬时复原峰值”**

FSDP2 将模型按照类似 tensor parallel 的方式进行分片（sharding），在 forward 和 backward 时通过 all-gather 拿到某层的完整参数，计算各自 data batch 的 activation 和 gradient，然后丢弃参数，保存 activation 和 gradient，最后 reduce-scatter 得到部分参数的全局梯度，用于更新参数

FSDP2 整体流程如下：

1. N 个 device 分别得到完整模型 1/N 的参数
2. forward 时， 以层为单位（FSDP Unit），做 all-gather 通信得到该层参数，用自己的 data batch 计算 activation；然后丢弃该层参数，存储完整的 local activation
4. backward 时，以层为单位（FSDP Unit），做 all-gather 通信得到该层参数，用 local activation 和自己的 data batch 计算 local gradient；然后丢弃该层参数，做 reduce-scatter 通信得到平均后的 global gradient
5. 对应本地分配到的参数，做参数更新

假设 $M$ 为模型总参数量，$N$ 为 Device 数量，$L_{max}$ 为模型中最大的一个 FSDP Unit（通常是一个 Transformer Block）的参数量。

则单个设备容纳的最大参数量为：

$$
\text{Max Memory} \approx \underbrace{\frac{M}{N}}_{\text{Static Shard}} + \underbrace{\frac{N-1}{N} \cdot L_{max}}_{\text{All-gather Buffer}} + \underbrace{ACT}_{\text{Local Activation}} + \underbrace{\frac{N-1}{N} \cdot L_{max}}_{\text{Reduce-scatter Buffer}}
$$
