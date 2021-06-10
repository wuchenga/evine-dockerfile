#!/usr/bin/env bash

## 运行脚本的前提：已经运行过 docker login 并已经成功登陆。
## 注意：本地编译仍然会花费好几个小时，并且极有可能中途报错，若中途报错，建议手动复制命令一条一条运行；也可另写脚本调用本脚本编译。
## 在Dockerfile同目录下运行，请通过运行 run.sh 来调用本脚本
## 需要先定义以下几个变量：
## QB_FULL_VERSION=           ## qbittorrent版本
## LIBTORRENT_FULL_VERSION=   ## libtorrent版本
## DOCKERHUB_REPOSITORY=      ## 镜像名称
## DOCKERFILE_NAME=""         ## 用来构建的Dockerfile文件名

set -e

## qBittorrent的各种版本号
RELEASE_SEMVER=${QB_FULL_VERSION}
PATCH_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-3)
MINOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-2)
MAJOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1)
ALL_MULTIARCH_TAG=( ${MAJOR_SEMVER} ${MINOR_SEMVER} ${PATCH_SEMVER} ${RELEASE_SEMVER} latest )
BUILDX_ARCH=( amd64 arm/v7 arm64 )

## 构建
declare -a IMAGES
IMAGES=()
for arch in "${BUILDX_ARCH[@]}"; do
    echo "------------------------- 构建目标平台：linux/${arch} -------------------------"
    docker buildx build \
        --cache-from "type=local,src=/tmp/.buildx-cache" \
        --cache-to "type=local,dest=/tmp/.buildx-cache" \
        --output "type=image,push=true" \
        --platform linux/${arch} \
        --build-arg "QBITTORRENT_VERSION=${QB_FULL_VERSION}" \
        --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_FULL_VERSION}" \
        --tag "${DOCKERHUB_REPOSITORY}:${MAJOR_SEMVER}-${arch//\//-}" \
        --tag "${DOCKERHUB_REPOSITORY}:${MINOR_SEMVER}-${arch//\//-}" \
        --tag "${DOCKERHUB_REPOSITORY}:${PATCH_SEMVER}-${arch//\//-}" \
        --tag "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-${arch//\//-}" \
        --tag "${DOCKERHUB_REPOSITORY}:latest-${arch//\//-}" \
        -f ${DOCKERFILE_NAME} \
        .

    IMAGES+=( "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-${arch//\//-}" )
done

set +e

## 增加manifest
for tag in ${ALL_MULTIARCH_TAG[@]}; do
    docker manifest create "${DOCKERHUB_REPOSITORY}:${tag}" "${IMAGES[@]}"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64" --variant "v8"
done

## 推送manifest到docker hub
for tag in ${ALL_MULTIARCH_TAG[@]}; do
    docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${tag}"
done

