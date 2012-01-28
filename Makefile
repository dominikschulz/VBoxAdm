#
# Makefile for vboxadm
#

# some variables
NAME = vboxadm
VERSION = 0.2.1
BUILDDATE = $(shell date +%Y-%m-%d)
WWWUSER ?= www-data
WWWGROUP ?= www-data

# Required programs
INSTALL = /usr/bin/install
POD2MAN = /usr/bin/pod2man
POD2HTML = /usr/bin/pod2html
CHMOD = /bin/chmod
CP = /bin/cp
INSTALL_DATA = $(INSTALL) -c -m 644
INSTALL_PROGRAM = $(INSTALL) -c -m 755
INSTALL_CONF = $(INSTALL) -c -m 600
INSTALL_WWW = $(INSTALL) -c -m 750 -g $(WWWGROUP)
MV = /bin/mv
RM = /bin/rm
FIND = /usr/bin/find
SED = /bin/sed
SHELL = /bin/sh
TAR = /bin/tar
GIT = /usr/bin/git
FILEPP = build/filepp.pl -u
PERLTIDY = /usr/bin/perltidy -syn -l=160 -nce -nbl -b
PERLCRITIC = /usr/bin/perlcritic
PERL = /usr/bin/perl
PROVE = /usr/bin/prove -l
YUIC = /usr/bin/java -jar build/yuicompressor-2.4.2.jar --charset UTF-8 --line-break 4000
HTMLC = /usr/bin/java -jar build/htmlcompressor-0.9.9.jar --type html --charset UTF-8 --remove-intertag-spaces --remove-quotes --compress-js --compress-css --line-break 4000


# Directories
BINDIR=$(DESTDIR)/usr/bin
SBINDIR=$(DESTDIR)/usr/sbin
MANDIR=$(DESTDIR)/usr/share/man
CFGDIR ?= $(DESTDIR)/etc
LIBDIR=$(DESTDIR)/usr/share/perl5
VBOXLIBDIR=$(DESTDIR)/usr/lib/vboxadm
VDNSLIBDIR=$(DESTDIR)/usr/lib/vdnsadm
VWEBLIBDIR=$(DESTDIR)/usr/lib/vwebadm
VBOXVHDIR=$(DESTDIR)/var/lib/vboxadm
VDNSVHDIR=$(DESTDIR)/var/lib/vdnsadm
VWEBVHDIR=$(DESTDIR)/var/lib/vwebadm

# Files
BINFILES = \
	bin/vacation.pl \
	bin/vboxadm-ma.pl \
	bin/vboxadm-sa.pl \
	bin/vboxadm.pl \
	bin/vboxadmr.pl \
	bin/vdnsadm.pl \
	bin/vdnsadmr.pl \
	cgi-bin/autodiscover.pl \
	cgi-bin/vboxadm.pl \
	cgi-bin/vboxadm.fcgi \
	cgi-bin/vboxapi.pl \
	cgi-bin/vdnsadm.fcgi \
	cgi-bin/vdnsadm.pl \
	cgi-bin/vdnsapi.pl \
	cron/cleanup.pl \
	cron/awl.pl \
	cron/notify.pl \
	cron/mailarchive.pl \
	contrib/inst_deps.pl \
	contrib/migration.pl \
	contrib/lexicons-export.pl \
	contrib/lexicons-import.pl \
	contrib/is_utf8.pl

