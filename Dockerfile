# Use the latest version of Alpine
FROM alpine:latest
LABEL maintainer="Netstack GmbH <info@netstack.de>"

# Set environment variables
ENV PHP_VERSION=85

# install curl
RUN apk add curl

RUN echo "https://pkg.henderkes.com/api/packages/${PHP_VERSION}/alpine/main/php-zts" | tee -a /etc/apk/repositories
RUN KEYFILE=$(curl -sJOw '%{filename_effective}' https://pkg.henderkes.com/api/packages/${PHP_VERSION}/alpine/key) && mv ${KEYFILE} /etc/apk/keys/
RUN apk update

# Install dependencies and PHP 8.2 with Nginx and Docker for docker in docker builds 
RUN apk add --no-cache \
    nginx \
    bash \
    curl \
    git \
    frankenphp \
    php-zts-fpm \
    php-zts-fileinfo \
    php-zts-mysqli \
    php-zts-ctype \
    php-zts-curl \
    php-zts-dom \
    php-zts-mbstring \
    php-zts-xml \
    php-zts-intl \
    php-zts-xmlwriter \
    php-zts-xmlreader \
    php-zts-simplexml \
    php-zts-tokenizer \
    php-zts-pcntl \
    php-zts-pdo \
    php-zts-pdo_mysql \
    php-zts-pdo_sqlite \
    php-zts-phar \
    php-zts-zip \
    php-zts-openssl \
    php-zts-gd \
    php-zts-iconv \
    php-zts-session \
    php-zts-zlib \
    php-zts-exif \
    php-zts-ftp \
    php-zts-bcmath \
    php-zts-sockets \
    mariadb-connector-c \
    nodejs \
    npm \
    docker

RUN php --version

# Remove default server definition from Nginx to avoid conflicts
RUN rm /etc/nginx/http.d/default.conf

# Copy custom Nginx configuration (if you have one)
COPY nginx.conf /etc/nginx/http.d/default.conf

# Configure PHP-FPM to run as the same user as Nginx
RUN sed -i 's/user = nobody/user = nginx/g' /etc/php-zts/fpm.d/www.conf \
    && sed -i 's/group = nobody/group = nginx/g' /etc/php-zts/fpm.d/www.conf \
    && sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-zts/fpm.d/www.conf \
    && sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-zts/fpm.d/www.conf

# Create directory for Nginx
RUN mkdir -p /run/nginx

# Create a directory for your web application
RUN mkdir -p /var/www/html

# Set permissions for the web application
RUN chown -R nginx:nginx /var/www/html

WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


CMD ["/bin/bash"]
