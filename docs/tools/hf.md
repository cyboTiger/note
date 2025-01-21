# Transfomer
## necessary libraries

```bash
!pip install transformers datasets evaluate accelerate torch
```

## pipeline
`pipeline()`函数：下载预训练模型和tokenizer进行推理，[支持多种task](https://huggingface.co/docs/transformers/quicktour#pipeline)

```python
from transformers import pipeline
classifier = pipeline("sentiment-analysis")

classifier("We are very happy to show you the 🤗 Transformers library.") # single query
[{'label': 'POSITIVE', 'score': 0.9998}]

results = classifier(["We are very happy to show you the 🤗 Transformers library.", "We hope you don't hate it."]) # multiple queries
for result in results:
    print(f"label: {result['label']}, with score: {round(result['score'], 4)}")
label: POSITIVE, with score: 0.9998
label: NEGATIVE, with score: 0.5309
```

### 指定模型和功能
#### 通过模型名指定模型
```python
import torch
from transformers import pipeline
from datasets import load_dataset, Audio

speech_recognizer = pipeline("automatic-speech-recognition", model="facebook/wav2vec2-base-960h")
dataset = load_dataset("PolyAI/minds14", name="en-US", split="train")
dataset = dataset.cast_column("audio", Audio(sampling_rate=speech_recognizer.feature_extractor.sampling_rate)) # match sampling rate, can ignore
result = speech_recognizer(dataset[:4]["audio"])
print([d["text"] for d in result])
```

#### 通过 `AutoClass` 指定模型
```python
from transformers import AutoTokenizer, AutoModelForSequenceClassification

model_name = "nlptown/bert-base-multilingual-uncased-sentiment"

# download and cache pretrained model and tokenizer
model = AutoModelForSequenceClassification.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

classifier = pipeline("sentiment-analysis", model=model, tokenizer=tokenizer)
classifier("Nous sommes très heureux de vous présenter la bibliothèque 🤗 Transformers.")
```

## AutoClass
### AutoTokenizer
用法如上，tokenizer返回一个`dict`对象：

+ input_ids: numerical representations of your tokens.
+ attention_mask: indicates which tokens should be attended to.

```python
encoding = tokenizer("We are very happy to show you the 🤗 Transformers library.")
print(encoding)

{'input_ids': [101, 11312, 10320, 12495, 19308, 10114, 11391, 10855, 10103, 100, 58263, 13299, 119, 102],
 'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
 'attention_mask': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]}

# tokenize in batch
pt_batch = tokenizer(
    ["We are very happy to show you the 🤗 Transformers library.", "We hope you don't hate it."],
    padding=True,
    truncation=True,
    max_length=512,
    return_tensors="pt", # return pytorch tensor, not tensorflow tensor
)
```

### AutoModel
默认情况会将权重设置为full precision (torch.float32)，设置 `torch_dtype="auto"` 可以将数据类型设置为the most memory-optimal data type

```python
from transformers import AutoModelForSequenceClassification
from torch import nn

model_name = "nlptown/bert-base-multilingual-uncased-sentiment"
pt_model = AutoModelForSequenceClassification.from_pretrained(model_name, torch_dtype="auto")

# feed the tokenized dict (add ** to unpack the dict) to the model
# The model outputs the final activations in the logits attribute
pt_outputs = pt_model(**pt_batch)

pt_predictions = nn.functional.softmax(pt_outputs.logits, dim=-1)
print(pt_predictions)
```

> All 🤗 Transformers models (PyTorch or TensorFlow) output the tensors before the final activation function (like softmax) because the final activation function is often fused with the loss.

### save a model
```python
pt_save_directory = "./pt_save_pretrained"
tokenizer.save_pretrained(pt_save_directory)
pt_model.save_pretrained(pt_save_directory)

# reload local model
pt_model = AutoModelForSequenceClassification.from_pretrained(pt_save_directory)
```

也可以通过`from_pt`和`from_tf`将存储的模型转换为 pytorch 或 tensorflow 架构

```python
from transformers import AutoModel

tokenizer = AutoTokenizer.from_pretrained(pt_save_directory)
pt_model = AutoModelForSequenceClassification.from_pretrained(pt_save_directory, from_pt=True)
```

## Customized configuration
可以改变hidden layer 层数、attention head 数等，但需要注意此时模型参数是随机初始化的，需要重新训练

```python
from transformers import AutoConfig, AutoModel

my_config = AutoConfig.from_pretrained("distilbert/distilbert-base-uncased", n_heads=12)
my_model = AutoModel.from_config(my_config)
```

## Trainer - a PyTorch optimized training loop
`torch.nn.Module` 的训练过程可以自定义，也可以用封装好的 `Trainer` 类，它提供了基本的training loop ，支持 distributed training, mixed precision, and more.

```python
from transformers import AutoModelForSequenceClassification
model = AutoModelForSequenceClassification.from_pretrained("distilbert/distilbert-base-uncased", torch_dtype="auto")

from transformers import TrainingArguments
training_args = TrainingArguments(
    output_dir="path/to/save/folder/",
    learning_rate=2e-5,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    num_train_epochs=2,
)

from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("distilbert/distilbert-base-uncased")

from datasets import load_dataset
dataset = load_dataset("rotten_tomatoes")  # doctest: +IGNORE_RESULT

# Create a function to tokenize the dataset
def tokenize_dataset(dataset):
    return tokenizer(dataset["text"])
# apply it over the entire dataset with map
dataset = dataset.map(tokenize_dataset, batched=True)
# A DataCollatorWithPadding to create a batch of examples from your dataset:
from transformers import DataCollatorWithPadding
data_collator = DataCollatorWithPadding(tokenizer=tokenizer)

# gather all these classes in Trainer:
from transformers import Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=dataset["train"],
    eval_dataset=dataset["test"],
    processing_class=tokenizer,
    data_collator=data_collator,
)  # doctest: +SKIP

# call train() to start training
trainer.train()
```
