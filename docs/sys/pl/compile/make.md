
## 常见自动变量

| 自动变量 | 含义 |
|---------|------|
| `$@` | 目标文件名 |
| `$<` | 第一个依赖文件 |
| `$^` | 所有依赖文件列表 |
| `$*` | 目标的主文件名（不含扩展名） |

## 使用变量
```bash
objects = main.o kbd.o command.o display.o \
    insert.o search.o files.o utils.o

edit : $(objects)
    cc -o edit $(objects)
```

## 自动推导
只要make看到一个 .o 文件，它就会自动的把 .c 文件加在依赖关系中，如果make找到一个 `whatever.o` ，那么 `whatever.c` 就会是 `whatever.o` 的依赖文件。并且命令 `cc -c whatever.c` 也会被推导出来

## Makefile里有什么？

Makefile里主要包含了五个东西：显式规则、隐式规则、变量定义、指令和注释。

+ 显式规则。显式规则说明了如何生成一个或多个目标文件。这是由Makefile的书写者明显指出要生成的文件、文件的依赖文件和生成的命令。

+ 隐式规则。由于我们的make有自动推导的功能，所以隐式规则可以让我们比较简略地书写Makefile，这是由make所支持的。

+ 变量的定义。在Makefile中我们要定义一系列的变量，变量一般都是字符串，这个有点像你C语言中的宏，当Makefile被执行时，其中的变量都会被扩展到相应的引用位置上。

+ 指令。其包括了三个部分，一个是在一个Makefile中引用另一个Makefile，就像C语言中的include一样；另一个是指根据某些情况指定Makefile中的有效部分，就像C语言中的预编译#if一样；还有就是定义一个多行的命令。

+ 注释。Makefile中只有行注释，和UNIX的Shell脚本一样，其注释是用 # 字符，这个就像C/C++中的 // 一样。如果你要在你的Makefile中使用 # 字符，可以用反斜杠进行转义，如： \# 

## 包含其它Makefile

在Makefile使用 include 指令可以把别的Makefile包含进来，这很像C语言的 #include ，被包含的文件会原模原样的放在当前文件的包含位置。 include 的语法是：

`include <filenames>...`

<filenames> 可以是当前操作系统Shell的文件模式（可以包含路径和通配符）。

在 include 前面可以有一些空字符，但是绝不能是 Tab 键开始。 include 和 <filenames> 可以用一个或多个空格隔开。

## make的工作方式

GNU的make工作时的执行步骤如下：（想来其它的make也是类似）

+ 读入所有的Makefile。
+ 读入被include的其它Makefile。
+ 初始化文件中的变量。
+ 推导隐式规则，并分析所有规则。
+ 为所有的目标文件创建依赖关系链。
+ 根据依赖关系，决定哪些目标要重新生成。
+ 执行生成命令。

## 书写规则
在Makefile中，规则的顺序是很重要的，因为，Makefile中只应该有一个最终目标，其它的目标都是被这个目标所连带出来的，所以一定要让make知道你的最终目标是什么。一般来说，定义在Makefile中的目标可能会有很多，但是第一条规则中的目标将被确立为最终的目标。如果第一条规则中的目标有很多个，那么，第一个目标会成为最终的目标。make所完成的也就是这个目标。

## 在规则中使用通配符
make支持三个通配符： `*` ， `?` 和 `~`

通配符 `*` 代替了你一系列的文件，如 *.c 表示所有后缀为c的文件。

对于变量中的通配符 `objects = *.o` ，表示了通配符同样可以用在变量中。并不是说 *.o 会展开，不！objects的值就是 *.o 。Makefile中的变量其实就是C/C++中的宏。如果你要让通配符在变量中展开，也就是让objects的值是所有 .o 的文件名的集合，那么，你可以这样：

1. 列出一确定文件夹中的所有 .c 文件
```bash
wildcard *.c
```
2. 列出(1)中所有文件对应的 .o 文件
```bash
$(patsubst %.c,%.o,$(wildcard *.c))
```

3. 由(1)(2)两步，可写出编译并链接所有 .c 和 .o 文件
```bash
objects := $(patsubst %.c,%.o,$(wildcard *.c))
foo : $(objects)
    cc -o foo $(objects)
```

## 文件搜寻
当make需要去找寻文件的依赖关系时，你可以在文件前加上路径，但最好的方法是把一个路径告诉make，让make在自动去找

