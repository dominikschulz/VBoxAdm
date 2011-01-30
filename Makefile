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
VERSION = 0.0.27
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
	bin/smtpproxy.pl \
	cgi-bin/vboxadm.pl \
	cron/cleanup.pl \
	cron/awl.pl \
	cron/notify.pl \
	contrib/migration.pl \
	contrib/lexicons-export.pl \
	contrib/lexicons-import.pl \
	contrib/is_utf8.pl \
	contrib/mkadmin.pl

LIBFILES = \
	lib/VBoxAdm/DovecotPW.pm \
	lib/VBoxAdm/Frontend.pm \
	lib/VBoxAdm/SmtpProxy.pm \
	lib/VBoxAdm/Utils.pm \
	lib/VBoxAdm/L10N.pm \
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
	lib/VBoxAdm/SMTP/Client.pm \
	lib/VBoxAdm/SMTP/Server.pm \
	lib/MSDW/SMTP/Client.pm \
	lib/MSDW/SMTP/Server.pm

TESTFILES = \
	t/VBoxAdm/L10N/de.t \
	t/VBoxAdm/L10N/en.t \
	t/VBoxAdm/DovecotPW.t \
	t/VBoxAdm/Frontend.t \
	t/VBoxAdm/L10N.t \
	t/VBoxAdm/SmtpProxy.t \
	t/VBoxAdm/Utils.t

.PHONY: install tidy critic test

%.pl: %.ipl
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

all: $(LIBFILES) $(BINFILES) $(TESTFILES)

lib: $(LIBFILES)

re: clean all

man:
	mkdir -p doc/man/
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/DovecotPW.ipm > doc/man/VBoxAdm::DovecotPW.8
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/Frontend.ipm > doc/man/VBoxAdm::Frontend.8
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/SmtpProxy.ipm > doc/man/VBoxAdm::SmtpProxy.8
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/Utils.ipm > doc/man/VBoxAdm::Utils.8
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/SMTP/Client.ipm > doc/man/VBoxAdm::SMTP::Client.8
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/SMTP/Server.ipm > doc/man/VBoxAdm::SMTP::Server.8

quick-install: real-install

install: clean real-install

