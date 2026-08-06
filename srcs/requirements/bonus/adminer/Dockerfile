FROM debian:bookworm

RUN apt update -y && apt install -y curl php-fpm php-mysqli

RUN mkdir -p /run/php && chown www-data:www-data /run/php

WORKDIR /var/www/html

RUN curl -L -o index.php https://www.adminer.org/latest.php

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]