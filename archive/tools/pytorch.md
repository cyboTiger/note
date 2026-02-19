## `model.state_dict`

在 PyTorch 中，`torch.nn.Module` 模型的学习参数（即权重和偏差）包含在模型的参数中（使用 `model.parameters()` 访问）。`state_dict` 只是一个 Python 字典对象，它将每个层映射到其参数张量。

> 请注意，只有具有可学习参数的层（卷积层、线性层等）和注册缓冲区（batchnorm 的 running_mean）在模型的 state_dict 中有条目。优化器对象 (torch.optim) 也有一个 state_dict，其中包含有关优化器状态以及所用超参数的信息。

### 示例
```python
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

class TheModelClass(nn.Module):
    ...
net = TheModelClass()
optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)

# Print model's state_dict
print("Model's state_dict:")
for param_tensor in net.state_dict():
    print(param_tensor, "\t", net.state_dict()[param_tensor].size())
# Print optimizer's state_dict
print("Optimizer's state_dict:")
for var_name in optimizer.state_dict():
    print(var_name, "\t", optimizer.state_dict()[var_name])
```

## 保存/加载模型
### 保存/加载 `state_dict`
```python
### save
torch.save(model.state_dict(), PATH)

### load
model = TheModelClass(*args, **kwargs)
model.load_state_dict(torch.load(PATH, weights_only=True))
model.eval()
```

> 在运行推理之前调用 `model.eval()` 以将 dropout 和批归一化层设置为评估模式。未能执行此操作将导致不一致的推理结果。

> 常见的 PyTorch 约定是使用 .pt 或 .pth 文件扩展名保存模型。

> 不要忘记 `best_model_state = model.state_dict()` 返回对状态的引用，而不是其副本！您必须序列化 `best_model_state` 或使用 `best_model_state = deepcopy(model.state_dict())` 以避免后续训练时 `state_dict` 被优化迭代

### 保存/加载整个模型
```python
# save
torch.save(model, PATH)

# Model class must be defined somewhere
model = torch.load(PATH, weights_only=False)
model.eval()
```

> 以这种方式保存模型将使用 Python 的 pickle 模块保存整个模块。此方法的缺点是序列化数据绑定到特定的类以及保存模型时使用的确切目录结构。原因是 pickle 不保存模型类本身。相反，它保存包含该类的文件的路径，该路径在加载时使用。因此，当在其他项目中使用或重构后，您的代码可能会以各种方式中断。

### 以 TorchScript 格式导出/加载模型

```python
### export/save
model_scripted = torch.jit.script(model) # Export to TorchScript
model_scripted.save('model_scripted.pt') # Save

### load
model = torch.jit.load('model_scripted.pt')
model.eval()
```

### 为 推理/恢复训练 保存和加载 general checkpoint
```python
# save
torch.save({
            'epoch': epoch,
            'model_state_dict': model.state_dict(),
            'optimizer_state_dict': optimizer.state_dict(),
            'loss': loss,
            ...
            }, PATH)


# load
model = TheModelClass(*args, **kwargs)
optimizer = TheOptimizerClass(*args, **kwargs)

checkpoint = torch.load(PATH, weights_only=True)
model.load_state_dict(checkpoint['model_state_dict'])
optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
epoch = checkpoint['epoch']
loss = checkpoint['loss']

model.eval()
# - or -
model.train()
```

> 此情况下，必须保存的不仅仅是模型的 `state_dict`。同样重要的是保存优化器的 `state_dict`，因为它包含在模型训练时更新的缓冲区和参数。您可能想要保存的其他项目包括您停止的 epoch、最新记录的训练损失、外部 `torch.nn.Embedding` 层等。因此，这样的检查点通常比单独的模型大 2~3 倍。

> 要保存多个组件，请将它们组织在一个字典中，并使用 torch.save() 序列化该字典。常见的 PyTorch 约定是使用 .tar 文件扩展名保存这些检查点。

### 在一个文件中保存多个模型
只需将多个组件的 state_dict 组织成一个字典再进行 save；load 时根据 loaded ckpt 对应的键值进行赋值

```python
# save
torch.save({
            'modelA_state_dict': modelA.state_dict(),
            'modelB_state_dict': modelB.state_dict(),
            'optimizerA_state_dict': optimizerA.state_dict(),
            'optimizerB_state_dict': optimizerB.state_dict(),
            ...
            }, PATH)


# load
modelA = TheModelAClass(*args, **kwargs)
modelB = TheModelBClass(*args, **kwargs)
optimizerA = TheOptimizerAClass(*args, **kwargs)
optimizerB = TheOptimizerBClass(*args, **kwargs)

checkpoint = torch.load(PATH, weights_only=True)
modelA.load_state_dict(checkpoint['modelA_state_dict'])
modelB.load_state_dict(checkpoint['modelB_state_dict'])
optimizerA.load_state_dict(checkpoint['optimizerA_state_dict'])
optimizerB.load_state_dict(checkpoint['optimizerB_state_dict'])

modelA.eval()
modelB.eval()
# - or -
modelA.train()
modelB.train()
```

### 使用来自不同模型的参数预热启动模型
可以在 `load_state_dict()` 函数中将 `strict` 参数设置为 `False` 以忽略不匹配的键。

```python
# save modelA
torch.save(modelA.state_dict(), PATH)

# load modelA for modelB (not necessarily of the same class)
modelB = TheModelBClass(*args, **kwargs)
modelB.load_state_dict(torch.load(PATH, weights_only=True), strict=False)
```

### 跨设备保存和加载模型
#### 在 GPU 上保存，在 CPU 上加载
```python
torch.save(model.state_dict(), PATH)

device = torch.device('cpu')
model = TheModelClass(*args, **kwargs)
model.load_state_dict(torch.load(PATH, map_location=device, weights_only=True))
```
此处需要设置 `map_location` 为 cpu

#### 在 GPU 上保存，在 GPU 上加载
```python
torch.save(model.state_dict(), PATH)

device = torch.device('cuda')
model = TheModelClass(*args, **kwargs)
model.load_state_dict(torch.load(PATH, weights_only=True))
model.to(device)
```
此处需要 `model.to(device)` 来将初始化的模型转换为 CUDA 优化模型，但不需要指定 `map_location`，因为原本就保存在 GPU 上；

此外，务必添加语句 `input = input.to(device)` 将输入转移到 CUDA GPU 上进行推理/训练

#### 在 CPU 上保存，在 GPU 上加载
```python
torch.save(model.state_dict(), PATH)

device = torch.device('cuda')
model = TheModelClass(*args, **kwargs)
model.load_state_dict(torch.load(PATH, map_location='cuda:0', weights_only=True))
model.to(device)
```
同上，务必添加语句 `input = input.to(device)` 将输入转移到 CUDA GPU 上进行推理/训练