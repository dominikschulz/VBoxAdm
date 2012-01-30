## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:50 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.1.7.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.1.9.sql

ALTER TABLE mailboxes DROP COLUMN is_superadmin; # was tinyint(1) NOT NULL
ALTER TABLE mailboxes ADD COLUMN is_siteadmin tinyint(1) NOT NULL;
