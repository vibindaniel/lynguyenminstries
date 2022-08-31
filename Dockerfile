FROM wordpress:fpm-alpine

RUN apk add -U --no-cache icu-dev &&\
  rm -rf /var/cache/apk/* &&\
  docker-php-ext-install -j$(nproc) intl pdo pdo_mysql
