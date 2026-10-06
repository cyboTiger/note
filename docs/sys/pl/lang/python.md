## python module and package

!!! info "reference"
    https://docs.python.org/3/tutorial/modules.html#

module 就是一个 .py 文件；

### The Module Search Path
在一个 py 文件中 import module 时，interpreter 会先在 built-in module 里找这个名字，可通过 `sys.builtin_module_names` 查看；如果没找到，则从 `sys.path` 里的文件夹中的文件寻找；

sys.path 从 3 个位置初始化：

+ 当运行 `python xx.py` 时，从 `xx.py` 所在文件夹寻找；当运行 python 时，从当前 terminal 所在文件夹寻找

+ 通过环境变量 `PYTHONPATH` 寻找

+ 虚拟环境中的 site-packages

这之后，可以通过脚本中自定义修改 `sys.path`

### `dir` 函数
用来列出一个 module 里面包含的所有 name

### package
当需要 `module.submodule.subsub..` 这样通过 dotted module names来组织多个 module 时，会用到 package。

使用 package 中的 module 需要在 module 所在文件夹下添加 `__init__.py`，可以是空文件，也可以有初始化代码，或者设置 `__all__` 来控制 import 的范围

当使用 `import item.subitem.subsubitem` 或者 `import item.subitem.subsubitem` 时，除了最后一个 item 外，其他的项必须都是 package；最后一个 item 可以是 module 或者 package

当使用 `from item.subitem.subsubitem import xx` 时

### absolute/relative import
对于绝对导入，任意一个 subpackage 中的 module 都可以使用；

对于相对导入，需要保证

使用 python xx.py 运行时，xx 变成 main module，而 main module 没有 package，所以作为 main module 的脚本只能使用 absolute import

## C/C++/CUDA extension
在 python 文件中执行 c/c++/cuda 函数，可以使用扩展工具来实现。一般的 C/C++ 扩展工具有

+ Python C API
+ pybind11
+ Cython

### Python C API
通过 `#include <Python.h>` 将 C 文件做成一个 python module，对传入的 python 参数做类型转换，返回的值再转换成 python 对象。需要告知模块中包含的所有的函数，最后初始化创建该模块

示例：

1. 第一步需要在 C 文件中做 python API 的转换

```cpp title="mymod.c"
#define PY_SSIZE_T_CLEAN
#include <Python.h>

// 实际的 C 函数
static int add(int a, int b) {
    return a + b;
}

// Python 调用时的包装函数
static PyObject* py_add(PyObject* self, PyObject* args) {
    int a, b;
    // 解析 Python 传进来的参数
    if (!PyArg_ParseTuple(args, "ii", &a, &b)) {
        return NULL;  // 解析失败，返回 NULL 表示抛异常
    }
    // 调用 C 函数，把结果打包成 Python 对象
    return PyLong_FromLong(add(a, b));
}

// 方法表：告诉 Python 这个模块有哪些函数
static PyMethodDef MyMethods[] = {
    {"add", py_add, METH_VARARGS, "两个整数相加"},
    {NULL, NULL, 0, NULL}  // 结束标记
};

// 模块定义
static struct PyModuleDef mymodule = {
    PyModuleDef_HEAD_INIT,
    "mymod",       // 模块名（必须和文件名一致）
    "示例模块",     // 模块文档
    -1,
    MyMethods
};

// 初始化函数（入口），名字必须是 PyInit_<模块名>
PyMODINIT_FUNC PyInit_mymod(void) {
    return PyModule_Create(&mymodule);
}
```

2. 第二步需要在 setup.py 中写 setup 逻辑

```py title="setup.py"
from setuptools import setup, Extension

setup(
    name="mymod",
    version="1.0",
    ext_modules=[Extension("mymod", ["mymod.c"])],
)
```

3. 第三步编译安装

```bash
python setup.py build_ext --inplace # 仅安装extension到 build/ 并复制到当前文件夹下
python setup.py build # 安装到 build/
python setup.py install # 安装到 build/ 并复制到 lib/python3.xx/site-packages/
```

之后可以直接使用 `import mymod; print(mymod.add(3, 4))` 

> 还顺便学了 nm 命令，用来查看 object 文件中的符号，例如 `nm a.so`

### pybind11

1. pybind 绑定

```cpp title="mymod.cpp"
#include <pybind11/pybind11.h>

int add(int a, int b) {
    return a + b;
}

// PYBIND11_MODULE(模块名, 变量名)
PYBIND11_MODULE(mymod, m) {
    m.doc() = "示例模块";
    m.def("add", &add, "两个整数相加");   // 一行注册
}
```

2. setup.py 如下：

```python
from setuptools import setup, Extension
import pybind11

setup(
    name="mymod",
    version="1.0",
    ext_modules=[
        Extension(
            "mymod",
            ["mymod.cpp"],
            include_dirs=[pybind11.get_include()],
            language="c++",
        )
    ],
)
```

优点：

+ 不用手写 `PyArg_ParseTuple`、`PyLong_FromLong`，pybind11 自动做类型转换
+ 一行 `m.def("add", &add)` 就完成了注册

### pybind11 + CUDA
对于 CUDA 扩展而言，一般会用 pytorch cuda extension。如下：

