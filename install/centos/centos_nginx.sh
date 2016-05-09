#!/usr/bin/env bash

#######pcre##########
cd /usr/local/src/
yum install gcc gcc-c++ -y
yum install zlib-devel pcre-devel openssl-devel -y

if [ ! -f "/usr/local/src/pcre-8.38.zip" ]; then
  wget http://tenet.dl.sourceforge.net/project/pcre/pcre/8.38/pcre-8.38.zip
fi
rm -rf pcre-8.38
unzip pcre-8.38.zip

#########zlib##########
if [ ! -f "/usr/local/src/zlib-1.2.8.tar.gz" ]; then
  wget http://www.zlib.net/zlib-1.2.8.tar.gz
fi
rm -rf zlib-1.2.8
tar zvxf zlib-1.2.8.tar.gz

#########openssl##########
if [ ! -f "/usr/local/src/openssl-1.0.1t.tar.gz" ]; then
  wget http://www.openssl.org/source/openssl-1.0.1t.tar.gz
fi
rm -rf openssl-1.0.1t
tar zvxf openssl-1.0.1t.tar.gz




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
--with-http_realip_module \
--with-http_sub_module \
--with-http_flv_module \
--with-http_dav_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-http_addition_module \
--with-http_ssl_module \
--with-pcre=/usr/local/src/pcre-8.38 \
--with-openssl=/usr/local/src/openssl-1.0.1t \
--with-zlib=/usr/local/src/zlib-1.2.8

make
make install