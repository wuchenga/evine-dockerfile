FROM alpine
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    CRON="3-53/5 * * * *"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk --no-cache add -f \
       bash \
       curl \
       openssl \
       tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && rm -rf /var/cache/apk/* \
    && echo "$CRON ddns -c /config/config.json" | crontab -
COPY --from=newfuture/ddns:latest /ddns /usr/local/bin/ddns
CMD ["crond", "-f"]
VOLUME ["/config"]
WORKDIR /config
