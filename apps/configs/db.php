<?php
$db['master'] = array(
    'type'       => Swoole\Database::TYPE_MYSQLi,
    'host'       => "192.168.51.129",
    'port'       => 3306,
    'dbms'       => 'mysql',
    'engine'     => 'InnoDB',
    'user'       => "root",
    'passwd'     => "123456",//12qwasde34rf
    'name'       => "test",
    'charset'    => "utf8",
    'setname'    => true,
    'persistent' => false, //MySQL长连接
);

$db['huya'] = array(
    'type'       => Swoole\Database::TYPE_MYSQLi,
    'host'       => "172.19.104.157",
    'port'       => 3306,
    'dbms'       => 'mysql',
    'engine'     => 'MyISAM',
    'user'       => "root",
    'passwd'     => "root",
    'name'       => "live",
    'charset'    => "utf8",
    'setname'    => true,
    'persistent' => false, //MySQL长连接
);

return $db;