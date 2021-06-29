#!/usr/bin/env bash

## 1. 运行脚本的前提：已经运行过 docker login 并已经成功登陆；
## 2. 本地编译仍然会花费好几个小时；
## 3. 在Dockerfile同目录下运行；
## 4. 请使用root用户运行；
## 5. 宿主机安装好 moreutils 这个包；
## 6. 需要先定义以下几个变量，可直接传参，依次为 $1 $2 $3 $4 $5：
##    QB_FULL_VERSION=           # qbittorrent版本
##    LIBTORRENT_FULL_VERSION=   # libtorrent版本
##    DOCKERHUB_REPOSITORY=      # 镜像名称，不输入则默认为nevinee/qbittorrent
##    DOCKERFILE_NAME=           # 用来构建的Dockerfile文件名，不输入则默认为Dockerfile
##    QBITTORRENT_URL=           # qBittorrent git地址，不输入则默认为https://gitee.com/evine/qBittorrent.git

set -o pipefail

cd $(dirname $0)

## 版本、镜像名称等
export QBITTORRENT_VERSION=${1:-4.3.6}
export LIBTORRENT_VERSION=${2:-1.2.14}
export DOCKERHUB_REPOSITORY=${3:-nevinee/qbittorrent}
export DOCKERFILE_NAME=${4:-Dockerfile}
export QBITTORRENT_URL=${5:-https://gitee.com/evine/qBittorrent.git}

## 要构建的平台
export BUILDX_ARCH="s390x ppc64le arm/v6 arm/v7 arm64 386 amd64"

## qBittorrent的各种版本号
RELEASE_SEMVER=${QBITTORRENT_VERSION}
PATCH_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-3)
MINOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-2)
MAJOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1)

## 多平台标签
if [[ $RELEASE_SEMVER == $PATCH_SEMVER ]]; then
    export ALL_MULTIARCH_TAG="${MAJOR_SEMVER} ${MINOR_SEMVER} ${RELEASE_SEMVER} latest"
else
    export ALL_MULTIARCH_TAG="${MAJOR_SEMVER} ${MINOR_SEMVER} ${PATCH_SEMVER} ${RELEASE_SEMVER} latest"
fi

## 跨平台构建相关
prepare_buildx() {
    export DOCKER_CLI_EXPERIMENTAL=enabled
    docker pull tonistiigi/binfmt
    docker run --privileged --rm tonistiigi/binfmt --install all
    docker buildx create --name builder --use 2>/dev/null || docker buildx use builder
    docker buildx inspect --bootstrap
}

## 克隆脚本
git_clone() {
    if [[ ! -d qBittorrent-${QBITTORRENT_VERSION} ]]; then
        git clone --branch release-${QBITTORRENT_VERSION} ${QBITTORRENT_URL} qBittorrent-${QBITTORRENT_VERSION}
    fi
}

## 构建
buildx_build() {
    for ((i = 1; i <= 20; i++)); do
        echo "============================= 第 $i 次构建尝试 ============================="
        ./buildx-build.sh && break
    done
}

## 推送
buildx_manifest() {
    [[ -z $i || $i -lt 20 ]] && ./buildx-manifest.sh
}

## 以子shell调用buildx-build.sh，在子shell中设置 `set -e`，出错立即退出并重新运行
run_buildx() {
    echo "控制变量如下："
    echo "QBITTORRENT_VERSION=${QBITTORRENT_VERSION}"
    echo "LIBTORRENT_VERSION=${LIBTORRENT_VERSION}"
    echo "DOCKERHUB_REPOSITORY=${DOCKERHUB_REPOSITORY}"
    echo "DOCKERFILE_NAME=${DOCKERFILE_NAME}"
    echo "QBITTORRENT_URL=${QBITTORRENT_URL}"
    prepare_buildx
    git_clone
    buildx_build
    buildx_manifest
}

## 记录日志并增加时间戳
run_buildx 2>&1 | ts "[%Y-%m-%d %H:%M:%.S]" | tee -a logs/${QBITTORRENT_VERSION}.log
