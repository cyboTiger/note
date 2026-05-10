## tencent/HunyuanVideo
### text/image encoder 部分
使用 llama 和 clip 两个 encoder
### DiT 部分
single/double stream transformer block，两者都是输入 txt 和 img(video) embedding，输出 txt 和 img(video) embedding；在 attention 部分同样都是 txt 和 img 拼接之后的序列做大矩阵的 $\mathbf{softmax(QK^T)V}$；不同之处在于 ScaleResidualShift 阶段是分开还是一起做的，也就是共用一套 scale, shift 还是用两套

没有 cross attention 和 self attention 的区分
## Wan-AI/Wan2.1-T2V-14B-Diffusers
### text/image encoder 部分
使用 UMT5
### DiT 部分
分为 cross attention 和 self attention