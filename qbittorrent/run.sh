#!/usr/bin/env bash

## 运行脚本的前提：已经运行过 docker login 并已经成功登陆。
## 注意：本地编译仍然会花费好几个小时，并且极有可能中途报错，若中途报错，建议手动复制命令一条一条运行；也可另写脚本调用本脚本编译。
## 在Dockerfile同目录下运行，请通过运行 run.sh 来调用本脚本
## 需要先定义以下几个变量：
## QB_FULL_VERSION=           ## qbittorrent版本
## LIBTORRENT_FULL_VERSION=   ## libtorrent版本
## DOCKERHUB_REPOSITORY=      ## 镜像名称
## DOCKERFILE_NAME=""         ## 用来构建的Dockerfile文件名

set -o pipefail

## 版本、镜像名称等
export QB_FULL_VERSION=4.3.5
export LIBTORRENT_FULL_VERSION=1.2.14
export DOCKERHUB_REPOSITORY=nevinee/qbittorrent
export DOCKERFILE_NAME=Dockerfile

## 跨平台构建相关
prepare_buildx() {
    export DOCKER_CLI_EXPERIMENTAL=enabled
    docker pull multiarch/qemu-user-static
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker buildx create --name builder --use 2>/dev/null || docker buildx use builder
    SUPPORTED_PLATFORMS=$(docker buildx inspect --bootstrap | grep 'Platforms:*.*' | cut -d : -f2,3)
    echo "本主机支持以下平台：$SUPPORTED_PLATFORMS"
}

## 以子shell调用buildx.sh，在子shell中设置 `set -e`，出错立即退出并重新运行
run_buildx() {
    prepare_buildx
    for ((i = 1; i <= 20; i++)); do
        echo "============================= 第 $i 次构建尝试 ============================="
        ./buildx.sh
        [[ $? -eq 0 ]] && break
        let i++
    done
}

## 记录日志并增加时间戳
run_buildx 2>&1 | ts "[%Y-%m-%d %H:%M:%.S]" | tee buildx.log
