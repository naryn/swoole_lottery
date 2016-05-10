#!/usr/bin/env bash

#######install apache##########

#http://httpd.apache.org/download.cgi

cd /usr/local/src/

if [ ! -f "/usr/local/src/apr-1.5.2.tar.gz" ]; then
  wget -O apr-1.5.2.tar.gz https://github.com/apache/apr/archive/1.5.2.tar.gz
fi
tar zvxf apr-1.5.2.tar.gz
cd apr-1.5.2
./configure --prefix=/usr/local/apr
make
make install


if [ ! -f "/usr/local/src/apr-util-1.5.4.tar.gz" ]; then
  wget -O apr-util-1.5.4.tar.gz https://github.com/apache/apr-util/archive/1.5.4.tar.gz
fi
tar zvxf apr-util-1.5.4.tar.gz
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util
make
make install


if [ ! -f "/usr/local/src/httpd-2.4.20.tar.gz" ]; then
  wget http://apache.fayea.com//httpd/httpd-2.4.20.tar.gz
fi
rm -rf httpd-2.4.20
tar -zvxf httpd-2.4.20.tar.gz
cd httpd-2.4.20
yum install gcc gcc-c++ -y


./configure \
--prefix=/application/apache2.4.20 \
--enable-deflate \
--enable-expires \
--enable-headers \
--enable-so \
--enable-modules=most \
--with-mpm=worker \
--enable-rewrite \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util/

make
make install
ln -s /usr/local/apache2.4.20 /usr/local/apache
sudo /usr/local/apache/bin/httpd -k start