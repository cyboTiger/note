## Chapter 1 - Logic and Proofs
有两种方式从命题函数得到具体命题：Predicate 和 Quantifier
### Predicates
+ 命题函数: $P(x_1,x_2,...,x_n)$
+ 取值：$(x_1,x_2,...,x_n) \in D$
+ predicate: $P(x_1,x_2,...,x_n)$
+ 命题函数的变量取具体值->命题

### Quantifiers
+ universal quantifier: $\forall xP(x)$
+ existential quantifier: $\exists xP(x)$
+ uniqueness quantifier: $\exists! xP(x)$，只有一个这样的x
+ 优先级：$\forall \exists$ 优先级高于所有逻辑运算符
+ Universe of discourse: 命题函数的取值域，每一个 quantifier 都存在这个域

!!! tip "Remark"
    $\forall x\forall yP(x,y) \Leftrightarrow \forall y\forall xP(x,y)$

    $\exists x\exists yP(x,y) \Leftrightarrow \exists y\exists xP(x,y)$

    $\forall x\exists yP(x,y) \nLeftrightarrow \exists y\forall xP(x,y)$

### Banding Variables
用 predicate 赋值变量或用 quantifier 在某变量时，该变量称为 bounded，其余变量称为 free

### predicate 等价公式
+ De Morgan's law
    + $\neg\forall xP(x) \Leftrightarrow \exists x\neg P(x)$
    + $\neg\exists xP(x) \Leftrightarrow \forall x\neg P(x)$

+ Quantifier
    + $\forall x(P(x) \wedge Q(x)) \Leftrightarrow (\forall xP(x)) \wedge (\forall xQ(x))$
    + $\exists x(P(x) \vee Q(x)) \Leftrightarrow (\exists xP(x)) \vee (\exists xQ(x))$
    
+ $\forall$ 相关
    + $A \wedge \forall xP(x) \Leftrightarrow \forall x(A \wedge P(x))$，若 A 中没有出现 x
    + $A \vee \forall xP(x) \Leftrightarrow \forall x(A \vee P(x))$，若 A 中没有出现 x
    + $A \rightarrow \forall xP(x) \Leftrightarrow \forall x(A \rightarrow P(x))$，若 A 中没有出现 x
    + **反直觉**: $\forall xP(x) \rightarrow A \Leftrightarrow \exists x(P(x) \rightarrow A)$，若 A 中没有出现 x

+ $\exists$ 相关
    + $A \wedge \exists xP(x) \Leftrightarrow \exists x(A \wedge P(x))$，若 A 中没有出现 x
    + $A \vee \exists xP(x) \Leftrightarrow \exists x(A \vee P(x))$，若 A 中没有出现 x
    + $A \rightarrow \exists xP(x) \Leftrightarrow \exists x(A \rightarrow P(x))$，若 A 中没有出现 x
    + **反直觉**: $\exists xP(x) \rightarrow A \Leftrightarrow \forall x(P(x) \rightarrow A)$，若 A 中没有出现 x

### Prenex normal form
+ 将 quantifier 放在命题最前面
+ 形式：$Q_1x_1Q_2x_2...Q_nx_nB$，其中 $Q_i$ 为 $\forall,\exists,\exists!$，$B$ 为没有 quantifier 的命题

## Chapter 2 - Sets and Functions