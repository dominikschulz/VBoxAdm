## mysqldiff 0.43
## 
## Run on Mon Jan 30 20:52:13 2012
## Options: debug=0
##
## --- file: /tmp/vboxadm-upgrades/schema-0.0.25.sql
## +++ file: /tmp/vboxadm-upgrades/schema-0.0.26.sql

ALTER TABLE vacation_notify DROP PRIMARY KEY; # was (on_vacation(100),notified(100))
ALTER TABLE vacation_notify ADD PRIMARY KEY (on_vacation,notified);
ALTER TABLE vacation_notify ENGINE=InnoDB DEFAULT CHARSET=utf8; # was ENGINE=MyISAM DEFAULT CHARSET=utf8
