FROM php:8.2-fpm

# Instala extensiones necesarias (incluye PostgreSQL)
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libonig-dev libxml2-dev zip curl \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql pdo_mysql mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Instala dependencias PHP y JS, y compila assets
RUN composer install --no-dev --optimize-autoloader
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install && npm run build

# Optimiza Laravel y ejecuta tareas necesarias
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache
RUN php artisan migrate --force || true
RUN php artisan storage:link || true

# Permisos
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8080

CMD php artisan serve --host 0.0.0.0 --port 8080