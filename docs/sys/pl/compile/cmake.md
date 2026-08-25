!!! info "参考资料"
    https://www.hahack.com/codes/cmake/
    https://zhuanlan.zhihu.com/p/657235610

## 基本骨架
```cmake title="CMakeLists.txt"
# CMake 最低版本号要求
cmake_minimum_required (VERSION 2.8)

# 项目信息
project (Demo1)

# 指定生成目标
add_executable(Demo main.cc)
```

## CMake命令行调用

```bash
# 在 build/ 文件夹下生成 makefile 以及 CMakeCache
cmake -B build
# 调用 build/ 文件夹下的 makefile 开始构建
cmake --build build
```

## 头文件(header)和库文件(library)
### 头文件(header)
C/C++ 是严格的类型检查语言，对于变量、函数的参数、返回值等，调用之前都必须声明类型。

头文件的出现，是为了避免同个 feature （函数、类、模板）在多份源文件中重复声明，于是放进 .h 文件中，其他文件在开头用一行 #include 就可以拷贝；需要编辑 feature 时，也只需要编辑 .h 文件即可

> 为了避免重复 include，建议在每个头文件第一行加上 `#pragma once` 

Make 的诞生解决了：

+ 自动化批量构建可执行文件，避免每个目标都需要手动 gcc xx.c 以及处理复杂的文件依赖关系
+ 只有少数源文件改动时，只会重新编译这些文件 .c -> .o

但 Make 系统也有缺点：

+ make 在 Unix 类系统上是通用的，但在 Windows 则不然。
+ 需要明确指明每个项目之间的依赖关系，有头文件的时候特别头疼。
+ make 的语法非常简单，不像 shell 或 python 可以做很多判断。
+ 不同的编译器有不同的 flag 规则，为 g++ 准备的参数可能对 MSVC 不适用。

因此跨平台的构建系统的构建系统 CMake 应运而生：

+ 只需要写一份 CMakeLists.txt，就能够在调用时生成当前系统所支持的构建系统。
+ CMake 可以自动检测源文件和头文件之间的依赖关系，导出到 Makefile 里。
+ CMake 具有相对高级的语法，内置的函数能够处理 configure, install 等常见需求。
+ CMake 可以自动检测当前的编译器，需要添加哪些 flag。比如 OpenMP，只需要在 CMakeLists.txt 中指明 target_link_libraries(a.out OpenMP::OpenMp_CXX)即可。

### 库文件(library)
#### 静态库和动态库
有时候我们会有多个可执行文件，他们之间用到的某些功能是相同的，我们想把这些公用的功能做成一个库，方便大家一起共享。

+ 库中的函数可以被可执行文件调用，也可以被其他库文件调用。
+ 库文件又分为静态库文件和动态库文件。
+ 其中静态库相当于**直接把代码插入到生成的可执行文件中**，会导致体积变大，但是只需要一个文件即可运行。
+ 而动态库则只在生成的可执行文件中生成「插桩」函数，当可执行文件被加载时会读取指定目录中的 .dll 文件，加载到内存中空闲的位置，并且替换相应的「插桩」。指向的地址为加载后的地址，这个过程称为**重定向**。这样以后函数被调用就会跳转到动态加载的地址去。

CMake 也能非常轻松的构建库，只需要调用 add_library 即可：

```bash
add_library(test STATIC source1.cpp source2.cpp)
# 生成静态库 libtest.a
add_library(test SHARED source1.cpp source2.cpp)
# 生成动态库 libtest.so
```

创建库以后，要在某个可执行文件中使用该库，只需要：

```bash
target_link_libraries(myexec PUBLIC test)
# 为 myexec 链接刚刚制作的库 libtest.a
```

## CMake添加源文件依赖/库文件/头文件/包/子模块
### 添加子模块
复杂的工程中，我们需要划分子模块，通常一个库一个目录。这里我们把 hellolib 库的东西移到 hellolib 文件夹下了，里面的 CMakeLists.txt 定义了 hellolib 的生成规则。要在根目录使用他，可以用 CMake 的 `add_subdirectory` 添加子目录，子目录也包含一个 CMakeLists.txt，其中定义的库在 `add_subdirectory` 之后就可以在外面使用。

```bash
cmake_minimum_required(VERSION 3.12)
project(hellocmake LANGUAGES CXX)

add_subdirectory(hellolib) #  子目录CMakeLists.txt内容 -> add_library(hellolib STATIC hello.cpp)

add_executable(a.out main.cpp)
target_link_libraries(a.out PUBLIC hellolib)
```

