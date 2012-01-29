#!/usr/bin/perl
use strict;
use warnings;

use lib '@LIBDIR@';

use VBoxAdm::Controller::Notify '@VERSION@';

my $RN = VBoxAdm::Controller::Notify::->new();
$RN->run();

__END__

=head1 NAME

notify - Notify senders, postmaster and recipients about misconfigured mailservers.

=head1 VERSION

This documentation refers to VBoxAdm notify version @VERSION@
built on @BUILDDATE@.

=head1 DESCRIPTION

This script implements notification of senders, postmaster
and recipients of mail sent from misconfigured mailservers.
Usually this mail is rejected our mailserver and as well the sender
as the recipient wonder why their mail is not delivered.

Most of the time the recjected messages may be spam, but some
of them could be legitimated, important, messages which you don't want to
loose. This script might make the involved parties aware of this
situation by sending messages to (a) the original sender, (b) the
designated recipient and (c) the postmaster of the sending mailserver.

THIS SCRIPT MUST BE USED WITH CARE!

This script could cause collateral damage, so please think
about the consequences before using if and watch it closely.

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

logfile - The logfile.

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
