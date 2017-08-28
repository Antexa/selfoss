FROM alpine:3.6

LABEL description "Multipurpose rss reader, live stream, mashup, aggregation web application" \
      maintainer="Hardware <contact@meshup.net>"

ARG VERSION=2.17
ARG SHA256_HASH="5c880fe79326c0e584be21faeaebe805fac792f2c56b7fd5144584e5137a608d"

ENV GID=991 UID=991 CRON_PERIOD=15m

RUN echo "@community http://nl.alpinelinux.org/alpine/v3.6/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    wget \
    git \
 && apk add \
    musl \
    nginx \
    s6 \
    su-exec \
    libwebp \
    ca-certificates \
    php7@community \
    php7-fpm@community \
    php7-gd@community \
    php7-json@community \
    php7-zlib@community \
    php7-xml@community \
    php7-dom@community \
    php7-curl@community \
    php7-iconv@community \
    php7-mcrypt@community \
    php7-pdo_sqlite@community \
    php7-ctype@community \
    php7-session@community \
    php7-mbstring@community \
    tini@community \
 && sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php7/php.ini \
 && wget -q https://github.com/SSilence/selfoss/releases/download/$VERSION/selfoss-$VERSION.zip -P /tmp \
 && echo "Verifying integrity of selfoss-${VERSION}.zip..." \
 && CHECKSUM=$(sha256sum /tmp/selfoss-$VERSION.zip | awk '{print $1}') \
 && if [ "${CHECKSUM}" != "${SHA256_HASH}" ]; then echo "Warning! Checksum does not match!" && exit 1; fi \
 && echo "All seems good, hash is valid." \
 && mkdir /selfoss && unzip -q /tmp/selfoss-$VERSION.zip -d /selfoss \
 && sed -i -e 's/base_url=/base_url=\//g' /selfoss/defaults.ini \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/* \
 && chown -R $UID:$GID /selfoss /etc/nginx /etc/php7 /var/log /var/lib/nginx /tmp /etc/s6.d

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY s6.d /etc/s6.d
COPY run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/run.sh /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

VOLUME /selfoss/data

EXPOSE 8888

CMD ["run.sh"]
