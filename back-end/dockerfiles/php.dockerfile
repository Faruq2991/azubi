FROM composer:2 AS build

ARG UID=1000
ARG GID=1000
ARG USER=app

ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}

WORKDIR /app

# Install required PHP extensions for composer install
RUN apk add --no-cache libpng libpng-dev jpeg-dev
RUN docker-php-ext-configure gd --enable-gd --with-jpeg
RUN docker-php-ext-install gd exif

# Copy backend source and install dependencies without dev
COPY . /app
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Create a non-root user to own the files
RUN addgroup -g ${GID} -S ${USER}
RUN adduser -G ${USER} -S -D -s /bin/sh -u ${UID} ${USER}

# Set proper ownership for the copied files
RUN chown -R ${USER}:${USER} /app

FROM php:8.3-fpm-alpine3.20

ARG UID=1000
ARG GID=1000
ARG USER=app

ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} -S ${USER}
RUN adduser -G ${USER} -S -D -s /bin/sh -u ${UID} ${USER}

RUN sed -i "s/user = www-data/user = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN apk add --no-cache libpng libpng-dev jpeg-dev
RUN apk add --no-cache netcat-openbsd

RUN docker-php-ext-configure gd --enable-gd --with-jpeg
RUN docker-php-ext-install gd

RUN docker-php-ext-install exif

RUN apk add --no-cache zip libzip-dev
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip

RUN docker-php-ext-install pdo pdo_mysql

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

# Copy app code from build stage
COPY --chown=${USER}:${USER} --from=build /app /var/www/html

RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
  && chown -R ${USER}:${USER} /var/www/html

# Copy and prepare entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]