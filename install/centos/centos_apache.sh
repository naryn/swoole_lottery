#!/usr/bin/env bash

#######install apache##########

#http://httpd.apache.org/download.cgi

cd /usr/local/src/
if [ ! -f "/usr/local/src/httpd-2.4.20.tar.gz" ]; then
  wget http://apache.fayea.com//httpd/httpd-2.4.20.tar.gz
fi

tar -zvxf httpd-2.4.20.tar.gz
cd httpd-2.4.20
yum install gcc gcc-c++ -y
yum install zlib-devel pcre-devel openssl-devel -y

./configure --prefix=/application/apache2.4.20 --enable-deflate --enable-expires --enable-headers --enable-so --enable-modules=most --with-mpm=worker --enable-rewrite
make
sudo make install
ln -s /usr/local/apache2.4.20 /usr/local/apache
sudo /usr/local/apache/bin/httpd -k start