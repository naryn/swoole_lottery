卡片活动说明文档
---------

【背景及需求】
---

1) 活动类型：寻宝（卡片收集）
2) 活动周期：2016年1月1日 - 2016年1月10日
3）5种卡片（A，B，C，D，E），其中卡片 A 总数1万张，1-9日，每日发放 5%，剩下的最后一天发放，其他卡片均 100万张，要求尽量做到每个时段、时间点平均
4）网站正常日PV 2000万，UV 200万，用户每次访问网站都有概率出现卡片，最后收集到5种卡片的，获得奖品。

【系统实现需求】
---
1）逻辑清晰，系统稳定，同时可能简单，语言不限
2）以上述场景为前提，需要综合考虑安全、性能、稳定性、防作弊 等因素，允许对需求进行一些微调
3）不考虑硬件支持情况，但是需要给出大概的系统资源消耗包括，硬盘，内存，带宽 等大概数值（大概数量级即可）


获得卡片策略
---
预计活动数据为平时的2倍,约4000万PV,400万UV,
1.每次进入页面有当前发放卡牌的数量/PV,活动进行10天.
第1-9天（1万*5%+4*100万/10）/4000万 = 10.01%
第10天（1w-4*(1万*5%)+4*100万/10）/4000万 = 10.013%

防刷策略
---
1.uid 平均12秒2次
2.ip 60秒30次


项目代码
---
/web/swoole_lottery/


接口地址
----
获取卡片
1.http://127.0.0.1/card/get?uid=123456

查询我的卡片
2.http://127.0.0.1/card/select?uid=123456

查询发放情况
3.http://127.0.0.1/card/result


服务守护
----
/web/swoole_lottery/bin/deamon.sh


负载分发
---
upstream appServer{
    server 127.0.0.1:9501;
    server 127.0.0.1:9502;
}

DB主从（未配）...
---
