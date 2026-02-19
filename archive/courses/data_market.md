# lec02 隐私计算常见技术
## 安全多方计算
百万富翁问题：两个富人比谁钱多，如何能实现互相保密（不借助第三方）但可以比出谁的钱多
## 联邦学习
本地训练模型，使数据不被多方共享
## 数据脱敏
## 差分隐私(differential privacy)
## 全同态加密
## 零知识证明(zero knowledge proof)

# lec03 数据定价基础
从面向成本定价转向面向需求定价
## 查询定价的无套利原则

# lec05 mechanism design (By Haifeng Xu)
**Goal**: design a game by specifying its rules to induce a desired outcome among strategic participants

+ Specify game rules, player payoffs, allowable actions, etc.
+ Objective is to induce desirable outcome, e.g., incentivizing socially good or fair behaviors, maximizing revenue if selling goods
+ Typically, want the game to be easy to play (friendly interface)

## Examples of Mechanism Design
### Single-Item Allocation
1个item和n个agents

agent i对于物品有自己的估价$v_i$

需要设计支付金额$p:(b_i)_i \rightarrow \R^n$和分配规则$x:(b_i)_i \rightarrow \R^n$

福利最大化原则：出价最高的人，物品对他的效用最大，因此卖给他。

诚实报价所需约束：采用二价拍卖(second-price auction)，出价最高的人，用二价得到物品。

> Truthful bidding is a dominant strategy equilibrium in second-price auctions. That is, bidding true value $v_i$ is optimal for i, regardless of how other people bid. In such cases, we say the mechanism is Dominant-Strategy Incentive Compatible **(DISC)**

### Multi-Item Allocation
m个item和n个agents

agent i 对于$[m]$的任何子集$S$有自己的估价$v_i(S)$

需要设计一个partition将m个物品分配到$S_1,S_2,...,S_n$中
#### VCG mechanism (Vickrey-Clarke-Groves mechanism)
1. Ask each bidder to report their value function $b_i(S)$

2. Compute optimal allocation $(S_1^*,...,S_n^*)=\arg\max_(S_1,...,S_n)\sum_{i=1}^nb_i(S_i)$

3. Allocate $S_i^*$ to bidder i, charge i the following amount 

$$
p_i=[\max_{S_{-i}}\sum_{j\neq i}b_j(S_j)]-\sum_{j\neq i}b_j(S_j^*)
$$

换句话说，$p_i$即agent i对其他人的福利的影响程度

### School Choice（无钱机制）
n个学生，m个学校进行匹配

## Myerson's Revenue-Optimal Auction