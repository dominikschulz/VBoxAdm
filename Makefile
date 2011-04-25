#
# Makefile for vboxadm
#

# Required programs
INSTALL = /usr/bin/install
POD2MAN = /usr/bin/pod2man
POD2HTML = /usr/bin/pod2html
CHMOD = /bin/chmod
CP = /bin/cp
INSTALL_DATA = $(INSTALL) -c -m 644
INSTALL_PROGRAM = $(INSTALL) -c -m 755
INSTALL_CONF = $(INSTALL) -c -m 600
INSTALL_WWW = $(INSTALL) -c -m 750 -g www-data
MV = /bin/mv
RM = /bin/rm
SED = /bin/sed
SHELL = /bin/sh
TAR = /bin/tar
GIT = /usr/bin/git
PERLTIDY = /usr/bin/perltidy -syn -l=160 -nce -nbl -b
PERLCRITIC = /usr/bin/perlcritic
PERL = /usr/bin/perl
PROVE = /usr/bin/prove -l

# some variables
NAME = vboxadm
VERSION = 0.0.48
BUILDDATE = $(shell date +%Y-%m-%d)

# Directories
BINDIR=$(DESTDIR)/usr/bin
SBINDIR=$(DESTDIR)/usr/sbin
MANDIR=$(DESTDIR)/usr/share/man
CFGDIR ?= $(DESTDIR)/etc
LIBDIR=$(DESTDIR)/usr/share/perl5
VBOXLIBDIR=$(DESTDIR)/usr/lib/vboxadm
VHDIR=$(DESTDIR)/var/lib/vboxadm

# Files
BINFILES = \
	bin/vacation.pl \
	bin/vboxadm-ma.pl \
	bin/vboxadm-sa.pl \
	bin/vboxadm.pl \
	cgi-bin/autodiscover.pl \
	cgi-bin/vboxadm.pl \
	cgi-bin/vboxadm.fcgi \
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
	lib/VBoxAdm/Controller/Frontend.pm \
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
	lib/VBoxAdm/Model/MessageQueue.pm \
	lib/VBoxAdm/Model/User.pm \
	lib/VBoxAdm/Model/VacationBlacklist.pm \
	lib/VBoxAdm/SMTP/Client.pm \
	lib/VBoxAdm/SMTP/Mailarchive.pm \
	lib/VBoxAdm/SMTP/Proxy.pm \
	lib/VBoxAdm/SMTP/Server.pm \
	lib/VBoxAdm/API.pm \
	lib/VBoxAdm/DB.pm \
	lib/VBoxAdm/L10N.pm \
	lib/VBoxAdm/Migration.pm \
	lib/VBoxAdm/Model.pm \
	lib/VBoxAdm/Password.pm \
	lib/VBoxAdm/SaltedHash.pm \
	lib/VBoxAdm/Utils.pm

MANFILES = \
	bin/vacation.8 \
	bin/vboxadm-ma.8 \
	bin/vboxadm-sa.8 \
	bin/vboxadm.8 \
	cgi-bin/autodiscover.1 \
	cgi-bin/vboxadm.1 \
	cron/awl.8 \
	cron/cleanup.8 \
	cron/mailarchive.8 \
	cron/notify.8 \
	lib/VBoxAdm/Controller/Frontend.3 \
	lib/VBoxAdm/Model/Alias.3 \
	lib/VBoxAdm/Model/AWL.3 \
	lib/VBoxAdm/Model/Domain.3 \
	lib/VBoxAdm/Model/DomainAlias.3 \
	lib/VBoxAdm/Model/Mailbox.3 \
	lib/VBoxAdm/Model/MessageQueue.3 \
	lib/VBoxAdm/Model/User.3 \
	lib/VBoxAdm/Model/VacationBlacklist.3 \
	lib/VBoxAdm/SMTP/Client.3 \
	lib/VBoxAdm/SMTP/Mailarchive.3 \
	lib/VBoxAdm/SMTP/Proxy.3 \
	lib/VBoxAdm/SMTP/Server.3 \
	lib/VBoxAdm/API.3 \
	lib/VBoxAdm/DB.3 \
	lib/VBoxAdm/L10N.3 \
	lib/VBoxAdm/Migration.3 \
	lib/VBoxAdm/Model.3 \
	lib/VBoxAdm/Password.3 \
	lib/VBoxAdm/SaltedHash.3 \
	lib/VBoxAdm/Utils.3

