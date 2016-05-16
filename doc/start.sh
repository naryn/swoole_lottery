#!/usr/bin/env bash

#start mysql
/usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/my.cnf&

#start nginx
/usr/local/nginx/sbin/nginx

#start redis
/usr/local/redis/bin/redis-server /usr/local/redis/redis.conf&

#start memcached
/usr/local/memcached/bin/memcached -d -m 60 -p 11211 -u root&

#start app_server

/usr/local/php/bin/php /web/swoole_lottery/bin/app_server9501.php start
/usr/local/php/bin/php /web/swoole_lottery/bin/app_server9502.php start

/web/swoole_lottery/bin/deamon.sh&
