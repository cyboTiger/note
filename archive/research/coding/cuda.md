## CUDA版本问题
> 回答源自qwen

+ nvidia-smi 显示的是 NVIDIA 驱动支持的最高 CUDA 工具包版本
+ torch.version.cuda 显示的是 PyTorch 编译时使用的 CUDA runtime 版本
+ 它们不需要完全一致，只要驱动支持 ≥ PyTorch 使用的版本即可

![](image.png)

     