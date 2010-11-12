# This is the configuration file for squirrelmail_vacation_proxy
#


# The binary could be installed in /usr/local/sbin
# Change this to fit with your system and remember 
# that it must match the $mail_vacation_binary
# setting in config.php in the parent directory
#
#BINDIR = /usr/local/sbin
BINDIR = ..



# Webserver user
# This is the only user that should be allowed to run the
# squirrelmail_vacation_proxy program.
#
WEBUSER = www-data



# To disable the WEBUSER check just comment out the 
# following line
#
#RESTRICTUSE = -D RESTRICTUSE



# To disallow use of this plugin for the root user,
# uncomment the following line
#
NOROOT = -D NOROOT



# To use the shadow password database file, 
# uncomment the following line
#
USESHADOW = -D USESHADOW



# Only uncomment this to debug problems with 
# the plugin
#
#DEBUG = -D DEBUG



# If your system complains about an "undefined reference to `crypt'"
# or similar, uncomment the following line
#
LCRYPT = -lcrypt 



## Compile time flags
#
LIBDIR =
CFLAGS = -g
LFLAGS = -g
CCM = cc -Em

