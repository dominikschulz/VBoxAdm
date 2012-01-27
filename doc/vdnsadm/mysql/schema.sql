SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

DROP TABLE IF EXISTS `cryptokeys`;
CREATE TABLE IF NOT EXISTS `cryptokeys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) NOT NULL,
  `flags` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `content` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

DROP TABLE IF EXISTS `domainmetadata`;
CREATE TABLE IF NOT EXISTS `domainmetadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) NOT NULL,
  `kind` varchar(16) DEFAULT NULL,
  `content` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

DROP TABLE IF EXISTS `domains`;
CREATE TABLE IF NOT EXISTS `domains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `master` varchar(128) DEFAULT NULL,
  `last_check` int(11) DEFAULT NULL,
  `type` varchar(6) NOT NULL,
  `notified_serial` int(11) DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_index` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

DROP TABLE IF EXISTS `log`;
CREATE TABLE IF NOT EXISTS `log` (
  `ts` datetime NOT NULL,
  `msg` text NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `records`;
CREATE TABLE IF NOT EXISTS `records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `content` varchar(4096) DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `prio` int(11) DEFAULT NULL,
  `change_date` int(11) DEFAULT NULL,
  `ordername` varchar(255) DEFAULT NULL,
  `auth` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rec_name_index` (`name`),
  KEY `nametype_index` (`name`,`type`),
  KEY `domain_id` (`domain_id`),
  KEY `orderindex` (`ordername`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

DROP TABLE IF EXISTS `supermasters`;
CREATE TABLE IF NOT EXISTS `supermasters` (
  `ip` varchar(25) NOT NULL,
  `nameserver` varchar(255) NOT NULL,
  `account` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `tsigkeys`;
CREATE TABLE IF NOT EXISTS `tsigkeys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `algorithm` varchar(255) DEFAULT NULL,
  `secret` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `namealgoindex` (`name`,`algorithm`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `domain_id` int(16) NOT NULL,
  `local_part` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_domainadmin` tinyint(1) NOT NULL,
  `is_siteadmin` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`,`local_part`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

ALTER TABLE `records`
  ADD CONSTRAINT `records_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
