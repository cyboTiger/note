<h1>Ch2</h1>

<h4>ch 2.3</h4>

* sequence:

  * sequence operation:

  * sequence iteration: **for** statement

  * sequence unpacking: 对多重嵌套sequence的子元素进行提取

   ```python
    >>> pairs = [[1, 2], [2, 2], [2, 3], [4, 4]]
    >>> same_count = 0
    >>> for x, y in pairs:
            if x == y:
                same_count = same_count + 1
    >>> same_count
    2
   ```

  * sequence processing: 
  
    * List comprehensions: 元素映射/筛选元素
  
    ```python
    [<map expression> for <name> in <sequence expression> if <filter expression>]
     # List comprehension general format, filter part can be omitted
    ```
  
    * Aggregation: 将sequence中的元素合并成一个value，如sum,min,max函数
  
  * Lists
  
  * range
  
  * strings
  
  * trees
  
  * Linked lists

<h4>Ch 2.4 Mutable data</h4>

+ object: A combination of data value and behavior；python中的任何value都是一个对象，有对应的data和method(class function)

* mutable object: value会随着程序执行而变化，比如list；

  list在赋值时，会将“=”左边的name指向对应的list对象，所以若有多个name指向同一个list object，对其中一个使用method，其他的都会相应变化。如果想要只复制value，可以通过`lst2=list(lst1)`进行。

	为了判断两个name是否指向同个object，通过`name1 is name2`的真假来判断

* Tuple: 是immutable sequence，格式为`(element1,element2,...)`，括号可省略（一般不省略）；一个tuple的元素不可更改，但是可以更改其中mutable element中的元素

* Dictionaries: 属于mutable object

  * 目的：通过描述性的index，而非连续的数字index来存储和获取值
  * 格式：`numerals = {'I': 1.0, 'V': 5, 'X': 10}`
  * 一些语法：

  ```python
  >>> numerals['X'] 
  10 #look up
  
  >>> numerals['L'] = 50
  >>> numerals
  {'I': 1, 'X': 10, 'L': 50, 'V': 5} #add new pair
  
  >>> sum(numerals.values())
  66 #combine all the value
  
  >>> dict([(3, 9), (4, 16), (5, 25)])
  {3: 9, 4: 16, 5: 25} #convert a list of pairs into dictionary
  
  >>> numerals.get('V', 0)
  5 #look up value of 'V' and return it; if not existing,return 0
  
  >>> {x: x*x for x in range(3,6)}
  {3: 9, 4: 16, 5: 25} #dictionaries comprehension create a new dictionary object
  ```

  > 注意：Dictionaries的key-value pair是无序的，所以在interpreter中显示时次序可能会变。
  >
  > key不可以是或包含mutable value，所以不能用list作key；一般用Tuple

+ `nonlocal`声明：
  + 声明了该`name`不在current frame中，而是在第一个出现该name被赋值的frame中，通过`nonlocal`声明，就可以修改current frame之外的变量
  + 用途：可以用于有local state的函数，如withdraw()
  + 限制：python关于name的access有这样的限制，如果没有`nonlocal`声明，那么对于一个`name`的引用必须在同一frame中，不可以在**非本地帧**中找到某name，而在**本地帧**中进行bind。因为python在本地帧中遵循的原则是，若左边的name未在本地出现过，那么就在本地帧中创建该名字并赋值，这时就会造成混淆：evaluate时，到底是看nonlocal的name值，还是刚刚创建的name值呢？
+ `nonlocal`赋值的好处：可以创建一个函数抽象的多个实例，且各个实例之间会随着程序执行而发生状态改变，但彼此之间互不干扰，如：

```python
1	def make_withdraw(balance):
2	    def withdraw(amount):
3	        nonlocal balance
4	        if amount > balance:
5	            return 'Insufficient funds'
6	        balance = balance - amount
7	        return balance
8	    return withdraw
9	
10	wd = make_withdraw(20)
11	wd2 = make_withdraw(7)
12	wd2(6)
13	wd(8)
```

	wd和wd2是两个不同的withdraw实例，有不同的parent（两次make_withdraw的的调用），都是通过make_withdraw创建，其中一个的balance变化不会影响另外一个，各管各的。

