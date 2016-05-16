#!/usr/bin/env bash

#自检启动守护程序

checkHttpd=`pgrep httpd`
checkNginx=`pgrep nginx`
checkRedis=`pgrep redis`
checkMysql=`pgrep mysql`
checkAppServer=`pgrep app_server9501`

while :
do
    date=$(date +"%Y-%m-%d %H:%M:%S")
        if [ -n "$checkMysql" ]; then
                echo 'mysql normal' >/dev/null 2>&1
        else
                /usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/my.cnf&
                echo 'checked error: mysqld at ' $date >> /root/server_error.log
                #send mail
        fi

        if [ -n "$checkNginx" ]; then
                echo 'nginx normal' >/dev/null 2>&1
        else
                /usr/local/nginx/sbin/nginx
                echo 'checked error: nginx at ' $date >> /root/server_error.log
                #send mail
        fi

        #if [ -n "$checkHttpd" ]; then
        #        echo 'httpd normal' >/dev/null 2>&1
        #else
        #        /usr/local/apache/bin/apachectl start
        #        echo 'checked error: httpd at ' $date >> /root/server_error.log
                #send mail
        #fi

        if [ -n "$checkRedis" ]; then
                echo 'Redis normal' >/dev/null 2>&1
        else
                /usr/local/redis/bin/redis-server /usr/local/redis/redis.conf&
                echo 'checked error: redis at ' $date >> /root/server_error.log
                #send mail
        fi

        if [ -n "$checkAppServer" ]; then
                echo 'checkAppServer normal' >/dev/null 2>&1
        else
                /usr/local/apache/bin/apachectl start
                echo 'checked error: AppServer at ' $date >> /root/server_error.log
                #send mail
        fi

        #休眠
        sleep 5
done