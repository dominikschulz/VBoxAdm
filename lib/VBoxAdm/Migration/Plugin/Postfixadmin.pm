package VBoxAdm::Migration::Plugin::Postfixadmin;
# ABSTRACT: VBoxAdm Migration Plugin for Postfixadmin import

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;
# use Carp;
# use English qw( -no_match_vars );
use Try::Tiny;

# extends ...
extends 'VBoxAdm::Migration::Plugin';
# has ...
# with ...
# initializers ...
sub _init_priority { return 10; }

# your code here ...
sub run {
    my $self = shift;
       if ( !$source_db ) {
            $source_db = 'postfix';
        }
        my $sql_domains         = "SELECT domain, active FROM domain ORDER BY domain";
        my $sth_domains         = $self->dbh()->prepare($sql_domains);
        my $sql_alias_domains   = "SELECT alias_domain, active FROM alias_domain WHERE target_domain = ? ORDER BY alias_domain";
        my $sth_alias_domains   = $self->dbh()->prepare($sql_alias_domains);
        my $sql_mailboxes       = "SELECT local_part, password, name, quota, active FROM mailbox WHERE domain = ?";
        my $sth_mailboxes       = $self->dbh()->prepare($sql_mailboxes);
        my $sql_domain_admin    = "SELECT username, domain FROM domains_admins WHERE active = 1";
        my $sth_domain_admin    = $self->dbh()->prepare($sql_domain_admin);
        my $sql_vacation        = "SELECT subject, body FROM vacation WHERE email = ?";
        my $sth_vacation        = $self->dbh()->prepare($sql_vacation);
        my $sql_vacation_notify = "SELECT on_vacation, notified, notified_at FROM vacation_notification WHERE notified_at > NOW() - INTERVAL 1 MONTH";
        my $sth_vacation_notify = $self->dbh()->prepare($sql_vacation_notify);

        #
        # Domains and Mailboxes
        #
        $sth_domains->execute();
        while ( my ( $domain, $is_active ) = $sth_domains->fetchrow_array() ) {

            # create a new domain
            $sth_new_domain->execute( $domain, $is_active )
              or die( "Could not execute query $sql_new_domain: " . $sth_new_domain->errstr );
            my $new_domain_id = $self->dbh()->last_insert_id( undef, undef, undef, undef ) || 1;
            $sth_mailboxes->execute($domain)
              or die( "Could not execute query $sql_mailboxes: " . $sth_mailboxes->errstr );
            while ( my @row = $sth_mailboxes->fetchrow_array() ) {
                my ( $local_part, $password, $name, $quota, $is_active ) = @row;
                $local_part = lc($local_part);
                my $is_on_vacation = 0;
                my $vacation_subj  = '';
                my $vacation_msg   = '';
                my $sa_active      = 1;
                my $sa_kill_score  = 6.31;
                my $is_domainadmin = 0;
                my $is_siteadmin   = 0;
                my $maxmsgsize     = 15 * 1024 * 1024;
                my $email          = $local_part . '@' . $domain;

                # process each mailbox
                # vacation status
                if ( $sth_vacation->execute($email) ) {
                    my ( $subj, $msg ) = $sth_vacation->fetchrow_array();
                    if ( $subj && $msg ) {
                        $is_on_vacation = 1;
                        $vacation_subj  = $subj;
                        $vacation_msg   = $msg;
                    }
                }
                $sth_new_mailbox->execute( $new_domain_id, $local_part, VWebAdm::SaltedHash::make_pass( $password, $self->config()->{'default'}{'pwscheme'} ),
                    $name, $is_active, $maxmsgsize, $is_on_vacation, $vacation_subj, $vacation_msg, $is_domainadmin, $is_siteadmin, $sa_active, $sa_kill_score,
                ) or die( "Could not execute query $sql_new_mailbox: " . $sth_new_mailbox->errstr );
                print
"New Mailbox: $new_domain_id, $local_part, $password, $name, $is_active, $maxmsgsize, $is_on_vacation,'$vacation_msg',$quota,$is_domainadmin,$is_siteadmin\n";
            }

            # domains aliases
            $sth_alias_domains->execute($domain)
              or die( "Could not execute query $sql_alias_domains: " . $sth_alias_domains->errstr );
            while ( my ( $domain_alias, $is_active ) = $sth_alias_domains->fetchrow_array() ) {

                # create new alias domain
                $sth_new_domain_alias->execute( $domain_alias, $new_domain_id )
                  or die( "Could not execute query $sql_new_domain_alias: " . $sth_new_domain_alias->errstr );
            }
        }

        # vacation notify
        $sth_vacation_notify->execute()
          or die( "Could not execute query $sql_vacation_notify: " . $sth_vacation_notify->errstr );
        while ( my ( $on_vacation, $notified, $notified_at ) = $sth_vacation_notify->fetchrow_array() ) {

            # insert vacation status
            $sth_vacation_status->execute( $on_vacation, $notified, $notified_at )
              or die( "Could not execute query $sql_vacation_status: " . $sth_vacation_status );
        }

        # domainadmins
        $sth_domain_admin->execute()
          or die( "Could not execute query $sql_domain_admin: " . $sth_domain_admin );
        while ( my ( $email, $domain ) = $sth_domain_admin->fetchrow_array() ) {
            my ( $local_part, $domain ) = split( /@/, $email );

            # update this user, set is_domainadmin = 1
            $sth_set_admin->execute( 1, 0, $local_part, $domain )
              or die( "Could not execute query $sql_set_admin: " . $sth_set_admin );

        }

        $sth_domains->finish();
        $sth_alias_domains->finish();
        $sth_mailboxes->finish();
        $sth_domain_admin->finish();
        $sth_vacation->finish();
        $sth_vacation_notify->finish();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Migration::Plugin::Postfixadmin - VBoxAdm Migration Plugin for Postfixadmin import

=method run

import

=cut
