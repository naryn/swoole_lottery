#!/usr/bin/env bash

#######install mysql##########
groupadd mysql
useradd -r -g mysql mysql

cd /usr/local/
wget http://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz
tar zvxf mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz
ln -s mysql-5.6.30-linux-glibc2.5-x86_64 mysql

cd mysql
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