TESTFILES = \
	t/VBoxAdm/Controller/Frontend.t \
	t/VBoxAdm/L10N/de.t \
	t/VBoxAdm/L10N/en.t \
	t/VBoxAdm/Model/Alias.t \
	t/VBoxAdm/Model/AWL.t \
	t/VBoxAdm/Model/Domain.t \
	t/VBoxAdm/Model/DomainAlias.t \
	t/VBoxAdm/Model/Mailbox.t \
	t/VBoxAdm/Model/MessageQueue.t \
	t/VBoxAdm/Model/User.t \
	t/VBoxAdm/Model/VacationBlacklist.t \
	t/VBoxAdm/SMTP/Client.t \
	t/VBoxAdm/SMTP/Mailarchive.t \
	t/VBoxAdm/SMTP/Proxy.t \
	t/VBoxAdm/SMTP/Server.t \
	t/VBoxAdm/API.t \
	t/VBoxAdm/DB.t \
	t/VBoxAdm/L10N.t \
	t/VBoxAdm/Migration.t \
	t/VBoxAdm/Model.t \
	t/VBoxAdm/SaltedHash.t \
	t/VBoxAdm/Utils.t

.PHONY: install tidy critic test

%.pl: %.ipl $(LIBFILES)
	$(SED) -e s/@BUILDDATE@/$(BUILDDATE)/ \
		   -e s/@VERSION@/$(VERSION)/ < $< > $@
	$(CHMOD) 755 $@
	$(PERLTIDY) $@
	$(CHMOD) +x $@
	$(PERL) -I lib/ -c $@

%.fcgi: %.ifcgi $(LIBFILES)
	$(SED) -e s/@BUILDDATE@/$(BUILDDATE)/ \
		   -e s/@VERSION@/$(VERSION)/ < $< > $@
	$(CHMOD) 755 $@
	$(PERLTIDY) $@
	$(CHMOD) +x $@
	$(PERL) -I lib/ -c $@

%.pm: %.ipm
	$(SED) -e s/@BUILDDATE@/$(BUILDDATE)/ \
		   -e s/@VERSION@/$(VERSION)/ < $< > $@
	$(PERLTIDY) $@

%.t: %.it
	$(SED) -e s/@BUILDDATE@/$(BUILDDATE)/ \
		   -e s/@VERSION@/$(VERSION)/ < $< > $@
	$(PERLTIDY) $@
	
%.1: %.pl
	doc/make-man.pl $< $@

%.3: %.pm
	doc/make-man.pl $< $@

%.8: %.pl
	doc/make-man.pl $< $@

all: $(LIBFILES) $(BINFILES) $(TESTFILES) $(MANFILES)

lib: $(LIBFILES)

re: clean all

quick-install: real-install

install: clean real-install

