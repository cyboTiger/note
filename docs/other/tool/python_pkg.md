## `inspect`
用于查看源代码、函数签名等

`inspect.signature`

```python
@triton.jit
def add_kernel(
    x_ptr, 
    y_ptr, 
    z_ptr,
    n_elem,
    block_size: tl.constexpr
):
    pass

def add(x: torch.Tensor, y: torch.Tensor, useless: str = 'hi'):
    pass

ik = inspect.signature(add_kernel)
ik_params = ik.parameters
for name, params in ik_params.items():
    print(name, params.default, params.annotation, params.kind)
print()

i = inspect.signature(add)
i_params = i.parameters
for name, params in i_params.items():
    print(name, params.default, params.annotation, params.kind)
print()

print(ik)
print(i)

# ------output-------
args <class 'inspect._empty'> <class 'inspect._empty'> VAR_POSITIONAL
kwargs <class 'inspect._empty'> <class 'inspect._empty'> VAR_KEYWORD

x <class 'inspect._empty'> <class 'torch.Tensor'> POSITIONAL_OR_KEYWORD
y <class 'inspect._empty'> <class 'torch.Tensor'> POSITIONAL_OR_KEYWORD
useless hi <class 'str'> POSITIONAL_OR_KEYWORD

(*args, **kwargs)
(x: torch.Tensor, y: torch.Tensor, useless: str = 'hi')
```