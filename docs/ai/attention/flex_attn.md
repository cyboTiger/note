!!! info "pytorch blog"
    https://pytorch.org/blog/flexattention/

核心是通过输入 `batch index`, `attention head index`, `query index`, `key/value index`, `attention score`

将特定位置的 attention score scalar 映射到为 modified attention score scalar 或者 boolean mask scalar

支持任意的 attention mask pattern，以及任意的 pre-softmax score modification

## 示例

```python
from torch.nn.attention.flex_attention import flex_attention

# full (bidirectional) attn with Relative position encodings
def relative_positional(score, b, h, q_idx, kv_idx):
    return score + (q_idx - kv_idx)
flex_attention(query, key, value, score_mod=relative_positional)


from torch.nn.attention.flex_attention import create_block_mask
from torch.nn.attention import or_masks

# causal prefix attention (attention sink)
prefix_length: [B]
def causal_mask(b, h, q_idx, kv_idx):
    return q_idx >= kv_idx
def prefix_mask(b, h, q_idx, kv_idx):
    return kv_idx <= prefix_length[b]
prefix_lm_causal = or_masks(prefix_mask, causal_mask)
block_mask = create_block_mask(prefix_lm_causal, B=B, H=None, S, S)
flex_attention(query, key, value, block_mask=block_mask)
```

## 使用场景
### 