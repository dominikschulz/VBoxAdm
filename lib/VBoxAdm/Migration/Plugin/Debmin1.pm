package VBoxAdm::Migration::Plugin::Debmin1;
# ABSTRACT: VBoxAdm Migration Plugin for Debmin v1 import

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
            $source_db = 'system';
        }
        my $sql_domains = 'SELECT id,domain,is_enabled FROM `' . $source_db . '`.exim_domains ORDER BY domain';
        my $sth_domains = $self->dbh()->prepare($sql_domains);
        my $sql_mailboxes =
            'SELECT local_part,forward,cc,name,pwclear,is_away,away_text,spam_check,is_enabled FROM `'
          . $source_db
          . '`.exim_emailtable WHERE domain = ? ORDER BY local_part';
        my $sth_mailboxes = $self->dbh()->prepare($sql_mailboxes);
        if ( !$sth_domains->execute() ) {
            $self->logger()->log( message => "Could not execute SQL ($sql_domains) due to error: " . $sth_domains->errstr(), level => 'error', );
            return;
        }

        #
        # CREATE DOMAINS
        #
      DOMAIN: while ( my ( $old_domain_id, $domain_name, $domain_is_enabled ) = $sth_domains->fetchrow_array() ) {
            my $domain_is_active = 1;
            if ( $domain_is_enabled && $domain_is_enabled =~ m/(no|0)/i ) {
                $domain_is_active = 0;
            }
            $domain_name = lc($domain_name);
            if ( !$self->config()->{'dry'} && $sth_new_domain->execute( $domain_name, $domain_is_active ) ) {
                print "Created new Domain '$domain_name'\n";
            }
            else {
                print "Failed to create new domain '$domain_name': " . $sth_new_domain->errstr . "\n";
                next DOMAIN;
            }
            my $new_domain_id = $self->dbh()->last_insert_id( undef, undef, undef, undef );
            print "SQL: $sql_mailboxes - Args: $domain_name\n";
            $sth_mailboxes->execute($domain_name)
              or die( "Could not execute Query $sql_mailboxes: " . $sth_mailboxes->errstr );

            #
            # CREATE MAILBOXES
            #
          MAILBOX: while ( my @row = $sth_mailboxes->fetchrow_array() ) {
                my ( $local_part, $forward, $cc, $name, $pwclear, $is_away, $away_text, $spam_check, $is_enabled ) = @row;
                $local_part = lc($local_part);
                my $sa_active = 1;
                if ( $spam_check && $spam_check =~ m/(no|0)/i ) {
                    $sa_active = 0;
                }
                my $is_on_vacation = 0;
                if ( $is_away && $is_away =~ m/(yes|1)/i ) {
                    $is_on_vacation = 1;
                }
                my $is_active = 1;
                if ( $is_enabled && $is_enabled =~ m/(no|0)/i ) {
                    $is_active = 0;
                }
                $away_text ||= '';
                if ( !$forward ) {

                    # a real mailbox
                    if (
                        !$self->config()->{'dry'}
                        && $sth_new_mailbox->execute(
                            $new_domain_id, $local_part, &VWebAdm::SaltedHash::make_pass( $pwclear, $self->config()->{'default'}{'pwscheme'} ),
                            $name, $is_active, 15360, $is_on_vacation, 'On Vacation', $away_text, 0, 0, $sa_active, 6.31
                        )
                      )
                    {
                        print "\tCreated new Mailbox: $local_part\@$domain_name\n";
                    }
                    else {
                        print "\tFailed to create new Mailbox $local_part\@$domain_name: " . $sth_new_mailbox->errstr . "\n";
                    }
                }
                else {

                    # an alias
                    if ( !$self->config()->{'dry'} && $sth_new_alias->execute( $new_domain_id, $local_part, $forward, $is_active ) ) {
                        print "\tCreated new Alias: $local_part\@$domain_name\n";
                    }
                    else {
                        print "\tFailed to create new Alias $local_part\@$domain_name: " . $sth_new_mailbox->errstr . "\n";
                    }
                }

                # handle cc, too (insert as alias)
                if ($cc) {
                    if ( !$self->config()->{'dry'} && $sth_new_alias->execute( $new_domain_id, $local_part, $cc, $is_active ) ) {
                        print "\tCreated new Alias (CC): $local_part\@$domain_name\n";
                    }
                    else {
                        print "\tFailed to create new Alias (CC) $local_part\@$domain_name: " . $sth_new_mailbox->errstr . "\n";
                    }
                }
            }
        }
        $sth_mailboxes->finish();
        $sth_domains->finish();
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