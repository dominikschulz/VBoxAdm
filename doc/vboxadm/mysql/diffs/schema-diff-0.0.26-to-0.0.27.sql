## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:14 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.26.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.27.sql

ALTER TABLE aliases DROP COLUMN CONSTRAINT; # was aliases_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE aliases CHANGE COLUMN local_part local_part varchar(255) CHARACTER SET latin1 NOT NULL; # was varchar(255) NOT NULL
ALTER TABLE aliases CHANGE COLUMN goto goto varchar(255) CHARACTER SET latin1 NOT NULL; # was varchar(255) NOT NULL
ALTER TABLE domain_aliases DROP COLUMN CONSTRAINT; # was domain_aliases_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE mailboxes DROP COLUMN CONSTRAINT; # was mailboxes_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE mailboxes ADD COLUMN vacation_end date NOT NULL;
ALTER TABLE mailboxes ADD COLUMN vacation_start date NOT NULL;
ALTER TABLE mailboxes ADD INDEX vacation_duration (vacation_start,vacation_end);
DROP TABLE vacation_notify;

CREATE TABLE awl (
  id int(16) NOT NULL AUTO_INCREMENT,
  email varchar(255) NOT NULL,
  last_seen datetime NOT NULL,
  disabled tinyint(1) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY email (email)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE rfc_notify (
  id int(16) NOT NULL AUTO_INCREMENT,
  email varchar(255) NOT NULL,
  ts datetime NOT NULL,
  PRIMARY KEY (id),
  KEY email (email)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE vacation_blacklist (
  id int(16) NOT NULL AUTO_INCREMENT,
  local_part varchar(255) NOT NULL,
  domain varchar(255) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY domain_lp (domain,local_part)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