LIBFILES = \
	lib/VBoxAdm/Controller/API.pm \
	lib/VBoxAdm/Controller/Autodiscover.pm \
	lib/VBoxAdm/Controller/CLI.pm \
	lib/VBoxAdm/Controller/Frontend.pm \
	lib/VBoxAdm/Controller/Notify.pm \
	lib/VBoxAdm/Controller/Vacation.pm \
	lib/VBoxAdm/L10N/ar.pm \
	lib/VBoxAdm/L10N/da.pm \
	lib/VBoxAdm/L10N/de.pm \
	lib/VBoxAdm/L10N/en.pm \
	lib/VBoxAdm/L10N/es.pm \
	lib/VBoxAdm/L10N/fi.pm \
	lib/VBoxAdm/L10N/fr.pm \
	lib/VBoxAdm/L10N/hi.pm \
	lib/VBoxAdm/L10N/it.pm \
	lib/VBoxAdm/L10N/ja.pm \
	lib/VBoxAdm/L10N/ko.pm \
	lib/VBoxAdm/L10N/pl.pm \
	lib/VBoxAdm/L10N/pt.pm \
	lib/VBoxAdm/L10N/ru.pm \
	lib/VBoxAdm/L10N/zh.pm \
	lib/VBoxAdm/Model/Alias.pm \
	lib/VBoxAdm/Model/AWL.pm \
	lib/VBoxAdm/Model/Domain.pm \
	lib/VBoxAdm/Model/DomainAlias.pm \
	lib/VBoxAdm/Model/Mailbox.pm \
	lib/VBoxAdm/Model/RFCNotify.pm \
	lib/VBoxAdm/Model/RoleAccount.pm \
	lib/VBoxAdm/Model/User.pm \
	lib/VBoxAdm/Model/VacationBlacklist.pm \
	lib/VBoxAdm/Model/VacationNotify.pm \
	lib/VBoxAdm/SMTP/Proxy/MA.pm \
	lib/VBoxAdm/SMTP/Proxy/SA.pm \
	lib/VBoxAdm/SMTP/Client.pm \
	lib/VBoxAdm/SMTP/Proxy.pm \
	lib/VBoxAdm/SMTP/Server.pm \
	lib/VBoxAdm/L10N.pm \
	lib/VBoxAdm/Migration.pm \
	lib/VDnsAdm/Controller/API.pm \
	lib/VDnsAdm/Controller/CLI.pm \
	lib/VDnsAdm/Controller/Frontend.pm \
	lib/VDnsAdm/L10N/de.pm \
	lib/VDnsAdm/L10N/en.pm \
	lib/VDnsAdm/Model/Domain.pm \
	lib/VDnsAdm/Model/Record.pm \
	lib/VDnsAdm/Model/User.pm \
	lib/VDnsAdm/L10N.pm \
	lib/VWebAdm/Model/MessageQueue.pm \
	lib/VWebAdm/Model/User.pm \
	lib/VWebAdm/API.pm \
	lib/VWebAdm/DB.pm \
	lib/VWebAdm/DNS.pm \
	lib/VWebAdm/L10N.pm \
	lib/VWebAdm/Logger.pm \
	lib/VWebAdm/Model.pm \
	lib/VWebAdm/Password.pm \
	lib/VWebAdm/SaltedHash.pm \
	lib/VWebAdm/Utils.pm

MANFILES = \
	bin/vacation.8 \
	bin/vboxadm-ma.8 \
	bin/vboxadm-sa.8 \
	bin/vboxadm.8 \
	bin/vdnsadm.8 \
	bin/vdnsadmr.8 \
	cgi-bin/autodiscover.1 \
	cgi-bin/vboxadm.1 \
	cgi-bin/vboxapi.1 \
	cgi-bin/vdnsadm.1 \
	cgi-bin/vdnsapi.1 \
	cron/awl.8 \
	cron/cleanup.8 \
	cron/mailarchive.8 \
	cron/notify.8 \
	lib/VBoxAdm/Controller/API.3 \
	lib/VBoxAdm/Controller/Autodiscover.3 \
	lib/VBoxAdm/Controller/CLI.3 \
	lib/VBoxAdm/Controller/Frontend.3 \
	lib/VBoxAdm/Controller/Notify.3 \
	lib/VBoxAdm/Controller/Vacation.3 \
	lib/VBoxAdm/Model/Alias.3 \
	lib/VBoxAdm/Model/AWL.3 \
	lib/VBoxAdm/Model/Domain.3 \
	lib/VBoxAdm/Model/DomainAlias.3 \
	lib/VBoxAdm/Model/Mailbox.3 \
	lib/VBoxAdm/Model/User.3 \
	lib/VBoxAdm/Model/VacationBlacklist.3 \
	lib/VBoxAdm/Model/VacationNotify.3 \
	lib/VBoxAdm/SMTP/Proxy/MA.3 \
	lib/VBoxAdm/SMTP/Proxy/SA.3 \
	lib/VBoxAdm/SMTP/Client.3 \
	lib/VBoxAdm/SMTP/Proxy.3 \
	lib/VBoxAdm/SMTP/Server.3 \
	lib/VBoxAdm/L10N.3 \
	lib/VBoxAdm/Migration.3 \
	lib/VDnsAdm/Controller/API.3 \
	lib/VDnsAdm/Controller/CLI.3 \
	lib/VDnsAdm/Controller/Frontend.3 \
	lib/VDnsAdm/Model/Domain.3 \
	lib/VDnsAdm/Model/Record.3 \
	lib/VDnsAdm/Model/User.3 \
	lib/VWebAdm/Model/MessageQueue.3 \
	lib/VWebAdm/Model/User.3 \
	lib/VWebAdm/API.3 \
	lib/VWebAdm/DB.3 \
	lib/VWebAdm/DNS.3 \
	lib/VWebAdm/L10N.3 \
	lib/VWebAdm/Logger.3 \
	lib/VWebAdm/Model.3 \
	lib/VWebAdm/Password.3 \
	lib/VWebAdm/SaltedHash.3 \
	lib/VWebAdm/Utils.3

