## 简介

https://github.com/ledccn/IYUUAutoReseed ，官方提供了Docker镜像的，建议选择官方的镜像。本镜像主要是为了本人使用方便。

## 本镜像创建

```
version: "2.0"
services:
  iyuuautoreseed:
    image: nevinee/iyuuautoreseed
    container_name: iyuuautoreseed
    restart: always
    network_mode: bridge
    hostname: iyuuautoreseed
    volumes:
      - ./userdata:/userdata           # 配置目录
      - ./torrent:/iyuu/torrent        # 辅种缓存目录
    environment:
      - CRON_GIT_PULL=23 6,19 * * *    # 更新脚本的cron
      - CRON_IYUU=51 7,19 * * *        # 辅种程序的cron
```

创建好后编辑`./userdata/config.php`即可，不负责解释一切疑问。

## 构建相关

https://github.com/nevinen/dockerfiles/tree/master/iyuuautoreseed

https://github.com/nevinen/dockerfiles/tree/master/.github/workflows