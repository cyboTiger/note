# 2024.11.10
## 本周进度

1. VLM paper阅读
   
   + Medusa: Simple Framework for Accelerating LLM Generation with Multiple Decoding Heads
   
   + Accelerating Large Language Model Decoding with Speculative Sampling
   
   + 几篇关于auto-regressive generation的blog（忘记网址了）

2. 实战

   + 利用vllm profiler对vllm的性能进行测试

## 下周规划

1. MIT6.5940学习：lec5-6；lab看情况
2. video generation论文阅读
   
   + [CLLM](https://arxiv.org/pdf/2403.00835)
   
   + [TRAINING-FREE SPECULATIVE JACOBI DECODING](https://arxiv.org/pdf/2410.01699)

3. 重温[A Survey on Multimodal Large Language Models](https://arxiv.org/abs/2306.13549)，跑一些典型模型的base code，如llava/Qwen-vl
4. 学习vllm/flashAttention的idea和code，测试性能
5. cs231n和pytorch basic收尾
6. 熟悉DiT/ViT架构

------

# 2024.11.17
## 本周进度

+ 完成mit6.5940的lec3-4学习
+ 完成cs231n的module2
+ 重温[A Survey on Multimodal Large Language Models](https://arxiv.org/abs/2306.13549)

## 下周规划

1. MIT6.5940学习：lec5-6；lab看情况
2. video generation论文阅读（顺延）

  + [CLLM](https://arxiv.org/pdf/2403.00835)
  
  + [TRAINING-FREE SPECULATIVE JACOBI DECODING](https://arxiv.org/pdf/2410.01699)

3. 跑一些典型模型的base code，如llava/Qwen-vl（顺延）
4. 学习vllm/flashAttention的idea和code，测试性能（顺延）
5. cs231n和pytorch basic收尾（顺延）
6. 熟悉DiT/ViT架构，阅读（顺延）

   + [Diffusion models](https://lilianweng.github.io/posts/2021-07-11-diffusion-models/)

   + [Generative models](https://yang-song.net/blog/2021/score/)

# 两周进度

1. 联系了yefei学长，准备上手做一个AR图像生成模型的蒸馏，阅读了

   + MEDUSA: Simple LLMInference Acceleration Framework with Multiple Decoding Heads

   + CLLMs: Consistency Large Language Models

   + ACCELERATING AUTO-REGRESSIVE TEXT-TO-IMAGE GENERATION WITH TRAINING-FREE SPECULATIVE JA COBI DECODING

   三篇论文，然后就鸽了学长，至今还没有回复

2. 科研教学群的进度，完成了cs231n的所有lecture，mit6.5940的lecture1。

3. liujing学长是cachekit的主要负责人，之前10.25的时候联系了学长，让我用pytorch profiler分析一下vllm优化过的LLAMA，跟没有优化过的进行对比。我只用vllm的profile了一下，鸽了学长，至今没有回复

   
# 问题
+ 在看论文的时候遇到不太理解的概念就会停下来不断追溯到最原始的paper，比如从sampling的论文开始看到一半就一直回溯之前的论文，直到RNN这些AR模型。感觉效率太低

+ 跟老师、师兄们缺乏沟通

+ 还是很强的惰性，实践很少，感觉自己总是对跑代码有某种心理障碍一样

+ 学得很乱，在科研时间内的学习十分碎片化，有的时候甚至不知道自己该学习什么资源