+ `nonlocal`赋值的局限性：re-binding操作不仅仅是返回值，它还可能会改变环境；同一个对象，由于它的状态会变化，因此不能根据它的data信息来识别它的identity，这叫做"change"；两个值相等的对象，未必就是同一个对象，这叫做"sameness"。



<h2>Disc4</h2>

data abstraction



<h2>Disc5</h2>

**Iterables**: 一种可以遍历其元素的对象，比如list、string等。任何在apply了built-in `iter` function之后返回`iterator`的object都是`iterator`。

**Iterators**: 也是一种object，通过调用`next`函数，追踪`iterable`中下一个元素，可以遍历`iterable`中的元素，调用完后此iterator对象状态变化，只剩没被遍历的元素；如果对iterator调用`iter`函数，则返回自身。

当iterator中已经遍历完所有元素后，再次调用`next`会raise`StopIteration`的exception。但怎样算遍历完了呢？不仅仅局限于直接调用 `next` 函数到没有元素为止，其他方法比如 `list(iterator1)` 也会遍历元素，因为`list` 需要直到 `iterator1` 中的所有元素，而iterator这种对象是**implicit sequence**，采用**lazy computation**，不会存储序列中的所有元素，而是在调用next后再弹出下一个元素，因此为了获取所有元素，也就implicitly遍历了 `iterator1`

**A comparison** : **Iterables**和**Iterators**的关系就像book和bookmark一样，可以有多个bookmark插在同一本book的不同位置，遍历此book；此外，bookmark并不知道book自身的变化，因此当book变化（remove或add或append等），bookmark还是插在相应的页之间，但调用 `next` 函数时会根据new book的状态来执行；当iterator弹出 `StopIteration` 后，相当于bookmark已经插在book的back cover之后了，所以不管如何改变iterable，对该iterator调用next函数只会弹出 `StopIteration` ，见下例2

> 注意：iterators在遍历元素时不影响原来的iterable

```python
>>> lst = [1, 2, 3, 4]
>>> list_iter = iter(lst)
>>> next(list_iter)
1
>>> list(list_iter) # Return remaining items in list_iter
[2, 3, 4]
```

```python
>>> s = [[1, 2, 3, 4]]
>>> i = iter(s)
>>> next(i)
[1, 2, 3, 4]
>>> s.append(5)
>>> next(i)
5
```

**Generators**: 一种特殊iterator，通过定义个性化的generator函数，return得到generator object

**yield statement**: generator函数中特有的语句

Generator函数的执行过程：调用generator函数（含`yield` statement的函数）产生一个 `generator` 对象，但不会执行generator函数的body；调用generator函数后，每次调用对该`generator`对象调用next函数，都会使对应的generator函数body开始执行，直到遇见`yield` statement（即返回`yield`后面的表达式的值），或遇到暂停点（比如`return`）；当暂停在某个 `yield` statement时，会记住此时离开的位置和状态，下次继续从该暂停点开始继续执行body

如果没元素可yield了，则raise `StopIteration`，与iterator类似

也可以用`yield from` statement从 `iterator` 或 `iterable` 中yield元素，见下例

```python
>>> def gen_list(lst):
...     yield from lst
...
>>> g = gen_list([1, 2])
>>> next(g)
1
>>> next(g)
2
>>> next(g)
StopIteration
```



<h2>OOP</h2>

**Class**和**instance**都是object，前者是模板，后者是实例。用class模板创建创建新的instance对象的操作称为***instantiate the class***。（下以Account class为例讲解）

```python
>>> class Account:
        """A bank account that has a non-negative balance."""
        interest = 0.02
        def __init__(self, account_holder):
            self.balance = 0
            self.holder = account_holder
        def deposit(self, amount):
            """Increase the account balance by amount and return the new balance."""
            self.balance = self.balance + amount
            return self.balance
        def withdraw(self, amount):
            """Decrease the account balance by amount and return the new balance."""
            if amount > self.balance:
                return 'Insufficient funds'
            self.balance = self.balance - amount
            return self.balance
```

