## 基本用法
```bash
# 初始化，生成 pyproject.toml
poetry init
poetry new poetry-demo 
```

## 创建虚拟环境
```bash
poetry env use python
poetry env python3.8
poetry env use 3.8 # 激活或创建虚拟环境
poetry env system # 激活系统默认的 python


poetry env remove 3.8 # 删除环境
poetry env list # 查看所有虚拟环境

poetry env activate
poetry env deacti
```

> `use xxx`根据系统环境变量`PATH`中 python 的版本号来创建虚拟环境，因此要确保 xxx 存在于 PATH

> Windows系统下 poetry 虚拟环境安装在 `\Users\username\AppData\Local\pypoetry\Cache\virtualenvs\`，MacOS在 `/Users/username/Library/Caches/pypoetry/virtualenvs`

## 安装依赖

```bash
poetry install # 安装 pyproject.toml 中所有依赖，按照 poetry.lock 中的版本安装
poetry add requests
poetry lock # 将 pyproject.toml 和 poetry.lock 同步
poetry update # 根据 pyproject.toml 中的版本更新包，并重新生成 poetry.lock

poetry show # 查看所有安装的 packages
poetry show --tree # 查看所有安装的 packages 以及依赖关系
pendulum 3.0.0 Python datetimes made easy
├── python-dateutil >=2.6
│   └── six >=1.5 
└── tzdata >=2020.1
```
> 没有虚拟环境时安装包，会自动创建虚拟环境

## 配置
```bash
poetry config --list 
poetry config virtualenvs.in-project true
```

## 换源
`poetry source add tsinghua https://pypi.tuna.tsinghua.edu.cn/simple`

!!! tips "manual"
    ```bash
    Available commands:
        about              Shows information about Poetry.
        add                Adds a new dependency to pyproject.toml and installs it.
        build              Builds a package, as a tarball and a wheel by default.
        check              Validates the content of the pyproject.toml file and its consistency with the poetry.lock file.
        config             Manages configuration settings.
        help               Displays help for a command.
        init               Creates a basic pyproject.toml file in the current directory.
        install            Installs the project dependencies.
        list               Lists commands.
        lock               Locks the project dependencies.
        new                Creates a new Python project at <path>.
        publish            Publishes a package to a remote repository.
        remove             Removes a package from the project dependencies.
        run                Runs a command in the appropriate environment.
        search             Searches for packages on remote repositories.
        show               Shows information about packages.
        sync               Update the project's environment according to the lockfile.
        update             Update the dependencies as according to the pyproject.toml file.
        version            Shows the version of the project or bumps it when a valid bump rule is provided.

    cache
        cache clear        Clears a Poetry cache by name.
        cache list         List Poetry's caches.

    debug
        debug info         Shows debug information.
        debug resolve      Debugs dependency resolution.
        debug tags         Shows compatible tags for your project's current active environment.

    env
        env activate       Print the command to activate a virtual environment.
        env info           Displays information about the current environment.
        env list           Lists all virtualenvs associated with the current project.
        env remove         Remove virtual environments associated with the project.
        env use            Activates or creates a new virtualenv for the current project.

    python
        python install     Install the specified Python version from the Python Standalone Builds project. (experimental feature)
        python list        Shows Python versions available for this environment. (experimental feature)
        python remove      Remove the specified Python version if managed by Poetry. (experimental feature)

    self
        self add           Add additional packages to Poetry's runtime environment.
        self install       Install locked packages (incl. addons) required by this Poetry installation.
        self lock          Lock the Poetry installation's system requirements.
        self remove        Remove additional packages from Poetry's runtime environment.
        self show          Show packages from Poetry's runtime environment.
        self show plugins  Shows information about the currently installed plugins.
        self sync          Sync Poetry's own environment according to the locked packages (incl. addons) required by this Poetry installation.
        self update        Updates Poetry to the latest version.

    source
        source add         Add source configuration for project.
        source remove      Remove source configured for the project.
        source show        Show information about sources configured for the project.

    ```