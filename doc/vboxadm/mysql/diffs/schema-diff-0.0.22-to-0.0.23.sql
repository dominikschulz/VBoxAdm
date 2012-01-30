## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:11 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.22.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.23.sql

ALTER TABLE aliases DROP COLUMN CONSTRAINT; # was aliases_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE aliases ENGINE=InnoDB DEFAULT CHARSET=utf8; # was ENGINE=InnoDB DEFAULT CHARSET=latin1
ALTER TABLE domain_aliases DROP COLUMN CONSTRAINT; # was domain_aliases_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE domain_aliases ENGINE=InnoDB DEFAULT CHARSET=utf8; # was ENGINE=InnoDB DEFAULT CHARSET=latin1
ALTER TABLE domains ENGINE=InnoDB DEFAULT CHARSET=utf8; # was ENGINE=InnoDB DEFAULT CHARSET=latin1
ALTER TABLE log ENGINE=ARCHIVE DEFAULT CHARSET=utf8; # was ENGINE=ARCHIVE DEFAULT CHARSET=latin1
ALTER TABLE mailboxes DROP COLUMN CONSTRAINT; # was mailboxes_ibfk_1 FOREIGN KEY (domain_id) REFERENCES domains (id) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE mailboxes ENGINE=InnoDB DEFAULT CHARSET=utf8; # was ENGINE=InnoDB DEFAULT CHARSET=latin1
DROP TABLE vacation_notify;

