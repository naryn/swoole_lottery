#!/usr/bin/env bash


cd /usr/local/src/

if [ ! -f "/usr/local/src/redis-3.2.0.tar.gz" ]; then
  wget -c http://download.redis.io/releases/redis-3.2.0.tar.gz
fi

rm -rf redis-3.2.0
tar zvxf redis-3.2.0.tar.gz

cd /usr/local/src/redis-3.2.0

make PREFIX=/usr/local/redis-3.2.0 install

cp redis.conf /usr/local/redis-3.2.0/redis.conf

ln -s /usr/local/redis-3.2.0 /usr/local/redis/

/usr/local/redis-3.2.0/bin/redis-server /usr/local/redis-3.2.0/redis.conf&