1. 一般会有 CUDA kernel 文件 `add_cuda_kernel.cu` 和 C++ 接口 `add_cuda.cpp`

```cpp title="add_cuda_kernel.cu"
#include <torch/extension.h>
#include <cuda_runtime.h>

__global__ void add_kernel(const float* a, const float* b, float* out, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        out[idx] = a[idx] + b[idx];
    }
}

torch::Tensor add_cuda(torch::Tensor a, torch::Tensor b) {
    auto out = torch::empty_like(a);
    int n = a.numel();

    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;

    cudaStream_t stream = at::cuda::getCurrentCUDAStream();

    add_kernel<<<blocks, threads, 0, stream>>>(
        a.data_ptr<float>(),
        b.data_ptr<float>(),
        out.data_ptr<float>(),
        n
    );
    return out;
}
```

```cpp title="add_cuda.cpp"
#include <torch/extension.h>

// 声明在 .cu 中定义的函数
torch::Tensor add_cuda(torch::Tensor a, torch::Tensor b);

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    m.def("add", &add_cuda, "CUDA tensor addition");
}
```

2. 在 setup.py 中使用 `torch.utils.cpp_extension` 添加 `CUDAExtension`

```python title="setup.py"
from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension

setup(
    name='add_cuda_ext',
    ext_modules=[
        CUDAExtension(
            name='add_cuda_ext',
            sources=['add_cuda.cpp', 'add_cuda_kernel.cu'],
        )
    ],
    cmdclass={'build_ext': BuildExtension},
)
```

3. 然后安装 `python setup.py build_ext --inplace`，调用 

```python
import torch
import add_cuda_ext

a = torch.randn(1024, device='cuda')
b = torch.randn(1024, device='cuda')

c = add_cuda_ext.add(a, b)
print(c)  # 应该等于 a + b
```

### Cython
Cython 让你用接近 Python 的语法写代码，它会编译成 C，再编译成 .so

1. 先 `pip install cython` ，注意这里是小写 c

2. 然后写 `mymod.pyx`

```python
# cython: language_level=3

def add(int a, int b):
    return a + b
```

3. 写 setup.py，注意这里的 Cython C 大写；以及 cythonize("xx.pyx") 返回的是一个 list，如果要和其他 extension 混用，可以 *cythonize 还原成多个 extension

```python
from setuptools import setup
from Cython.Build import cythonize

setup(
    name="mymod",
    ext_modules=cythonize("mymod.pyx"),
)
```

## python package build/install & python wheel
一个 python 项目在开发完成之后，需要打包（包括构建和源码复制），以供分发；而分发的形式可以是 wheel、源码；用户将包下载到本地后需要进行安装，然后可以开始使用项目 (import)

### setup.py
`python setup.py [cmd]` 是一套旧的项目打包方式，build 会在 build/ 文件夹下构建项目，结构类似于如下：

```bash
build/
├── lib.linux-x86_64-cpython-312
│   ├── add.cpython-312-x86_64-linux-gnu.so
│   ├── mul.cpython-312-x86_64-linux-gnu.so
│   └── ops
│       ├── __init__.py
│       └── ops.py
└── temp.linux-x86_64-cpython-312 # can be ignored
    └── csrc
        ├── add.o
        └── mul.o
```

install 则在 build 的基础上将构建产物复制到 `venv/lib/python3.12/site-packages` 的包目录中，这样可以直接 import

### python wheel
Wheel（文件后缀 .whl）是 Python 的一种预编译二进制分发包格式，是 Python 打包领域的现代标准。

wheel 本质上是一个 ZIP 压缩包，可以直接通过 `pip install xx.whl` 来安装包，将得到的 python 源码以及编译好的 c/cpp/cuda 扩展复制到 site_packages/ 中，并写入元数据 `xx.dist-info`（还有依赖处理、命令行注册等杂事）。相比于源码（sdist）安装，不需要重新编译源码

### modern packaging
现代主流 python 打包方式是 `pip install .`，它会

+ 在隔离环境里执行 setup.py bdist_wheel（构建 wheel）
+ 再安装 wheel
+ 最终的安装结果复制到 site-packages 目录下

安装完成后，源代码的改动不会自动生效。你修改了项目里的 .py 文件，必须重新运行 `pip install .` 才会更新。

### editable
开发自己/他人的包时，一般会从源码开始编译。此时会用 `pip install -e .` 可编辑式安装，在 site_packages 中放一个指向当前目录的链接文件，之后在当前目录下的改动立即生效。

然而在有 c/cpp/cuda extension 的情况下，extension 部分不会自动重新构建，所以需要重新运行 `pip install -e .`，它会重新触发 build_ext 并更新编译产物；

此外， `pip install` 在构建时会创建一个临时环境，用于安装编译时依赖（setuptools/cython等）以及项目依赖（如 numpy 等 python 包）进行构建，在生成 wheel 之后丢弃该临时环境和编译时依赖，但项目依赖依旧保留在 site_packages 中，因此最好在 `pip install` 之前新建虚拟环境，防止系统 python site_packages 的污染；

如果不想创建临时环境，就想复用当前环境下的编译时依赖（torch/ninja/cuda工具链 等），可以加上 `--no-build-isolation` 选项