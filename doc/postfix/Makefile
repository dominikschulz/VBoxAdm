# Makefile for postfix maps
POSTMAP = /usr/sbin/postmap
BTREE = \
	/etc/postfix/maps/access_recipient-rfc.db \
	/etc/postfix/maps/access_client.db \
	/etc/postfix/maps/access_helo.db \
	/etc/postfix/maps/access_sender.db \
	/etc/postfix/maps/access_recipient.db \
	/etc/postfix/maps/transport.db

%.db: %
	$(POSTMAP) btree:$<

maps: $(BTREE)
	postfix reload
