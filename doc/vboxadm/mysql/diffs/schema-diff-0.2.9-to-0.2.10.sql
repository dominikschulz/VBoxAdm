## mysqldiff 0.43
## 
## Run on Wed Feb  1 20:05:26 2012
## Options: debug=0
##
## --- file: doc/vboxadm/mysql/vboxadm-current.sql
## +++ file: /tmp/UyyV_NOOqq/vboxadm-current.sql

ALTER TABLE aliases CHANGE COLUMN local_part local_part varchar(255) CHARACTER SET latin1 NOT NULL; # was varchar(64) CHARACTER SET latin1 NOT NULL
ALTER TABLE aliases CHANGE COLUMN goto goto varchar(255) CHARACTER SET latin1 NOT NULL; # was varchar(4096) CHARACTER SET latin1 NOT NULL
ALTER TABLE aliases ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8; # was ENGINE=InnoDB DEFAULT CHARSET=utf8
ALTER TABLE awl CHANGE COLUMN email email varchar(255) NOT NULL; # was varchar(320) NOT NULL
ALTER TABLE awl ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8; # was ENGINE=MyISAM DEFAULT CHARSET=utf8
ALTER TABLE domain_aliases ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1; # was ENGINE=InnoDB DEFAULT CHARSET=utf8
ALTER TABLE domains ADD COLUMN is_relay_domain tinyint(1) NOT NULL DEFAULT '0';
ALTER TABLE domains ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1; # was ENGINE=InnoDB DEFAULT CHARSET=utf8
ALTER TABLE log ENGINE=ARCHIVE DEFAULT CHARSET=latin1; # was ENGINE=ARCHIVE DEFAULT CHARSET=utf8
ALTER TABLE mailboxes CHANGE COLUMN local_part local_part varchar(255) NOT NULL; # was varchar(64) NOT NULL
ALTER TABLE mailboxes ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1; # was ENGINE=InnoDB DEFAULT CHARSET=utf8
ALTER TABLE rfc_notify CHANGE COLUMN email email varchar(255) NOT NULL; # was varchar(320) NOT NULL
ALTER TABLE rfc_notify ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8; # was ENGINE=MyISAM DEFAULT CHARSET=latin1
ALTER TABLE role_accounts ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8; # was ENGINE=MyISAM DEFAULT CHARSET=utf8
ALTER TABLE vacation_blacklist CHANGE COLUMN local_part local_part varchar(255) NOT NULL; # was varchar(64) NOT NULL
ALTER TABLE vacation_blacklist ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8; # was ENGINE=InnoDB DEFAULT CHARSET=latin1
ALTER TABLE vacation_notify CHANGE COLUMN notified notified varchar(255) NOT NULL; # was varchar(320) NOT NULL
ALTER TABLE vacation_notify CHANGE COLUMN on_vacation on_vacation varchar(255) NOT NULL; # was varchar(320) NOT NULL
ALTER TABLE vacation_notify ENGINE=MyISAM DEFAULT CHARSET=latin1; # was ENGINE=InnoDB DEFAULT CHARSET=latin1
CREATE TABLE archiv_2011_01 (
  id bigint(64) NOT NULL AUTO_INCREMENT,
  body text NOT NULL,
  PRIMARY KEY (id)
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8;

