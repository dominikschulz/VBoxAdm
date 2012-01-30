## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:51:54 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.5.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.6.sql

ALTER TABLE aliases DROP INDEX domain_id; # was INDEX (domain_id,local_part)
ALTER TABLE aliases ADD UNIQUE domain_id (domain_id,local_part);
ALTER TABLE domain_aliases DROP INDEX name; # was INDEX (name,domain_id)
ALTER TABLE domain_aliases ADD UNIQUE name (name);
ALTER TABLE mailboxes ADD COLUMN name varchar(255) NOT NULL;
ALTER TABLE mailboxes DROP INDEX domain_id; # was INDEX (domain_id,local_part)
ALTER TABLE mailboxes ADD UNIQUE domain_id (domain_id,local_part);
