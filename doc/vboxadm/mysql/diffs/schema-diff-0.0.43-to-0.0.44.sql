## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:36 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.43.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.44.sql

ALTER TABLE aliases DROP COLUMN CONSTRAINT; # was aliases_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE aliases CHANGE COLUMN local_part local_part varchar(64) CHARACTER SET latin1 NOT NULL; # was varchar(255) CHARACTER SET latin1 NOT NULL
ALTER TABLE awl CHANGE COLUMN email email varchar(320) NOT NULL; # was varchar(255) NOT NULL
ALTER TABLE domain_aliases DROP COLUMN CONSTRAINT; # was domain_aliases_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE mailboxes CHANGE COLUMN local_part local_part varchar(64) NOT NULL; # was varchar(255) NOT NULL
ALTER TABLE mailboxes DROP COLUMN CONSTRAINT; # was mailboxes_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE rfc_notify CHANGE COLUMN email email varchar(320) NOT NULL; # was varchar(255) NOT NULL
ALTER TABLE vacation_blacklist CHANGE COLUMN local_part local_part varchar(64) NOT NULL; # was varchar(255) NOT NULL
DROP TABLE vacation_notify;

