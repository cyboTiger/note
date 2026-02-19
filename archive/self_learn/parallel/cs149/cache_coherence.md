## 严格定义
A memory system is coherent if:

1. A read by processor P to address X that follows a write by P to address X, should return the value of the write by P (assuming no other processor wrote to X in between)（单处理器一致）

2. A read by processor P1 to address X that follows a write by processor P2 to X returns the written value... if the read and write are “sufficiently separated” in time (assuming no other write to X occurs in between)（多处理器一致）

3. Writes to the same address are serialized: two writes to address X by any two processors are observed in the same order by all processors. （写顺序一致）

## 等价条件
Condition 1: obeys program order （表现和单处理器一致）

Condition 2: “write propagation”: Notification of a write must eventually get to the other processors. Note that precisely when information about the write is propagated is not specified in the definition of coherence.（写结果传播）

Condition 3: “write serialization”（写顺序一致）

## 实现coherence的硬件解决方案
### Snooping-based
#### write-through invalidation

![alt text](image-12.png)

解释：

+ Valid 状态下的 PrWr / BusWr 意味着当 local processor 想要 write 时，会发送 BusWr 信号给其他 processor，告诉他们需要 invalidate 这个cache line

+ Invalid 状态下的 PrWr / BusWr 意味着当 local processor 想要 write 时， 会直接写到内存，而不会先 allocate 到 cache 再 write back

+ PrRd / BusRd 意味着当 local processor 想要 read 一个 invalid line 时，会发送 BusRd 信号，通过总线从 mem 获取数据，最后 validate 该 line

劣势：

+ write through 直接写入 mem，对带宽要求很高，延迟大

#### write-back invalidation