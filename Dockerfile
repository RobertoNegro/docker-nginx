FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.14-php8

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NGINX_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# install packages
RUN \
  apk add --no-cache --upgrade \
    curl && \
  if [ -z ${NGINX_VERSION+x} ]; then \
    NGINX_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:nginx$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache --upgrade \
    memcached \
    nginx==${NGINX_VERSION} \
    nginx-mod-http-brotli==${NGINX_VERSION} \
    nginx-mod-http-dav-ext==${NGINX_VERSION} \
    nginx-mod-http-echo==${NGINX_VERSION} \
    nginx-mod-http-fancyindex==${NGINX_VERSION} \
    nginx-mod-http-geoip==${NGINX_VERSION} \
    nginx-mod-http-geoip2==${NGINX_VERSION} \
    nginx-mod-http-headers-more==${NGINX_VERSION} \
    nginx-mod-http-image-filter==${NGINX_VERSION} \
    nginx-mod-http-nchan==${NGINX_VERSION} \
    nginx-mod-http-perl==${NGINX_VERSION} \
    nginx-mod-http-redis2==${NGINX_VERSION} \
    nginx-mod-http-set-misc==${NGINX_VERSION} \
    nginx-mod-http-upload-progress==${NGINX_VERSION} \
    nginx-mod-http-xslt-filter==${NGINX_VERSION} \
    nginx-mod-mail==${NGINX_VERSION} \
    nginx-mod-rtmp==${NGINX_VERSION} \
    nginx-mod-stream==${NGINX_VERSION} \
    nginx-mod-stream-geoip==${NGINX_VERSION} \
    nginx-mod-stream-geoip2==${NGINX_VERSION} \
    nginx-vim==${NGINX_VERSION} \
    php8-bcmath \
    php8-bz2 \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-ftp \
    php8-gd \
    php8-gmp \
    php8-iconv \
    php8-imap \
    php8-intl \
    php8-ldap \
    php8-mysqli \
    php8-mysqlnd \
    php8-opcache \
    php8-pdo_mysql \
    php8-pdo_odbc \
    php8-pdo_pgsql \
    php8-pdo_sqlite \
    php8-pear \
    php8-pecl-apcu \
    php8-pecl-mailparse \
    php8-pecl-redis \
    php8-pgsql \
    php8-phar \
    php8-posix \
    php8-soap \
    php8-sockets \
    php8-sodium \
    php8-sqlite3 \
    php8-tokenizer \
    php8-xml \
    php8-xmlreader \
    php8-xsl \
    php8-zip

RUN \
  echo "**** installing imagemagick ****" && \
  apk add --no-cache \
    php8-pecl-imagick \
    imagemagick

RUN \
  echo "**** installing composer ****" && \
  curl -sS https://getcomposer.org/installer | php8 -- --install-dir=/usr/bin --filename=composer

RUN \
  ln -s /usr/bin/php8 /usr/bin/php

RUN \
  echo "**** configure nginx ****" && \
  rm -f /etc/nginx/http.d/default.conf && \
  sed -i \
    's|include /config/nginx/site-confs/\*;|include /config/nginx/site-confs/\*;\n\t#Removed lua. Do not remove this comment|g' \
    /defaults/nginx.conf

# add local files
COPY root/ /
