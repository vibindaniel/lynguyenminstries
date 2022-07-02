FROM wordpress:php7.3-fpm-alpine

RUN apk add -U --no-cache icu-dev &&\
  rm -rf /var/cache/apk/* &&\
  docker-php-ext-install -j$(nproc) intl
