#!/usr/bin/perl
use strict;
use warnings;

use lib '@LIBDIR@';

use VBoxAdm::Controller::DMARC '@VERSION@';

my $RN = VBoxAdm::Controller::DMARC::->new();
$RN->run();

__END__

=head1 NAME

dmarc - Process DMARC reports

=head1 VERSION

This documentation refers to VBoxAdm notify version @VERSION@
built on @BUILDDATE@.

=head1 DESCRIPTION

TODO

=head1 CONFIGURATION AND ENVIRONMENT

The configuration file should be place either in /etc/vboxadm.conf or
in /etc/vboxadm/vboxadm.conf. This is a common configuration file
for the whole suite of VBoxAdm applications. Each part of this suite
has its own section in the config file and all use the values
from the default section when appropriate.

=head2 default
The default section should contain at least the database configuration.

dbuser - The user used to connect to the MySQL database.
dbpass - This users password.
dbdb - The db used by this application.
dbhost - The MySQL database host, usually localhost.

=head2 notify

server - the mailserver
username - the dmarc report mailbox
password - the password
folder (optional) - the folder containing the DMARC reports
delete - when true all processed mails will be removed from the mailbox

=head1 DEPENDENCIES

VWebAdm::Utils, DBI.

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to Dominik Schulz (dominik.schulz@gauner.org)
Patches are welcome.

=head1 AUTHOR

Dominik Schulz (dominik.schulz@gauner.org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Dominik Schulz (dominik.schulz@gauner.org). All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
