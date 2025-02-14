## `argparse.Namespace`
```python
import argparse

# 创建 ArgumentParser 对象
parser = argparse.ArgumentParser(description='示例程序')

# 添加参数
parser.add_argument('--foo', help='foo 参数')
parser.add_argument('bar', nargs='?', default='bar', help='bar 参数')

# 解析参数
args = parser.parse_args()

# 使用参数
print(args.foo)
print(args.bar)

# 如果你想将 Namespace 对象转换为字典，可以使用 vars() 函数
args_dict = vars(args)
print(args_dict['foo'])
print(args_dict['bar'])
```