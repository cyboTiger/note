!!! info "有用资源"
    [pytorch internals](https://blog.ezyang.com/2019/05/pytorch-internals/)

## `torch.repeat_interleave`

`torch.repeat_interleave(input, repeats, dim=None, *, output_size=None)`

`repeats` 为重复次数，可以统一，也可以在给定 axis 上为每个元素定制；

`dim` 为重复的维度。直接在对应元素之后重复。

`output_size` 为 output 在该维度的大小（似乎不太必要）