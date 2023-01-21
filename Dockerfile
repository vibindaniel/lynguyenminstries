FROM wordpress:php7.4-fpm-alpine

RUN apk add -U --no-cache icu-dev build-base autoconf \
  && rm -rf /var/cache/apk/* \
  && docker-php-ext-install -j$(nproc) intl pdo pdo_mysql \
  && pecl install redis \
  && docker-php-ext-enable redis
