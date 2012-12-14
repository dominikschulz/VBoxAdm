#
# Makefile for vboxadm
#

# some variables
NAME = vboxadm
VERSION = 0.2.32
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

.PHONY: install tidy critic test

all: $(LIBFILES) $(BINFILES) $(TESTFILES) $(MANFILES) $(CSSFILES) $(JSFILES) $(TPLFILES)

lib: $(LIBFILES)

re: clean all

quick-install: real-install

install: clean real-install

real-install: all test rcvboxadm
	$(INSTALL) -d $(BINDIR)
	$(INSTALL) -d $(SBINDIR)
	$(INSTALL) -d $(DESTDIR)/etc
	$(INSTALL) -d $(CFGDIR)/vboxadm
	$(INSTALL) -d $(CFGDIR)/vdnsadm
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/Controller
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/L10N
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/Model
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/SMTP/Proxy
	$(INSTALL) -d $(LIBDIR)/VDnsAdm/Controller
	$(INSTALL) -d $(LIBDIR)/VDnsAdm/L10N
	$(INSTALL) -d $(LIBDIR)/VDnsAdm/Model
	$(INSTALL) -d $(LIBDIR)/VWebAdm/Model
	$(INSTALL) -d $(MANDIR)/man1
	$(INSTALL) -d $(MANDIR)/man3
	$(INSTALL) -d $(MANDIR)/man8
	$(INSTALL) -d $(VBOXLIBDIR)/bin
	$(INSTALL) -d $(VBOXLIBDIR)/munin
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/alias
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/autoconfig
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/awl
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/domain
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/domain_alias
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/includes
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/mailbox
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/notify
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/rfc_notify
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/vacation_blacklist
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/vacation_notify
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vboxadm/role_account
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vdnsadm/domain
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vdnsadm/includes
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vdnsadm/record
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vdnsadm/user
	$(INSTALL) -d $(VWEBLIBDIR)/tpl/vwebadm/includes
	$(INSTALL) -g $(WWWGROUP) -d $(VBOXVHDIR)/cgi-bin
	$(INSTALL) -g $(WWWGROUP) -d $(VDNSVHDIR)/cgi-bin
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/images/knob
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/images/datatables
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/css/datatable
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/css/themes/ui-darkness/images
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/js/libs
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/js/mylibs
	$(INSTALL) -g $(WWWGROUP) -d $(VWEBVHDIR)/htdocs/js/profiling
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
	$(INSTALL_PROGRAM) cron/dmarc.pl $(VBOXLIBDIR)/bin/dmarc
	$(INSTALL_PROGRAM) cron/mailarchive.pl $(VBOXLIBDIR)/bin/mailarchive
	$(INSTALL_PROGRAM) cron/notify.pl $(VBOXLIBDIR)/bin/notify
	$(INSTALL_PROGRAM) contrib/munin/vboxadm_cache $(VBOXLIBDIR)/munin/vboxadm_cache
	$(INSTALL_PROGRAM) contrib/munin/vboxadm_spam $(VBOXLIBDIR)/munin/vboxadm_spam
	$(INSTALL_CONF) doc/vboxadm/apache/vboxadm.conf $(CFGDIR)/vboxadm/apache.conf
	$(INSTALL_CONF) doc/vboxadm/lighttpd/50-vboxadm.conf $(CFGDIR)/vboxadm/lighttpd.conf
	$(INSTALL_CONF) doc/vdnsadm/apache/vdnsadm.conf $(CFGDIR)/vdnsadm/apache.conf
	$(INSTALL_CONF) doc/vdnsadm/lighttpd/50-vdnsadm.conf $(CFGDIR)/vdnsadm/lighttpd.conf
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
	$(INSTALL_DATA) tpl/vboxadm/role_account/*.tpl $(VWEBLIBDIR)/tpl/vboxadm/role_account/
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
	echo "ok"

clean:
	echo "ok"

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
