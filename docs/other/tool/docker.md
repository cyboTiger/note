## 容器构建和运行选项
```bash
docker run # 创建并运行容器
-it # -i + -t = interactive terminal
--rm # deletion on exit
--name my-container # specify container name
-v /home/ruihan/workspace:/workspace # volume = [host dir]:[container dir]
-v /ssd/ruihan:/data1 # multiple mounting volumes
hello/world # 拉取的镜像
command # 容器运行的命令
```

## 实际案例

```bash
docker run -it \ 
    --gpus all \
    --shm-size 32g \  # 共享内存用于和其他进程通信
    -p 30000:30000 \  # 宿主机端口转发至容器端口
    -v /home/ruihan/workspace:/workspace \
    -v /ssd/ruihan:/data_ssd \
    -v /scr/dataset/ruihan:/data \
    --env "HF_TOKEN=hf_xxx" \
    --env "HF_HOME=/data" \  # 容器不继承环境变量，需手动设置
    --ipc=host \  # 
    --name zrh-sgl \
    lmsysorg/sglang:dev \
    bash -c '\
        echo "Installing diffusion dependencies..." && \
        pip install -e "python[diffusion]" && \
        tail -f /dev/null \
    '
```

> docker run 命令是主进程，当命令执行完后，容器自动退出；`tail -f /dev/null` 是一个永不退出的进程，保证了后续可以继续进入容器开发

```bash
# 启动
docker start zrh
docker exec -it zrh-sgl
# 进入容器 shell
echo "Starting SGLang-Diffusion..." && \
sglang generate \
    --model-path black-forest-labs/FLUX.1-dev \
    --prompt "A logo With Bold Large text: SGL Diffusion" \
    --save-output \
```

## 其他操作和选项
### 操作
```bash
docker logs zrh-sgl
docker cp zrh-sgl:/app/images/photo.jpg . # 将图片拷贝到宿主机目录
```

### 选项
```bash
--gpus "device=2,3"
```