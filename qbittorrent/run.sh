#!/usr/bin/env bash

set -o pipefail

## 版本、镜像名称等
export QB_FULL_VERSION=4.3.5
export LIBTORRENT_FULL_VERSION=1.2.13
export DOCKERHUB_REPOSITORY=nevinee/qbtest
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
    i=1
    while :; do
        echo "============================= 第 $i 次构建尝试 ============================="
        ./buildx.sh
        [[ $? -eq 0 ]] && break
        let i++
        [[ $i -gt 20 ]] && break  ## 超过20次大概率是遇到了同样的错误，如果无问题可注释本行
    done
}

## 记录日志并增加时间戳
run_buildx 2>&1 | ts "[%Y-%m-%d %H:%M:%.S]" | tee buildx.log
