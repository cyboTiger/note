## Python装饰器原理详解

装饰器是Python中一个非常强大的特性，它允许我们在不修改原有函数代码的情况下，动态地给函数添加新的功能。让我从基础到深入为你讲解。

### 1. 基础概念：函数是一等公民

在Python中，函数是**一等公民**，这意味着：

```python
# 1. 函数可以赋值给变量
def greet(name):
    return f"Hello, {name}"

say_hello = greet  # 函数赋值
print(say_hello("Alice"))  # 输出: Hello, Alice

# 2. 函数可以作为参数传递
def call_func(func, name):
    return func(name)

print(call_func(greet, "Bob"))  # 输出: Hello, Bob

# 3. 函数可以嵌套定义
def outer():
    x = 10
    def inner():
        return x + 5
    return inner  # 返回内部函数

func = outer()
print(func())  # 输出: 15
```

### 2. 简单的装饰器实现

基于上面的特性，我们可以实现一个最简单的装饰器：

```python
# 一个简单的计时装饰器
def timer_decorator(func):
    def wrapper():
        import time
        start = time.time()
        func()
        end = time.time()
        print(f"函数执行时间: {end - start}秒")
    return wrapper

# 使用装饰器
@timer_decorator
def my_function():
    import time
    time.sleep(1)
    print("函数执行中...")

# 等价于：
# my_function = timer_decorator(my_function)

my_function()
```

### 3. 装饰器的本质

让我们一步步拆解装饰器的工作原理：

```python
# 步骤1：定义装饰器函数
def decorator(func):
    print("装饰器被调用")
    def wrapper():
        print("在调用原函数之前")
        result = func()
        print("在调用原函数之后")
        return result
    return wrapper

# 步骤2：使用装饰器语法
@decorator
def say_hello():
    print("Hello!")

# 当Python解释器执行到这里时，实际发生的事情：
# 1. 定义原始的say_hello函数
# 2. 调用decorator(say_hello)
# 3. 将返回值（wrapper函数）重新赋值给say_hello

print("准备调用函数")
say_hello()

# 输出顺序：
# 装饰器被调用
# 准备调用函数
# 在调用原函数之前
# Hello!
# 在调用原函数之后
```

### 4. 处理带参数的函数

```python
def logger_decorator(func):
    def wrapper(*args, **kwargs):
        print(f"调用函数: {func.__name__}")
        print(f"参数: args={args}, kwargs={kwargs}")
        result = func(*args, **kwargs)
        print(f"返回值: {result}")
        return result
    return wrapper

@logger_decorator
def add(a, b):
    return a + b

@logger_decorator
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}"

print(add(3, 5))
print(greet("Alice", greeting="Hi"))
```

### 5. 带参数的装饰器

有时我们需要给装饰器本身传递参数：

```python
def repeat(n):
    def decorator(func):
        def wrapper(*args, **kwargs):
            results = []
            for i in range(n):
                results.append(func(*args, **kwargs))
            return results
        return wrapper
    return decorator

@repeat(3)  # 执行3次
def say_hello(name):
    print(f"Hello, {name}")
    return f"Done for {name}"

# 等价于：
# say_hello = repeat(3)(say_hello)

print(say_hello("Alice"))
```

### 6. 使用functools.wraps保留原函数信息

使用装饰器后，原函数的元信息会丢失：

```python
def simple_decorator(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@simple_decorator
def test():
    """这是一个测试函数"""
    pass

print(test.__name__)  # 输出: wrapper (不是 test)
print(test.__doc__)   # 输出: None

# 解决方法：使用functools.wraps
from functools import wraps

def proper_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@proper_decorator
def test():
    """这是一个测试函数"""
    pass

print(test.__name__)  # 输出: test
print(test.__doc__)   # 输出: 这是一个测试函数
```

### 7. 多个装饰器的执行顺序

```python
def decorator_a(func):
    print("进入decorator_a")
    def wrapper(*args, **kwargs):
        print("执行decorator_a的包装函数")
        return func(*args, **kwargs)
    return wrapper

def decorator_b(func):
    print("进入decorator_b")
    def wrapper(*args, **kwargs):
        print("执行decorator_b的包装函数")
        return func(*args, **kwargs)
    return wrapper

@decorator_a
@decorator_b
def my_function():
    print("执行原函数")

# 装饰顺序：从下往上
# 执行顺序：从上往下
my_function()

# 输出：
# 进入decorator_b
# 进入decorator_a
# 执行decorator_a的包装函数
# 执行decorator_b的包装函数
# 执行原函数
```

