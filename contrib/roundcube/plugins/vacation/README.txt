About
-----
The vacation plugin allows mail to be forwarded and/or auto-replied with a
custom subject / message body.
Note that the actual auto-reply is done by a program such as /usr/bin/vacation
,the virtual user aware vacation.pl or a Sieve script.


Features
--------
The following combination of features is supported for end-users:
- keep a local copy of the mail
- forward the mail to another e-mail address
- send an out of office reply with custom subject & message body
- enable auto-reply for aliases (all drivers except for SQL) 

An administrator can configure the following options:
- Support for default subject and body.
- Per host config + driver and ability to disable 'Vacation' tab on a per-host basis


Licensing
----------
This product is distributed under the GPL. Please read through the file
LICENSE in Roundcube's root directory for more information about the license.


Available drivers
------------------
The following drivers are available to do the low level work:
- Sieve. This driver uses ManagedSieve to set/get the Sieve script for sending mail.
- FTP. This driver uploads the .forward file to the user's homedirectory.
- SSHFTP. This driver uses SSH to upload .forward file to the user's homedirectory.
- Setuid. This driver places the .forward file in the user's homedirectory using
the squirrel setuid binary.
- SQL. This driver creates entries in the vacation table in a MySQL database and
modifies the alias table.
At the moment the SQL driver is tailored towards Postfix with either MySQL or PostgreSQL
 but can be modified to suit other configurations.
- None. This driver disables the Vacation tab for hosts that do not support Out of office replies.

More on each driver below: 


FTP Driver
----------

The FTP driver establishes an FTP-connection to the current IMAP-host or the server
specified in config.ini
The login credentials of the current user are used to login to the FTP-server.   

If .forward exists and it contains /usr/bin/vacation (as specified in config.ini),
the out of office is enabled. 

If there are any forwarding addresses found in .forward, these are displayed to the user.

If alias_identities = true and there are any aliases found in .forward,
these are displayed to the user.
If alias_identities = true and there are no aliases found in .forward,
 the identities are loaded and shown. 

An alias contains no domain as it's limited to normal system users (/etc/passwd).
If there is more than one identity present, the button 'Get aliases' is shown. 

In either case it then downloads the .vacation.msg file that contains both
 message body and subject. If .vacation.msg cannot be found,
it uses the default body and subject as defined in 'config.ini'.

Requirements for using this driver:
- A working FTP-server that allows users to login to their $HOME directory.
- The SMTP-server must use .forward files found in the $HOME directory
- The FTP-server must allow upload of dot-files. Pure-ftpd does not allow this by default


SSHFTP Driver
-------------

The SSHFTP backend uses SSH to establish a secure connection to the current
IMAP-host or the server specified in config.ini
It then uses the SFTP subsystem to read and write files.
The SSHFTP behaves just like the FTP driver.

Requirements for using this driver:
- Requires PECL package to be installed. See http://nl2.php.net/manual/en/ssh2.installation.php
- The SMTP-server must use .forward files in the $HOME directory

Sieve driver
------------
TBD
http://wiki.dovecot.org/ManageSieve/Configuration




Setuid Driver
-------------
The setuid backend uses a setuid binary to read/write .forward,.vacation.msg
files for the current logged in user.
Apache executes the setuid binary and passes the user credentials as parameters. 

The extra/vacation_binary/ directory of the plugin contains the setuid binary and its source code. 
To install this driver, change directory to $path/to/extra/vacation_binary and
issue with root priviliges the command: "make install".

This command install "squirrel_vacation_proxy" to /usr/bin with the setuid bit set.
This directory can be changed in config.mk

Apart from the way it reads/writes files, it behaves like the FTP driver.

Requirements for using this driver:
- The Apache user needs to be 'apache' or you need to edit config.mk
and recompile squirrelmail_vacation_proxy using 'make'.

Requirement for using .forward files
------------------------------------
The SSHFTP, FTP and setuid backend all use .forward files.
See config.ini for available options, like enabling identities, keeping copies etc.

