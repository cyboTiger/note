## `setup.py`

```python
from setuptools import setup, find_packages

setup(
    name="mytest",
    version="1.0",
    author="wangbm",
    author_email="wongbingming@163.com",
    description="Learn to Pack Python Module  -->公众号：Python编程时光",

    # 项目主页
    url="http://iswbm.com/", 

    # 你要安装的包，通过 setuptools.find_packages 找到当前目录下有哪些包
    packages=find_packages()
)
```