#!/usr/bin/env bash

#######install apache##########
yum install gcc gcc-c++ autoconf libtool -y

#http://httpd.apache.org/download.cgi


################apr#######################
cd /usr/local/src/

if [ ! -f "/usr/local/src/apr-1.5.2.tar.gz" ]; then
  wget -O apr-1.5.2.tar.gz https://github.com/apache/apr/archive/1.5.2.tar.gz
fi
rm -rf apr-1.5.2
tar zvxf apr-1.5.2.tar.gz
cd apr-1.5.2

./buildconf
CFLAGS="-fprofile-arcs -ftest-coverage" ./configure --prefix=/usr/local/apr
make
cd test
make
./testall
cd ..
make install

################apr-util#######################
cd /usr/local/src/
if [ ! -f "/usr/local/src/apr-util-1.5.4.tar.gz" ]; then
  wget -O apr-util-1.5.4.tar.gz https://github.com/apache/apr-util/archive/1.5.4.tar.gz
fi
rm -rf apr-util-1.5.4
tar zvxf apr-util-1.5.4.tar.gz
cd apr-util-1.5.4
./buildconf --with-apr=../apr-1.5.2
CFLAGS="-fprofile-arcs -ftest-coverage" ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make
cd test
make
./testall
cd ..
make install



################apache#######################
cd /usr/local/src/
if [ ! -f "/usr/local/src/httpd-2.4.20.tar.gz" ]; then
  wget http://apache.fayea.com/httpd/httpd-2.4.20.tar.gz
fi
rm -rf httpd-2.4.20
tar -zvxf httpd-2.4.20.tar.gz
cd httpd-2.4.20


./configure \
--prefix=/usr/local/apache2.4.20 \
--enable-deflate \
--enable-expires \
--enable-headers \
--enable-so \
--enable-modules=most \
--with-mpm=worker \
--enable-rewrite \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util

make
make install
unlink /usr/local/apache
ln -s /usr/local/apache2.4.20 /usr/local/apache
#httpd.conf
#/usr/local/apache/bin/httpd -k start


#<IfModule mod_php7.c>
#  php_value include_path ".:/usr/local/lib/php"
#  php_admin_flag engine on
#</IfModule>

#LoadModule php7_module modules/libphp7.so


#<FilesMatch "\.ph(p[2-7]?|tml)$">
#    SetHandler application/x-httpd-php
#</FilesMatch>