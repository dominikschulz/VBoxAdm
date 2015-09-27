FROM ubuntu:14.04

MAINTAINER Dominik Schulz <dominik.schulz@gauner.org>

RUN apt-get update --yes && apt-get install --yes --force-yes --no-install-recommends \
  build-essential \
  make \
  perl \
  perltidy \
  libdbi-perl \
  libdbd-mysql-perl \
  libconfig-std-perl \
  libtest-pod-perl \
  libmail-sender-perl \
  libcgi-application-perl \
  libcgi-application-basic-plugin-bundle-perl \
  libmime-encwords-perl \
  libhtml-clean-perl \
  libtemplate-perl \
  lighttpd \
  libmail-spamassassin-perl \
  libnet-imap-perl \
  libjson-perl \
  libreadonly-perl \
  libcgi-fast-perl \
  libcrypt-cbc-perl \
  libdigest-perl \
  libtext-csv-perl \
  libdigest-md5-file-perl 
  && rm -rf /var/lib/apt/lists/*

ADD . /srv/vboxadm
RUN cd /srv/vboxadm && make install

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

