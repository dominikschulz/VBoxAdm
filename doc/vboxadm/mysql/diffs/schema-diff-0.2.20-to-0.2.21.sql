## mysqldiff 0.43
## 
## Run on Sat Mar 17 11:48:22 2012
## Options: debug=0
##
## --- file: doc/vboxadm/mysql/vboxadm-current.sql
## +++ file: /tmp/oPuqvWZzZp/vboxadm-current.sql

ALTER TABLE aliases CHANGE COLUMN is_active is_active tinyint(1) NOT NULL DEFAULT '1'; # was tinyint(1) NOT NULL
ALTER TABLE awl CHANGE COLUMN disabled disabled tinyint(1) NOT NULL DEFAULT '0'; # was tinyint(1) NOT NULL
ALTER TABLE domain_aliases CHANGE COLUMN is_active is_active tinyint(1) NOT NULL DEFAULT '1'; # was tinyint(1) NOT NULL
ALTER TABLE domains CHANGE COLUMN is_active is_active tinyint(1) NOT NULL DEFAULT '1'; # was tinyint(1) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN quota quota int(16) unsigned NOT NULL DEFAULT '26214400'; # was int(16) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN max_msg_size max_msg_size int(16) unsigned NOT NULL DEFAULT '26214400'; # was int(16) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN sa_kill_score sa_kill_score decimal(5,2) NOT NULL DEFAULT '6.31'; # was decimal(5,2) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN is_on_vacation is_on_vacation tinyint(1) NOT NULL DEFAULT '0'; # was tinyint(1) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN sa_active sa_active tinyint(1) NOT NULL DEFAULT '0'; # was tinyint(1) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN is_active is_active tinyint(1) NOT NULL DEFAULT '1'; # was tinyint(1) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN is_domainadmin is_domainadmin tinyint(1) NOT NULL DEFAULT '0'; # was tinyint(1) NOT NULL
ALTER TABLE mailboxes CHANGE COLUMN is_siteadmin is_siteadmin tinyint(1) NOT NULL DEFAULT '0'; # was tinyint(1) NOT NULL
