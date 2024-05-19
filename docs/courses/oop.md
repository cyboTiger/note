# OOP笔记
## I/O streams
istream和ostream的图示
??? info
    ![](oop_pics/iostream.png)
### operators
The operator `<<` is used as an output operator on objects of type `ostream`;
The operator `>>` is used as an input operator determines what input is accepted and what is the target of the input operation;
#### `>>`的读入规则
若读入类型为integer，则读入终止于非digit字符；若读入string，则终止于空格或回车
> 也可以用如`getline(cin,str)`来读入一整行，并抛弃掉末尾的newline

### IO state
`int i; while(cin >> i);`会读入i直到读入失败为止，彼时`cin >> i`会return false，而且`cin.fail()`会return true，表明istream无法读取下一个；此时可以通过`cin.clear()`来重新设置istream的状态

### I/O of User-Defined Types
例子：
```C
struct Entry {
    string name;
    int number;
};

ostream& operator<<(ostream& os, const Entry& e)
{
    return os << "{\"" << e.name << "\", " << e.number << "}";
}

istream& operator>>(istream& is, Entry& e)
// read { "name" , number } pair. Note: for matted with { " " , and }
{
    char c, c2;
    if (is>>c && c=='{' && is>>c2 && c2=='"') { // star t with a { "
        string name; // the default value of a string is the empty string: ""
        while (is.get(c) && c!='"') // anything before a " is part of the name
        name+=c;
        if (is>>c && c==',') {
            int number = 0;
            if (is>>number>>c && c=='}') { // read the number and a }
                e = {name ,number}; // assign to the entry
                return is;
            }
        }
    }
    is.state_base::failbit; // register the failure in the stream
    return is;
}
```
### Formatting
最简单的formatting controls是manipulators，在<ios>, <istream>, <ostream>和 <iomanip> (for manipulators that take arguments)中
+ 例子：
```C
cout << 1234 << ',' << hex << 1234 << ',' << oct << 1234 << '\n'; 
// print 1234,4d2,2322

constexpr double d = 123.456;
cout << d << "; " // use the default
<< scientific << d << "; " // use 1.123e2 style 
<< hexfloat << d << "; " // use hexadecimal notation 
<< fixed << d << "; " // use 123.456 style
<< defaultfloat << d << '\n'; // use the default

// C++ uses rounding instead of truncating
cout.precision(8);
cout << 1234.56789 << ' ' << 1234.56789 << ' ' << 123456 << '\n';
// 1234.5679 1234.5679 123456

cout.precision(4);
cout << 1234.56789 << ' ' << 1234.56789 << ' ' << 123456 << '\n';
// 1235 1235 123456
```

### File stream
In `<fstream>`, the standard library provides streams to and from a file:
+ `ifstream` for reading from a file
+ `ofstream` for writing to a file
+ `fstream` for reading from and writing to a file

```C
ofstream ofs("target"); // ‘‘o’’ for ‘‘output’’
if (!ofs) error("couldn't open 'target' for writing");

fstream ifs; // ‘‘i’’ for ‘‘input’’
if (!ifs) error("couldn't open 'source' for reading");
```

### String stream
In `<sstream>`, the standard library provides streams to and from a string:
+ `istringstream` for reading from a string
+ `ostringstream` for writing to a string
+ `stringstream` for reading from and writing to a string.
...不清楚怎么用yet


## The vector
用时需要`#include <vector>`
### 基本规则和操作
```C
vector<class T> amounts; 
//vector<type> name;
amounts.empty(); 
// return true if amounts is empty
amounts.size();
amounts.clear();
// empty amounts
amounts.push_back(const T& elem);
/* append to amounts. 
if elem is a direct object instead of a pointer,
makes a deep, independent copy of that object. */
amounts.pop_back();
amounts[2];
// access using operator[]

// iterator
amounts.begin();
amounts.end();
amounts.erase(iterator where);
/* remove element addressed by where
and return an iterator pointing to the elements
after the removed one*/
```

> Changes to a vector invalidate all existing iterators. As a result, previously generated iterators could reference meaningless data.

## The map
### 基本规则和操作
```C
pair<iterator, bool> insert(const pair<Key, Value>& newEntry);
/* if Key already exists in map, return (an iterator addressing 
the pair stored inside the map on behalf of the key, false);
Otherwise return (..., true), and insert the (key, value) pair 
into the map;
*/
iterator find(const Key& key);
// ...
```
## Inline functions
### 原理
区别于正常函数与主程序分开存放，inline函数在调用时将它的definition，即运行代码贴在调用处。这样就避免了正常函数调用时需要存储返回地址和instruction pointer跳转等操作带来的时间消耗。
但这也同时导致了使用inline函数会是程序更长，属于用大空间换短时间。
### 适用范围
也正是由于这个特性，某些函数不适合用inline：
1. 函数本身的运行时间远大于调用所需时间
因为这样调用节省的时间忽略不计，白白浪费空间
2. 函数并没有被频繁调用
这样就没有发挥出inline的用处
### 使用方法
在声明或定义函数时增加前缀`inline`即可，如`inline double square(double x) { return x * x; }`
> compiler未必会满足inline的需求；如果该函数太大，或recursive，inline都会被忽略，当作正常函数

## Reference
+ 规则：必须在声明reference变量时初始化，和某变量绑定（成为其别名），不可二次绑定

## The copy constructor (拷贝构造函数)
格式：

```cpp
    T::T(const T&);

    T t1;
    // copy ctor usage
    T t2 = t1;
    T t3(t1);
```

若没有写，则c++编译器会生成一个默认拷贝构造函数。当通过`=`来赋值时，拷贝右值对象的每个字段给左值(memberwise initialization)。

若成员中有其他class，则递归拷贝构造该字段。
!!! warning
    若成员中有指针变量，需要着重考虑指针的拷贝方式，是直接拷贝指向地址，还是拷贝一份指向的对象再指向拷贝对象。否则在析构时，有可能发生重复析构的报错

### 拷贝优化
!!! note "draft"
    若某函数return一个T(s)，即临时构造的对象；而该函数被作为右值赋给某T对象，则会被优化为该T对象直接按s来进行临时构造

为了避免重复冗余的copy构造，当使用`vector`等容器时，可以预留容器容量，然后再向容器中添加元素。通过`std::vector.reserve(size)`来预留容量，就可以有效减少`vector`扩容带来的copy操作

??? info "`std::vector` mechanism"
    vector被初始化时`capacity`为0。当`push_back/emplace_back`时，若`capacity`不够，则重新分配一块大小为原来两倍的内存给此`vector`，`capacity`变为2倍，然后把原来内存中的元素依次copy到新的内存中


## static修饰符
class中的static变量

## operator overloading（运算符重载）
极少数运算符不可重载；运算符重载后优先级不变

格式：

```cpp
    /* unary operator */
    
    /* binary operator */
    // within class
    Integer operator+(const Integer & i1) {return ...;}
    // in global scope
    Integer operator+(const Integer & i1, const Integer & i2)
    { return ...; }
```

