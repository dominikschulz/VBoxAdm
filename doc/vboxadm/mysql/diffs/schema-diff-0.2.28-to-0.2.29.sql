## mysqldiff 0.43
## 
## Run on Sat Aug 18 22:06:27 2012
## Options: debug=0
##
## --- file: doc/vboxadm/mysql/vboxadm-current.sql
## +++ file: /tmp/yNjDAJouLZ/vboxadm-current.sql

CREATE TABLE dmarc_records (
  id int(16) NOT NULL AUTO_INCREMENT,
  report_id int(16) NOT NULL,
  ip varchar(255) NOT NULL,
  count int(16) NOT NULL,
  disposition varchar(255) NOT NULL,
  reason varchar(255) NOT NULL,
  dkimdomain varchar(255) NOT NULL,
  dkimresult varchar(255) NOT NULL,
  spfdomain varchar(255) NOT NULL,
  spfresult varchar(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE dmarc_reports (
  id int(16) NOT NULL AUTO_INCREMENT,
  tsfrom int(16) NOT NULL,
  tsto int(16) NOT NULL,
  domain varchar(255) NOT NULL,
  org varchar(255) NOT NULL,
  reportid varchar(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

