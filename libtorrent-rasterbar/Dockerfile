FROM alpine AS builder
ARG LIBTORRENT_VERSION
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
       autoconf \
       automake \
       boost-dev \
       build-base \
       cppunit-dev \
       libtool \
       linux-headers \
       ncurses-dev \
       openssl-dev \
       zlib-dev \
    && rm -rf /tmp/* /var/cache/apk/*
COPY libtorrent-${LIBTORRENT_VERSION} /tmp/libtorrent
RUN cd /tmp/libtorrent \
    && ls -al \
    && ./autotool.sh \
    && ./configure CXXFLAGS="-std=c++17" --with-libiconv \
    && make -j$(nproc) \
    && make install-strip \
    && ls -al /usr/local/lib/

FROM scratch
COPY --from=builder /usr/local/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/libtorrent-rasterbar.so.10
