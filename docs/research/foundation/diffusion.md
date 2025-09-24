## Prerequisites
### 先验/后验分布
后验分布（posterior Distribution）是指在收集到实际的观测数据后对**未知参数 or 隐变量**做出的概率分布估计；相对的，先验分布（prior Distribution）是指在没有实际观测数据时对**未知参数 or 隐变量**的信念。

根据贝叶斯斯定理，后验分布 $p(\theta|x)$ 正比于先验分布 $p(\theta)$ 和似然函数 $p(x|\theta)$ 的乘积。
$$
p(\theta|x) = \frac{p(x|\theta)p(\theta)}{p(x)}
$$
其中，$p(\theta|x)$ 是后验分布，$p(\theta)$ 是先验分布，这两者是关于参数 $\theta$ 取值的概率分布；$p(x|\theta)$ 是似然函数，它衡量不同参数值下观测到特定数据的可能性，未必满足概率分布的性质；$p(x)$ 是证据（或边缘似然）。

??? note "证据 $p(x)$ 的含义"
    证据 $p(x)$ 的定义是：
    $$
    p(x)=\int p(x|\theta)p(\theta)d\theta
    $$
    它是用来归一化后验分布 $p(\theta|x)$ 的

### 变分分布
变分分布（Variational Distribution）是用于近似后验分布的简单、易于处理的概率分布，我们通过变分推断来优化变分分布的参数使其尽可能近似后验分布。在很多复杂的模型中，直接计算后验分布是非常困难的，甚至是不可能的，因为证据 p(x) 的计算通常涉及复杂的积分或求和。这时，我们就需要找到一种方法来近似它。

#### 变分推断
就是一种通过引入变分分布 q(z) 来近似难以计算的真实后验分布 $p(z|x)$ 的方法。

1. 选择一个简单的变分分布 q(z)，这个分布通常具有一些简单的形式，比如高斯分布或者伯努利分布的乘积。这个分布包含一些可以调整的参数（也叫变分参数）。

2. 优化变分参数，让变分分布 q(z) 尽可能地接近真实后验分布 $p(z|x)$。通常使用 Kullback-Leibler (KL) 散度来衡量两个分布之间的差异，然后通过优化变分参数来最小化KL散度。

### ELBO (Evidence Lower Bound)
ELBO 是对一个模型观测数据对数似然（log-likelihood）的一个下界。在很多复杂的概率模型中，我们希望最大化数据的对数似然 $\log P(x)$，以使模型更好地拟合观测数据。然而，直接计算 $\log P(x)$ 往往涉及对所有可能的隐变量进行积分或求和，这在连续空间或高维离散空间中是**难以处理（intractable）**的。

变分推断提供了一种近似方法。它引入一个变分分布 $q(\mathbf{z}|\mathbf{x})$ 来近似真实但难以计算的后验分布 $P(\mathbf{z}|\mathbf{x})$，其中 $\mathbf{z}$ 是隐变量，$\mathbf{x}$ 是观测数据。

ELBO 的推导基于詹森不等式（Jensen's Inequality）：

$$
\begin{aligned} 
\log P(\mathbf{x}) &= \log \sum_{\mathbf{z}} P(\mathbf{x}, \mathbf{z}) \\ 
&= \log \sum_{\mathbf{z}} q(\mathbf{z}|\mathbf{x}) \frac{P(\mathbf{x}, \mathbf{z})}{q(\mathbf{z}|\mathbf{x})} \\ 
&= \log \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} \frac{P(\mathbf{x}, \mathbf{z})}{q(\mathbf{z}|\mathbf{x})} 
\end{aligned}
$$

然后应用 jensen 不等式

