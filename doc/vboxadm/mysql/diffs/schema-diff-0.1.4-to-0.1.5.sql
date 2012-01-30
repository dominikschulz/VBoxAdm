## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:47 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.1.4.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.1.5.sql

ALTER TABLE mailboxes ADD COLUMN pw_lock tinyint(1) NOT NULL DEFAULT '0';
