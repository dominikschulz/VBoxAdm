FROM ubuntu:16.04

MAINTAINER Dominik Schulz <dominik.schulz@gauner.org>

RUN apt-get update --yes && apt-get install --yes --force-yes --no-install-recommends \
  build-essential \
  cpanminus \
  libcgi-application-basic-plugin-bundle-perl \
  libcgi-application-perl \
  libcgi-application-plugin-authentication-perl \
  libcgi-application-plugin-requiressl-perl \
  libcgi-application-plugin-tt-perl \
  libcgi-fast-perl \
  libconfig-std-perl \
  libcourriel-perl \
  libcrypt-cbc-perl \
  libdbd-mysql-perl \
  libdbi-perl \
  libdigest-md5-file-perl \
  libdigest-perl \
  libdigest-perl-md5-perl \
  libemail-date-format-perl \
  libhtml-clean-perl \
  libjson-perl \
  libmail-pop3client-perl \
  libmail-sender-perl \
  libmail-spamassassin-perl \
  libmime-encwords-perl \
  libmime-tools-perl \
  libmoose-perl \
  libnamespace-autoclean-perl \
  libnet-imap-client-perl \
  libnet-imap-perl \
  libnet-server-perl \
  libreadonly-perl \
  libtemplate-perl \
  libtest-pod-perl \
  libtest-memory-cycle-perl \
  libtext-csv-perl \
  libtext-csv-xs-perl \
  libtext-levenshtein-perl \
  lighttpd \
  make \
  openjdk-8-jre-headless \
  perl \
  perltidy \
  && rm -rf /var/lib/apt/lists/*

RUN cpanm \
  Log::Tree \
  Data::Pwgen

ADD . /srv/vboxadm
WORKDIR /srv/vboxadm
RUN make real-install

RUN ln -s /srv/vboxadm/doc/vboxadm/lighttpd/50-vboxadm-fcgi.conf /etc/lighttpd/conf-enabled/
RUN mkdir -p /etc/vboxadm
RUN cp /srv/vboxadm/conf/vboxadm.conf.dist /etc/vboxadm/vboxadm.conf && chmod 0644 /etc/vboxadm/vboxadm.conf

EXPOSE 80
EXPOSE 443

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
