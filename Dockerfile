FROM php:8.2-fpm

# Instalar extensões do PHP e outras dependências
RUN apt-get update && apt-get install -y \
    sudo \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath

#ARG XDEBUG_VERSION=3.2.2
#RUN pecl install -o -f xdebug-$XDEBUG_VERSION \
#    && docker-php-ext-enable xdebug \
#    && echo "xdebug.client_port=9001" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
#    && echo "xdebug.mode=debug" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
#    && echo "xdebug.discover_client_host=0" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
#    && echo "xdebug.client_host=host.docker.internal" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
#    && echo "xdebug.start_with_request=yes" >> "$PHP_INI_DIR/conf.d/xdebug.ini" \
#    && echo "xdebug.log=/var/www/laravel/storage/logs/xdebug.log" >> "$PHP_INI_DIR/conf.d/xdebug.ini"

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar arquivos do projeto
WORKDIR /var/www/app
COPY . .

EXPOSE 9000
CMD ["php-fpm"]
