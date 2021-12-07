FROM php:7.4-fpm AS base
RUN apt update \
    && apt install -y \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        curl \
        zip \
        unzip
RUN docker-php-ext-install pdo_mysql
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www
COPY composer.json composer.lock ./

# develop stage
FROM base AS develop-stage
COPY . .
CMD composer install && \
    php artisan migrate && \
    php artisan serve --host 0.0.0.0 --port 8000

# production stage
FROM base AS production-stage
RUN composer install --ignore-platform-reqs --prefer-dist --no-scripts --no-progress --no-interaction --no-dev --no-autoloader
COPY . .
EXPOSE 9000
CMD php artisan optimize \
    && php-fpm
