FROM wordpress:php7.4-fpm-alpine

RUN apk add -U --no-cache icu-dev \
    && rm -rf /var/cache/apk/* \
    && pecl install redis \
    && docker-php-ext-install -j$(nproc) intl pdo pdo_mysql redis