### 添加头文件
因为 `hello.h` 被移到了 `hellolib` 子文件夹里，因此 main.cpp 里也要改成`#include "hellolib/hello.h"`；

如果要避免修改代码，我们可以通过 `target_include_directories` 指定 `a.out` 的头文件搜索目录：（其中第一个 hellolib 是库名，第二个是目录）

```bash
add_executable(a.out main.cpp)
target_link_libraries(a.out PUBLIC hellolib)
target_include_directories(a.out PUBLIC hellolib)
```

这样就将 `./hellolib` 目录添加到头文件搜索目录了，甚至可以用 <hello.h> 来引用这个头文件，因为通过 `target_include_directories` 指定的路径会被视为与系统路径等价：`#include <hello.h>`

如果有多个目标需要添加该目录到头文件搜索目录，可以直接通过关键字 `PUBLIC` 来广播。只需在 hellolib 子目录里的 CMakeLists.txt 里定义该库的头文件搜索目录即可，引用他的可执行文件 CMake 会自动添加这个路径：

```bash
add_library(hellolib STATIC hello.cpp)
target_include_directories(hellolib PUBLIC .)
```

如果不希望让引用 hellolib 的可执行文件自动添加这个路径，把 PUBLIC 改成 PRIVATE 即可

### 其他目标选项
```bash
target_include_directories(myapp PUBLIC /usr/include/eigen3)
# 添加头文件搜索目录
target_link_libraries(myapp PUBLIC hellolib)
# 添加要链接的库
target_add_definitions(myapp PUBLIC MY_MACRO=1)
# 添加一个宏定义
target_add_definitions(myapp PUBLIC -DMY_MACRO=1)
# 与 MY_MACRO=1 等价
target_complie_options(myapp PUBLIC -fopenmp)
# 添加编译器命令行选项
target_sources(myapp PUBLIC hello.cpp other.cpp)
# 添加要编译的源文件
```

如果需要对所有目标都添加，可以这样（不推荐，因为会混淆依赖）：

```bash
include_directories(/opt/cuda/include)
# 添加头文件搜索目录
link_directories(/opt/cuda)
# 添加库文件的搜索路径
add_definitions(MY_MACRO=1)
# 添加一个宏定义
add_compile_options(-fopenmp)
# 添加编译器命令行选项
```

## 第三方库
### 作为纯头文件引入
+ 优点：只需要把他们的 include 目录或头文件下载下来，然后 `include_directories(spdlog/include)`

+ 缺点：函数直接实现在头文件里，没有提前编译，从而需要重复编译同样内容，编译时间长。
### 作为子模块引入
第二友好的方式则是作为 CMake 子模块引入，也就是通过 `add_subdirectory`

方法就是把那个项目（以fmt为例）的源码放到你工程的根目录：

```bash
cmake_minimum_required(VERSION 3.12)
project(hellocmake LANGUAGES CXX)

add_subdirectory(fmt)

add_executable(a.out main.cpp)
target_link_libraries(a.out PUBLIC fmt)
```

### 引用系统中预安装的第三方库
可以通过 find_package 命令寻找系统中的包/库（也称 module）：

```bash
find_package(fmt REQUIRED)
target_link_libraries(myexec PUBLIC fmt::fmt)
```

+ 为什么是 fmt::fmt 而不是简单的 fmt？

    现代 CMake 认为一个包（package）可以提供多个库，又称组件（components），比如 TBB 这个包，就包含了 tbb, tbbmalloc, tbbmalloc_proxy 这三个组件。
    因此为了避免冲突，每个包都享有一个独立的名字空间，以 :: 的分割（和 C++ 还挺像的）。

+ 你可以指定要用哪几个组件：

    ```bash
    find_package(TBB REQUIRED COMPONENTS tbb tbbmalloc REQUIRED)
    target_link_libraries(myexec PUBLIC TBB::tbb TBB::tbbmalloc)
    ```

不同的包之间常常有着依赖关系，而包管理器的作者为 `find_package` 编写的脚本（例如 `/usr/lib/cmake/TBB/TBBConfig.cmake` ）能够自动查找所有依赖

CMake 预安装的 module 有两类：

+ Utility Modules
    通过 `include(AndroidTestUtilities)` 的方式加载

+ Find Modules
    通过 `find_package(CUDAToolkit)` 的方式加载

### 安装第三方库 - 包管理器
Linux 可以用系统自带的包管理器（如 apt）安装 C++ 包

此外，还有别的命令如 `set()` 设置配置变量，`file()` 查找匹配模式的文件等等，以后整理