**attribute**和**method**: 都是attribute，前者是data，后者是function。attribute又可以分为**instance attribute** 和 **class attribute**。

+ **instance attribute**：独属于某个特定instance的属性，一般与同class的其他instance不同，代表该实例的identity。一般是在`def class`中`def __init__(self, ...)` body中进行初始化的，如
+ **class attribute**：在`def class`中，但在`def __init__(self, ...)` 及其他method之外初始化的attribute，是同class的instance共享的属性

> 当instance attribute改变时，仅该instance改变；当class attribute改变时，所有instance都会改变属性。

此时就会出现一个问题，如果instance attribute和class attribute重名了会怎样呢？这就涉及到

1.  attribute name的估值机制：对于`<expression> . <name>` 的`name`，先从instance attribute中找，若找不到则从class attribute中找，若找不到则从super class中找......；然后根据找到的attribute估出对应的值。
2. attribute assignment机制：对`<expression> . <name>`，
   1. 若`<expression>`是instance，对于instance attribute中没有的`name`，会为<u>该instance</u>(即为inst1)创建`name`的instance attribute。以后，不管class中是否有`name` 的属性，`inst1.name`访问的就不是class attribute，而是自己的instance attribute了。
   2. 若`<expression>`是class，则该assignment statement会修改class attribute。


```python
# Account示例
>>> Account.interest = 0.04
>>> spock_account.interest
0.04
>>> kirk_account.interest
0.04
>>> kirk_account.interest = 0.08 #该interest是kirk的instance attribute
>>> kirk_account.interest
0.08
>>> spock_account.interest #该interest仍然代表Account的class attribute
0.04
>>> Account.interest = 0.05  # changing the class attribute
>>> spock_account.interest     # changes instances without like-named instance attributes
0.05
>>> kirk_account.interest     # but the existing instance attribute is unaffected
0.08
```



关于`__init__`method: 被叫做the *constructor* for the class，然而它并不是真正意义上的constructor，而是初始化object，即被省略的`self`。它的参数表`(self, ...)`。在instantiate时，`self`被bind到当前正在被instantiate的object instance

**bound method**不同于普通**function**的地方在于：它会自动将该object绑定到`self`形参中。对前者，self对应的argument自动省略，对于后者，则必须提供`self`的argument value。见下code示例

```python
>>> type(Account.deposit)
<class 'function'>
>>> type(spock_account.deposit)
<class 'method'>

>>> Account.deposit(spock_account, 1001)  # The deposit function takes 2 arguments
1011
>>> spock_account.deposit(1000)           # The deposit method takes 1 argument
2011
```



**Inheritance**: 以*base class (parent class, super class)*为基础对一些attribute进行修改 (override) 得到*subclass (child class)*

**Inheritance**的用法：

```python
>>> class CheckingAccount(Account):
        """A bank account that charges for withdrawals."""
        withdraw_charge = 1
        interest = 0.01
        def withdraw(self, amount):
            return Account.withdraw(self, amount + self.withdraw_charge)
```



<h4>string conversion</h4>

Two built-in conversion function: 产生一个object的string表示

1. **str**: human-interpretable text (人看得懂的string表示)
2. **repr**: Python-interpretable expression (Python看得懂) ;且有`eval(repr(object)) == object`;若没有能估值为原object value的字符表示，则会输出一段尖括号包围的描述，如：

```python
>>> repr(min)
'<built-in function min>'
```

当定义了一个class时，`__str__`和`__repr__`都是该class的built-in method。当我们执行`str(obj)` 以及`repr(obj)`时，实际上是invoke了`obj`的`__str__`和`__repr__` method。

此外，`print()`函数实际上调用了`obj`的`__str__`方法并在display时去掉引号；在interactive mode下simply call the object实际上调用了`obj`的`__repr__`方法并在display时去掉引号。

<h2>Recursive object</h2>

<h4>1. Linked List Class</h4>

