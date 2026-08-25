记录一下安装 cuda toolkit 的过程：

先从官网下载 deb 包，它包含了 toolkit 包实际的 url 以及包的公钥 

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
```

ubuntu 的版本和架构可以通过 `lsb_release -a` 和 `uname -a` 查询

这样下载完之后，使用 dpkg 安装 deb 包

```bash
dpkg -i cuda-keyring_1.1-1_all.deb
```

会做两件事：

+ 生成 `/usr/share/keyrings/cuda-archive-keyring.gpg` GPG 密钥，用于核对后续要下载的 toolkit 包是否被篡改过
+ 生成 `/etc/apt/sources.list.d/cuda.list` 源配置文件，指向 toolkit 对应的 url 和发行版本号

我使用的是 autodl 预安装了 gpu 驱动的机器，原本已经有 /usr/share/keyrings/cuda-archive-keyring.gpg 了，所以 dpkg 之后 apt-get update 没有添加 nvidia cuda 源；所以自行手动添加了 `/etc/apt/sources.list.d/cuda.list` 文件，内容如下：

```
deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /
```

之后进行 `apt-get update` 更新源，然后 `apt-get -y install cuda-toolkit-13-3` 即可；

cuda-toolkit 包含了 nvcc 编译器、runtime library、debugger、还有特定应用的 library

GPU-accelerated libraries, debugging and optimization tools, a C/C++ compiler, and a runtime library

如果想要 toolkit 和 nvidia driver 一起安装，可以直接 `apt-get install cuda`

----

安装完成之后，通常位于在 `/usr/local/cuda-x.x` 下，需要在 .bashrc 配置文件中更新 `PATH` 和 `LD_LIBRARY_PATH`，以便可以使用 toolkit：

```bash
export PATH=/usr/local/cuda-12/bin/:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12/lib64:$LD_LIBRARY_PATH
```

## CUDA C 程序开发环境配置
vscode 项目根文件夹下的 `.vscode/c_cpp_properties.json` 中，按如下配置：

```json
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${workspaceFolder}/**",
                "/usr/include",
                "/usr/local/include",
                "/usr/local/cuda-13/include/"
            ],
            "defines": [],
            "compilerPath": "/usr/local/cuda-13/bin/nvcc",
            "cStandard": "c17",
            "cppStandard": "gnu++17",
            "intelliSenseMode": "linux-gcc-x64"
        }
    ],
    "version": 4
}
```