$$
\begin{aligned} 
&\geq \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} \left[ \log \left( \frac{P(\mathbf{x}, \mathbf{z})}{q(\mathbf{z}|\mathbf{x})} \right) \right] \quad \text{(Jensen's Inequality)} \\ 
&= \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} [\log P(\mathbf{x}, \mathbf{z}) - \log q(\mathbf{z}|\mathbf{x})] \\ 
&= \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} [\log P(\mathbf{x}|\mathbf{z}) + \log P(\mathbf{z}) - \log q(\mathbf{z}|\mathbf{x})] \\ 
&= \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} [\log P(\mathbf{x}|\mathbf{z})] - \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} [\log q(\mathbf{z}|\mathbf{x}) - \log P(\mathbf{z})] \\ 
&= \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} [\log P(\mathbf{x}|\mathbf{z})] - D_{KL}(q(\mathbf{z}|\mathbf{x}) || P(\mathbf{z})) \end{aligned} 
$$

所以，ELBO 是：

$$
\mathcal{L}(P, q) = \mathbb{E}_{q(\mathbf{z}|\mathbf{x})} [\log P(\mathbf{x}|\mathbf{z})] - D_{KL}(q(\mathbf{z}|\mathbf{x}) || P(\mathbf{z}))
$$ 

ELBO 的最大化相当于在优化后验分布 $P(\mathbf{z}|\mathbf{x})$ 和变分分布 $q(\mathbf{z}|\mathbf{x})$ 之间的 Kullback-Leibler (KL) 散度 $D_{KL}(q(\mathbf{z}|\mathbf{x}) || P(\mathbf{z}|\mathbf{x}))$。

由于 $D_{KL}(q||p) \geq 0$，且 $\log P(\mathbf{x}) = \mathcal{L}(P,q) + D_{KL}(q(\mathbf{z}|\mathbf{x}) || P(\mathbf{z}|\mathbf{x}))$，所以最大化 ELBO 实际上就是在最大化 $\log P(\mathbf{x})$ 的同时，使变分后验 $q(\mathbf{z}|\mathbf{x})$ 尽可能接近真实的后验 $P(\mathbf{z}|\mathbf{x})$。 


## VAE（Variational AutoEncoder）
VAE 是用来生成图片的模型。分为编码器和解码器两个部件。

+ 编码器
    + 接收输入数据（例如图片 x），并将其压缩成一个潜在空间 (latent space) 中的表示。

    + 与传统自编码器不同的是，编码器不直接输出一个潜在向量 z，而是输出两个向量：潜在分布的均值 μ 和方差 σ（通常是 $\log\sigma^2$）。这两个向量定义了一个高斯分布 $q(z|x)$

    + 这意味着对于一个输入 x，它不再只对应潜在空间的一个点，而是对应一个概率分布，这就是 VAE 的“变分”之处。

+ 解码器 (Decoder)：

    + 从编码器输出的潜在分布 $q(z|x)$ 中采样一个潜在向量 z。

    + 然后将这个采样的 z 输入解码器，解码器将其转换回原始数据空间，生成一个重建的数据 x'。

### 训练目标

VAE 的训练目标有两部分：

+ 重建损失 (Reconstruction Loss)：

    + 衡量的是解码器生成的 x' 与原始输入 x 之间的相似度。通常使用均方误差 (MSE) 或交叉熵 (Cross-Entropy)。

    + 目标是让解码器能够尽可能准确地重建原始输入，确保模型能够捕捉到数据的细节。

+ KL 散度损失 (KL Divergence Loss)：

    + 衡量的是编码器输出的潜在分布 $q(z|x)$ 与一个预设的先验分布 p(z) 之间的相似度，通常这个先验分布是一个标准高斯分布。

    + 它的作用是规范化潜在空间，确保潜在空间具有良好的特性，例如平滑性、连续性和可采样性。这个部分正是“变分”二字的精髓，它鼓励变分分布 $q(z|x)$ 接近简单的先验分布，从而我们可以从先验分布中采样来生成新数据。

### 重参数化技巧 (Reparameterization Trick)
解码器阶段的采样操作导致最终的损失函数关于编码器的参数不可导。为了让训练过程可微分并进行梯度下降，VAE 引入了重参数化技巧。由于从一个分布中采样是不可微分的，它将采样过程表示为：
$$
z = \mu + \sigma \odot \boldsymbol{\epsilon}
$$

