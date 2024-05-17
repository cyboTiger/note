# AVL tree
## 定义
### 一些必要的前提定义

+ **高度(height of a tree)**：根结点到自己的叶孩子结点的最大距离。叶结点的高度为0，空结点的高度为-1

+ **平衡因子(Balance Factor, BF)**：一棵树T的BF为$BF(T)=height(T_l)-height(T_r)$，其中$T_l, T_r$分别为T的左、右子树

那么**AVL tree**就是一棵BST，满足对所有结点T，都有 $\left| h(T_l)-h(T_r)\right| \leq 1$，即**BF**绝对值不超过1；

换句话说，如果二叉树 T 是 AVL 树，则其左右子树也都应该是 AVL 树，且有 $BF(T) \in \{0,\pm 1\}$；
## 性质
### 高度与结点数的关系
可以证明，结点数为 $N$ 的AVL树的高度为 $O(\log N)$，证明如下：
??? proof "Height of AVL Trees"
    !!! inline note ""
        ```mermaid
        graph TD;
        A(("Root"))
        B[/"Left Subtree"\]
        C[/"Right Subtree"\]
        A === B
        A === C
        ```
    
    我们记 $n_h$ 是高度为 $h$ 的 AVL 树所包含的最少节点数，则有如下递推关系：

    $$
    n_h = \left\{
        \begin{array}{l}
            1                       & (h = 0) \\
            2                       & (h = 1) \\
            n_{h-1} + n_{h-2} + 1   & (h > 1)
        \end{array}
    \right.
    $$

    发现 $n_h + 1$ 符合 Fibonacci 数列的递推公式（但是初始条件不一样），所以我们可以用 Fibonacci 对其进行一个估计。

    而对于如下 Fibonacci 数列：

    $$
    F_i = \left\{
        \begin{array}{l}
            1                   & (i = 1) \\
            1                   & (i = 2) \\
            F_{i-1} + F_{i-2}   & (i > 2)
        \end{array}
    \right.
    $$

    其通项为：

    $$
    \begin{aligned}
        F_n &= \frac{1}{\sqrt{5}} \left( \left( \frac{1 + \sqrt{5}}{2} \right)^n - \left( \frac{1 - \sqrt{5}}{2} \right)^n \right) \\
            &\approx \frac{1}{\sqrt{5}} \left( \frac{1 + \sqrt{5}}{2} \right)^n \\
        \log{(F_n)} &\approx n
    \end{aligned}
    $$

    而 $n_h + 1 \approx F_{h+2}$，所以 $h \approx \log{(n_h)}$，也就是说 $h \approx \log{N}$。
## 操作
对于AVL树的**插入**，我们采用每插入一个结点，就动态「调整树结构+更新相关结点**BF**字段」的方式。调整的基本操作包括左旋、右旋；

两个结点的概念：
+ **Trouble maker**：指插入的新结点，它导致AVL树的性质违反+ 
+ **Trouble finder**：指因插入新结点，而导致其BF不再为0或1的结点
> 由于插入操作只会影响从新插入的叶结点到根这条路径上的结点的BF值，因此定位**Trouble maker**和**Trouble finder**时只需要考虑该路径上的结点；由于AVL树的递归定义形式，我们倾向于从叶子结点开始调整树的结构，因此在定位**Trouble finder**时一般先定位最靠近叶子的结点

而对于不同的情况，需要用到不同的左右旋组合。根据**Trouble maker**和**Trouble finder**的关系，我们把情况分为以下四种：
!!! note "4 cases"
    === "LL"
        + LL single rotation: **Trouble maker**位于**Trouble finder**的 ^^左孩子^^ 的 ^^左子树^^ 中

        === "before"
            ```mermaid
            flowchart TD
                A((("A")))
                B((("B")))
                Ar[/"A_R"\]
                Bl[/"B_L"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                A === B
                B === Bl === tm
                B === Br
                A === Ar
            ```
        === "after"
            ```mermaid
            flowchart TD
                A((("A")))
                B((("B")))
                Ar[/"A_R"\]
                Bl[/"B_L"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                B === Bl === tm
                B === A
                A === Br
                A === Ar
            ```

    === "RR"
        + RR single rotation: **Trouble maker**位于**Trouble finder**的 ^^右孩子^^ 的 ^^右子树^^
        
        === "before"
            ```mermaid
            flowchart TD
                A((("A")))
                Al[/"A_L"\]
                B((("B")))
                Bl[/"B_L"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                A === B
                B === Bl
                B === Br === tm
                A === Al
            ```
        === "after"
            ```mermaid
            flowchart TD
                A((("A")))
                Al[/"A_L"\]
                B((("B")))
                Bl[/"B_L"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                B === A
                A === Bl
                B === Br === tm
                A === Al
            ```
    
    === "LR"
        + LR double rotation: **Trouble maker**位于**Trouble finder**的 ^^左孩子^^ 的 ^^右子树^^ 中

        === "before"
            ```mermaid
            flowchart TD
                A((("A")))
                B((("B")))
                Ar[/"A_R"\]
                Bl[/"B_L"\]
                C((("C")))
                Cl[/"C_L"\]
                Cr[/"C_R"\]
                tm(("Trouble\nMaker"))
                A === B
                A === Ar
                B === Bl
                B === C
                C === Cl === tm
                C === Cr === tm
            ```
        === "middle"
            ```mermaid
            flowchart TD
                A((("A")))
                B((("B")))
                Ar[/"A_R"\]
                Bl[/"B_L"\]
                C((("C")))
                Cl[/"C_L"\]
                Cr[/"C_R"\]
                tm(("Trouble\nMaker"))
                A === C
                C === B === Bl
                C === Cr === tm
                B === Cl === tm
                A === Ar
            ```
        === "after"
            ```mermaid
            flowchart TD
                A((("A")))
                B((("B")))
                Ar[/"A_R"\]
                Bl[/"B_L"\]
                C((("C")))
                Cl[/"C_L"\]
                Cr[/"C_R"\]
                tm(("Trouble\nMaker"))
                C === B === Bl
                B === Cl === tm
                C === A
                A === Cr === tm
                A === Ar
            ```
    === "RL"
        + RL double rotaion: **Trouble maker**位于**Trouble finder**的 ^^右孩子^^ 的 ^^左子树^^ 中

        === "before"
            ```mermaid
            flowchart TD
                A((("A")))
                Al[/"A_L"\]
                B((("B")))
                C((("C")))
                Cl[/"C_L"\]
                Cr[/"C_R"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                A === Al
                A === B
                B === C
                C === Cl === tm
                C === Cr === tm
                B === Br
            ```
        === "middle"
            ```mermaid
            flowchart TD
                A((("A")))
                Al[/"A_L"\]
                B((("B")))
                C((("C")))
                Cl[/"C_L"\]
                Cr[/"C_R"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                A === Al
                A === C
                C === Cl === tm
                C === B
                B === Cr === tm
                B === Br
            ```
        === "after"
            ```mermaid
            flowchart TD
                A((("A")))
                Al[/"A_L"\]
                B((("B")))
                C((("C")))
                Cl[/"C_L"\]
                Cr[/"C_R"\]
                Br[/"B_R"\]
                tm(("Trouble\nMaker"))
                C === A
                A === Al
                A === Cl === tm
                C === B
                B === Cr === tm
                B === Br
            ```
    
# Splay tree
## 定义
## 性质