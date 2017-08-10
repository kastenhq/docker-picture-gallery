FROM mkodockx/docker-supervisor
MAINTAINER https://m-ko-x.de Markus Kosmal <code@m-ko-x.de>

RUN apt-get update -yqq && \
    apt-get install -yqq wget git unzip nginx fontconfig-config fonts-dejavu-core \
    php5-fpm php5-common php5-json php5-cli php5-common php5-mysql\
    php5-gd php5-json php5-mcrypt php5-readline psmisc ssl-cert \
    ufw php-pear libgd-tools libmcrypt-dev mcrypt mysql-server mysql-client pwgen

ENV DATABASE_NAME pics
ENV DATABASE_USER picuser
ENV DATABASE_SECRET pic_password

ENV PHP_MAX_UPLOAD 1G

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN service mysql start && \
    mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME};" && \
    mysql -uroot -e "CREATE USER '${DATABASE_USER}'@'localhost' IDENTIFIED BY '${DATABASE_SECRET}';" && \
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${DATABASE_USER}'@'localhost' WITH GRANT OPTION;" && \
    mysql -uroot -e "FLUSH PRIVILEGES;"

RUN mkdir /var/lib/mysql_init && \
    mv /var/lib/mysql/* /var/lib/mysql_init

ADD conf/php.ini /etc/php5/fpm/
RUN chown -R www-data:www-data /tmp
RUN php5enmod mcrypt

RUN mkdir /var/www && \
    chown www-data:www-data /var/www && \
    rm /etc/nginx/sites-enabled/* && \
    rm /etc/nginx/sites-available/*

ADD conf/nginx.conf /etc/nginx/
ADD conf/php.conf /etc/nginx/
ADD conf/lychee /etc/nginx/sites-enabled/

WORKDIR /var/www
RUN git clone https://github.com/electerious/Lychee.git lychee

RUN mkdir /var/www/lychee/uploads_init

RUN ln -s /var/www/lychee /var/www/lychee/picture-gallery && \
    chown -R www-data:www-data /var/www/lychee && \
    chmod -R 770 /var/www/lychee && \
    chmod -R 777 /var/www/lychee/uploads && \
    chmod -R 777 /var/www/lychee/data  && \
    chmod -R 777 /var/www/lychee/uploads_init

RUN mv /var/www/lychee/uploads/* /var/www/lychee/uploads_init

#RUN echo $'<?php \
#### \
## @name			Configuration/n \
# @author		Tobias Reich/n \
# @copyright	2014 Tobias Reich/n \
###/n \
#if(!defined('LYCHEE')) exit('Error: Direct access is not allowed!');/n \
# Database configuration/n \
#$dbHost = 'localhost'; # Host of the database/n \
#$dbUser = '${DATABASE_USER}'; # Username of the database/n \
#$dbPassword = '${DATABASE_SECRET}'; # Password of the database/n \
#$dbName = '${DATABASE_NAME}'; # Database name/n \
#$dbTablePrefix = ''; # Table prefix/n \
#?>/n \' > /var/www/lychee/data/config.php

EXPOSE 80

WORKDIR /
RUN ln -s /var/www/lychee/uploads uploads
RUN ln -s /var/www/lychee/data data
RUN ln -s /var/lib/mysql mysql

VOLUME /uploads
VOLUME /data
VOLUME /mysql

ADD conf/startup.conf /etc/supervisor/conf.d/
ADD conf/post_install.sh /root/

RUN chmod +x /root/post_install.sh

RUN echo ${DATABASE_SECRET}

CMD  ["supervisord",  "-c",  "/etc/supervisor/supervisord.conf"]
