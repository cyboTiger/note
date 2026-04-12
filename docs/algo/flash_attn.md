## forward

## backward
FlashAttention Backward 的核心挑战在于：**在不显式存储 $O(N^2)$ 的 Softmax 矩阵的情况下，如何通过分块计算高效地求出 $dQ, dK, dV$。**

其关键在于利用 Forward 阶段留下的 $L$ (Log-Sum-Exp) 进行**局部重计算**。

---

### 1. 微分推导基础
标准 Attention 公式为：
 $$ O = PV, \quad P = \text{softmax}(S), \quad S = QK^T $$ 

通过链式法则，我们需要计算：

*   **$dV$:** $P^T dO$
*   **$dP$:** $dO V^T$
*   **$dS$:** 这里是难点。由于 Softmax 的性质，对 $S$ 的导数可以表示为：
     $$ dS = P \circ (dP - (dP \cdot P) \mathbf{1}\mathbf{1}^T) $$ 
    在 FlashAttention 中，定义 $D = \text{rowsum}(dO \circ O) = \text{rowsum}(dP \circ P)$，可以将 $dS$ 简化为：
     $$ dS = P \circ (dO V^T - D) $$ 
*   **$dQ$:** $dS K$
*   **$dK$:** $dS^T Q$

---

### 2. 分块 Backward 的算法流程
为了节省显存，Backward 同样采用外层循环和内层循环。通常外层循环遍历 $K, V$ 的分块（列块），内层循环遍历 $Q$ 的分块（行块）。

#### **Step 1: 预计算 $D$**
在 Kernel 启动之初，先在 HBM 中计算并存储向量 $D \in \mathbb{R}^N$：
 $$ D_i = \sum_{j=1}^d (dO_{ij} \circ O_{ij}) $$ 
这个 $D$ 向量会在后续计算 $dQ$ 和 $dK$ 时反复使用，用来抵消 Softmax 归一化项的梯度。

#### **Step 2: 双重循环重计算**
对于每一个 $Q_i, K_j, V_j$ 的分块：

1.  **从 HBM 加载：** 读取 $Q_i, K_j, V_j, dO_i, L_i, D_i$ 到 SRAM。
2.  **重构 $P_{ij}$：** 
    利用 Forward 存下的 $L_i$（行最大值与和的组合），在 SRAM 中重新计算：
     $$ S_{ij} = Q_i K_j^T, \quad P_{ij} = \exp(S_{ij} - L_i) $$ 
3.  **计算 $dV_j$：**
     $$ dV_j \leftarrow dV_j + P_{ij}^T dO_i $$ 
4.  **计算 $dS_{ij}$：**
    利用预计算的 $D_i$，在 SRAM 中原地计算梯度矩阵块：
     $$ dS_{ij} = P_{ij} \circ (dO_i V_j^T - D_i) $$ 
5.  **计算 $dQ_i$ 与 $dK_j$：**
     $$ dQ_i \leftarrow dQ_i + dS_{ij} K_j $$ 
     $$ dK_j \leftarrow dK_j + dS_{ij}^T Q_i $$ 

---

### 3. 为什么这样能行？（关键细节）

*   **精妙的 $D$ 向量：** Softmax 的梯度计算通常需要全局信息。FlashAttention 通过引入 $D_i = \text{rowsum}(dO_i \cdot O_i)$，巧妙地将梯度的归一化部分解耦到了行上。这意味着在计算 $dS_{ij}$ 时，只需要当前行对应的 $D_i$，而不需要看这一行的其他块。
*   **计算换带宽：** Backward 的计算量大约是标准 Attention 的 2.5 倍（因为要重复算一遍 $P_{ij}$），但由于它极大减少了对 HBM 的读写（不需要读 $N^2$ 的大矩阵），在算力过剩的现代 GPU（如 A100/H100）上，整体速度反而快得多。

### 总结
FlashAttention Backward 的分块逻辑本质上是**“在 SRAM 里复现 Forward 的一部分，顺便把导数求了”**。它存储 $L$ 是为了快速复现 $P$，预计算 $D$ 是为了让 $dS$ 的计算局域化。

你最近在做的 **LatexNet** 涉及到 VLM，如果涉及到长文本或高分辨率图像的 Attention 优化，这种分块求导的思路对理解算子层面的加速非常有帮助。
