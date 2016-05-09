#!/usr/bin/env bash

#######install pcre##########
cd /usr/local/src/
yum install gcc gcc-c++ -y
yum install zlib-devel pcre-devel openssl-devel -y

if [ ! -f "/usr/local/src/pcre-8.38.zip" ]; then
  wget http://tenet.dl.sourceforge.net/project/pcre/pcre/8.38/pcre-8.38.zip
fi
rm -rf pcre-8.38
unzip pcre-8.38.zip
cd pcre-8.38
./configure

make
make install

#######install nginx##########
cd /usr/local/src/
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
  --with-pcre=/usr/local/pcre-8.38/ \
  --with-zlib=/usr/lib

make
make install