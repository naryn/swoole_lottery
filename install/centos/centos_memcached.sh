#!/usr/bin/env bash

yum install autoconf automake -y

cd /usr/local/src/
if [ ! -f "/usr/local/src/memcached-1.4.25.tar.gz" ]; then
  wget -c -O libevent-2.0.20-stable.tar.gz https://github.com/downloads/libevent/libevent/libevent-2.0.20-stable.tar.gz
fi

tar zxvf libevent-2.0.20-stable.tar.gz
cd libevent-2.0.20-stable
./configure --prefix=/usr/local/libevent
make
make install
#yum install libevent-devel.x86_64 -y

cd /usr/local/src/
if [ ! -f "/usr/local/src/memcached-1.4.25.tar.gz" ]; then
  wget -O memcached-1.4.25.tar.gz https://github.com/memcached/memcached/archive/1.4.25.tar.gz
fi


tar zxvf memcached-1.4.25.tar.gz

cd memcached-1.4.25
./configure --prefix=/usr/local/memcached --with-libevent=/usr/local/libevent
make
make test
make install

/usr/local/memcached/bin/memcached -d -m 100 -p 11211 -u root

