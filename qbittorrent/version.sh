#!/usr/bin/env bash

set -o pipefail

dir_shell=$(cd $(dirname $0); pwd)
dir_myscripts=$(cd $(dirname $0); cd ../../myscripts; pwd)

cd $dir_shell

## 官方版本
qb_tag=$(curl -s --retry 5 --retry-delay 8 https://api.github.com/repos/qbittorrent/qBittorrent/tags)
ver_qb_official=$(echo $qb_tag | jq -r .[].name | grep -m1 -E "release-([0-9]\.?){3,4}$" | sed "s/release-//")
ver_qbbeta_official=$(echo $qb_tag | jq -r .[].name | grep -m1 -E "release-([0-9]\.?){3,4}[a-zA-Z]+.*" | sed "s/release-//")

## 本地版本
ver_qb_local=$(cat qbittorrent.version)
ver_qbbeta_local=$(cat qbittorrent-beta.version)

## 导入配置
. $dir_myscripts/notify.sh
. $dir_myscripts/my_config.sh

cmd_dispatches="curl -X POST -H \"Accept: application/vnd.github.v3+json\" -H \"Authorization: token ${GITHUB_MIRROR_TOKEN}\" https://api.github.com/repos/nevinen/dockerfiles/dispatches"

## 触发同步仓库
if [[ $ver_qb_official ]] || [[ $ver_qbbeta_official ]]; then
    if [[ $ver_qb_official != $ver_qb_local || $ver_qbbeta_official != $ver_qbbeta_local ]]; then
        $cmd_dispatches -d '{"event_type":"mirror"}'
    fi
fi

## 检测官方版本与本地版本是否一致，如不一致则触发Github Action构建镜像
if [[ $ver_qb_official ]]; then
    if [[ $ver_qb_official != $ver_qb_local ]]; then
        echo "官方已升级qBittorrent版本至：$ver_qb_official，开始触发Github Action..."
        # $cmd_dispatches -d '{"event_type":"qbittorrent"}'  ## 改用gh workflow触发
        sleep 3
        gh workflow run qbittorrent.yml -f version=$ver_qb_official
        [[ $? -eq 0 ]] && {
            echo "$ver_qb_official" > qbittorrent.version
            notify "qBittorrent已经升级" "当前官方版本: ${ver_qb_official}\n当前本地版本: ${ver_qb_local}\n已经向 Github Action 触发构建程序"
        }
    else
        echo "qBittorrent官方版本和本地一致，均为：$ver_qb_official"
    fi
fi
if [[ $ver_qbbeta_official ]]; then
    if [[ $ver_qbbeta_official != $ver_qbbeta_local ]]; then
        echo "官方已升级qBittorrent beta版本至：$ver_qbbeta_official，开始触发Github Action..."
        # $cmd_dispatches -d '{"event_type":"qbittorrent-beta"}'  ## 改用gh workflow触发
        sleep 3
        gh workflow run qbittorrent.yml -f version=$ver_qbbeta_official
        [[ $? -eq 0 ]] && {
            echo "$ver_qbbeta_official" > qbittorrent-beta.version
            notify "qBittorrent beta已经升级" "当前官方版本: ${ver_qbbeta_official}\n当前本地版本: ${ver_qbbeta_local}\n已经向 Github Action 触发构建程序"
        }
    else
        echo "qBittorrent beta官方版本和本地一致，均为：$ver_qbbeta_official"
    fi
fi