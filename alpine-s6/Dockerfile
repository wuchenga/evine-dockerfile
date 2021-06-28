FROM alpine:latest
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash s6-overlay \
    && rm -rf /var/cache/apk/*
ENTRYPOINT ["/init"]