real-install: all test rcvboxadm
	$(INSTALL) -d $(BINDIR) $(SBINDIR) $(DESTDIR)/etc
	$(INSTALL) -d $(CFGDIR)/vboxadm
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/L10N $(LIBDIR)/VBoxAdm/SMTP $(LIBDIR)/VBoxAdm/Model $(LIBDIR)/VBoxAdm/Controller
	$(INSTALL) -d $(MANDIR)/man1 $(MANDIR)/man3 $(MANDIR)/man8
	$(INSTALL) -d $(VBOXLIBDIR)/bin $(VBOXLIBDIR)/tpl
	$(INSTALL) -g www-data -d $(VHDIR)/cgi-bin $(VHDIR)/htdocs/css $(VHDIR)/htdocs/images/knob
	$(INSTALL) -g www-data -d $(VHDIR)/htdocs/js/libs $(VHDIR)/htdocs/js/mylibs $(VHDIR)/htdocs/js/profiling
	$(INSTALL_PROGRAM) bin/vboxadm-ma.pl $(SBINDIR)/vboxadm-ma
	$(INSTALL_PROGRAM) bin/vacation.pl $(VBOXLIBDIR)/bin/vacation
	$(INSTALL_PROGRAM) bin/vboxadm-sa.pl $(SBINDIR)/vboxadm-sa
	$(INSTALL_PROGRAM) bin/vboxadm.pl $(BINDIR)/vboxadm
	$(INSTALL_DATA) bin/*.8 $(MANDIR)/man8/
	$(INSTALL_DATA) cgi-bin/*.1 $(MANDIR)/man1/
	$(INSTALL_DATA) cron/*.8 $(MANDIR)/man8/
	$(INSTALL_PROGRAM) cgi-bin/autodiscover.pl $(VHDIR)/cgi-bin/autodiscover.pl
	$(INSTALL_PROGRAM) cgi-bin/vboxadm.pl $(VHDIR)/cgi-bin/vboxadm.pl
	$(INSTALL_PROGRAM) cgi-bin/vboxadm.fcgi $(VHDIR)/cgi-bin/vboxadm.fcgi
	$(INSTALL_PROGRAM) cron/cleanup.pl $(VBOXLIBDIR)/bin/cleanup
	$(INSTALL_PROGRAM) cron/awl.pl $(VBOXLIBDIR)/bin/awl
	$(INSTALL_PROGRAM) cron/notify.pl $(VBOXLIBDIR)/bin/notify
	$(INSTALL_PROGRAM) cron/mailarchive.pl $(VBOXLIBDIR)/bin/mailarchive
	$(INSTALL_DATA) lib/VBoxAdm/Controller/*.pm $(LIBDIR)/VBoxAdm/Controller/
	$(INSTALL_DATA) lib/VBoxAdm/Controller/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/L10N/*.pm $(LIBDIR)/VBoxAdm/L10N/
	$(INSTALL_DATA) lib/VBoxAdm/Model/*.pm $(LIBDIR)/VBoxAdm/Model/
	$(INSTALL_DATA) lib/VBoxAdm/Model/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/*.pm $(LIBDIR)/VBoxAdm/SMTP/
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) lib/VBoxAdm/*.pm $(LIBDIR)/VBoxAdm/
	$(INSTALL_DATA) lib/VBoxAdm/VBoxAdm::*.3 $(MANDIR)/man3/
	$(INSTALL_DATA) tpl/*.tpl $(VBOXLIBDIR)/tpl/
	$(INSTALL_DATA) res/css/*.css $(VHDIR)/htdocs/css/
	$(INSTALL_DATA) res/images/*.png $(VHDIR)/htdocs/images/
	$(INSTALL_DATA) res/images/knob/*.png $(VHDIR)/htdocs/images/knob/
	$(INSTALL_DATA) res/js/*.js $(VHDIR)/htdocs/js/
	$(INSTALL_DATA) res/js/libs/*.js $(VHDIR)/htdocs/js/libs/
#	$(INSTALL_DATA) res/js/mylibs/*.js $(VHDIR)/htdocs/js/mylibs/
	$(INSTALL_DATA) res/js/profiling/*.js $(VHDIR)/htdocs/js/profiling/
	$(INSTALL_DATA) res/apple-touch-icon.png $(VHDIR)/htdocs/apple-touch-icon.png
	$(INSTALL_DATA) res/crossdomain.xml $(VHDIR)/htdocs/crossdomain.xml
	$(INSTALL_DATA) res/favicon.ico $(VHDIR)/htdocs/favicon.ico
	$(INSTALL_DATA) res/robots.txt $(VHDIR)/htdocs/robots.txt
	$(INSTALL_CONF) conf/vboxadm.conf.dist $(CFGDIR)/vboxadm/vboxadm.conf
	$(INSTALL_CONF) doc/apache/vboxadm.conf $(CFGDIR)/vboxadm/apache.conf
	$(INSTALL_CONF) doc/lighttpd/50-vboxadm.conf $(CFGDIR)/vboxadm/lighttpd.conf

tidy:
	$(PERLTIDY) lib/VBoxAdm/*.ipm
	$(PERLTIDY) lib/VBoxAdm/Model/*.ipm
	$(PERLTIDY) lib/VBoxAdm/L10N/*.ipm
	$(PERLTIDY) lib/VBoxAdm/SMTP/*.ipm
	$(PERLTIDY) t/VBoxAdm/*.it
	$(PERLTIDY) t/VBoxAdm/L10N/*.it
	$(PERLTIDY) t/VBoxAdm/Model/*.it
	$(PERLTIDY) bin/*.ipl
	$(PERLTIDY) cgi-bin/*.ipl
	$(PERLTIDY) cgi-bin/*.ifcgi
	$(PERLTIDY) cron/*.ipl
	$(PERLTIDY) contrib/*.ipl

clean:
	$(RM) -f bin/tmon.out
	$(RM) -f bin/*.bak
	$(RM) -f bin/*.pl
	$(RM) -f bin/*.ERR
	$(RM) -f bin/*.8
	$(RM) -f cgi-bin/*.bak
	$(RM) -f cgi-bin/*.pl
	$(RM) -f cgi-bin/*.fcgi
	$(RM) -f cgi-bin/*.1
	$(RM) -f contrib/*.bak
	$(RM) -f contrib/*.pl
	$(RM) -f cron/*.bak
	$(RM) -f cron/*.pl
	$(RM) -f cron/*.8
	$(RM) -f doc/man/*
	$(RM) -f lib/VBoxAdm/*.bak
	$(RM) -f lib/VBoxAdm/*.pm.LOG
	$(RM) -f lib/VBoxAdm/*.pm
	$(RM) -f lib/VBoxAdm/*.3
	$(RM) -f lib/VBoxAdm/Controller/*.bak
	$(RM) -f lib/VBoxAdm/Controller/*.pm.LOG
	$(RM) -f lib/VBoxAdm/Controller/*.pm
	$(RM) -f lib/VBoxAdm/Controller/*.3
	$(RM) -f lib/VBoxAdm/Model/*.bak
	$(RM) -f lib/VBoxAdm/Model/*.pm.LOG
	$(RM) -f lib/VBoxAdm/Model/*.pm
	$(RM) -f lib/VBoxAdm/Model/*.3
	$(RM) -f lib/VBoxAdm/L10N/*.bak
	$(RM) -f lib/VBoxAdm/L10N/*.pm.LOG
	$(RM) -f lib/VBoxAdm/L10N/*.pm
	$(RM) -f lib/VBoxAdm/L10N/*.3
	$(RM) -f lib/VBoxAdm/SMTP/*.bak
	$(RM) -f lib/VBoxAdm/SMTP/*.pm.LOG
	$(RM) -f lib/VBoxAdm/SMTP/*.pm
	$(RM) -f lib/VBoxAdm/SMTP/*.3
	$(RM) -f contrib/roundcube-plugin-vboxadm.tar.gz
	$(RM) -f t/VBoxAdm/*.t
	$(RM) -f t/VBoxAdm/*.bak
	$(RM) -f t/VBoxAdm/L10N/*.t
	$(RM) -f t/VBoxAdm/L10N/*.bak

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
	doc/release.pl --verbose

dist-local: git
	doc/release.pl --verbose --local

dist-minor: git
	doc/release.pl --verbose --minor

dist-major: test-all git
	doc/release.pl --verbose --major

critic:
	$(PERLCRITIC) --stern bin/
	$(PERLCRITIC) --stern lib/

test: all
	rm -rf .pc/
	QUICK_TEST=1 $(PROVE) -r

test-all: all
	$(PROVE) -r
