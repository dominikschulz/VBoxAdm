#
# Makefile for mysql-toolkit
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
VERSION = 0.0.1
BUILDDATE = $(shell date +%Y-%m-%d)

# Directories
BINDIR=$(DESTDIR)/usr/bin
SBINDIR=$(DESTDIR)/usr/sbin
MANDIR=$(DESTDIR)/usr/share/man
CFGDIR ?= $(DESTDIR)/etc
LIBDIR=$(DESTDIR)/usr/share/perl5
VBOXLIBDIR=$(DESTDIR)/usr/lib/mtk
VHDIR=$(DESTDIR)/var/lib/vboxadm

# Files
BINFILES = \
	bin/vacation.pl \
	cgi-bin/vboxadm.pl \
	cron/cleanup.pl

LIBFILES = \
	lib/VboxAdm/Frontend.pm

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

man:
	mkdir -p doc/man/
	$(POD2MAN) --center=" " --section=8 --release="vboxadm" lib/VBoxAdm/Frontend.ipm > doc/man/VBoxAdm::Frontend.8

quick-install: real-install

install: clean real-install

real-install: all test man
	$(INSTALL) -d $(BINDIR) $(SBINDIR) $(DESTDIR)/etc
	$(INSTALL) -d $(CFGDIR)/vboxadm
	$(INSTALL) -d $(LIBDIR)/VBoxAdm
	$(INSTALL) -d $(MANDIR)/man1 $(MANDIR)/man3 $(MANDIR)/man8
	$(INSTALL) -d $(VBOXLIBDIR)/bin
	$(INSTALL) -g www-data -d $(VHDIR)/cgi-bin $(VHDIR)/htdocs/css $(VHDIR)/htdocs/images $(VHDIR)/htdocs/js
	$(INSTALL_DATA) doc/man/VBoxAdm::Frontend.8 $(MANDIR)/man8/VBoxAdm::Frontend.8
	$(INSTALL_PROGRAM) bin/vacation.pl $(VBOXLIBDIR)/bin/vacation
	$(INSTALL_PROGRAM) cgi-bin/vboxadm.pl $(VHDIR)/cgi-bin/vboxadm.pl
	$(INSTALL_PROGRAM) cron/cleanup.pl $(VBOXLIBDIR)/bin/cleanup
	$(INSTALL_DATA) lib/VBoxAdm/Frontend.pm $(LIBDIR)/VBoxAdm/Frontend.pm
#	$(INSTALL_DATA) res/css/ocp.css $(VHDIR)/htdocs/css/ocp.css
#	$(INSTALL_DATA) res/js/sorttable.js $(VHDIR)/htdocs/js/sorttable.js
#	$(INSTALL_DATA) res/images/*.png $(VHDIR)/htdocs/images/
#	$(INSTALL_DATA) res/images/*.svg $(VHDIR)/htdocs/images/
#	$(INSTALL_DATA) res/images/*.gif $(VHDIR)/htdocs/images/
	$(INSTALL_CONF) conf/vboxadm.conf.dist $(CFGDIR)/vboxadm/vboxadm.conf

tidy:
	$(PERLTIDY) lib/VBoxAdm/*.ipm
	$(PERLTIDY) bin/*.ipl
	$(PERLTIDY) cgi-bin/*.ipl
	$(PERLTIDY) cron/*.ipl

clean:
	$(RM) -f bin/tmon.out
	$(RM) -f bin/*.bak
	$(RM) -f bin/*.pl
	$(RM) -f bin/*.ERR
	$(RM) -f cgi-bin/*.bak
	$(RM) -f cgi-bin/*.pl
	$(RM) -f cron/*.bak
	$(RM) -f cron/*.pl
	$(RM) -f doc/man/*
	$(RM) -f lib/VBoxAdm/*.bak
	$(RM) -f lib/VBoxAdm/*.pm

git: tidy all clean
	$(GIT) status
	$(GIT) diff
	$(GIT) commit -a || true
	$(GIT) push kronos
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
