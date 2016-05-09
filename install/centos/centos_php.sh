#!/usr/bin/env bash

#######install php##########
cd /usr/local/src/
yum install unzip -y

#######新建php用户和php组
groupadd -r php && useradd -r -g php -s /bin/false -d /usr/local/php7 -M php
######从GitHub下载php7安装包
wget -c --no-check-certificate -O php7-src-master.zip https://github.com/php/php-src/archive/master.zip
######开始解压php7包
unzip -q php7-src-master.zip && cd php-src-master
#####安装编译php7时需要的依赖包
yum -y install libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel


./configure
--prefix=/usr/local/php7 \
--exec-prefix=/usr/local/php7 \
--bindir=/usr/local/php7/bin \
--sbindir=/usr/local/php7/sbin \
--includedir=/usr/local/php7/include \
--libdir=/usr/local/php7/lib/php \
--mandir=/usr/local/php7/php/man \
--with-config-file-path=/usr/local/php7/etc \
--with-mysql-sock=/var/run/mysql/mysql.sock \
--with-mcrypt=/usr/include \
--with-mhash \
--with-openssl \
--with-mysql=shared,mysqlnd \
--with-mysqli=shared,mysqlnd \
--with-pdo-mysql=shared,mysqlnd \
--with-gd \
--with-iconv \
--with-zlib \
--enable-zip \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-xml \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-mbregex \
--enable-mbstring \
--enable-ftp \
--enable-gd-native-ttf \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-soap \
--without-pear \
--with-gettext \
--enable-session \
--with-curl \
--with-jpeg-dir \
--with-freetype-dir \
--enable-opcache \
--enable-fpm \
--enable-fastcgi \
--with-fpm-user=php \
--with-fpm-group=php \
--without-gdbm \
--disable-fileinfo


make && make install
