#!/usr/bin/env bash

## 请不要直接运行本脚本，请通过运行 buildx-run.sh 脚本来调用本脚本。

set -e

echo ${BUILDX_ARCH}
echo ${ALL_MULTIARCH_TAG}
## 构建镜像
for arch in ${BUILDX_ARCH}; do
    cmd_tag=""
    for tag in ${ALL_MULTIARCH_TAG}; do
        cmd_tag="$cmd_tag --tag ${DOCKERHUB_REPOSITORY}:${tag}-${arch//\//-}"
    done
    echo "------------------------- 构建目标平台：linux/${arch} -------------------------"
    docker buildx build $cmd_tag \
        --cache-from "type=local,src=/root/.buildx-cache" \
        --cache-to "type=local,dest=/root/.buildx-cache" \
        --output "type=docker" \
        --platform linux/${arch} \
        --build-arg "QBITTORRENT_VERSION=${QBITTORRENT_VERSION}" \
        --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_VERSION}" \
        --file ${DOCKERFILE_NAME} \
        .
done


