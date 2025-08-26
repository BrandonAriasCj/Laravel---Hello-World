FROM php:8.3-fpm

# Instala dependencias del sistema y extensiones necesarias para Laravel + PostgreSQL
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    zip \
    libpq-dev \
    libonig-dev \
    libxml2-dev \
    curl \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl

# Instala Composer desde la imagen oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .

# Habilita plugin de Laravel para que Composer no falle
RUN composer config --no-plugins allow-plugins.laravel/serializable-closure true

# Instala las dependencias PHP del proyecto
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Abre puerto
EXPOSE 8000

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000