### 8. 类装饰器

装饰器也可以是类：

```python
class CountCalls:
    def __init__(self, func):
        self.func = func
        self.count = 0
        
    def __call__(self, *args, **kwargs):
        self.count += 1
        print(f"函数被调用了 {self.count} 次")
        return self.func(*args, **kwargs)

@CountCalls
def say_hello(name):
    print(f"Hello, {name}")

say_hello("Alice")
say_hello("Bob")
```

### 9. 实用装饰器示例

```python
# 缓存装饰器
from functools import wraps

def memoize(func):
    cache = {}
    
    @wraps(func)
    def wrapper(*args):
        if args in cache:
            print(f"从缓存获取: {args}")
            return cache[args]
        result = func(*args)
        cache[args] = result
        return result
    
    return wrapper

@memoize
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))  # 大量重复计算被缓存优化

# 权限验证装饰器
def require_auth(role=None):
    def decorator(func):
        @wraps(func)
        def wrapper(user, *args, **kwargs):
            if not user.get('is_authenticated'):
                raise Exception("用户未认证")
            if role and user.get('role') != role:
                raise Exception(f"需要{role}权限")
            return func(user, *args, **kwargs)
        return wrapper
    return decorator

@require_auth(role='admin')
def delete_user(current_user, user_id):
    print(f"用户 {user_id} 已被删除")

# 测试
admin = {'name': 'Alice', 'is_authenticated': True, 'role': 'admin'}
delete_user(admin, 123)
```

### 总结

装饰器的核心原理是：
1. **函数可以作为参数传递**
2. **函数可以返回函数**
3. **闭包可以捕获外部作用域的变量**

这种设计模式让我们能够：
- 在不修改原函数代码的情况下添加功能
- 实现横切关注点（日志、性能测试、事务处理等）
- 提高代码的复用性和可读性

你提到的这些问题都涉及到Python中非常重要的概念：**上下文管理**和**生成器**。它们都是处理资源和惰性求值的优雅方式。

## 一、资源回收与上下文管理器

### 1. 为什么需要资源回收？

当我们在操作文件、数据库连接、网络连接等资源时，需要确保使用后正确释放，否则可能导致资源泄漏：

```python
# 不好的做法
f = open('file.txt', 'w')
f.write('Hello')
# 忘记关闭文件，可能导致数据丢失或文件锁定

# 传统方式
f = open('file.txt', 'w')
try:
    f.write('Hello')
finally:
    f.close()  # 确保总是关闭文件
```

### 2. with语句的原理

`with`语句让资源管理变得更加简单和安全：

```python
# 使用with语句
with open('file.txt', 'w') as f:
    f.write('Hello')
# 退出with块后自动关闭文件
```

### 3. 上下文管理器协议

`with`语句的工作原理基于**上下文管理器协议**，包含两个特殊方法：

```python
class ManagedResource:
    def __enter__(self):
        """进入with块时调用"""
        print("获取资源")
        # 可以返回需要使用的对象
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """退出with块时调用（无论是否发生异常）"""
        print("释放资源")
        # 返回True表示异常已被处理
        # 返回False（或没有返回值）则传播异常
    
    def do_something(self):
        print("使用资源")

# 使用自定义上下文管理器
with ManagedResource() as resource:
    resource.do_something()
# 自动调用__exit__
```

### 4. 实际示例：自定义数据库连接

```python
class DatabaseConnection:
    def __init__(self, connection_string):
        self.connection_string = connection_string
        self.connection = None
    
    def __enter__(self):
        print(f"连接到数据库: {self.connection_string}")
        # 模拟建立连接
        self.connection = {"connected": True}
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("关闭数据库连接")
        self.connection = None
        # 如果有异常，可以在这里处理
        if exc_type:
            print(f"发生异常: {exc_val}")
        # 返回False让异常继续传播
        return False
    
    def query(self, sql):
        if not self.connection:
            raise RuntimeError("没有数据库连接")
        print(f"执行查询: {sql}")
        return ["result1", "result2"]

# 使用示例
with DatabaseConnection("mysql://localhost:3306/test") as db:
    results = db.query("SELECT * FROM users")
    print(results)
# 自动关闭连接
```