TESTFILES = \
	t/VBoxAdm/Controller/API.t \
	t/VBoxAdm/Controller/Autodiscover.t \
	t/VBoxAdm/Controller/CLI.t \
	t/VBoxAdm/Controller/Frontend.t \
	t/VBoxAdm/Controller/Notify.t \
	t/VBoxAdm/Controller/Vacation.t \
	t/VBoxAdm/L10N/de.t \
	t/VBoxAdm/L10N/en.t \
	t/VBoxAdm/Model/Alias.t \
	t/VBoxAdm/Model/AWL.t \
	t/VBoxAdm/Model/Domain.t \
	t/VBoxAdm/Model/DomainAlias.t \
	t/VBoxAdm/Model/Mailbox.t \
	t/VBoxAdm/Model/User.t \
	t/VBoxAdm/Model/VacationBlacklist.t \
	t/VBoxAdm/Model/VacationNotify.t \
	t/VBoxAdm/SMTP/Proxy/MA.t \
	t/VBoxAdm/SMTP/Proxy/SA.t \
	t/VBoxAdm/SMTP/Client.t \
	t/VBoxAdm/SMTP/Proxy.t \
	t/VBoxAdm/SMTP/Server.t \
	t/VBoxAdm/L10N.t \
	t/VBoxAdm/Migration.t \
	t/VDnsAdm/Controller/API.t \
	t/VDnsAdm/Controller/CLI.t \
	t/VDnsAdm/Controller/Frontend.t \
	t/VDnsAdm/Model/Domain.t \
	t/VDnsAdm/Model/Record.t \
	t/VDnsAdm/Model/User.t \
	t/VDnsAdm/L10N.t \
	t/VWebAdm/Model/MessageQueue.t \
	t/VWebAdm/Model/User.t \
	t/VWebAdm/API.t \
	t/VWebAdm/DB.t \
	t/VWebAdm/DNS.t \
	t/VWebAdm/Logger.t \
	t/VWebAdm/Model.t \
	t/VWebAdm/Password.t \
	t/VWebAdm/SaltedHash.t \
	t/VWebAdm/Utils.t

CSSFILES = \
	res/css/datatable/datatable_jui.min.css \
	res/css/style.min.css

JSFILES = \
	res/js/libs/jquery-1.5.1.min.js \
	res/js/libs/jquery-ui-1.8.12.custom.min.js \
	res/js/libs/jquery.dataTables.min.js \
	res/js/script.min.js

