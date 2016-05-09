<?php
namespace Swoole;

class clsMemcached extends \Memcached
{
    /**
     * memcached扩展采用libmemcache，支持更多特性，更标准通用
     */
    protected $memcached = false;
    protected $cache;
    //启用压缩
    protected $flags = 0;

    const DEFAULT_PORT = 11211;
    const DEFAULT_HOST = '127.0.0.1';

    function __construct($config, $persistent_id = NULL)
    {
        parent::__construct($persistent_id);
        $options = array();
        $options[self::OPT_DISTRIBUTION] = self::DISTRIBUTION_CONSISTENT;
        $timeout = intval($config['timeout']) * 1000;
        $options[self::OPT_CONNECT_TIMEOUT] = $timeout ?: 1000;
        $options[self::OPT_RETRY_TIMEOUT] = intval($config['retry']) ?: 1;
        // $options[self::OPT_COMPRESSION] = TRUE; // default is true
        $this->setOptions($options);

        $servers = array();
        foreach($config['servers'] as $serv){
            $servers[] = array('host' => $serv['host'], 'port' => intval($serv['port']), 'weight' => intval($serv['weight']));
        }
        $this->addServers($servers);
    }

    /**
     * 格式化配置
     * @param $cf
     * @return null
     */
    protected function formatConfig(&$cf)
    {
        if (empty($cf['host']))
        {
            $cf['host'] = self::DEFAULT_HOST;
        }
        if (empty($cf['port']))
        {
            $cf['port'] = self::DEFAULT_PORT;
        }
        if (empty($cf['weight']))
        {
            $cf['weight'] = 1;
        }
        if (empty($cf['persistent']))
        {
            $cf['persistent'] = true;
        }
    }

}

