CREATE TABLE `card_log` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `uid` bigint(20) unsigned NOT NULL default '0',
  `card` tinyint(3) unsigned NOT NULL default '0',
  `dateline` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `ukey` (`uid`)
) ENGINE=InnoDB