## `lsof` 
`lsof` 是一个功能强大的命令行工具，用于列出当前系统打开的所有文件及相关进程信息。在 Linux 中，"一切皆文件"的理念意味着 lsof 不仅能显示常规文件，还能显示网络连接、设备文件、管道和套接字等。


## `find`
https://www.runoob.com/linux/linux-comm-find.html

```bash
# find [path] [filter]
find /home/ruihan/miniconda3/lib/python3.13/site-packages/ -name *cuda_runtime.h*

/home/ruihan/miniconda3/lib/python3.13/site-packages/triton/backends/nvidia/include/cuda_runtime.h
/home/ruihan/miniconda3/lib/python3.13/site-packages/nvidia/cuda_runtime/include/cuda_runtime.h
```