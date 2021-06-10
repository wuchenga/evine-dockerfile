## 修改自：https://github.com/crazy-max/docker-qbittorrent/blob/master/Dockerfile

ARG LIBTORRENT_VERSION=1.2.13
ARG QBITTORRENT_VERSION=4.3.5

FROM alpine AS builder

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
        autoconf \
        automake \
        binutils \
        boost-dev \
        build-base \
        cppunit-dev \
        git \
        libtool \
        linux-headers \
        ncurses-dev \
        openssl-dev \
        zlib-dev \
    && rm -rf /tmp/* /var/cache/apk/*

ARG LIBTORRENT_VERSION
RUN cd /tmp \
    && git clone --branch v${LIBTORRENT_VERSION} --recurse-submodules https://gitee.com/evine/libtorrent.git \
    && cd libtorrent \
    && ./autotool.sh \
    && ./configure CXXFLAGS="-std=c++14" --with-libiconv \
    && make -j$(nproc) \
    && make install-strip \
    && ls -al /usr/local/lib/

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
        qt5-qtbase \
        qt5-qttools-dev \
    && rm -rf /tmp/* /var/cache/apk/*

ARG QBITTORRENT_VERSION
RUN cd /tmp \
    && git clone --branch release-${QBITTORRENT_VERSION} https://gitee.com/evine/qBittorrent.git \
    && cd qBittorrent \
    && ./configure --disable-gui \
    && make -j$(nproc) \
    && make install \
    && ls -al /usr/local/bin/ \
    && qbittorrent-nox --help

FROM alpine

COPY --from=nevinee/s6-overlay-stage:latest / /
COPY --from=builder /usr/local/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/libtorrent-rasterbar.so.10
COPY --from=builder /usr/local/bin/qbittorrent-nox /usr/bin/qbittorrent-nox

ENV QBITTORRENT_HOME="/home/qbittorrent" \
    TZ="Asia/Shanghai" \
    PUID="1500" \
    PGID="1500" \
    WEBUI_PORT="8080" \
    BT_PORT="34567" \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ "

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk --update --no-cache add \
        bind-tools \
        curl \
        openssl \
        qt5-qtbase \
        shadow \
        tzdata \
        zlib \
        jq \
        bash \
        python3 \
    && rm -rf /tmp/* /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -U -m -d ${QBITTORRENT_HOME} -s /bin/bash \
    && qbittorrent-nox --version

COPY s6-overlay /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["/init"]