### 特殊变量 VPATH
Makefile 文件中的特殊变量 `VPATH` 就是完成这个功能的，如果没有指明这个变量，make只会**在当前的目录**中去找寻依赖文件和目标文件。如果定义了这个变量，那么，make就会在当前目录找不到的情况下，到所指定的目录中去找寻文件了

```bash
VPATH = src:../headers
```

上面的定义指定两个目录，“src”和“../headers”，make会按照这个顺序进行搜索。目录由“冒号”分隔。（当然，当前目录永远是最高优先搜索的地方）

### 关键字 vpath
vpath 是一个make的关键字，这和上面提到的那个VPATH变量很类似，但是它更为灵活。它可以指定不同的文件在不同的搜索目录中，格式为

```bash
vpath <pattern> <directories>
```

<pattern>需要包含 % 字符。 % 的意思是匹配零或若干字符。例如：

```bash
vpath %.h ../headers
```

该语句表示，要求make在 `../headers` 目录下搜索所有以 .h 结尾的文件。

make会按照vpath语句的先后顺序来执行搜索，如：

```bash
vpath %.c foo
vpath %   blish
vpath %.c bar
```

其表示 .c 结尾的文件，先在“foo”目录，然后是“blish”，最后是“bar”目录。

## 伪目标
伪目标用 `.PHONY` 来显式指明，告诉make不需要生成该目标文件，只需要执行命令

### 用途
如果你的Makefile需要一口气生成若干个可执行文件，但你只想简单地敲一个make完事，并且，所有的目标文件都写在一个Makefile中，那么你可以使用“伪目标”这个特性：

```bash
all : prog1 prog2 prog3
.PHONY : all

prog1 : prog1.o utils.o
    cc -o prog1 prog1.o utils.o

prog2 : prog2.o
    cc -o prog2 prog2.o

prog3 : prog3.o sort.o utils.o
    cc -o prog3 prog3.o sort.o utils.o
```

## 多目标
Makefile的规则中的目标可以不止一个，其支持多目标，有可能我们的多个目标同时依赖于一个文件，并且其生成的命令大体类似。于是我们就能把其合并起来。合并可以使用一个自动化变量 `$@` ，这个变量表示着目前规则中所有的目标的集合，例如：

```bash
bigoutput littleoutput : text.g
    generate text.g -$(subst output,,$@) > $@
```

上述规则等价于：

```bash
bigoutput : text.g
    generate text.g -big > bigoutput
littleoutput : text.g
    generate text.g -little > littleoutput
```

### 静态模式
静态模式可以更加容易地定义多目标的规则，可以让我们的规则变得更加的有弹性和灵活。我们还是先来看一下语法：

```bash
<targets ...> : <target-pattern> : <prereq-patterns ...>
    <commands>
    ...

```

看一个例子：

```bash
objects = foo.o bar.o

all: $(objects)

$(objects): %.o: %.c
    $(CC) -c $(CFLAGS) $< -o $@
```

命令中的 $< 和 $@ 则是自动化变量， `$<` 表示第一个依赖文件， `$@` 表示目标集（也就是`foo.o bar.o`）。于是，上面的规则展开后等价于下面的规则：


```bash
foo.o : foo.c
    $(CC) -c $(CFLAGS) foo.c -o foo.o
bar.o : bar.c
    $(CC) -c $(CFLAGS) bar.c -o bar.o
```

如果多个目标，不同模式的目标生成方式不同，那么可以如下书写：

```bash
files = foo.elc bar.o lose.o

$(filter %.o,$(files)): %.o: %.c
    $(CC) -c $(CFLAGS) $< -o $@
$(filter %.elc,$(files)): %.elc: %.el
    emacs -f batch-byte-compile $<
```

## 自动生成依赖

如果是一个比较大型的工程，你必需清楚哪些C文件包含了哪些头文件，并且，你在加入或删除头文件时，也需要小心地修改Makefile，这是一个很没有维护性的工作。为了避免这种繁重而又容易出错的事情，我们可以使用C/C++编译的一个功能。大多数的C/C++编译器都支持一个“-M”的选项，即自动找寻源文件中包含的头文件，并生成一个依赖关系。例如，如果我们执行下面的命令:

```bash
cc -M main.c
```

如果我们的main.c中有一句 `#include "defs.h"` ，就会输出包含相应依赖的make规则：

```bash
main.o : main.c defs.h
```

于是**由编译器自动生成的依赖关系**，这样一来，你就不必再手动书写若干文件的依赖关系，而由编译器自动生成了。

