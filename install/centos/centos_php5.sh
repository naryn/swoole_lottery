#!/bin/bash

yum install mod_ssl apr-util-devel apr-devel -y
yum install gcc bison bison-devel zlib-devel libmcrypt-devel mcrypt mhash-devel openssl-devel libxml2-devel libcurl-devel bzip2-devel readline-devel libedit-devel sqlite-devel libxslt-devel libvpx libjpeg libpng libpng-devel zlib libXpm libXpm-devel FreeType t1lib  libt1-devel libwebp libwebp-devel libXpm-devel freetype-devel -y

cd /usr/local/src/

if [ ! -f "php-5.6.16.tar.gz" ]; then
  wget http://cn2.php.net/distributions/php-5.6.16.tar.gz
fi
tar zxf php-5.6.16.tar.gz


if [ ! -f "jpegsrc.v9a.tar.gz" ]; then
  wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz
fi

tar zxf jpegsrc.v9a.tar.gz

cd jpeg-9a
./configure --prefix=/usr/local/jpeg --enable-shared --enable-static
make
make install
cd ../

cd php-5.6.16

./configure --prefix=/usr/local/php5 --with-config-file-path=/usr/local/php --enable-mbstring --enable-ftp --enable-mysqlnd --with-freetype-dir=/usr --enable-gd-native-ttf --with-libxml-dir=/usr --with-xmlrpc --enable-xml --enable-sockets --with-gd --with-zlib --with-iconv --enable-zip --with-freetype-dir=/usr/lib/ --enable-soap --enable-pcntl --enable-cli --with-curl=/usr/local/curl --with-apxs2=/usr/local/apache/bin/apxs --with-jpeg-dir=/usr/local/jpeg

make
make install
cd ../

unlink /usr/local/php
ln -s /usr/local/php5 /usr/local/php

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