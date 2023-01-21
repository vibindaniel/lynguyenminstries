FROM wordpress:php7.4-fpm-alpine

RUN apk add -U --no-cache icu-dev php7-pecl-redis &&\
  rm -rf /var/cache/apk/* &&\
  docker-php-ext-install -j$(nproc) intl pdo pdo_mysql
