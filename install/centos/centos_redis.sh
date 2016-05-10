#!/usr/bin/env bash


cd /usr/local/src/

if [ ! -f "/usr/local/src/redis-3.2.0.tar.gz" ]; then
  wget http://download.redis.io/releases/redis-3.2.0.tar.gz
fi

rm -rf redis-3.2.0
tar zvxf redis-3.2.0.tar.gz

cd /usr/local/src/redis-3.2.0

make PREFIX=/usr/local/redis-3.2.0 install

cp redis.conf /usr/local/redis-3.2.0/redis.conf
