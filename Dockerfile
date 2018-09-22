FROM alpine:latest
LABEL Maintainer="yongze.chen <sapphire.php@gmail.com>" \
      Description="Lightweight container with Nginx 1.14 & PHP-FPM 7.2 based on Alpine Linux."

RUN apk --no-cache add nginx supervisor curl

#RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories \
#&& echo "http://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
#&& echo "http://nl.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories \
#&& echo "nameserver 8.8.8.8" >> /etc/resolv.conf && apk update && apk upgrade

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype \
    php7-mbstring php7-gd

RUN ln -fs /usr/bin/php7 /usr/bin/php \
&& rm -rf /var/cache/apk/ && mkdir /var/cache/apk && rm -rf /tmp/*

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories \
&& echo "http://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
&& echo "http://nl.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories \
&& echo "nameserver 8.8.8.8" >> /etc/resolv.conf && apk update && apk upgrade

RUN apk --no-cache php7-redis php7-xdebug php7-amqp php7-xhprof php7-rdkafka php7-fileinfo php7-mongodb

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
COPY src/ /var/www/html/

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
