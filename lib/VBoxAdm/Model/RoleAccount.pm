package VBoxAdm::Model::RoleAccount;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB;
use VWebAdm::Utils;

extends 'VWebAdm::Model';

sub _init_fields { return [qw(id name local_part domain ts)]; }

sub create {
    my ( $self, $role, $goto ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $delim = $self->config()->{'smtpproxy'}->{'recipient_delimiter'};

    if ( !&VWebAdm::Utils::is_valid_localpart_rfc822($role) ) {
        $self->msg->push( 'error', 'Invalid localpart as role name given.' );
        return;
    }
    elsif ( !&VWebAdm::Utils::is_valid_address_rfc822($goto) ) {
        $self->msg->push( 'error', 'Invalid email address given.' );
        return;
    }
    elsif ( $role && $delim && $role =~ m/\Q$delim\E/ ) {
        $self->msg->push( 'error', 'Localpart may not contain the recipent_delimiter (' . $delim . ')' );
        return;
    }
    my ( $local_part, $domain ) = split /@/, $goto;

    my $sql = "INSERT IGNORE INTO role_accounts (name,local_part,domain,ts) VALUES(?,?,?,NOW())";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, $role, $local_part, $domain );

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $sql . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    $sth->finish();

    return 1;
}

sub get_id {
    my ( $self, $role ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $sql = "SELECT id FROM role_accounts WHERE name = ?";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, $role );
    my $id  = $sth->fetchrow_array();

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $sql . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    $sth->finish();

    return $id;
}

sub update {
    my ( $self, $entry_id, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }
    my $goto = $params->{'Goto'};
    if ( !&VWebAdm::Utils::is_valid_address_rfc822($goto) ) {
        $self->msg->push( 'error', 'Invalid email address given.' );
        return;
    }
    my ( $local_part, $domain ) = split /@/, $goto;

    if ( $entry_id && defined($goto) ) {
        my $query = "UPDATE role_accounts SET local_part = ?, domain = ? WHERE id = ?";
        if ( my $sth = $self->dbh->prepare($query) ) {
            if ( $sth->execute( $local_part, $domain, $entry_id ) ) {
                $sth->finish();
                $self->msg->push( 'information', "Updated entry [_1]. Set target to[_2]@[_3].", $entry_id, $local_part, $domain );
                return 1;
            }
            else {
                $self->logger()->log( message => 'Could not execute query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
                $self->msg->push( 'error', "Unable to update RoleAccount. Database Error." );
                return;
            }
        }
        else {
            $self->logger()->log( message => 'Could not prepare query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
            $self->msg->push( 'error', "Unable to update RoleAccount. Database Error." );
            return;
        }
    }

    return;
}

sub delete {
    my ( $self, $entry_id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    # delete role account
    if ( $entry_id && $entry_id =~ m/^\d+$/ ) {
        my $query = "DELETE FROM role_accounts WHERE id = ?";
        if ( my $sth = $self->dbh->prepare($query) ) {
            if ( $sth->execute($entry_id) ) {
                $sth->finish();
                $self->msg->push( 'information', "Deleted entry [_1].", $entry_id );
                return 1;
            }
            else {
                $self->logger()->log( message => 'Could not execute query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
                return;
            }
        }
        else {
            $self->logger()->log( message => 'Could not prepare query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
            $self->msg->push( 'error', "Unable to delete RoleAccount $entry_id. Database Error." );
            return;
        }
    }

    return;
}

sub read {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_read( 'role_accounts', $id, );
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_list( 'role_accounts', $params );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::RoleAccount - Class for RoleAccount

=cut
