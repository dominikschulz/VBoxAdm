## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:51:55 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.6.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.7.sql

ALTER TABLE mailboxes ADD COLUMN vacation_subj varchar(255) NOT NULL;
ALTER TABLE mailboxes ADD COLUMN sa_kill_score decimal(5,2) NOT NULL;
ALTER TABLE mailboxes ADD COLUMN sa_active tinyint(1) NOT NULL;
