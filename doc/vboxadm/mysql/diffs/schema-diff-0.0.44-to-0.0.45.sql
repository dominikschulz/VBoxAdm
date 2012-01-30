## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:37 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.44.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.45.sql

ALTER TABLE mailboxes ADD COLUMN pw_ts timestamp NOT NULL DEFAULT '0000-00-00 00:00:00';
DROP TABLE rfc_notify;

DROP TABLE vacation_blacklist;