TPLFILES = \
	tpl/vboxadm/alias/create_partial.tpl \
	tpl/vboxadm/alias/create.tpl \
	tpl/vboxadm/alias/edit_partial.tpl \
	tpl/vboxadm/alias/edit.tpl \
	tpl/vboxadm/alias/list.tpl \
	tpl/vboxadm/awl/list.tpl \
	tpl/vboxadm/domain/create_partial.tpl \
	tpl/vboxadm/domain/create.tpl \
	tpl/vboxadm/domain/list.tpl \
	tpl/vboxadm/domain/show.tpl \
	tpl/vboxadm/domain_alias/create_partial.tpl \
	tpl/vboxadm/domain_alias/create.tpl \
	tpl/vboxadm/domain_alias/edit_partial.tpl \
	tpl/vboxadm/domain_alias/edit.tpl \
	tpl/vboxadm/domain_alias/list.tpl \
	tpl/vboxadm/includes/navigation.tpl \
	tpl/vboxadm/mailbox/admins.tpl \
	tpl/vboxadm/mailbox/create_partial.tpl \
	tpl/vboxadm/mailbox/create.tpl \
	tpl/vboxadm/mailbox/edit_partial.tpl \
	tpl/vboxadm/mailbox/edit.tpl \
	tpl/vboxadm/mailbox/list.tpl \
	tpl/vboxadm/rfc_notify/list.tpl \
	tpl/vboxadm/role_account/create_partial.tpl \
	tpl/vboxadm/role_account/create.tpl \
	tpl/vboxadm/role_account/edit_partial.tpl \
	tpl/vboxadm/role_account/edit.tpl \
	tpl/vboxadm/role_account/list.tpl \
	tpl/vboxadm/vacation_blacklist/create_partial.tpl \
	tpl/vboxadm/vacation_blacklist/create.tpl \
	tpl/vboxadm/vacation_blacklist/list.tpl \
	tpl/vboxadm/vacation_notify/list.tpl \
	tpl/vboxadm/broadcast_result.tpl \
	tpl/vboxadm/broadcast.tpl \
	tpl/vboxadm/welcome.tpl \
	tpl/vdnsadm/domain/create_partial.tpl \
	tpl/vdnsadm/domain/create.tpl \
	tpl/vdnsadm/domain/edit_partial.tpl \
	tpl/vdnsadm/domain/edit.tpl \
	tpl/vdnsadm/domain/list.tpl \
	tpl/vdnsadm/domain/show.tpl \
	tpl/vdnsadm/includes/navigation.tpl \
	tpl/vdnsadm/record/create_partial.tpl \
	tpl/vdnsadm/record/create.tpl \
	tpl/vdnsadm/record/edit_partial.tpl \
	tpl/vdnsadm/record/edit.tpl \
	tpl/vdnsadm/record/list.tpl \
	tpl/vdnsadm/record/show.tpl \
	tpl/vdnsadm/user/create_partial.tpl \
	tpl/vdnsadm/user/create.tpl \
	tpl/vdnsadm/user/edit_partial.tpl \
	tpl/vdnsadm/user/edit.tpl \
	tpl/vdnsadm/user/list.tpl \
	tpl/vdnsadm/user/show.tpl \
	tpl/vdnsadm/welcome.tpl \
	tpl/vwebadm/includes/footer.tpl \
	tpl/vwebadm/includes/header.tpl \
	tpl/vwebadm/log.tpl \
	tpl/vwebadm/login.tpl

.PHONY: install tidy critic test

%.min.js: %.js
	$(YUIC) --type js -o $@ $<

%.min.css: %.css
	$(YUIC) --type css -o $@ $<

%.tpl: %.itpl
	$(SED) -e s/@BUILDDATE@/$(BUILDDATE)/ \
		   -e s/@VERSION@/$(VERSION)/ < $< > $@
	$(HTMLC) -o $@ $@

%.pl: %.ipl $(LIBFILES)
	$(FILEPP) -D@BUILDDATE@=$(BUILDDATE) -D@VERSION@=$(VERSION) -D@LIBDIR@="$(LIBDIR)" -D@CFGDIR@="$(CFGDIR)" $< -o $@ && \
	$(CHMOD) 755 $@ && \
	$(PERLTIDY) $@ && \
	$(CHMOD) +x $@ && \
	$(PERL) -I lib/ -c $@