real-install: all test man rcvboxadm
	$(INSTALL) -d $(BINDIR) $(SBINDIR) $(DESTDIR)/etc
	$(INSTALL) -d $(CFGDIR)/vboxadm
	$(INSTALL) -d $(LIBDIR)/VBoxAdm/L10N $(LIBDIR)/VBoxAdm/SMTP $(LIBDIR)/MSDW/SMTP
	$(INSTALL) -d $(MANDIR)/man1 $(MANDIR)/man3 $(MANDIR)/man8
	$(INSTALL) -d $(VBOXLIBDIR)/bin $(VBOXLIBDIR)/tpl
	$(INSTALL) -g www-data -d $(VHDIR)/cgi-bin $(VHDIR)/htdocs/css $(VHDIR)/htdocs/images/knob
	$(INSTALL) -g www-data -d $(VHDIR)/htdocs/js/libs $(VHDIR)/htdocs/js/mylibs $(VHDIR)/htdocs/js/profiling
	$(INSTALL_DATA) doc/man/VBoxAdm::DovecotPW.8 $(MANDIR)/man8/VBoxAdm::DovecotPW.8
	$(INSTALL_DATA) doc/man/VBoxAdm::Frontend.8 $(MANDIR)/man8/VBoxAdm::Frontend.8
	$(INSTALL_DATA) doc/man/VBoxAdm::SmtpProxy.8 $(MANDIR)/man8/VBoxAdm::SmtpProxy.8
	$(INSTALL_DATA) doc/man/VBoxAdm::Utils.8 $(MANDIR)/man8/VBoxAdm::Utils.8
	$(INSTALL_DATA) doc/man/VBoxAdm::SMTP::Client.8 $(MANDIR)/man8/VBoxAdm::SMTP::Client.8
	$(INSTALL_DATA) doc/man/VBoxAdm::SMTP::Server.8 $(MANDIR)/man8/VBoxAdm::SMTP::Server.8
	$(INSTALL_PROGRAM) bin/vacation.pl $(VBOXLIBDIR)/vacation
	$(INSTALL_PROGRAM) bin/smtpproxy.pl $(SBINDIR)/vboxadm-smtpproxy
	$(INSTALL_PROGRAM) cgi-bin/vboxadm.pl $(VHDIR)/cgi-bin/vboxadm.pl
	$(INSTALL_PROGRAM) cron/cleanup.pl $(VBOXLIBDIR)/bin/cleanup
	$(INSTALL_DATA) lib/MSDW/SMTP/Client.pm $(LIBDIR)/MSDW/SMTP/Client.pm
	$(INSTALL_DATA) lib/MSDW/SMTP/Server.pm $(LIBDIR)/MSDW/SMTP/Server.pm
	$(INSTALL_DATA) lib/VBoxAdm/DovecotPW.pm $(LIBDIR)/VBoxAdm/DovecotPW.pm
	$(INSTALL_DATA) lib/VBoxAdm/Frontend.pm $(LIBDIR)/VBoxAdm/Frontend.pm
	$(INSTALL_DATA) lib/VBoxAdm/SmtpProxy.pm $(LIBDIR)/VBoxAdm/SmtpProxy.pm
	$(INSTALL_DATA) lib/VBoxAdm/Utils.pm $(LIBDIR)/VBoxAdm/Utils.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N.pm $(LIBDIR)/VBoxAdm/L10N.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/de.pm $(LIBDIR)/VBoxAdm/L10N/de.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/en.pm $(LIBDIR)/VBoxAdm/L10N/en.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/es.pm $(LIBDIR)/VBoxAdm/L10N/es.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/fr.pm $(LIBDIR)/VBoxAdm/L10N/fr.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/it.pm $(LIBDIR)/VBoxAdm/L10N/it.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/pl.pm $(LIBDIR)/VBoxAdm/L10N/pl.pm
	$(INSTALL_DATA) lib/VBoxAdm/L10N/pt.pm $(LIBDIR)/VBoxAdm/L10N/pt.pm
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/Client.pm $(LIBDIR)/VBoxAdm/SMTP/Client.pm
	$(INSTALL_DATA) lib/VBoxAdm/SMTP/Server.pm $(LIBDIR)/VBoxAdm/SMTP/Server.pm
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
	$(PERLTIDY) lib/VBoxAdm/L10N/*.ipm
	$(PERLTIDY) lib/VBoxAdm/SMTP/*.ipm
	$(PERLTIDY) lib/MSDW/SMTP/*.ipm
	$(PERLTIDY) bin/*.ipl
	$(PERLTIDY) cgi-bin/*.ipl
	$(PERLTIDY) cron/*.ipl
	$(PERLTIDY) contrib/*.ipl

clean:
	$(RM) -f bin/tmon.out
	$(RM) -f bin/*.bak
	$(RM) -f bin/*.pl
	$(RM) -f bin/*.ERR
	$(RM) -f cgi-bin/*.bak
	$(RM) -f cgi-bin/*.pl
	$(RM) -f contrib/*.bak
	$(RM) -f contrib/*.pl
	$(RM) -f cron/*.bak
	$(RM) -f cron/*.pl
	$(RM) -f doc/man/*
	$(RM) -f lib/VBoxAdm/*.bak
	$(RM) -f lib/VBoxAdm/*.pm
	$(RM) -f lib/VBoxAdm/L10N/*.bak
	$(RM) -f lib/VBoxAdm/L10N/*.pm
	$(RM) -f lib/VBoxAdm/SMTP/*.bak
	$(RM) -f lib/VBoxAdm/SMTP/*.pm
	$(RM) -f lib/MSDW/SMTP/*.bak
	$(RM) -f lib/MSDW/SMTP/*.pm
	$(RM) -f contrib/roundcube-plugin-vboxadm.tar.gz

rcvboxadm:
	cd contrib/roundcube/plugins/ && tar -cvzf ../../roundcube-plugin-vboxadm.tar.gz vboxadm/ && cd ../../../

git: tidy all clean
	$(GIT) status
	$(GIT) diff
	$(GIT) commit -a || true
	$(GIT) push origin
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

test: all
	rm -rf .pc/
	QUICK_TEST=1 $(PROVE) -r

test-all: all
	$(PROVE) -r
