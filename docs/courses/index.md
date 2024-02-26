# 笔记本

For full documentation visit [mkdocs.org](https://www.mkdocs.org).

## Commands

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs -h` - Print help message and exit.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

## Code line:
Here is code lines: `python`

## Code block:
Here is code blocks:
```python
def func(a,b):
    return a + b
```

## With a title:
``` python title="qsort.py" linenums="1"
def qsort(array,order):
    for i in range(array.len):
        for j in range(array.len):
            ...
```

## Open a Virtual Environment
Sometimes, we need a **venv** to make some command run.
### Steps 
+ in your terminal, `cd` into the expected directory.
+ enter `python3 -m venv venv` or `python -m venv venv`
+ enter `source venv/bin/activate`
+ check if the command works...