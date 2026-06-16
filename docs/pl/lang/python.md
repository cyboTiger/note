## python module and package
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