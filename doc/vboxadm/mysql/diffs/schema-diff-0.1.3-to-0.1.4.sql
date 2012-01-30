## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:46 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.1.3.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.1.4.sql

ALTER TABLE aliases CHANGE COLUMN goto goto varchar(4096) CHARACTER SET latin1 NOT NULL; # was varchar(255) CHARACTER SET latin1 NOT NULL
