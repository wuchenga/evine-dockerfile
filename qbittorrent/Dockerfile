## 修改自：https://github.com/crazy-max/docker-qbittorrent/blob/master/Dockerfile
## 本地构建由buildx-run.sh使用

FROM nevinee/libtorrent-rasterbar:1 AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
       autoconf \
       automake \
       boost-dev \
       build-base \
       libtool \
       qt5-qttools-dev \
    && rm -rf /tmp/* /var/cache/apk/*
ARG QBITTORRENT_VERSION
COPY qBittorrent-${QBITTORRENT_VERSION} /tmp/qBittorrent
RUN cd /tmp/qBittorrent \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=17 \
        -DSTACKTRACE=OFF \
        -DDBUS=OFF \
        -DGUI=OFF \
        -B release \
        -G Ninja \
    && cd release \
    && ninja -j 1 \
    && ninja install \
    && ls -al /usr/local/bin/ \
    && qbittorrent-nox --help
RUN echo "Copy to /out" \
    && strip /usr/local/lib/libtorrent-rasterbar.so.* \
    && strip /usr/local/bin/qbittorrent-nox \
    && mkdir /out \
    && mkdir -p /out/usr/lib \
    && mkdir -p /out/usr/bin \
    && cp -d /usr/local/lib/libtorrent-rasterbar.so* /out/usr/lib \
    && cp /usr/local/bin/qbittorrent-nox /out/usr/bin

FROM alpine
ENV QBITTORRENT_HOME="/home/qbittorrent" \
    TZ="Asia/Shanghai" \
    PUID="1500" \
    PGID="1500" \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ "
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
       curl \
       openssl \
       qt5-qtbase \
       shadow \
       tzdata \
       jq \
       bash \
       s6-overlay \
    && rm -rf /tmp/* /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -U -m -d ${QBITTORRENT_HOME} -s /bin/bash
COPY --from=builder /out /
COPY s6-overlay /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["/init"]
