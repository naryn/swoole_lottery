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
    protected $_asyncMysql = TRUE;//异步mysql 入库
    protected $_iplimit = TRUE;//ip 限制
    protected $_uidlimit = TRUE;//UID 限制

    protected $__huodongPV = 40000000;//估计平时2倍
    protected $__huodongUV = 2000000;//估计平时2倍

    protected $uid;
    protected $dayNum = 0;

    protected $dateCardTypeSold = 'date_c';//每天
    protected $cardTypeSold = 'card_';//总的

    protected $mcDateCard = 'mc_date_c';//mc 每天

    protected $hdConfig = [
        'start'          => 1462723200,//'20160509',
        'end'            => 1463501800,//'20160518',
        'ip_limit'       => 30,
        'ip_limit_time'  => 60,//60秒20次;30=3uid
        'uid_limit'      => 2,
        'uid_limit_time' => 12,//12秒2次
    ];

    protected $cardConfig = [
        'a' => [
            'total'   => 10000,
            'day'     => [500, 500, 500, 500, 500, 500, 500, 500, 500, 5500],
            'allSell' => 10//第10天,发放所有
        ],
        'b' => [
            'total' => 1000000,
            'avg'   => 100000
        ],
        'c' => [
            'total' => 1000000,
            'avg'   => 100000
        ],
        'd' => [
            'total' => 1000000,
            'avg'   => 100000
        ],
        'e' => [
            'total' => 1000000,
            'avg'   => 100000
        ]
    ];

    /**
     * 获取卡片
     * @return string
     */
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

        //uid 频率限制 直接返回没中奖
        if($this->_uidlimit && $this->restrictionRules($this->uid, $this->hdConfig['uid_limit'], $this->hdConfig['uid_limit_time'])){
            return $this->json([], 100, '没中奖~');
        }

        //ip 频率限制 直接返回没中奖
        $ip = Swoole\Tool::getIp();
        if($this->_iplimit && $this->restrictionRules($ip, $this->hdConfig['ip_limit'], $this->hdConfig['ip_limit_time'])){
            return $this->json([], 100, '没中奖~');
        }

        //有可能得到卡片概率
        $cardType = $this->__lottery();
        if(!$cardType){
            return $this->json([], 100, '没中奖');
        }

        //库存判断
        $surplus = $this->_getCard($cardType);
        if(!$surplus){
            return $this->json([], 100, '没中奖!');
        }

        return $this->json(['card' => $cardType], 100, '你获得了一张' . $cardType);
    }

    /**
     * 计算是否中卡片,返回中奖卡片
     */
    private function __lottery()
    {
        $this->dayNum = intval((time() - $this->hdConfig['start']) / 86400);

        $totalNum = 0;
        foreach($this->cardConfig as $card){
            $tmp = isset($card['day']) ? $card['day'][$this->dayNum] : $card['avg'];
            $totalNum += $tmp;
        }
        $mtRand = mt_rand(0, $this->__huodongPV);
        if($mtRand >= $totalNum){
            return FALSE;
        }

        $tmp = 0;
        $mtRand = mt_rand(1, $totalNum);
        foreach($this->cardConfig as $type => $card){
            $cardNum = isset($card['day']) ? $card['day'][$this->dayNum] : $card['avg'];
            $tmp = $cardNum + $tmp;
            if($mtRand <= $tmp){
                return $type;
            }
        }
        return FALSE;
    }


    /**
     * 库存判断
     * @param $card
     * @return bool
     */
    private function _getCard($card)
    {
        if(!isset($this->cardConfig[$card])){
            return FALSE;
        }

        if(isset($this->cardConfig[$card]['day'])){
            $num = $this->cardConfig[$card]['day'];
        } else{
            $num = $this->cardConfig[$card]['avg'];
        }

        //第N天允许发完剩余
        if(isset($this->cardConfig[$card]['allSell']) && $this->dayNum == $this->cardConfig[$card]['allSell']){
            $cardSold = $this->redis->incr($this->cardTypeSold . $card);
            if($this->cardConfig[$card]['total'] >= $cardSold){
                return $this->__update($card, $cardSold);
            } else{
                return FALSE;
            }
        }

        //今天是否超额.
        $todayCardSold = $this->redis->incr($this->dateCardTypeSold . $card);
        if($num >= $todayCardSold){
            $cardSold = $this->redis->incr($this->cardTypeSold . $card);
            return $this->__update($card, $cardSold);
        }
        return FALSE;
    }

    private function __update($card, $cardSold)
    {
        if($this->_asyncMysql){
            $this->_aSynSave($this->uid, $card);
            $this->clsMemcached->set($this->mcDateCard . date('m-d') . $card, $cardSold);
            return TRUE;
        } else{
            $cid = $this->_log($this->uid, $card);
            if($cid){
                $this->clsMemcached->set($this->mcDateCard . date('m-d') . $card, $cardSold);
                return TRUE;
            }
        }
        return FALSE;
    }

    private function _log($uid, $card)
    {
        static $cardLog;
        if(!$cardLog){
            $cardLog = Model('card_log');
        }
        $cardIndex = array_flip(array_keys($this->cardConfig));
        $id = $cardLog->put(array('uid' => intval($uid), 'card' => $cardIndex[$card], 'dateline' => 13));
        return $id;
    }

    /**
     * 主库添加
     * @param $uid
     * @param $card
     */
    private function _aSynSave($uid, $card)
    {
        static $pool;
        $dateline = time();
        if(!$pool){
            $config = array(
                'host'     => $this->config['db']['master']['host'],
                'user'     => $this->config['db']['master']['user'],
                'password' => $this->config['db']['master']['passwd'],
                'database' => $this->config['db']['master']['name'],
            );

            $pool = new Swoole\Async\MySQL($config, 100);
        }
        $cardIndex = array_flip(array_keys($this->cardConfig));

        $pool->query("INSERT INTO `card_log` (`uid`, `card`, `dateline`) VALUES ({$uid},{$cardIndex[$card]},{$dateline})", function () {
            return TRUE;
        });
    }

    /**
     * 查询用户的所有卡片
     * @return string
     */
    public function select()
    {
        $uid = isset($this->swoole->request->get['uid']) ? intval($this->swoole->request->get['uid']) : 0;
        if($uid <= 0){
            return 'error';
        }
        $apt = new Swoole\SelectDB($this->db);//重库查询
        $apt->from('card_log');
        $apt->equal('uid', $uid);
        $res = $apt->getall();

        $result = [];
        $cards = array_keys($this->cardConfig);
        foreach($res as $r){
            if(isset($result[$cards[$r['card']]])){
                $result[$cards[$r['card']]]++;
            } else{
                $result[$cards[$r['card']]] = 1;
            }

        }

        return $this->json($result);
    }

    /**
     *  查看每天发放情况
     * @return string
     */
    public function result()
    {
        $c = [];
        $start = $this->hdConfig['start'];

        while($start < $this->hdConfig['end']){
            $day = date('m-d', $start);
            foreach($this->cardConfig as $cd => $v){
                $num = intval($this->clsMemcached->get($this->mcDateCard . $day . $cd));
                var_dump($this->mcDateCard . $day . $cd);
                $res[$day][$cd] = $num;

                $t = isset($c[$cd]) ? intval($c[$cd]) : 0;
                $c[$cd] = $t + $num;
            }
            $start += 86400;
        }

        $res['total'] = $c;
        return $this->json([], 100, '发放结果');

    }

    /**
     * 是否限制提交
     * @param     $ip
     * @param int $limit
     * @param int $deadline
     * @return bool|string
     */
    protected function restrictionRules($ip, $limit = 20, $deadline = 60)
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