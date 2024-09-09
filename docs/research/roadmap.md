经过昨天的讨论，最重要的点就是 

1. 不懂的要自学，多问，善用搜索

2. 要高效读论文，从related work、citation、按topic搜索的开山作、在论文中出现的key word等等方式找到应该读的论文

3. 实践部分，要跑一跑领域内最基本的llm，跑一跑baseline

回顾一下现在的情况：Transformer还没有完全理解，LLaVA还没跑，方向有点混乱无从下手。

那就先学习cs231n、跑一跑LLaVA吧

抽空学习一下pengsida的经验，学习一下zotero的功能

-------
+ 读survey、广度搜索阅读
+ 跑llama、llava代码
+ 学习cuda、vLLM、triton等工具
-------
+ [RNN](https://arxiv.org/abs/2102.04906#)
+ [LoRA](https://arxiv.org/pdf/2106.09685)
+ [FlashAttention](https://arxiv.org/abs/2205.14135)
+ [LLaVA](https://github.com/haotian-liu/LLaVA)
+ [SSM/Mamba](https://github.com/state-spaces/mamba)


!!! info "tips"

    多关注related work

    多找找国外的优质blog

    大方向看代表作1，2篇

    llava是最basic的模型一定要熟悉

    可以在google scholar里搜topic

    看完一篇paper，要知道 它干了什么，novelty在哪里，效果如何

    paper分为两类：开山之作，做得好的工作。前者要精读，后者大致看创新点

    一般而言，做实验用开山作的参数，否则自己调参成本比较高

    wang xinyu: 做多模态大模型
    chen zhuokun: model merging
    