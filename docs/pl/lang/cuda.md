## nvcc 编译选项
`-arch=sm_XX`：为指定的 GPU 架构生成二进制代码（SASS）

`-arch=compute_XX`：生成 PTX 中间代码（可移植性更好）

`-code=sm_XX`：指定要生成哪个架构的二进制代码

`arch=compute_XX,code=sm_XX`：同时生成 PTX 和二进制（最灵活）

`-gencode arch=compute_XX,code=sm_XX`：组合多个生成目标

## cuda programming model
!!! info "source"
    https://docs.nvidia.com/cuda/cuda-programming-guide/01-introduction/programming-model.html

![gpu-cpu-system](/assets/img/cuda/gpu-cpu-system-diagram.png)

nvidia gpu 由三个部分组成：

SM，一个 SM 可以并行执行几十到几百个个 thread block

一个 SM 里面包含
+ a local register file, 

+ a unified data cache， 可以在运行时动态的分配给 L1 cache 和 shared memory，这两者被一个 thread block 里的所有 thread 共享
    
    + L1 cache
    + share memory

+ a number of computational units，计算单元

global memory，这是所有