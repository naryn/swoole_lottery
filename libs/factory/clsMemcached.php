<?php
global $php;
$config = $php->config['memcached'];

if (empty($config) or empty($config['servers']))
{
    throw new Exception("require memcached[$php->factory_key] config.");
}
static $Memcached;
if($Memcached){
    return $Memcached;
}
$Memcached = new \Swoole\clsMemcached($config);
return $Memcached;