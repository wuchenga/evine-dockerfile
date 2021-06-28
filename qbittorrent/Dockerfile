## 修改自：https://github.com/crazy-max/docker-qbittorrent/blob/master/Dockerfile

FROM alpine AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
       autoconf \
       automake \
       boost-dev \
       build-base \
       cppunit-dev \
       libtool \
       ncurses-dev \
       qt5-qttools-dev \
    && rm -rf /tmp/* /var/cache/apk/*
ARG QBITTORRENT_VERSION
COPY qBittorrent-${QBITTORRENT_VERSION} /tmp/qBittorrent
RUN cd /tmp/qBittorrent \
    && ls -al \
    && ./configure --disable-gui \
    && make -j$(nproc) \
    && make install \
    && ls -al /usr/local/bin/ \
    && qbittorrent-nox --help

FROM alpine
ARG LIBTORRENT_VERSION
COPY --from=nevinee/libtorrent-rasterbar:${LIBTORRENT_VERSION} /usr/lib/libtorrent-rasterbar.so.10 /usr/lib/libtorrent-rasterbar.so.10
COPY --from=builder /usr/local/bin/qbittorrent-nox /usr/bin/qbittorrent-nox
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
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -U -m -d ${QBITTORRENT_HOME} -s /bin/bash
COPY s6-overlay /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["/init"]