%.fcgi: %.ifcgi $(LIBFILES)
	$(FILEPP) -D@BUILDDATE@=$(BUILDDATE) -D@VERSION@=$(VERSION) -D@LIBDIR@="$(LIBDIR)" -D@CFGDIR@="$(CFGDIR)" $< -o $@ && \
	$(CHMOD) 755 $@ && \
	$(PERLTIDY) $@ && \
	$(CHMOD) +x $@ && \
	$(PERL) -I lib/ -c $@

%.pm: %.ipm
	$(FILEPP) -D@BUILDDATE@=$(BUILDDATE) -D@VERSION@=$(VERSION) -D@LIBDIR@="$(LIBDIR)" -D@CFGDIR@="$(CFGDIR)" $< -o $@ && \
	$(PERLTIDY) $@

%.t: %.it
	$(FILEPP) -D@BUILDDATE@=$(BUILDDATE) -D@VERSION@=$(VERSION) $< -o $@ && \
	$(PERLTIDY) $@
	
%.1: %.pl
	build/make-man.pl $< $@

%.3: %.pm
	build/make-man.pl $< $@

%.8: %.pl
	build/make-man.pl $< $@

all: $(LIBFILES) $(BINFILES) $(TESTFILES) $(MANFILES) $(CSSFILES) $(JSFILES) $(TPLFILES)

lib: $(LIBFILES)

re: clean all

quick-install: real-install

install: clean real-install

