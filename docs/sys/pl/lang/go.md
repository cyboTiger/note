参考资料：https://go.dev/tour/

## 类型转换
Go 要求类型转换必须是显式转换

## Defer 语句

> A `defer` statement pushes a function call onto a list. The list of saved calls is executed after the surrounding function returns. Defer is commonly used to simplify functions that perform various clean-up actions.

defer 修饰的语句会在函数体内其他语句执行完后再执行；

defer 以一种优雅的方式对各种函数末尾的清理动作进行了规范。例如下面的例子：

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }

    written, err = io.Copy(dst, src)
    dst.Close()
    src.Close()
    return
}
```

使用 defer 可以保证 src 和 dst 句柄不管是否正常打开，都能够关闭：

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }
    defer dst.Close()

    return io.Copy(dst, src)
}
```

对于 defered 函数调用来说，在defer 被估值时，其函数参数就会被估值，而不是等到 defer 执行时才估值参数；例如，以下例子打印 0 而非 1：

```go
func a() {
    i := 0
    defer fmt.Println(i)
    i++
    return
}
```

defer 语句以 Last-In-First-Out 顺序执行；例如，以下例子打印 3210：

```go
func b() {
    for i := 0; i < 4; i++ {
        defer fmt.Print(i)
    }
}
```

defer 语句如果修改了函数的命名返回变量(returning function’s named return values)，则会在 return 之前再读取并赋值；例如：

```go
func c() (i int) {
    defer func() { i++ }()
    return 1
}
```

defer 适合与 panic 和 recover 一起使用。

> Panic is a built-in function that stops the ordinary flow of control and begins panicking. When the function F calls panic, execution of F stops, any deferred functions in F are executed normally, and then F returns to its caller. To the caller, F then behaves like a call to panic. The process continues up the stack until all functions in the current goroutine have returned, at which point the program crashes. Panics can be initiated by invoking panic directly. They can also be caused by runtime errors, such as out-of-bounds array accesses.

> Recover is a built-in function that regains control of a panicking goroutine. Recover is only useful inside deferred functions. During normal execution, a call to recover will return nil and have no other effect. If the current goroutine is panicking, a call to recover will capture the value given to panic and resume normal execution.

例如以下例子：

```go
package main

import "fmt"

func main() {
    f()
    fmt.Println("Returned normally from f.")
}

func f() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered in f", r)
        }
    }()
    fmt.Println("Calling g.")
    g(0)
    fmt.Println("Returned normally from g.")
}

func g(i int) {
    if i > 3 {
        fmt.Println("Panicking!")
        panic(fmt.Sprintf("%v", i))
    }
    defer fmt.Println("Defer in g", i)
    fmt.Println("Printing in g", i)
    g(i + 1)
}
```

其输出为：
```bash
Calling g.
Printing in g 0
Printing in g 1
Printing in g 2
Printing in g 3
Panicking!
Defer in g 3
Defer in g 2
Defer in g 1
Defer in g 0
Recovered in f 4
Returned normally from f.
```

也就是说，当出现 panic 时，栈上的 defer 语句会正常按 LIFO 顺序执行，然后退出函数体；直到 recover 后，继续正常执行 recover 后的部分

## Array
`var a [10]int`

## Slice
切片类似于引用，它不存储数据，它只是一个指向对象的描述符。也就是说，改变 slice 就会将改变 underlying array

slice 有 length 和 capacity 两个概念；前者表示 slice 包含的数组长度，后者表示 slice 指向的底层数组实际的元素数量。分别用 `len(slice)` 和 `cap(slice)` 两个 built-in 函数调用得到

若从 0 开始切片，则 slice 指向的底层数组就是原数组；若从 k > 0 开始，则 slice 指向的底层数组就是以元素 k 为开头的数组。这一点类似于 C 语言的数组，这也意味着 slice 可以 extend 和 drop。extend 指可以访问到大于 `len(slice)` 小于 `cap(slice)` 的元素；drop 是指 通过 `slice[k:]` 抛弃开头 k 个元素

length 和 capacity 为 0 的 slice 为 nil，`slice == nil`

### make
The `make` function allocates a zeroed array and returns a slice that refers to that array: 

```go
a := make([]int, 5)  // len(a)=5
b := make([]int, 0, 5) // len(b)=0, cap(b)=5
```

### append
Go provides a built-in `append` function to append new elements to a slice

```go
package main

import "fmt"

func main() {
	var s []int
	printSlice(s)

	s = append(s, 0)
	printSlice(s)

	s = append(s, 1)
	printSlice(s)

	s = append(s, 2, 3, 4)
	printSlice(s)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}

```

## Range
The `range` form of the `for` loop iterates over a slice or map.

