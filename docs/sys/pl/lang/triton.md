## 基本用法
```python
import triton
import triton.language as tl
import torch

@triton.jit
def add_kernel(
    x_ptr, 
    y_ptr, 
    z_ptr,
    n_elem,
    block_size: tl.constexpr
):
    pid = tl.program_id(0)
    offset = pid*block_size + tl.arange(0, block_size)
    mask = offset < n_elem

    x = tl.load(x_ptr + offset, mask=mask)
    y = tl.load(y_ptr + offset, mask=mask)
    z = x + y

    tl.store(z_ptr + offset, z, mask=mask)

def add(x: torch.Tensor, y: torch.Tensor):
    B = 32
    z = torch.zeros_like(x).to(x.device)
    N = x.shape[0]

    grid = lambda meta: (triton.cdiv(N, meta['block_size']),)
    # option 1
    add_kernel[grid](x, y, z, N, block_size=B)
    # option 2
    meta = {'block_size': B}
    add_kernel[grid](x, y, z, N, **meta)
    
    return z

a = torch.tensor([1,2,3,4]).cuda()
b = torch.tensor([2,1,4,3]).cuda()
c = add(a,b)

print(c)
```

### 编译时常量 `tl.constexpr`
triton kernel 的函数签名中，有一部分参数是**编译时常量**（`tl.constexpr`），在编译期间就已确定值，triton 在 jit compile 这个 kernel 时，就不需要读取这些常量的值，而是直接将它作为字面量硬编码到 ptx/asm 代码中，比如 `block_size`；而且在控制流分支中可以进行循环体展开等优化。

其他参数则是**运行时变量**，kernel 被调用时，这些参数需要从内存 `mov` 到寄存器，而且一般在循环分支中不能优化。

### grid 的概念
调用 triton kernel 时，可以手动指定每个维度的并行线程数量，即 grid，或者叫网格配置。

grid 除了可以是 tuple 外，还可以是 lambda 函数，这是最常见的用法；具体的原理是：当调用 kernel 时，编译器会识别出 kernel 中的编译时常量，然后根据传入的 grid 函数，动态计算出网格配置。因此，调用 kernel 时，编译时常量必须通过关键字参数（`**kwargs`）传递，不能通过位置参数传递（`*args`）

### JIT kernel 的缓存机制
正如其名，triton kernel 是在运行时 Just In Time 编译的。编译时变量确定后，triton 编译器就会缓存这个 kernel 实例；当下一次调用这个 kernel 时，编译器会先在缓存中查找有无按照这组编译时常量编译好的 kernel（通常使用所有编译时常量 hash 值作为键来查找），如果有就直接拿来用，没有则重新编译一个新的 kernel 实例。

使用缓存好的 kernel 实例通常比重新编译新的 kernel 实例快得多。因此，在设计 kernel 时，固定不变的量尽可能设置为编译时常量，即在 kernel 函数签名中添加 `tl.constexpr` annotation，比如 `block_size`；而不固定的量应该设为运行时变量，比如总元素数 `N`

```python
import triton
import triton.language as tl
import time
import torch

@triton.jit
def kernel_with_runtime_n(
    x_ptr, y_ptr, out_ptr,
    n,  # 运行时
    BLOCK_SIZE: tl.constexpr,
):
    pid = tl.program_id(0)
    offsets = pid * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    mask = offsets < n
    x = tl.load(x_ptr + offsets, mask=mask)
    y = tl.load(y_ptr + offsets, mask=mask)
    tl.store(out_ptr + offsets, x + y, mask=mask)

@triton.jit
def kernel_with_constexpr_n(
    x_ptr, y_ptr, out_ptr,
    n: tl.constexpr,  # 编译时
    BLOCK_SIZE: tl.constexpr,
):
    pid = tl.program_id(0)
    offsets = pid * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    mask = offsets < n
    x = tl.load(x_ptr + offsets, mask=mask)
    y = tl.load(y_ptr + offsets, mask=mask)
    tl.store(out_ptr + offsets, x + y, mask=mask)

# 测试数据
x = torch.randn(10000, device='cuda')
y = torch.randn(10000, device='cuda')
out = torch.empty_like(x)

BLOCK = 256
grid = (triton.cdiv(10000, BLOCK),)

# 运行时参数版本：可以传不同值，不会重新编译
print("Runtime n version:")
for n in range(10000,9990,-1):
    start = time.time()
    kernel_with_runtime_n[grid](x, y, out, n, BLOCK_SIZE=BLOCK)
    print(f"  n={n}, time={time.time()-start:.6f}s")
    # 每次调用都很快，因为不需要重新编译

print("\nConstexpr n version:")
for n in range(10000,9990,-1):
    start = time.time()
    kernel_with_constexpr_n[grid](x, y, out, n=n, BLOCK_SIZE=BLOCK)
    print(f"  n={n}, time={time.time()-start:.6f}s")
    # 第一次调用会编译，后续相同 n 会使用缓存
```
结果如下：
```bash
Runtime n version:
  n=10000, time=0.316052s
  n=9999, time=0.001147s
  n=9998, time=0.000026s
  n=9997, time=0.000016s
  n=9996, time=0.000014s
  n=9995, time=0.000012s
  n=9994, time=0.000012s
  n=9993, time=0.000011s
  n=9992, time=0.000011s
  n=9991, time=0.000011s

Constexpr n version:
  n=10000, time=0.001543s
  n=9999, time=0.001030s
  n=9998, time=0.001006s
  n=9997, time=0.001107s
  n=9996, time=0.001019s
  n=9995, time=0.001029s
  n=9994, time=0.001024s
  n=9993, time=0.001003s
  n=9992, time=0.001074s
  n=9991, time=0.001027s
```
