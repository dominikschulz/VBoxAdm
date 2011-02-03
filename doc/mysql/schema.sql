SET FOREIGN_KEY_CHECKS=0;

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

SET AUTOCOMMIT=0;
START TRANSACTION;

DROP TABLE IF EXISTS `aliases`;
CREATE TABLE IF NOT EXISTS `aliases` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `domain_id` int(16) NOT NULL,
  `local_part` varchar(255) CHARACTER SET latin1 NOT NULL,
  `goto` varchar(255) CHARACTER SET latin1 NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`,`local_part`),
  KEY `active` (`is_active`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `awl`;
CREATE TABLE IF NOT EXISTS `awl` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `last_seen` datetime NOT NULL,
  `disabled` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `domains`;
CREATE TABLE IF NOT EXISTS `domains` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `active` (`is_active`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `domain_aliases`;
CREATE TABLE IF NOT EXISTS `domain_aliases` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `domain_id` int(16) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `active` (`is_active`),
  KEY `domain_id` (`domain_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `log`;
CREATE TABLE IF NOT EXISTS `log` (
  `ts` datetime NOT NULL,
  `msg` text NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `mailboxes`;
CREATE TABLE IF NOT EXISTS `mailboxes` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `domain_id` int(16) NOT NULL,
  `local_part` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `max_msg_size` int(16) NOT NULL,
  `is_on_vacation` tinyint(1) NOT NULL,
  `vacation_subj` varchar(255) NOT NULL,
  `vacation_msg` text NOT NULL,
  `vacation_start` date NOT NULL,
  `vacation_end` date NOT NULL,
  `quota` int(16) NOT NULL,
  `is_domainadmin` tinyint(1) NOT NULL,
  `is_superadmin` tinyint(1) NOT NULL,
  `sa_active` tinyint(1) NOT NULL,
  `sa_kill_score` decimal(5,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`,`local_part`),
  KEY `vacation_duration` (`vacation_start`,`vacation_end`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `rfc_notify`;
CREATE TABLE IF NOT EXISTS `rfc_notify` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `ts` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email` (`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `vacation_blacklist`;
CREATE TABLE IF NOT EXISTS `vacation_blacklist` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `local_part` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_lp` (`domain`,`local_part`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `vacation_notify`;
CREATE TABLE IF NOT EXISTS `vacation_notify` (
  `on_vacation` varchar(255) NOT NULL,
  `notified` varchar(255) NOT NULL,
  `notified_at` datetime NOT NULL,
  PRIMARY KEY (`on_vacation`,`notified`),
  KEY `notified_at` (`notified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `aliases`
  ADD CONSTRAINT `aliases_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `domain_aliases`
  ADD CONSTRAINT `domain_aliases_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `mailboxes`
  ADD CONSTRAINT `mailboxes_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

SET FOREIGN_KEY_CHECKS=1;

COMMIT;
