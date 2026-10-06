## MLA

抛开 KV cache 体积，我认为是 MHA 和 MQA 的结合体：nope 的部分是 MHA，qk 的头一对一；rope 的部分是 MQA，qk 的头是多对一；

如果再考虑 KV cache，MLA 实际上是对 hidden state ht 进行低秩压缩，作为 cache；此外 k rope 因为只有一个头，所以也 cache；后续的 K 和 V 的 nope 则由各自的升秩矩阵，得到多头 nope；

q 也分为 nope 和 rope，但因为不需要 cache，所以 nope 和 rope 都是多头

看了苏神的博客 https://spaces.ac.cn/archives/10091，指出 qk 相乘时，wq 和 wk 可以吸收成一个矩阵，这样 qk 就变为 (cq wq wkt) ckv ，所以 cache 不需要升秩矩阵变换；至于 cq wq wkt 的计算，实际上 (cq wq) wkt 串行算比 cq (wq wkt) 计算复杂度低；ckv wv wo 也是同样的道理

但是 rope 的引入本质上和矩阵吸收是不兼容的，因为 rope 矩阵 Rt 是位置敏感的，qk 会变成 cq wq rq rkt wkt ckv，这样由于中间的 rope 矩阵不是常量矩阵，所以不能融合成一个矩阵；

为了引入 rope，在原有 qkv 基础上增加少量 rope 维度，然后将 rope k 直接 cache