#!/usr/bin/env bash

rm -rf master
rm -rf swoole_lottery-master

yum install wget unzip -y

wget https://codeload.github.com/naryn/swoole_lottery/zip/master
unzip master
unlink swoole_lottery
ln -s  swoole_lottery-master swoole_lottery

chmod +x /web/swoole_lottery/install/centos/*



#docker run -itd -p 9876:80  192.168.62.187:5000/centos:6 /bin/bash
#vi /var/lib/boot2docker/profile


#ubuntu
#/etc/default/docker