```python
>>> class Link:
        """A linked list with a first element and the rest."""
        empty = ()
        def __init__(self, first, rest=empty):
            assert rest is Link.empty or isinstance(rest, Link) #built-in function
            self.first = first
            self.rest = rest
        def __getitem__(self, i):
            if i == 0:
                return self.first
            else:
                return self.rest[i-1]  #recursive call 
        def __len__(self):
            return 1 + len(self.rest)
# linked list representation and addition
>>> def link_expression(s):
        """Return a string that would evaluate to s."""
        if s.rest is Link.empty:
            rest = ''
        else:
            rest = ', ' + link_expression(s.rest)
        return 'Link({0}{1})'.format(s.first, rest)
>>> Link.__repr__ = link_expression

>>> def extend_link(s, t):
        if s is Link.empty:
            return t
        else:
            return Link(s.first, extend_link(s.rest, t))
>>> Link.__add__ = extend_link # combine two linked list

# linked list comprehension
>>> def map_link(f, s):
        if s is Link.empty:
            return s
        else:
            return Link(f(s.first), map_link(f, s.rest))
>>> def filter_link(f, s):
        if s is Link.empty:
            return s
        else:
            filtered = filter_link(f, s.rest)
            if f(s.first):
                return Link(s.first, filtered)
            else:
                return filtered
#compact string constructor of linked list
>>> def join_link(s, separator):
        if s is Link.empty:
            return ""
        elif s.rest is Link.empty:
            return str(s.first)
        else:
            return str(s.first) + separator + join_link(s.rest, separator)
>>> join_link(s, ", ")
'3, 4, 5'

# class version of linked list partition (previously we used ADT tree recursion)
>>> def partitions(n, m):
        """Return a linked list of partitions of n using parts of up to m.
        Each partition is represented as a linked list.
        """
        if n == 0:
            return Link(Link.empty) # A list containing the empty partition
        elif n < 0 or m == 0:
            return Link.empty
        else:
            using_m = partitions(n-m, m)
            with_m = map_link(lambda s: Link(m, s), using_m)
            without_m = partitions(n, m-1)
            return with_m + without_m
        
>>> def print_partitions(n, m):
        lists = partitions(n, m)
        strings = map_link(lambda s: join_link(s, " + "), lists)
        print(join_link(strings, "\n"))
```

**2. Tree Class**

```python
>>> class Tree:
        def __init__(self, label, branches=()):
            self.label = label
            for branch in branches:
                assert isinstance(branch, Tree)
            self.branches = branches
        def __repr__(self):
            if self.branches:
                return 'Tree({0}, {1})'.format(self.label, repr(self.branches))
            else:
                return 'Tree({0})'.format(repr(self.label))
        def is_leaf(self):
            return not self.branches
```

**3. Sets（集合）**

**mutable**，但**不包含mutable data types**，与数学上的集合在**概念上**和**记号上**基本相同，用**{ }**把元素括起来，元素不重复，无序。

```python
>>> s = {3, 2, 1, 4, 4}
>>> s
{1, 2, 3, 4}
# membership test, length, union, intersection(交集和并集)
>>> 3 in s
True
>>> len(s)
4
>>> s.union({1, 5})
{1, 2, 3, 4, 5}
>>> s.intersection({6, 5, 4, 3})
{3, 4}

isdisjoint(),issubset, and issuperset #是否不相交，为子集，为母集 
```

<h2>Disc7 Tree Class</h2>

|                              | Tree constructor and selector functions                      | Tree class                                                   |
| :--------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Constructing a tree          | `tree(label, branches)`                                      | `Tree(label, branches)` (which calls the `Tree.__init__` method) |
| Label and branches           | call `label(t)` or `branches(t)` respectively                | `t.label` or `t.branches`                                    |
| Mutability                   | **immutable** because we cannot assign values to call expressions | **mutable**, The `label` and `branches` attributes of a `Tree` instance can be reassigned |
| Checking if a tree is a leaf | `is_leaf(t)`                                                 | `t.is_leaf()`                                                |