real-install: all test rcvboxadm
	$(INSTALL) -d $(BINDIR) $(SBINDIR) $(DESTDIR)/etc
	$(INSTALL) -d $(CFGDIR)/vboxadm $(CFGDIR)/vdnsadm
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/Controller $(LIBDIR)/VBoxAdm/L10N $(LIBDIR)/VBoxAdm/Model $(LIBDIR)/VBoxAdm/SMTP/Proxy 
	$(INSTALL) -d $(LIBDIR)/VDnsAdm/Controller $(LIBDIR)/VDnsAdm/L10N $(LIBDIR)/VDnsAdm/Model
	$(INSTALL) -d $(LIBDIR)/VWebAdm/Model
	$(INSTALL) -d $(MANDIR)/man1 $(MANDIR)/man3 $(MANDIR)/man8
	$(INSTALL) -d $(VBOXLIBDIR)/bin
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/alias $(VWEBLIBDIR)/tpl/vboxadm/autoconfig $(VWEBLIBDIR)/tpl/vboxadm/awl $(VWEBLIBDIR)/tpl/vboxadm/domain
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/domain_alias $(VWEBLIBDIR)/tpl/vboxadm/includes $(VWEBLIBDIR)/tpl/vboxadm/mailbox $(VWEBLIBDIR)/tpl/vboxadm/notify
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/rfc_notify $(VWEBLIBDIR)/tpl/vboxadm/vacation_blacklist $(VWEBLIBDIR)/tpl/vboxadm/vacation_notify
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vdnsadm/domain $(VWEBLIBDIR)/tpl/vdnsadm/includes $(VWEBLIBDIR)/tpl/vdnsadm/record
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vdnsadm/user
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vwebadm/includes
	$(INSTALL) -g $(WWWGROUP) -d $(VBOXVHDIR)/cgi-bin $(VDNSVHDIR)/cgi-bin
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/images/knob $(VWEBVHDIR)/htdocs/images/datatables
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/css/datatable $(VWEBVHDIR)/htdocs/css/themes/ui-darkness/images
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/js/libs $(VWEBVHDIR)/htdocs/js/mylibs $(VWEBVHDIR)/htdocs/js/profiling
	$(INSTALL_PROGRAM) bin/vacation.pl $(VBOXLIBDIR)/bin/vacation
	$(INSTALL_PROGRAM) bin/vboxadm-ma.pl $(SBINDIR)/vboxadm-ma
	$(INSTALL_PROGRAM) bin/vboxadm-sa.pl $(SBINDIR)/vboxadm-sa
	$(INSTALL_PROGRAM) bin/vboxadm.pl $(BINDIR)/vboxadm
	$(INSTALL_PROGRAM) bin/vboxadmr.pl $(BINDIR)/vboxadmr
	$(INSTALL_PROGRAM) bin/vdnsadm.pl $(BINDIR)/vdnsadm
	$(INSTALL_WWW) cgi-bin/autodiscover.pl $(VBOXVHDIR)/cgi-bin/autodiscover.pl
	$(INSTALL_WWW) cgi-bin/vboxadm.fcgi $(VBOXVHDIR)/cgi-bin/vboxadm.fcgi
	$(INSTALL_WWW) cgi-bin/vboxadm.pl $(VBOXVHDIR)/cgi-bin/vboxadm.pl
	$(INSTALL_WWW) cgi-bin/vboxapi.pl $(VBOXVHDIR)/cgi-bin/vboxapi.pl
	$(INSTALL_WWW) cgi-bin/vdnsadm.fcgi $(VDNSVHDIR)/cgi-bin/vdnsadm.fcgi
	$(INSTALL_WWW) cgi-bin/vdnsadm.pl $(VDNSVHDIR)/cgi-bin/vdnsadm.pl
	$(INSTALL_WWW) cgi-bin/vdnsapi.pl $(VDNSVHDIR)/cgi-bin/vdnsapi.pl
	$(INSTALL_CONF) conf/vboxadm.conf.dist $(CFGDIR)/vboxadm/vboxadm.conf
	$(INSTALL_CONF) conf/vdnsadm.conf.dist $(CFGDIR)/vdnsadm/vdnsadm.conf
	$(INSTALL_PROGRAM) cron/awl.pl $(VBOXLIBDIR)/bin/awl
	$(INSTALL_PROGRAM) cron/cleanup.pl $(VBOXLIBDIR)/bin/cleanup
	$(INSTALL_PROGRAM) cron/mailarchive.pl $(VBOXLIBDIR)/bin/mailarchive
	$(INSTALL_PROGRAM) cron/notify.pl $(VBOXLIBDIR)/bin/notify
	$(INSTALL_CONF) doc/vboxadm/apache/vboxadm.conf $(CFGDIR)/vboxadm/apache.conf
	$(INSTALL_CONF) doc/vboxadm/lighttpd/50-vboxadm.conf $(CFGDIR)/vboxadm/lighttpd.conf
	$(INSTALL_CONF) doc/vdnsadm/powerdns/pdns.local $(CFGDIR)/vdnsadm/pdns.local
	$(INSTALL_DATA) lib/VBoxAdm/Controller/*.pm $(LIBDIR)/VBoxAdm/Controller/
	$(INSTALL_DATA) lib/VBoxAdm/Controller/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/L10N/*.pm $(LIBDIR)/VBoxAdm/L10N/
	$(INSTALL_DATA) lib/VBoxAdm/Model/*.pm $(LIBDIR)/VBoxAdm/Model/
	$(INSTALL_DATA) lib/VBoxAdm/Model/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/*.pm $(LIBDIR)/VBoxAdm/SMTP/
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/Proxy/*.pm $(LIBDIR)/VBoxAdm/SMTP/Proxy/
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/Proxy/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/*.pm $(LIBDIR)/VBoxAdm/
	$(INSTALL_DATA) lib/VBoxAdm/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VDnsAdm/Controller/*.pm $(LIBDIR)/VDnsAdm/Controller/
	$(INSTALL_DATA) lib/VDnsAdm/Controller/VDnsAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VDnsAdm/L10N/*.pm $(LIBDIR)/VDnsAdm/L10N/
	$(INSTALL_DATA) lib/VDnsAdm/Model/*.pm $(LIBDIR)/VDnsAdm/Model/
	$(INSTALL_DATA) lib/VDnsAdm/Model/VDnsAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VDnsAdm/*.pm $(LIBDIR)/VDnsAdm/
	$(INSTALL_DATA) lib/VWebAdm/Model/*.pm $(LIBDIR)/VWebAdm/Model/
	$(INSTALL_DATA) lib/VWebAdm/Model/VWebAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VWebAdm/*.pm $(LIBDIR)/VWebAdm/
	$(INSTALL_DATA) lib/VWebAdm/VWebAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) tpl/vboxadm/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/
	$(INSTALL_DATA) tpl/vboxadm/alias/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/alias/
	$(INSTALL_DATA) tpl/vboxadm/autoconfig/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/autoconfig/
	$(INSTALL_DATA) tpl/vboxadm/awl/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/awl/
	$(INSTALL_DATA) tpl/vboxadm/domain/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/domain/
	$(INSTALL_DATA) tpl/vboxadm/domain_alias/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/domain_alias/
	$(INSTALL_DATA) tpl/vboxadm/includes/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/includes/
	$(INSTALL_DATA) tpl/vboxadm/mailbox/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/mailbox/
	$(INSTALL_DATA) tpl/vboxadm/notify/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/notify/
	$(INSTALL_DATA) tpl/vboxadm/rfc_notify/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/rfc_notify/
	$(INSTALL_DATA) tpl/vboxadm/vacation_blacklist/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/vacation_blacklist/
	$(INSTALL_DATA) tpl/vboxadm/vacation_notify/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/vacation_notify/
	$(INSTALL_DATA) tpl/vdnsadm/domain/*.tpl $(VWEBLIBDIR)/tpl/vdnsadm/domain/
	$(INSTALL_DATA) tpl/vdnsadm/includes/*.tpl $(VWEBLIBDIR)/tpl/vdnsadm/includes/
	$(INSTALL_DATA) tpl/vdnsadm/record/*.tpl $(VWEBLIBDIR)/tpl/vdnsadm/record/
	$(INSTALL_DATA) tpl/vdnsadm/user/*.tpl $(VWEBLIBDIR)/tpl/vdnsadm/user/
	$(INSTALL_DATA) tpl/vdnsadm/*.tpl $(VWEBLIBDIR)/tpl/vdnsadm/
	$(INSTALL_DATA) tpl/vwebadm/includes/*.tpl $(VWEBLIBDIR)/tpl/vwebadm/includes/
	$(INSTALL_DATA) tpl/vwebadm/*.tpl $(VWEBLIBDIR)/tpl/vwebadm/
	$(INSTALL_DATA) res/css/*.css $(VWEBVHDIR)/htdocs/css/
	$(INSTALL_DATA) res/css/datatable/*.css $(VWEBVHDIR)/htdocs/css/datatable/
	$(INSTALL_DATA) res/css/themes/ui-darkness/*.css $(VWEBVHDIR)/htdocs/css/themes/ui-darkness/
	$(INSTALL_DATA) res/css/themes/ui-darkness/images/*.png $(VWEBVHDIR)/htdocs/css/themes/ui-darkness/images/
	$(INSTALL_DATA) res/images/*.png $(VWEBVHDIR)/htdocs/images/
	$(INSTALL_DATA) res/images/knob/*.png $(VWEBVHDIR)/htdocs/images/knob/
	$(INSTALL_DATA) res/images/datatables/*.png $(VWEBVHDIR)/htdocs/images/datatables/
	$(INSTALL_DATA) res/js/*.js $(VWEBVHDIR)/htdocs/js/
	$(INSTALL_DATA) res/js/libs/*.js $(VWEBVHDIR)/htdocs/js/libs/
	$(INSTALL_DATA) res/js/profiling/*.js $(VWEBVHDIR)/htdocs/js/profiling/
	$(INSTALL_DATA) res/apple-touch-icon.png $(VWEBVHDIR)/htdocs/apple-touch-icon.png
	$(INSTALL_DATA) res/crossdomain.xml $(VWEBVHDIR)/htdocs/crossdomain.xml
	$(INSTALL_DATA) res/favicon.ico $(VWEBVHDIR)/htdocs/favicon.ico
	$(INSTALL_DATA) res/robots.txt $(VWEBVHDIR)/htdocs/robots.txt
	$(INSTALL_DATA) bin/*.8 $(MANDIR)/man8/
	$(INSTALL_DATA) cgi-bin/*.1 $(MANDIR)/man1/
	$(INSTALL_DATA) cron/*.8 $(MANDIR)/man8/

tidy:
	$(FIND) . -name "*.ipl" -exec $(PERLTIDY) {} \;
	$(FIND) . -name "*.ipm" -exec $(PERLTIDY) {} \;
	$(FIND) . -name "*.it"  -exec $(PERLTIDY) {} \;
	$(PERLTIDY) cgi-bin/*.ifcgi

clean:
	$(FIND) bin/ -name "*.pl" -exec $(RM) {} \;
	$(FIND) cgi-bin/ -name "*.pl" -exec $(RM) {} \;
	$(FIND) cron/ -name "*.pl" -exec $(RM) {} \;
	$(FIND) t/ -name "*.t" -exec $(RM) {} \;
	$(RM) -f tpl/vboxadm/alias/*.tpl
	$(RM) -f tpl/vboxadm/awl/*.tpl
	$(RM) -f tpl/vboxadm/domain/*.tpl
	$(RM) -f tpl/vboxadm/domain_alias/*.tpl
	$(RM) -f tpl/vboxadm/includes/*.tpl
	$(RM) -f tpl/vboxadm/mailbox/*.tpl
	$(RM) -f tpl/vboxadm/rfc_notify/*.tpl
	$(RM) -f tpl/vboxadm/role_account/*.tpl
	$(RM) -f tpl/vboxadm/vacation_blacklist/*.tpl
	$(RM) -f tpl/vboxadm/vacation_notify/*.tpl
	$(RM) -f tpl/vboxadm/*.tpl
	$(RM) -f tpl/vdnsadm/domain/*.tpl
	$(RM) -f tpl/vdnsadm/includes/*.tpl
	$(RM) -f tpl/vdnsadm/record/*.tpl
	$(RM) -f tpl/vdnsadm/user/*.tpl
	$(RM) -f tpl/vdnsadm/*.tpl
	$(RM) -f tpl/vwebadm/includes/*.tpl
	$(RM) -f tpl/vwebadm/*.tpl
	$(FIND) . -name "*.bak" -exec $(RM) {} \;
	$(FIND) . -name "*.ERR" -exec $(RM) {} \;
	$(FIND) . -name "*.LOG" -exec $(RM) {} \;
	$(FIND) . -name "*.1" -exec $(RM) {} \;
	$(FIND) . -name "*.3" -exec $(RM) {} \;
	$(FIND) . -name "*.8" -exec $(RM) {} \;
	$(FIND) . -name "*.pm" -exec $(RM) {} \;
	$(FIND) . -name "*.pm~" -exec $(RM) {} \;
	$(RM) -f bin/tmon.out
	$(RM) -f doc/man/*
	$(RM) -f contrib/roundcube-plugin-vboxadm.tar.gz

rcvboxadm:
	cd contrib/roundcube/plugins/ && tar -cvzf ../../roundcube-plugin-vboxadm.tar.gz vboxadm/ && cd ../../../

git: tidy all clean
	$(GIT) status
	$(GIT) diff
	$(GIT) commit -a -s || true
	$(GIT) push origin master
	test -d /projects/ && $(GIT) push projects || true

help:
	@echo "Usage for this Makefile:"
	@echo "\tcompile - check if perl can compile the binaries"
	@echo "\tinstall - install to DESTDIR. runs tidy, clean and test"
	@echo "\ttidy - run perltidy on bin/"
	@echo "\tclean - remove _Inline, bak and tmon.out"
	@echo "\tgit - commit to git and push. runs tidy, clean and test"
	@echo "\tdist - creates a new release. runs git"
	@echo "\tdist-local - creates a new local release. runs git"
	@echo "\tcritic - runs perlcritic --stern on bin/"
	@echo "\ttest - runs all tests. runs compile"

dist: git
	build/release.pl --verbose

dist-local: git
	build/release.pl --verbose --local

dist-minor: git
	build/release.pl --verbose --minor

dist-major: test-all git
	build/release.pl --verbose --major

critic: all
	$(PERLCRITIC) --stern bin/
	$(PERLCRITIC) --stern cgi-bin/
	$(PERLCRITIC) --stern cron/
	$(PERLCRITIC) --stern lib/

test: all
	rm -rf .pc/
	QUICK_TEST=1 $(PROVE) -r

test-all: all
	$(PROVE) -r
