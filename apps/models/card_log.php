<?php
/**
 * Created by PhpStorm.
 * User: Cnr
 * Date: 16-5-3
 * Time: 下午8:23
 */

namespace App\Model;
use Swoole;

class card_log extends Swoole\Model
{
    /**
     * 表名
     * @var string
     */
    public $table = 'card_log';
}