### 5. contextlib模块简化

Python提供了`contextlib`模块来简化上下文管理器的创建：

```python
from contextlib import contextmanager

@contextmanager
def managed_resource():
    """使用生成器实现上下文管理器"""
    print("获取资源")
    resource = {"name": "my_resource"}
    try:
        yield resource  # 提供资源给with块
    finally:
        print("释放资源")

# 使用
with managed_resource() as r:
    print(f"使用资源: {r}")
    
# 更实用的例子：临时改变目录
import os
from contextlib import contextmanager

@contextmanager
def change_directory(path):
    """临时改变工作目录"""
    old_path = os.getcwd()
    print(f"从 {old_path} 切换到 {path}")
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(old_path)
        print(f"恢复目录: {old_path}")

# 使用
with change_directory('/tmp'):
    print(f"当前目录: {os.getcwd()}")
    # 在/tmp目录下执行操作
print(f"当前目录: {os.getcwd()}")  # 已恢复
```

## 二、生成器与yield

### 1. 生成器的基本概念

生成器是一种特殊的迭代器，可以逐步产生值，而不是一次性生成所有值：

```python
# 普通函数：一次性返回所有值
def get_numbers():
    return [1, 2, 3, 4, 5]

# 生成器函数：逐个产生值
def generate_numbers():
    print("开始生成")
    yield 1
    print("产生第一个值后")
    yield 2
    print("产生第二个值后")
    yield 3
    print("结束")

# 使用生成器
gen = generate_numbers()
print(next(gen))  # 输出: 开始生成 \n 1
print(next(gen))  # 输出: 产生第一个值后 \n 2
print(next(gen))  # 输出: 产生第二个值后 \n 3
# print(next(gen))  # StopIteration
```

### 2. 生成器的内存优势

生成器在处理大数据集时特别有用：

```python
# 普通方式：占用大量内存
def get_fibonacci_list(n):
    result = []
    a, b = 0, 1
    for _ in range(n):
        result.append(a)
        a, b = b, a + b
    return result

# 生成器方式：内存友好
def fibonacci_generator(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

# 测试内存使用
import sys

# 列表方式
fib_list = get_fibonacci_list(10000)
print(f"列表内存: {sys.getsizeof(fib_list)} bytes")

# 生成器方式
fib_gen = fibonacci_generator(10000)
print(f"生成器内存: {sys.getsizeof(fib_gen)} bytes")

# 列表内存: 85176 bytes
# 生成器内存: 224 bytes

# 逐个获取值
for num in fibonacci_generator(10):
    print(num, end=' ')  # 输出: 0 1 1 2 3 5 8 13 21 34
```

### 3. 生成器表达式

类似于列表推导式，但使用圆括号：

```python
# 列表推导式：立即计算所有值
list_squares = [x**2 for x in range(10)]
print(f"列表: {list_squares}")
print(f"内存: {sys.getsizeof(list_squares)}")

# 生成器表达式：惰性计算
gen_squares = (x**2 for x in range(10))
print(f"生成器: {gen_squares}")
print(f"内存: {sys.getsizeof(gen_squares)}")

# 逐个获取值
for square in gen_squares:
    print(square, end=' ')
```

### 4. 高级生成器特性

#### send()方法：双向通信

```python
def echo_generator():
    print("生成器启动")
    while True:
        received = yield  # 接收发送的值
        print(f"收到: {received}")

gen = echo_generator()
next(gen)  # 启动生成器，执行到yield
gen.send("Hello")  # 输出: 收到: Hello
gen.send("World")  # 输出: 收到: World
# gen.close()  # 关闭生成器
```

#### throw()方法：在生成器中抛出异常

```python
def safe_generator():
    try:
        yield 1
        yield 2
        yield 3
    except GeneratorExit:
        print("生成器被关闭")
    except Exception as e:
        print(f"捕获异常: {e}")

gen = safe_generator()
print(next(gen))  # 输出: 1
gen.throw(ValueError("自定义错误"))
```

### 5. yield from：委托给另一个生成器

```python
def sub_generator():
    yield from range(3)
    yield "来自子生成器"

def main_generator():
    yield "开始"
    yield from sub_generator()  # 委托
    yield "结束"

for value in main_generator():
    print(value)
# 输出: 开始, 0, 1, 2, 来自子生成器, 结束
```

### 6. 实际应用示例