When ranging over a slice, two values are returned for each iteration. The first is the index, and the second is a **copy** of the element at that index. 

```go
package main
import "fmt"
var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
	for i, v := range pow {
		fmt.Printf("2**%d = %d\n", i, v)
	}
}
```

## Maps
The zero value of a map is `nil`. A `nil` map has no keys, nor can keys be added.

The `make` function returns a map of the given type, initialized and ready for use. 

```go
package main
import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m map[string]Vertex
func main() {
	m = make(map[string]Vertex)
	m["Bell Labs"] = Vertex{
		40.68433, -74.39967,
	}
	fmt.Println(m["Bell Labs"])
}

```

## Functions
函数可以作为值传递，比如作为函数参数、返回值，

### Function closures
function 可以在 function 内部定义，如果内部定义的 function 访问了外部 function 的变量，则称为 Function closures

A closure is a function value that references variables from outside its body. The function may access and assign to the referenced variables; in this sense the function is "bound" to the variables. 

## Methods

Go does not have classes. However, you can define methods on types.

A method is a function with a special receiver argument.

The receiver appears in its own argument list between the func keyword and the method name.

In this example, the Abs method has a receiver of type Vertex named v. 

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}

```

You can declare a method on non-struct types, too.

In this example we see a numeric type MyFloat with an Abs method.

You can only declare a method with a receiver whose type is defined in the same package as the method. You cannot declare a method with a receiver whose type is defined in another package (which includes the built-in types such as `int`). 

## Pointer receivers
Methods with pointer receivers can modify the value to which the receiver points (as `Scale` does here). Since methods often need to modify their receiver, pointer receivers are more common than value receivers. 

```go
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(10)
	fmt.Println(v.Abs())
}

```

## Methods and pointer indirection
+ functions with a pointer argument must take a pointer
+ methods with pointer receivers take either a value or a pointer as the receiver

+ functions that take a value argument must take a value of that specific type 
+ methods with value receivers take either a value or a pointer as the receiver

总结：method 自动进行对象引用/指针解引用

### Choosing receiver type
如果要改变对象自身的值，必须用 Pointer receiver；Pointer receiver 另一好处是可以避免对象拷贝

## Interfaces
A type implements an interface by implementing its methods. There is no explicit declaration of intent, no "implements" keyword.

Implicit interfaces decouple the definition of an interface from its implementation, which could then appear in any package without prearrangement. 

### Interface values with nil underlying values

If the concrete value inside the interface itself is nil, the method will be called with a nil receiver.

In some languages this would trigger a null pointer exception, but in Go it is common to write methods that gracefully handle being called with a nil receiver (as with the method M in this example.)

Note that an interface value that holds a nil concrete value is itself non-nil. 

### Nil interface values

A nil interface value holds neither value nor concrete type.

Calling a method on a nil interface is a run-time error because there is no type inside the interface tuple to indicate which concrete method to call. 

### The empty interface
The interface type that specifies zero methods is known as the empty interface:

`interface{}`

An empty interface may hold values of any type. (Every type implements at least zero methods.)

`any` is an alias for `interface{}`, and the two are completely equivalent.

Empty interfaces are used by code that handles values of unknown type. For example, fmt.Print takes any number of arguments of type any. 

```go
package main
import "fmt"

func main() {
	var i interface{}
	describe(i)

	i = 42
	describe(i)

	i = "hello"
	describe(i)
}

func describe(i interface{}) {
	fmt.Printf("(%v, %T)\n", i, i)
}

```

## Type assertions

A type assertion provides access to an interface value's underlying concrete value.

```go
t := i.(T)
t, ok := i.(T) // If i holds a T, then t will be the underlying value and ok will be true. 
```

### Type switches

A type switch is a construct that permits several type assertions in series.

A type switch is like a regular switch statement, but the cases in a type switch specify types (not values), and those values are compared against the type of the value held by the given interface value.

```go
switch v := i.(type) {
case T:
    // here v has type T
case S:
    // here v has type S
default:
    // no match; here v has the same type as i
}
```

### Stringers

One of the most ubiquitous interfaces is Stringer defined by the fmt package.

```go
type Stringer interface {
    String() string
}
```

A Stringer is a type that can describe itself as a string. The fmt package (and many others) look for this interface to print values. 

## Generic function and Type parameters

Go functions can be written to work on multiple types using type parameters. The type parameters of a function appear between brackets, before the function's arguments.

```go
func Index[T comparable](s []T, x T) int
```

This declaration means that s is a slice of any type T that fulfills the built-in constraint comparable. x is also a value of the same type.

comparable is a useful constraint that makes it possible to use the == and != operators on values of the type. In this example, we use it to compare a value to all slice elements until a match is found. This Index function works for any type that supports comparison. 