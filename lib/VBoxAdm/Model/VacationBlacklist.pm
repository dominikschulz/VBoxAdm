package VBoxAdm::Model::VacationBlacklist;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB;
use VWebAdm::Utils;

extends 'VWebAdm::Model';

sub _init_fields { return [qw(id local_part domain)]; }

sub create {
    my ( $self, $email ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    if ($email) {
        my $query = "INSERT INTO vacation_blacklist (local_part,domain) VALUES(?,?)";
        my ( $local_part, $domain ) = split /@/, $email;
        if ( my $sth = &VWebAdm::DB::prepexec( $self->dbh, $query, $local_part, $domain ) ) {
            $sth->finish();
            $self->msg->push( 'information', "Added Vacation Blacklist Entry [_1].", $email );
            return 1;
        }
        else {
            $self->logger()->log(
                message => 'Could not execute Query: ' . $query . ', Args: ' . join( "-", ( $local_part, $domain ) ) . ', Error: ' . $self->dbh()->errstr,
                level => 'error',
            );
            $self->msg->push( 'error', "Failed to add Vacation Blacklist Entry [_1]. Database Error: " . $self->dbh()->err(), $email );
            return;
        }
    }
    else {
        $self->msg->push( 'error', 'Invalid email address given. Please provide a valid RFC822 email address.' );
        return;
    }

    return;
}

sub get_id {
    my ( $self, $email ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    if ( !&VWebAdm::Utils::is_valid_address_rfc822($email) ) {
        $self->logger()->log( message => 'Invalid email passed to get_id: ' . $email, level => 'error', );
        return;
    }

    my ( $local_part, $domain ) = split /@/, $email;

    my $sql = "SELECT id FROM vacation_blacklist WHERE local_part = ? AND domain = ?";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, $local_part, $domain );

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $sql . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error' );
        return;
    }

    my $id = $sth->fetchrow_array();
    $sth->finish();
    return $id;
}

sub delete {
    my ( $self, $entry_id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    if ($entry_id) {
        my $query = "SELECT CONCAT(local_part,'\@',domain) FROM vacation_blacklist WHERE id = ?";
        my $sth   = $self->dbh->prepare($query);
        $sth->execute($entry_id);
        my $email = $sth->fetchrow_array();
        $sth->finish();

        $query = "DELETE FROM vacation_blacklist WHERE id = ?";
        if ( &VWebAdm::DB::prepexec( $self->dbh, $query, $entry_id ) ) {
            $sth->finish();
            $self->msg->push( 'information', "Deleted Vacation Blacklist Entry [_1].", $email );
            return 1;
        }
        else {
            $self->logger()
              ->log( message => 'Could not execute Query: ' . $query . ', Args: ' . $entry_id . ', Error: ' . $self->dbh->errstr, level => 'error', );
            $self->msg->push( 'error', "Failed to remove Vacation Blacklist Entry [_1]. Database Error: " . $self->dbh()->err(), $email );
            return;
        }
    }
    else {
        $self->msg->push( 'error', 'Invalid id given. Please provide a valid id.' );
        return;
    }

    return;
}

sub update {
    die("No need for VacationBlacklist::update.");
}

sub read {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_read( 'vacation_blacklist', $id, );
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_list( 'vacation_blacklist', $params );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::VacationBlacklist - Class for Vacation Blacklist.

=cut
