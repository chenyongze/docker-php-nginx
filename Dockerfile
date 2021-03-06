# Use Alpine Linux
FROM php:7.2.10-fpm-alpine

LABEL Maintainer="yongze.chen <sapphire.php@gmail.com>" \
      Description="Lightweight container with Nginx 1.14 & PHP-FPM 7.2 based on Alpine Linux."

# Set Timezone Environments
ENV TIMEZONE  Asia/Shanghai

RUN echo -e "https://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttps://mirrors.ustc.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories \
    && apk update \
    &&  apk upgrade
# RUN echo "nameserver 114.114.114.114 \n search DHCP HOST" > /etc/resolv.conf &&  apk update && apk upgrade

# install php start
RUN apk add --update tzdata  \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime  \
    && echo "${TIMEZONE}" > /etc/timezone  \
    && apk del tzdata  \
    && apk add --no-cache --virtual .build-deps \
                 curl \
                 g++ \
                 make \
                 autoconf \
                 openssl-dev  \
                 libaio  \
                 libaio-dev \
                 linux-headers \
                 zlib-dev \
    && apk add --no-cache \
                 bash \
                 openssh \
                 libssl1.0 \
                 libxslt-dev \
                 libjpeg-turbo-dev \
                 libwebp-dev \
                 libpng-dev \
                 libxml2-dev \
                 freetype-dev \
                 libmcrypt \
                 freetds-dev  \
                 libmemcached-dev  \
                 cyrus-sasl-dev  \
    && docker-php-source extract  \
    && docker-php-ext-configure pdo  \
    && docker-php-ext-configure pdo_mysql  \
    && docker-php-ext-configure mysqli  \
    && docker-php-ext-configure opcache  \
    && docker-php-ext-configure exif  \
    && docker-php-ext-configure sockets  \
    && docker-php-ext-configure soap  \
    && docker-php-ext-configure bcmath  \
    && docker-php-ext-configure pcntl  \
    && docker-php-ext-configure sysvsem  \
    && docker-php-ext-configure tokenizer  \
    && docker-php-ext-configure zip  \
    && docker-php-ext-configure xsl  \
    && docker-php-ext-configure shmop  \
    && docker-php-ext-configure gd \
                                --with-jpeg-dir=/usr/include \
                                --with-png-dir=/usr/include \
                                --with-webp-dir=/usr/include \
                                --with-freetype-dir=/usr/include  \
    && pecl install swoole redis xdebug mongodb ampq \
    && pecl clear-cache  \
    && docker-php-ext-enable swoole redis xdebug mongodb \
    && docker-php-ext-install pdo \
                           pdo_mysql \
                           mysqli \
                           opcache \
                           exif \
                           sockets \
                           soap \
                           bcmath \
                           pcntl \
                           sysvsem \
                           tokenizer \
                           zip \
                           xsl \
                           shmop \
                           gd  \
    && docker-php-source delete  \
    && apk del .build-deps  \
    && ln -sf /dev/stdout /usr/local/var/log/php-fpm.access.log  \
    && ln -sf /dev/stderr /usr/local/var/log/php-fpm.error.log  \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer  \
    && curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar  \
    && chmod +x /usr/local/bin/phpunit

#install php end

# Install packages
RUN apk --no-cache add nginx supervisor curl

RUN ln -fs /usr/bin/php7 /usr/bin/php \
&& rm -rf /var/cache/apk/ && mkdir /var/cache/apk && rm -rf /tmp/*

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
# COPY config/php.ini /usr/local/etc/php/php.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
COPY src/ /var/www/html/

EXPOSE 80 443 9000
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]