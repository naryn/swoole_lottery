#!/usr/bin/env bash

#######install mysql##########
groupadd mysql
useradd -r -g mysql mysql

cd /usr/local/src/
if [ ! -f "/usr/local/src/mysql-5.6.30.tar.gz" ]; then
  wget https://github.com/mysql/mysql-server/archive/mysql-5.6.30.tar.gz
fi

tar zvxf mysql-5.6.30.tar.gz
cp -f mysql-5.6.30 /usr/local/mysql

cd /usr/local/mysql
chown -R mysql .
chgrp -R mysql .
scripts/mysql_install_db --user=mysql

chown -R root .
chown -R mysql data
cp support-files/my-medium.cnf /etc/my.cnf

cp support-files/mysql.server /etc/init.d/mysqld
#chkconfig --list mysqld
service mysqld start
netstat -anp|grep mysqld