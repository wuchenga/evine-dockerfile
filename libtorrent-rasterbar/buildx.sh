#!/usr/bin/env bash

## 1. 运行脚本的前提：已经运行过 docker login 并已经成功登陆；
## 2. 本地编译仍然会花费好几个小时；
## 3. 在Dockerfile同目录下运行；
## 4. 请使用root用户运行；
## 5. 宿主机安装好 moreutils 这个包；
## 6. 需要先定义以下几个变量，可直接传参，依次为 $1 $2 $3 $4：
##    LIBTORRENT_FULL_VERSION=   # libtorrent版本
##    DOCKERHUB_REPOSITORY=      # 镜像名称，不输入则默认为nevinee/libtorrent-rasterbar
##    DOCKERFILE_NAME=           # 用来构建的Dockerfile文件名，不输入则默认为Dockerfile
##    LIBTORRENT_URL=            # libtorrent git地址，不输入则默认为https://gitee.com/evine/libtorrent.git

set -o pipefail

cd $(dirname $0)

## 版本、镜像名称等
export LIBTORRENT_VERSION=${1:-1.2.14}
export DOCKERHUB_REPOSITORY=${2:-nevinee/libtorrent-rasterbar}
export DOCKERFILE_NAME=${3:-Dockerfile}
export LIBTORRENT_URL=${4:-https://gitee.com/evine/libtorrent.git}

## 大版本
export BIG_VERSION=$(echo ${LIBTORRENT_VERSION} | perl -pe "s|(\d+)\..+|\1|")

## 要构建的平台
export BUILDX_ARCH="linux/s390x,linux/ppc64le,linux/arm/v6,linux/arm/v7,linux/arm64,linux/386,linux/amd64"

## 跨平台构建基本环境
prepare_buildx() {
    export DOCKER_CLI_EXPERIMENTAL=enabled
    docker pull tonistiigi/binfmt
    docker run --privileged --rm tonistiigi/binfmt --install all
    docker buildx create --name builder --use 2>/dev/null || docker buildx use builder
    docker buildx inspect --bootstrap
}

## 克隆脚本
git_clone() {
    if [[ ! -d libtorrent-${LIBTORRENT_VERSION} ]]; then
        git clone --branch v${LIBTORRENT_VERSION} --recurse-submodules ${LIBTORRENT_URL} libtorrent-${LIBTORRENT_VERSION}
    fi
}

## 构建
buildx_build() {
    docker buildx build \
        --progress "plain" \
        --cache-from "type=local,src=/root/.buildx-cache" \
        --cache-to "type=local,dest=/root/.buildx-cache" \
        --output "type=image,push=true" \
        --platform "${BUILDX_ARCH}" \
        --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_VERSION}" \
        --tag "${DOCKERHUB_REPOSITORY}:${LIBTORRENT_VERSION}" \
        --tag "${DOCKERHUB_REPOSITORY}:${BIG_VERSION}" \
        --file ${DOCKERFILE_NAME} \
        .
}

## 调用上述函数
run_buildx() {
    echo "控制变量如下："
    echo "LIBTORRENT_VERSION=${LIBTORRENT_VERSION}"
    echo "DOCKERHUB_REPOSITORY=${DOCKERHUB_REPOSITORY}"
    echo "DOCKERFILE_NAME=${DOCKERFILE_NAME}"
    echo "LIBTORRENT_URL=${LIBTORRENT_URL}"
    [[ ! -d logs ]] && mkdir logs
    prepare_buildx
    git_clone
    buildx_build
}

## 记录日志并增加时间戳
run_buildx 2>&1 | ts "[%Y-%m-%d %H:%M:%.S]" | tee -a logs/${LIBTORRENT_VERSION}.log
