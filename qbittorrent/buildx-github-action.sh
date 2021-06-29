#!/usr/bin/env bash

set -o pipefail

## 获取qBittorrent和libtorrent的版本号
QBITTORRENT_VERSION=$(curl -s https://api.github.com/repos/qbittorrent/qBittorrent/tags | jq -r .[]."name" | grep -m1 -E "release-([0-9]\.?){3,4}$" | sed "s/release-//")
if [[ ${QBITTORRENT_VERSION} == 4.3* ]]; then
    LIBTORRENT_VERSION=$(curl -s https://api.github.com/repos/arvidn/libtorrent/tags | jq -r .[]."name" | grep -m1 -E "v1\.([0-9]\.?){2,3}$" | sed "s/v//")
else
    LIBTORRENT_VERSION=$(curl -s https://api.github.com/repos/arvidn/libtorrent/tags | jq -r .[]."name" | grep -m1 -E "v2\.([0-9]\.?){2,3}$" | sed "s/v//")
fi

## qBittorrent的各种版本号
RELEASE_SEMVER=${QBITTORRENT_VERSION}
PATCH_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-3)
MINOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1-2)
MAJOR_SEMVER=$(printf "${RELEASE_SEMVER}" | cut -d '.' -f 1)

## 多平台标签
if [[ ${RELEASE_SEMVER} == ${PATCH_SEMVER} ]]; then
    ALL_MULTIARCH_TAG="${MAJOR_SEMVER} ${MINOR_SEMVER} ${RELEASE_SEMVER} latest"
else
    ALL_MULTIARCH_TAG="${MAJOR_SEMVER} ${MINOR_SEMVER} ${PATCH_SEMVER} ${RELEASE_SEMVER} latest"
fi

## 输出变量到控制台
echo "控制变量如下："
echo "QBITTORRENT_VERSION=${QBITTORRENT_VERSION}"
echo "LIBTORRENT_VERSION=${LIBTORRENT_VERSION}"
echo "DOCKERFILE_NAME=${DOCKERFILE_NAME}"

## 构建
cmd_tag=""
for tag in ${ALL_MULTIARCH_TAG}; do
    cmd_tag="$cmd_tag --tag ${DOCKERHUB_REPOSITORY}:${tag}"
done
docker buildx build $cmd_tag \
    --progress "plain" \
    --cache-from "type=local,src=/tmp/.buildx-cache" \
    --cache-to "type=local,dest=/tmp/.buildx-cache" \
    --output "type=image,push=true" \
    --platform "${BUILDX_ARCH}" \
    --build-arg "QBITTORRENT_VERSION=${QBITTORRENT_VERSION}" \
    --build-arg "LIBTORRENT_VERSION=${LIBTORRENT_VERSION}" \
    --file ${DOCKERFILE_NAME} \
    .
