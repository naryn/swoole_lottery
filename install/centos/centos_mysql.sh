#!/usr/bin/env bash

#######install mysql#########
#http://dev.mysql.com/doc/refman/5.7/en/source-installation.html
groupadd mysql
useradd -r -g mysql mysql

yum install cmake bison-devel ncurses-devel  bison.x86_64  bison-devel.x86_64 -y
cd /usr/local/src/
if [ ! -f "/usr/local/src/mysql-5.6.30.tar.gz" ]; then
  wget https://github.com/mysql/mysql-server/archive/mysql-5.6.30.tar.gz
fi

tar zvxf mysql-5.6.30.tar.gz
cd mysql-server-mysql-5.6.30

#http://dev.mysql.com/doc/refman/5.5/en/source-configuration-options.html
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci

make
make install

chown -R mysql:mysql /usr/local/mysql

cd /usr/local/mysql
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql

#cp support-files/mysql.server /etc/init.d/mysql
#chkconfig mysql on
#service mysql start  --启动MySQL
