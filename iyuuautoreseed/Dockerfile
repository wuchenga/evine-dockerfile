## 修改自：https://github.com/ledccn/IYUUAutoReseed

FROM alpine
ARG TIMEZONE=Asia/Shanghai
ENV APP_ENV=prod \
    LANG=zh_CN.UTF-8 \
    PS1="\u@\h:\w \$ "
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
       s6-overlay \
       bash \
       git \
       tzdata \
       php7 \
       php7-curl \
       php7-dom \
       php7-json \
       php7-mbstring \
       php7-simplexml \
       php7-zip \
       php7-xml \
    && echo "upload_max_filesize=100M\npost_max_size=108M\nmemory_limit=1024M\ndate.timezone=${TIMEZONE}" > /etc/php7/conf.d/99-overrides.ini \
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && rm -rf \
       /var/cache/apk/* \
       /tmp/* \
       /usr/share/man \
       /usr/share/php7
COPY s6-overlay /
WORKDIR /iyuu
VOLUME /iyuu
ENTRYPOINT ["/init"]