> 需要提醒一句的是，如果你使用GNU的C/C++编译器，你得用 -MM 参数，不然， -M 参数会把一些标准库的头文件也包含进来。

### 通过汇总 .d Makefile 自动生成所有目标的依赖
那么，编译器的这个功能如何与我们的Makefile联系在一起呢。因为这样一来，我们的Makefile也要根据这些源文件重新生成，让 Makefile 自己依赖于源文件？这个功能并不现实，不过我们可以有其它手段来迂回地实现这一功能。GNU组织建议把编译器为每一个源文件的自动生成的依赖关系放到一个文件中，为每一个 name.c 的文件都生成一个 name.d 的Makefile文件， .d 文件中就存放对应 .c 文件的依赖关系

于是，我们可以写出 .c 文件和 .d 文件的依赖关系，并让 make 自动更新或生成 .d 文件，并把其包含在我们的主Makefile中，这样，我们就可以自动化地生成每个文件的依赖关系了。

这里，我们给出了一个模式规则来产生 .d 文件：

```bash
%.d: %.c
    @set -e; rm -f $@; \
    $(CC) -M $(CPPFLAGS) $< > $@.$$$$; \
    sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
    rm -f $@.$$$$
```

这个规则的意思是，所有的 `.d` 文件依赖于 `.c` 文件

+ `rm -f $@` 的意思是删除所有的目标，也就是 `.d` 文件
+ 第二行的意思是，为每个依赖文件 `$<` ，也就是 `.c` 文件生成依赖文件， `$@` 表示模式 `%.d` 文件，如果有一个C文件是 `name.c` ，那么 `%` 就是 `name` ， `$$$$` 意为一个随机编号，第二行生成的文件有可能是 `name.d.12345`
+ 第三行使用sed命令做了一个替换
+ 第四行就是删除临时文件

总而言之，这个模式要做的事就是在编译器生成的依赖关系中加入 .d 文件的依赖，即把依赖关系：

```bash
main.o : main.c defs.h
```

转成：

```bash
main.o main.d : main.c defs.h
```

于是，我们的 `.d` 文件**也会自动更新**了，并会自动生成了，当然，你还可以在这个 `.d` 文件中加入的不只是依赖关系，包括生成的命令也可一并加入，让每个 `.d` 文件都包含一个完整的规则。一旦我们完成这个工作，接下来，我们就要把这些自动生成的规则放进我们的主Makefile中。我们可以使用Makefile的“include”命令，来引入别的Makefile文件（前面讲过），例如：


```bash
sources = foo.c bar.c

include $(sources:.c=.d)
```

上述语句中的 `$(sources:.c=.d)` 中的 `.c=.d` 的意思是做一个替换，把变量 `$(sources)` 所有 `.c` 的字串都替换成 `.d` 。当然，你得注意次序，因为include是按次序来载入文件，最先载入的 .d 文件中的目标会成为默认目标。

## 显式命令
make 在执行时默认会打印执行的命令，当我们用 @ 字符在命令行前，那么这个命令将不被 make 显示出来。例如

```bash
@echo 正在编译XXX模块......
```

只会输出 `正在编译XXX模块......`，避免了重复的输出

```
echo 正在编译XXX模块......
正在编译XXX模块......
```

## 命令出错

每当命令运行完后，make会检测每个命令的返回码，如果命令返回成功，那么make会执行下一条命令，当规则中所有的命令成功返回后，这个规则就算是成功完成了。如果一个规则中的某个命令出错了（命令退出码非零），那么make就会终止执行当前规则，这将有可能终止所有规则的执行

有些时候，命令的出错并不表示就是错误的。例如mkdir命令，我们一定需要建立一个目录，如果目录存在，那么就出错了；我们就不希望mkdir出错而终止规则的运行

为了忽略命令的出错，我们可以在Makefile的命令行前加一个减号 `-` （在Tab键之后），标记为不管命令出不出错都认为是成功的。例如

```bash
clean:
    -rm -f *.o
```

## 嵌套执行make

在一些大的工程中，我们会把我们不同模块或是不同功能的源文件放在不同的目录中，我们可以在每个目录中都书写一个该目录的Makefile，这有利于让我们的Makefile变得更加地简洁，而不至于把所有的东西全部写在一个Makefile中，这样会很难维护我们的Makefile，这个技术对于我们模块编译和分段编译有着非常大的好处