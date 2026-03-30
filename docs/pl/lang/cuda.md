## nvcc 编译选项
`-arch=sm_XX`：为指定的 GPU 架构生成二进制代码（SASS）

`-arch=compute_XX`：生成 PTX 中间代码（可移植性更好）

`-code=sm_XX`：指定要生成哪个架构的二进制代码

`arch=compute_XX,code=sm_XX`：同时生成 PTX 和二进制（最灵活）

`-gencode arch=compute_XX,code=sm_XX`：组合多个生成目标