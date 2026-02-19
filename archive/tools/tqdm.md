下面展示一个实时显示网页文件下载进度的例子，关注 line 6 的`tqdm`

```python linenums="1"
import tqdm
import urllib.request
with urllib.request.urlopen(url) as response:
    file_size = int(response.info().get('Content-Length', 0))
    block_size = 8192  # 8 KB
    with open(out_file_tmp, 'wb') as out_file_obj, tqdm(
            desc=os.path.basename(out_file),
            total=file_size,
            unit='iB',
            unit_scale=True,
            unit_divisor=1024,
    ) as bar:
        while True:
            buffer = response.read(block_size)
            if not buffer:
                break
            out_file_obj.write(buffer)
            bar.update(len(buffer))
```