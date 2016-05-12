#!/usr/bin/env bash

yum install gcc gcc-c++ automake unzip -y

#######新建php用户和php组
groupadd -r php
useradd -r -g php -s /bin/false -d /usr/local/php7 -M php

######从GitHub下载php7安装包 install#################
cd /usr/local/src/

if [ ! -f "/usr/local/src/php-7.0.6.tar.gz" ]; then
  wget -c https://github.com/php/php-src/archive/php-7.0.6.tar.gz

fi

tar zxvf php-7.0.6.tar.gz
cd php-src-php-7.0.6
#####安装编译php7时需要的依赖包
yum -y install libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel

# rm -rf php-src-php-7.0.6
# tar zvxf php-7.0.6.tar.gz
# cd php-src-php-7.0.6
./configure \
--prefix=/usr/local/php7 \
--exec-prefix=/usr/local/php7 \
--bindir=/usr/local/php7/bin \
--sbindir=/usr/local/php7/sbin \
--includedir=/usr/local/php7/include \
--libdir=/usr/local/php7/lib/php \
--mandir=/usr/local/php7/php/man \
--with-config-file-path=/usr/local/php7/etc \
--with-apxs2=/usr/local/apache/bin/apxs \
--with-mysql-sock=/var/run/mysql/mysql.sock \
--with-mcrypt=/usr/include \
--with-mhash \
--with-openssl \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
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


make ZEND_EXTRA_LIBS='-liconv'

make install

cp php.ini-production /usr/local/php7/etc/php.ini

cd ..

unlink /usr/local/php
ln -s /usr/local/php7 /usr/local/php

###############php redis extension###############
cd /usr/local/src/

if [ ! -f "/usr/local/src/phpredis-2.2.7.tar.gz" ]; then
    wget -c -O phpredis-2.2.7.tar.gz https://github.com/phpredis/phpredis/archive/2.2.7.tar.gz
fi
tar zxvf phpredis-2.2.7.tar.gz

cd phpredis-2.2.7
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install
sed -i '852 a extension=redis.so' /usr/local/php/etc/php.ini
cd ..


###############php swoole extension###############
cd /usr/local/src/

if [ ! -f "/usr/local/src/swoole-1.8.4-stable.tar.gz" ]; then
    wget -c https://github.com/swoole/swoole-src/archive/swoole-1.8.4-stable.tar.gz
fi

tar zxvf swoole-1.8.4-stable.tar.gz
cd swoole-src-swoole-1.8.4-stable/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install
sed -i '852 a extension=swoole.so' /usr/local/php/etc/php.ini

cd ..



###############php-memcached extension###############
cd /usr/local/src/

if [ ! -f "/usr/local/src/php-memcached-2.2.0.tar.gz" ]; then
    wget -c -O php-memcached-2.2.0.tar.gz https://github.com/php-memcached-dev/php-memcached/archive/2.2.0.tar.gz
fi

tar zvxf php-memcached-2.2.0.tar.gz

cd php-memcached-2.2.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config

make
make install
sed -i '852 a extension=memcached.so' /usr/local/php/etc/php.ini

cd ..