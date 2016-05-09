<?php
/**
 * Created by PhpStorm.
 * User: Cnr
 * Date: 16-5-9
 * Time: 上午8:32
 */

namespace App\Controller;

use Swoole;

class card extends Swoole\Controller
{
    protected $uid;

    protected $card = [
        'a', 'b', 'c', 'd', 'e'
    ];

    protected $hdConfig = [
        'start'         => 1462723200,//'20160509',
        'end'           => 1463501800,//'20160518',
        'ip_limit'      => 25,
        'ip_limit_time' => 60,
    ];

    protected $cardConfig = [
        'a' => [
            'total' => 10000,
            'day'   => [500, 500, 500, 500, 500, 500, 500, 500, 6000]
        ],
        'b' => [
            'total' => 1000000,
            'avg'   => 111111
        ],
        'c' => [
            'total' => 1000000,
            'avg'   => 111111
        ],
        'd' => [
            'total' => 1000000,
            'avg'   => 111111
        ],
        'e' => [
            'total' => 1000000,
            'avg'   => 111111
        ]
    ];

    public function test()
    {
        $config = array(
            'host' => '127.0.0.1',
            'user' => 'root',
            'password' => '123456',
            'database' => 'test',
        );

        $uid = '2';
        $card = 'b';
        $dateline = time();

        $pool = new Swoole\Async\MySQL($config, 100);

        $pool->query("INSERT INTO `card_log` (`uid`, `card`, `dateline`) VALUES ($uid,$card,$dateline)", function () {
            var_dump(time());
        });

        return $this->showTrace(true);
    }

    public function get()
    {
        $this->http->header('Content-Type', 'text/html; charset=UTF-8');
        $this->uid = isset($this->swoole->request->get['uid']) ? intval($this->swoole->request->get['uid']) : 0;

        $now = time();
        if($now < $this->hdConfig['start'] || $now > $this->hdConfig['end']){
            return $this->json([], 101, '活动已经结束');
        }

        if($this->uid <= 0){
            return $this->json([], 101, 'uid == 0');
        }

        //ip 频率限制 直接返回没中奖
        $ip = Swoole\Tool::getIp();
        if($this->restrictionRules($ip, $this->hdConfig['ip_limit'], $this->hdConfig['ip_limit_time'])){
            return $this->json([], 100, '');
        }

        //是否中奖
        $getCard = $this->__lottery();
        if(!$getCard){
            return $this->json([], 100, '没中奖');
        }

        $surplus = $this->_cardNum($getCard);

        /**
         * 卡片没有库存
         */
        if(!$surplus){
            return $this->json([], 100, '没中奖');
        }

        return $this->json(['card' => $getCard], 100, '你获得了一张' . $getCard);
    }

    /**
     * 计算是否中奖,返回中奖卡片
     */
    private function __lottery()
    {
        $num = 1;
        if($num > 2){
            return FALSE;
        }

        $max = 0;
        foreach($this->cardConfig as $card){
            $max += $card['total'];
        }
        $num = rand(0, $max);

        $tmp = 0;
        foreach($this->cardConfig as $type => $card){
            $tmp = $card['total'] + $tmp;
            if($num <= $tmp){
                return $type;
            }
        }
        return FALSE;
    }

    /**
     * 计算卡片剩余量
     * @param $card
     */
    private function _cardNum($card)
    {
        if(!isset($this->cardConfig[$card])){
            return FALSE;
        }

        $sold = $this->redis->incr(date('m-d') . 'card_' . $card);

        //天数量限制
        if(isset($this->cardConfig[$card]['day'])){
            //第几天
            $num = intval((time() - $this->hdConfig['start']) / 86400);
            $dayLimit = $this->cardConfig[$card]['day'];

            if($dayLimit[$num] && $sold < $dayLimit[$num]){
                $this->redis->incr(date('m-d') . 'putout_card_' . $card);
                $this->_aSynMysql($this->uid, $card, time());
                return $card;
            }
        } elseif(isset($this->cardConfig[$card]['avg'])){
            if($sold < $this->cardConfig[$card]['avg']){
                $this->redis->incr(date('m-d') . 'putout_card_' . $card);
                $this->_aSynMysql($this->uid, $card, time());
                return $card;
            }
        }

        return FALSE;
    }

    private function _aSynMysql($uid, $card, $dateline)
    {
        static $pool;

        if(!$pool){
            $config = array(
                'host' => $this->config['db']['master']['host'],
                'user' => $this->config['db']['master']['user'],
                'password' => $this->config['db']['master']['passwd'],
                'database' => $this->config['db']['master']['name'],
            );

            $pool = new Swoole\Async\MySQL($config, 100);
        }
        $pool->query("INSERT INTO `card_log` (`uid`, `card`, `dateline`) VALUES ($uid,$card,$dateline)", function () {
            return TRUE;
        });
    }

    public function select()
    {
        $uid = isset($this->swoole->request->get['uid']) ? intval($this->swoole->request->get['uid']) : 0;

        $apt = new Swoole\SelectDB($this->db);
        $apt->from('card_log');
        $apt->equal('uid', $uid);
        $res = $apt->getall();
        return $this->json($res);
    }

    public function putOutInfo()
    {
        $res = ['total' => 0];
        $c = [];
        $start = $this->hdConfig['start'];

        while($start < $this->hdConfig['end']){
            $day = date('m-d', $start);
            foreach($this->cardConfig as $cd => $v){
                $num = intval($this->redis->get(date('m-d', $start) . 'putout_card_' . $cd));
                $res[$day][$cd] = $num;

                $t = isset($c[$cd]) ? intval($c[$cd]) : 0;
                $c[$cd] = $t + $num;
                //$res[$day.'key'][]= $day . 'putout_card_' . $cd;
            }
            $start += 86400;
        }

        $res['total'] = $c;
        return $this->json($res, 100, '发放结果');

    }

    /**
     * 是否限制提交
     * @param     $ip
     * @param int $limit
     * @param int $deadline
     * @return bool|string
     */
    public function restrictionRules($ip, $limit = 20, $deadline = 60)
    {
        $key = sprintf("xz_%s", $ip);
        $params = [$key, $deadline];

        $rs = $this->redis->eval(
            'local current
             current = redis.call("incr",KEYS[1])
             if tonumber(current) == 1 then
             redis.call("expire",KEYS[1],KEYS[2])
             end
             return tonumber(current)',
            $params,
            count($params)
        );

        if($rs > $limit){
            return sprintf("%s分钟只能提交%s条，歇会再来哦~", $deadline / 60, $limit);
        }
        return FALSE;
    }
}