package VBoxAdm::Migration::Plugin::Vexim;
# ABSTRACT: VBoxAdm Migration Plugin for Vexim import

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

    #
    # Iterate over all domains, we need the domain_id
    #
    my $query       = 'SELECT domain_id,domain,enabled FROM `' . $self->parent()->sourcedb . '`.domains';
    my $sth_domains = $self->dbh()->prepare($query);
    $query = "SELECT alias FROM vexim.domainalias WHERE domain_id = ?";
    my $sth_domainalias = $self->dbh()->prepare($query);
    $query =
'SELECT localpart,clear,smtp,pop,type,admin,on_vacation,enabled,forward,maxmsgsize,quota,realname,vacation,on_spamassassin,sa_refuse,crypt,on_forward FROM `'
      . $self->parent()->sourcedb
      . '`.users WHERE domain_id = ?';
    my $sth_users = $self->dbh()->prepare($query);

    $sth_domains->execute()
      or die( "Could not execute query $query: " . $sth_domains->errstr );
    while ( my ( $old_domain_id, $domain, $is_active ) = $sth_domains->fetchrow_array() ) {

        #
        # Create new domain
        #
        if ( !$self->sth_new_domain->execute( $domain, $is_active ) ) {
            warn( "Could not execute Query: " . $self->sth_new_domain->errstr );
            next;
        }
        my $new_domain_id = $self->dbh()->last_insert_id( undef, undef, undef, undef ) || 1;

        #
        # Convert domain_aliases
        #
        $sth_domainalias->execute($old_domain_id);
        while ( my $domain_alias = $sth_domainalias->fetchrow_array() ) {

            #
            # Create new domain alias
            #
            $self->sth_new_domain_alias->execute( $domain_alias, $new_domain_id )
              or warn( "Could not execute query: " . $self->sth_new_domain_alias->errstr );
        }

        #
        # Convert users/aliases
        #
        $sth_users->execute($old_domain_id);
        while ( my @row = $sth_users->fetchrow_array() ) {
            my (
                $localpart,  $pwclear, $smtp,     $pop,          $type,      $admin,         $on_vacation, $enabled, $forward,
                $maxmsgsize, $quota,   $realname, $vacation_msg, $sa_active, $sa_kill_score, $pwcrypt,     $on_forward,
            ) = @row;
            my $is_siteadmin     = 0;
            my $is_domainadmin   = 0;
            my $is_alias         = 0;
            my $is_local         = 0;
            my $alias_is_enabled = 0;
            $localpart = lc($localpart);
            $vacation_msg ||= '';
            $vacation_msg = &VWebAdm::Utils::trim($vacation_msg);

            if ( $type eq 'site' && $admin ) {
                $is_siteadmin = 1;
            }
            if ( $type eq 'local' && $admin ) {
                $is_domainadmin = 1;
            }
            if ( $type eq 'alias' ) {
                $is_alias         = 1;
                $alias_is_enabled = $enabled;
                $forward          = $smtp;
                $forward          = &VWebAdm::Utils::trim($forward);
                $forward =~ s/\s+/,/g;
            }
            if ( $type eq 'local' ) {
                $is_local = 1;
            }
            if ( $type eq 'local' && $forward ) {
                $is_alias         = 1;
                $alias_is_enabled = $on_forward;
            }
            if ($is_alias) {
                $self->sth_new_alias->execute( $new_domain_id, $localpart, $forward, $alias_is_enabled )
                  or warn( "Could not execute Query: " . $self->sth_new_alias->errstr );
                print "New Alias: $localpart\@$domain ($new_domain_id) => $forward, Enabled: $alias_is_enabled\n";
            }
            if ($is_local) {
                my $pw = '';
                if ($pwclear) {
                    $pw = &VWebAdm::SaltedHash::make_pass( $pwclear, $self->config()->{'default'}{'pwscheme'} );
                }
                elsif ( $pwcrypt && $pwcrypt =~ m/^\$1\$/ ) {
                    $pw = '{MD5-CRYPT}' . $pwcrypt;
                }
                $self->sth_new_mailbox->execute(
                    $new_domain_id,  $localpart,    $pw,             $realname,     $enabled,   $maxmsgsize, $on_vacation,
                    'Out of Office', $vacation_msg, $is_domainadmin, $is_siteadmin, $sa_active, $sa_kill_score,
                ) or warn( "Could not execute query: " . $self->sth_new_mailbox->errstr );
                print
"New Mailbox: $localpart\@$domain ($new_domain_id), Name: $realname, Enabled: $enabled, Max. Size: $maxmsgsize, VAC: $on_vacation, DA: $is_domainadmin, SA: $is_siteadmin\n";
            }
        }
    }
    $sth_domains->finish();
    $sth_domainalias->finish();
    $sth_users->finish();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Migration::Plugin::Vexim - VBoxAdm Migration Plugin for Vexim import

=method run

import

=cut