#### 逐行读取大文件

```python
def read_large_file(file_path):
    """惰性读取大文件，避免内存溢出"""
    with open(file_path, 'r') as file:
        for line in file:
            yield line.strip()

# 处理大文件
def process_log_file(file_path):
    error_count = 0
    for line in read_large_file(file_path):
        if 'ERROR' in line:
            error_count += 1
            if error_count <= 5:  # 只显示前5个错误
                print(f"错误日志: {line}")
    print(f"总错误数: {error_count}")
```

#### 实现数据管道

```python
def read_data(filename):
    """读取原始数据"""
    with open(filename) as f:
        for line in f:
            yield line

def clean_data(lines):
    """清洗数据"""
    for line in lines:
        cleaned = line.strip().lower()
        if cleaned:  # 跳过空行
            yield cleaned

def extract_fields(lines):
    """提取字段"""
    for line in lines:
        fields = line.split(',')
        yield {
            'name': fields[0],
            'age': int(fields[1]),
            'city': fields[2]
        }

def filter_adults(records):
    """过滤成年人"""
    for record in records:
        if record['age'] >= 18:
            yield record

# 构建处理管道
pipeline = filter_adults(
    extract_fields(
        clean_data(
            read_data('people.txt')
        )
    )
)

# 惰性处理，一次只处理一条记录
for adult in pipeline:
    print(f"成年人: {adult}")
```

### 7. with和yield的结合：资源清理

```python
from contextlib import contextmanager

@contextmanager
def database_transaction(connection):
    """数据库事务上下文管理器"""
    print("开始事务")
    try:
        yield connection  # 提供连接对象
        connection.commit()  # 无异常时提交
        print("提交事务")
    except Exception:
        connection.rollback()  # 发生异常时回滚
        print("回滚事务")
        raise  # 重新抛出异常
    finally:
        print("清理资源")

# 使用示例
class Connection:
    def commit(self): print("提交")
    def rollback(self): print("回滚")
    def execute(self, sql): print(f"执行: {sql}")

conn = Connection()

with database_transaction(conn) as db:
    db.execute("INSERT INTO users...")
    db.execute("UPDATE accounts...")
    # 如果这里发生异常，会自动回滚
```

## 三、综合示例：资源管理与生成器

下面是一个完整的示例，展示了资源管理和生成器的结合使用：

```python
class DataProcessor:
    """数据处理类，演示资源管理和生成器的结合"""
    
    def __init__(self, input_file, output_file):
        self.input_file = input_file
        self.output_file = output_file
        self.input_handle = None
        self.output_handle = None
        self.processed_count = 0
    
    def __enter__(self):
        """进入上下文：打开文件"""
        print("打开输入文件")
        self.input_handle = open(self.input_file, 'r')
        print("打开输出文件")
        self.output_handle = open(self.output_file, 'w')
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """退出上下文：关闭文件"""
        if self.input_handle:
            print("关闭输入文件")
            self.input_handle.close()
        if self.output_handle:
            print("关闭输出文件")
            self.output_handle.close()
        print(f"总共处理了 {self.processed_count} 条记录")
    
    def read_lines(self):
        """生成器：逐行读取数据"""
        for line in self.input_handle:
            yield line.strip()
    
    def process_line(self, line):
        """处理单行数据"""
        # 模拟数据处理
        return line.upper()
    
    def process_all(self):
        """处理所有数据"""
        for line in self.read_lines():
            processed = self.process_line(line)
            self.output_handle.write(processed + '\n')
            self.processed_count += 1
            if self.processed_count % 100 == 0:
                print(f"已处理 {self.processed_count} 条")

# 使用示例
with DataProcessor('input.txt', 'output.txt') as processor:
    processor.process_all()
# 自动关闭文件
```

## 总结

### 资源管理（with）：
- **自动管理资源**：确保资源被正确释放
- **异常安全**：即使发生异常也能清理资源
- **代码简洁**：减少样板代码
- **适用范围**：文件、数据库连接、锁、网络连接等

### 生成器（yield）：
- **惰性求值**：需要时才计算，节省内存
- **表示无限序列**：可以处理理论上的无限数据流
- **数据管道**：构建高效的数据处理流水线
- **协程基础**：可以实现简单的协程

这两种特性在Python中经常结合使用，特别是在处理I/O操作、大数据处理和资源管理时，能够写出既高效又优雅的代码。