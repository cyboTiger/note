# 两周进度 2024.11.21

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

## after talk
generation: 目前yefei和yuanyu学长做的AR图像生成框架效果良好，可以发一篇paper了；可以在此基础上做各种quantization和sparsity

understanding: 目前ak师兄做kv cache，打算将minicache拓展到VLLM

北美、港、新、澳洲申请形势：

+ 北美要读6-7年，中途不能回国。trump上台限制

+ 香港很卷，基本都要排队和ranking

+ 新加坡不想招华人，因此名额极少

+ 澳洲相对好，但是由于申请者大多为有多篇顶会的master，因此也不容易