其中，$\boldsymbol{\epsilon}$ 是从标准正态分布 $\mathcal{N}(0,1)$ 中采样的随机噪声，$\odot$ 是元素级乘法。这样，随机性就从采样的 $z$ 转移到了输入的 $\boldsymbol{\epsilon}$，使得整个过程对于 $\mu$ 和 $\sigma$ 都是可微分的。

### 优缺点

优点：

+ 可解释的潜在空间：潜在空间通常具有良好的平滑性和连续性，有助于理解模型学习到的特征。

+ 避免模式崩溃 (Mode Collapse)：由于其训练方式，VAE 通常不会出现 GAN 中常见的模式崩溃问题（即生成器只生成一小部分多样性的样本）。

+ 生成多样性：能够生成多样化的样本。

缺点：

+ 生成样本质量可能不如 GAN：生成的图片常常比较模糊或缺乏细节，尤其是在高分辨率图片生成方面。

## 生成对抗网络 (GAN)

GAN 的核心思想是一种对抗性训练的框架，让两个神经网络相互竞争来提升生成能力。这就像一场“猫捉老鼠”的博弈。

### 基本原理

GAN 由两个主要的网络组成：

生成器 (Generator, G)：

+ 生成器的任务是生成假数据，以尽可能地欺骗判别器。

+ 它接收一个随机噪声向量 z（通常是从高斯分布中采样），并将其转换成一个看起来像真实数据的输出（例如图片）。

+ 生成器的目标是学习真实数据的分布，使得它生成的数据能够与真实数据难以区分。

判别器 (Discriminator, D)：

+ 判别器的任务是判断输入数据是真实的还是由生成器生成的假数据。

+ 它接收两种输入：真实的数据样本，以及生成器生成的假数据样本。

+ 判别器是一个二元分类器，输出一个概率值，表示输入是真实数据的可能性。

+ 判别器的目标是尽可能准确地区分真实数据和假数据。

### 对抗性训练过程

GAN 的训练是一个博弈过程，生成器和判别器轮流进行优化：

训练判别器 (固定生成器)：

+ 判别器接收一批真实数据和一批生成器生成的假数据。

+ 判别器会更新其参数，以便更好地将真实数据判断为“真”，将假数据判断为“假”。

+ 目标是最大化判别器正确分类的概率。

训练生成器 (固定判别器)：

+ 生成器生成一批假数据，并将其输入判别器。

+ 生成器会更新其参数，以便让判别器将其生成的假数据误判为“真”。

+ 目标是最小化判别器判断其生成数据为“假”的概率。

这个过程不断重复，生成器努力生成越来越真实的数据来欺骗判别器，而判别器则努力提升其辨别能力。理想情况下，当训练达到纳什均衡时，生成器能够生成几可乱真的数据，以至于判别器无法区分真实数据和生成数据（判别器判断真假的概率约为 0.5）。

### 优缺点

优点：

+ 生成样本质量高：GAN 在生成逼真、高分辨率的图片方面表现出色，常常能产生令人惊艳的结果。

+ 灵活性：可以应用于多种生成任务，不仅限于图片。

缺点：

+ 训练不稳定：GAN 的训练非常困难和不稳定，容易出现训练崩溃、梯度消失/爆炸等问题，需要仔细调整超参数和网络架构。

+ 模式崩溃 (Mode Collapse)：生成器可能会陷入只生成训练数据中部分模式的困境，导致生成样本的多样性不足。

+ 难以衡量进度：由于其对抗性性质，很难客观地衡量 GAN 的训练进度。

## Diffusion
在 lilian weng 的博客里面，我有几点疑惑

1. 为什么 forward 过程 

$$ q(x_{t+1}|x_t)=N(x_{t+1}; \sqrt{\alpha}x_t, (1-\alpha_t)I) $$ 

可以确定 $$ x_{t+1}=\sqrt{\alpha}x_t+\sqrt{1-\alpha}\sigma_t $$

而反过来 $$ q(x_t|x_{t+1}) $$ 却不能由 $$ x_t=\frac{1}{\sqrt{\alpha}}x_{t+1}-\frac{\sqrt{1-\alpha}}{\sqrt{\alpha}}\sigma_t $$ 确定？