If you want to use one of these drivers, please note: 
- The /usr/bin/binary must create .vacation.db when it is missing.
- Upgrade to vacation 1.2.7.0 as earlier versions have a bug that cause vacation to crash when
  .vacation.db is missing.


Virtual/SQL Driver
------------------
The Virtual/SQL driver is the most advanced driver but tailored to be used with Postfix. 
This is how it works:

If the vacation box gets checked by the end-user a new virtual alias will be created in the designated table as
joe@domain.org@vacation.domain.org
The 'vacation.domain.org' part is configered in config.ini (see also INSTALL.TXT) as well as /etc/postfix/master.cf

joe@domain.org is passed as a for the 'vacation.pl' script that is associated with 'vacation.domain.org' transport.
This vacation.pl fetches the mail body and subject from the database and constructs a new mail.

The code is tested with a Postfix/MySQL setup based on the tutorials at http://workaround.org/ispmail/lenny
It supports either normalized tables (domain_id) or non-normalized tables (domainname).
Please see config.ini for options.

While the driver should be able to work with different database schemes,for the vacation table 
layout it relies on the schema which can be found in the extra/virtual_vacation directory.

Installation instructions are provided by the Postfixadmin team,
 included in the extra/virtual_vacation directory.
Please follow the instructions as described in INSTALL.TXT before enabling the driver.

The virtual driver can create /etc/postfixadmin/vacation.conf for you,
based on the current database configuration.
To enable this, set createvacationconf = True in config.ini 

You do not need Postfixadmin to use the virtual vacation plugin. 

From a security point of view it's recommended to use a dedicated database user
for the SQL driver for virtual users. 
This user must have UPDATE,SELECT and INSERT privileges to database 'postfix',
table 'vacation' and database 'postfix', table 'virtual_aliases'.
It should not be able to access Roundcube's tables.

For MySQL the following can be used:
CREATE USER 'virtual_vacation'@'localhost' IDENTIFIED BY 'choose_a_password';
GRANT UPDATE,INSERT,SELECT ON `postfix` . vacation TO 'virtual_vacation'@'localhost';
GRANT DELETE,INSERT,SELECT ON `postfix` . virtual_aliases TO 'virtual_vacation'@'localhost';

If Roundcube's main DSN is somehow affected by an SQL injection bug,
no damage can be done to the actual maildelivery.
Using a dedicated DSN is optional, the plugin works fine with the main DSN.

Aliases are not supported as the implemention in vacation.pl is specific for postfixadmin.
You can however change the source code so it matches your setup. This is beyond the scope
of this driver. 


None Driver
-----------
This pseudo driver disables the Vacation tab for hosts that do not support Out of office replies.


Writing a new driver
--------------------
1) Create relevant entries in config.ini. The name of array key must match the class name.
3) Create lib/$driver.class.php
3) Have your new driver extend VacationDriver
4) Implement abstract public methods from base class: init(), setVacation(),_get()
   You can access configuration settings using $this->cfg or $this->dotforward
   Form variables can be accessed directly using class properties, see save() method
5) Write new private helper methods like is_active() if needed.
6) Register the available options for this driver in VacationConfig.class.php
7) Test it
8) Submit a patch


Troubleshooting
---------------
For troubleshooting, you want to increase the log_level in config/main.inc.php to 4,
 so errors are shown.
Be sure to check the content of the database or .forward. 
Check also appropriate maillog to see what's going on.


Known bugs / limitations
------------------------
- Translations are incomplete


Todo
----
- LDAP support
- Support for setting envelop sender in with settings other than -Z
- Handling case when no identities are found.


Credits
-------
- The Postfixadmin team for creating the virtual vacation program.
- Squirrelmail team for the setuid backend binary
- Peter Ruiter for his initial work on the plugin.
- Rick Saul and Johnson Chow for testing


Patches,feedback and suggestions
--------------------------------
Please submit patches and suggestions by e-mail (jaspersl @ gmail . com).
Project URL: https://sourceforge.net/projects/rcubevacation/
Feedback is always welcome.
