#!/usr/bin/env bash

set -o pipefail

dir_shell=$(cd $(dirname $0); pwd)
dir_myscripts=$(cd $(dirname $0); cd ../../myscripts; pwd)

cd $dir_shell

## 官方版本
ver_lib_official=$(curl -s https://api.github.com/repos/arvidn/libtorrent/tags | jq -r .[]."name" | grep -vi "rc" | grep -m 1 "v1." | sed "s/v//")
ver_lib1_official=$(echo $ver_lib_official | jq -r .[]."name" | grep -vi "rc" | grep -m 1 "v1." | sed "s/v//")
ver_lib2_official=$(echo $ver_lib_official | jq -r .[]."name" | grep -vi "rc" | grep -m 1 "v2." | sed "s/v//")

## 本地版本
ver_lib1_local=$(cat ./1.x.version)
ver_lib2_local=$(cat ./2.x.version)

## 检测官方版本与本地版本是否一致
if [[ $ver_lib1_official ]] && [[ $ver_lib2_official ]]; then
    if [[ $ver_lib1_official != $ver_lib1_local ]] || [[ $ver_lib2_official != $ver_lib2_local ]]; then
        . $dir_myscripts/notify.sh
        . $dir_myscripts/my_config.sh
        curl \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${GITHUB_MIRROR_TOKEN}" \
            -d '{"event_type":"mirror"}' \
            https://api.github.com/repos/nevinen/dockerfiles/dispatches
        notify "libtorrent已经升级" "当前官方版本信息如下：\nlibtorrent 1.x: ${ver_lib1_official}\nlibtorrent 2.x: ${ver_lib2_official}\n\m当前本地版本信息如下：\nlibtorrent 1.x: ${ver_lib1_local}\nlibtorrent 2.x: ${ver_lib2_local}"
    fi
fi
