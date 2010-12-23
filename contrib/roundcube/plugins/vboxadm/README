Roundcube VeximAccountAdmin plugin: README
Last updated: 2009-11-12
===========================================

About
================

Plugin that covers the non-admin part of Vexim web interface.

Possible future versions will be posted to:
http://axel.sjostedt.no/misc/dev/roundcube/

Author
================
Written by Axel Sjostedt.

Install
================

* Place plugin folder into plugins directory of Roundcube
* Enable the plugin by adding it to the Roundcube configuration file 
  Example: 
     $rcmail_config['plugins'] = array("veximaccountadmin", "otherplugin")

Configuration 
================

* Copy config.inc.php.dist to config.inc.php in the plugin folder
  It is recommended to keep the dist file.
* You should make sure config.inc.php is not public-readable, as it
  will contain the password to your Vexim database
* Open config.inc.php
* Add your Vexim database info
* Check that the cryptscheme and vexim_vacation_maxlength settings
  is the same as in your Vexim config 
* If you use any of the Exim/Vexim customizations described on 
  http://axel.sjostedt.no/misc/dev/vexim-customizations/ (disable saving
  of passwords in clear text, move spam to folder support, shell spam 
  parsing script), you should enable support for these in
  VeximAccountAdmin config.
* Check that the Vexim URL is correct if you want to provide a Vexim link
  to admin users

Other notes
================
If you also want to update your Vexim login page with a Roundcube-like
design, see http://axel.sjostedt.no/misc/dev/vexim-customizations/
