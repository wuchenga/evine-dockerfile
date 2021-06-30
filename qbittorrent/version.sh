#!/usr/bin/env bash

set -o pipefail

dir_shell=$(cd $(dirname $0); pwd)
dir_myscripts=$(cd $(dirname $0); cd ../../myscripts; pwd)
url_dispatches=https://api.github.com/repos/nevinen/dockerfiles/dispatches

cd $dir_shell

## 官方版本
ver_qb_official=$(curl -s https://api.github.com/repos/qbittorrent/qBittorrent/tags | jq -r .[]."name" | grep -m1 -E "release-([0-9]\.?){3,4}$" | sed "s/release-//")

## 本地版本
ver_qb_local=$(cat qbittorrent.version)

## 检测qbittorrent官方版本与本地版本是否一致，如不一致则重新构建
if [[ $ver_qb_official ]]; then
    if [[ $ver_qb_official != $ver_qb_local ]]; then
        echo "官方已升级qBittorrent版本至：$ver_qb_official，开始触发Github Action..."
        . $dir_myscripts/notify.sh
        . $dir_myscripts/my_config.sh

        ## 触发Github Action同步源代码到Gitee
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"mirror"}' \
            $url_dispatches
        
        ## 触发Github Action构建qbittorrent镜像
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"qbittorrent"}' \
            $url_dispatches

        [[ $? -eq 0 ]] && {
            echo "$ver_qb_official" > qbittorrent.version
            notify "qBittorrent已经升级" "当前官方版本: ${ver_qb_official}\n当前本地版本: ${ver_qb_local}\n已经向 Github Action 触发构建程序"
        }
    else
        echo "qBittorrent官方版本和本地一致，均为：$ver_qb_official"
    fi
fi
