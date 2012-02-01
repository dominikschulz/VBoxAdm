## mysqldiff 0.43
## 
## Run on Wed Feb  1 20:22:52 2012
## Options: debug=0
##
## --- file: doc/vdnsadm/mysql/powerdns-vanilla.sql
## +++ file: doc/vdnsadm/mysql/vdnsadm-current.sql

ALTER TABLE domains DROP COLUMN account; # was varchar(40) DEFAULT NULL
ALTER TABLE domains ADD COLUMN is_active tinyint(4) NOT NULL DEFAULT '1';
CREATE TABLE log (
  ts datetime NOT NULL,
  msg text NOT NULL
) ENGINE=ARCHIVE DEFAULT CHARSET=latin1;

CREATE TABLE users (
  id int(16) NOT NULL AUTO_INCREMENT,
  domain_id int(16) NOT NULL,
  local_part varchar(255) NOT NULL,
  password varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  is_active tinyint(1) NOT NULL,
  is_domainadmin tinyint(1) NOT NULL,
  is_siteadmin tinyint(1) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY domain_id (domain_id,local_part),
  CONSTRAINT users_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



