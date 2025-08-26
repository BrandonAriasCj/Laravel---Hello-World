FROM php:8.2-fpm

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libonig-dev libxml2-dev zip curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el código
WORKDIR /var/www
COPY . .

# Instala dependencias PHP y JS, y compila assets
RUN composer install --no-dev --optimize-autoloader
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install && npm run build

# Permisos
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expone el puerto
EXPOSE 8080

# Comando de arranque
CMD php artisan serve --host 0.0.0.0 --port 8080