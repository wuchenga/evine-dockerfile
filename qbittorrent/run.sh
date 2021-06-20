#!/usr/bin/env bash

## 1. 运行脚本的前提：已经运行过 docker login 并已经成功登陆；
## 2. 本地编译仍然会花费好几个小时；
## 3. 在Dockerfile同目录下运行；
## 4. 请使用root用户运行；
## 5. 宿主机安装好 moreutils 这个包；
## 6. 需要先定义以下几个变量，可直接传参，依次为 $1 $2 $3 $4：
##    QB_FULL_VERSION=           # qbittorrent版本
##    LIBTORRENT_FULL_VERSION=   # libtorrent版本
##    DOCKERHUB_REPOSITORY=      # 镜像名称
##    DOCKERFILE_NAME=           # 用来构建的Dockerfile文件名

set -o pipefail

## 版本、镜像名称等
export QB_FULL_VERSION=${1:-4.3.5}
export LIBTORRENT_FULL_VERSION=${2:-1.2.14}
export DOCKERHUB_REPOSITORY=${3:-nevinee/qbittorrent}
export DOCKERFILE_NAME=${4:-Dockerfile}

## 跨平台构建相关
prepare_buildx() {
    export DOCKER_CLI_EXPERIMENTAL=enabled
    docker pull tonistiigi/binfmt
    docker run --privileged --rm tonistiigi/binfmt --install all
    docker buildx create --name builder --use 2>/dev/null || docker buildx use builder
    docker buildx inspect --bootstrap
}

## 以子shell调用buildx.sh，在子shell中设置 `set -e`，出错立即退出并重新运行
run_buildx() {
    prepare_buildx
    echo "控制变量如下："
    echo "QB_FULL_VERSION=${QB_FULL_VERSION}"
    echo "LIBTORRENT_FULL_VERSION=${LIBTORRENT_FULL_VERSION}"
    echo "DOCKERHUB_REPOSITORY=${DOCKERHUB_REPOSITORY}"
    echo "DOCKERFILE_NAME=${DOCKERFILE_NAME}"
    for ((i = 1; i <= 20; i++)); do
        echo "============================= 第 $i 次构建尝试 ============================="
        ./buildx.sh && break
    done
}

## 记录日志并增加时间戳
run_buildx 2>&1 | ts "[%Y-%m-%d %H:%M:%.S]" | tee buildx_${QB_FULL_VERSION}.log
