#!/usr/bin/env bash

## 请不要直接运行本脚本，请通过运行 buildx-run.sh 脚本来调用本脚本。

## 镜像清单
IMAGES=()
for arch in ${BUILDX_ARCH}; do
    IMAGES+=( "${DOCKERHUB_REPOSITORY}:latest-${arch//\//-}" )
done

## 推送镜像
for arch in ${BUILDX_ARCH}; do
    for tag in "${ALL_MULTIARCH_TAG}"; do
        docker push ${DOCKERHUB_REPOSITORY}:${tag}-${arch//\//-}
    done
done

## 添加多平台标签
for tag in ${ALL_MULTIARCH_TAG}; do
    docker manifest create "${DOCKERHUB_REPOSITORY}:${tag}" "${IMAGES[@]}"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v6" --variant "v6"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm-v7" --variant "v7"
    docker manifest annotate "${DOCKERHUB_REPOSITORY}:${tag}" "${DOCKERHUB_REPOSITORY}:${RELEASE_SEMVER}-arm64" --variant "v8"
done

## 推送多平台标签
for tag in ${ALL_MULTIARCH_TAG}; do
    docker manifest push --purge "${DOCKERHUB_REPOSITORY}:${tag}"
done

