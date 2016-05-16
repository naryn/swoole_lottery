<?php
$memcached = [
    'servers' => [
        [
            'host' => "127.0.0.1",//127.0.0.1
            'port' => 11211,
            'weight' => 1,
        ]
    ],
    'timeout' => 1,
    'retry' => 1,
];
return $memcached;