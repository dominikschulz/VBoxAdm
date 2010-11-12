include config.mk

OBJECTS = squirrelmail_vacation_proxy.o
LIBS = $(LCRYPT)

squirrelmail_vacation_proxy: $(OBJECTS)
	cc -o squirrelmail_vacation_proxy $(LFLAGS) $(OBJECTS) $(LIBS)

install: squirrelmail_vacation_proxy 
	install -g root -o root -m 4755 squirrelmail_vacation_proxy $(BINDIR)

clean:
	rm -f *.o *~* core squirrelmail_vacation_proxy 

squirrelmail_vacation_proxy.o: squirrelmail_vacation_proxy.c
	cc -c $(CFLAGS) $(DEBUG) $(USESHADOW) $(NOROOT) $(RESTRICTUSE) -D WEBUSER=\"$(WEBUSER)\" squirrelmail_vacation_proxy.c
