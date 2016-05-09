#!/usr/bin/env bash

#######install nginx##########
cd /usr/local/src/
yum install gcc gcc-c++ -y
yum install zlib-devel pcre-devel openssl-devel -y

if [ ! -f "/usr/local/src/nginx-1.10.0.tar.gz" ]; then
  wget http://nginx.org/download/nginx-1.10.0.tar.gz
fi

tar zvxf nginx-1.10.0.tar.gz
cd nginx-1.10.0

groupadd nginx
useradd -r -g nginx nginx

./configure \
  --prefix=/usr/local/nginx \
  --pid-path=/usr/local/nginx \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-pcre=/usr/lib/ \
  --with-zlib=/usr/lib

make
make install