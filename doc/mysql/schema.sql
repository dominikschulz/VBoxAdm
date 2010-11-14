-- phpMyAdmin SQL Dump
-- version 3.2.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Erstellungszeit: 06. November 2010 um 23:41
-- Server Version: 5.1.49
-- PHP-Version: 5.3.3-2

SET FOREIGN_KEY_CHECKS=0;

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

SET AUTOCOMMIT=0;
START TRANSACTION;

--
-- Datenbank: `vboxadm`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `aliases`
--
-- Erzeugt am: 06. November 2010 um 23:34
--

DROP TABLE IF EXISTS `aliases`;
CREATE TABLE IF NOT EXISTS `aliases` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `domain_id` int(16) NOT NULL,
  `local_part` varchar(255) NOT NULL,
  `goto` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`,`local_part`),
  KEY `active` (`is_active`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- RELATIONEN DER TABELLE `aliases`:
--   `domain_id`
--       `domains` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `domains`
--
-- Erzeugt am: 06. November 2010 um 23:29
--

DROP TABLE IF EXISTS `domains`;
CREATE TABLE IF NOT EXISTS `domains` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `active` (`is_active`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `domain_aliases`
--
-- Erzeugt am: 06. November 2010 um 23:34
--

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- RELATIONEN DER TABELLE `domain_aliases`:
--   `domain_id`
--       `domains` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `log`
--
-- Erzeugt am: 06. November 2010 um 23:17
-- Aktualisiert am: 06. November 2010 um 23:17
--

DROP TABLE IF EXISTS `log`;
CREATE TABLE IF NOT EXISTS `log` (
  `ts` datetime NOT NULL,
  `msg` text NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mailboxes`
--
-- Erzeugt am: 06. November 2010 um 23:41
--

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
  `quota` int(16) NOT NULL,
  `is_domainadmin` tinyint(1) NOT NULL,
  `is_superadmin` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`,`local_part`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- RELATIONEN DER TABELLE `mailboxes`:
--   `domain_id`
--       `domains` -> `id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `vacation_notify`
--
-- Erzeugt am: 06. November 2010 um 23:16
-- Aktualisiert am: 06. November 2010 um 23:16
-- Letzter Check am: 06. November 2010 um 23:16
--

DROP TABLE IF EXISTS `vacation_notify`;
CREATE TABLE IF NOT EXISTS `vacation_notify` (
  `on_vacation` varchar(255) NOT NULL,
  `notified` varchar(255) NOT NULL,
  `notified_at` datetime NOT NULL,
  PRIMARY KEY (`on_vacation`,`notified`),
  KEY `notified_at` (`notified_at`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `aliases`
--
ALTER TABLE `aliases`
  ADD CONSTRAINT `aliases_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `domain_aliases`
--
ALTER TABLE `domain_aliases`
  ADD CONSTRAINT `domain_aliases_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `mailboxes`
--
ALTER TABLE `mailboxes`
  ADD CONSTRAINT `mailboxes_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

SET FOREIGN_KEY_CHECKS=1;

COMMIT;
