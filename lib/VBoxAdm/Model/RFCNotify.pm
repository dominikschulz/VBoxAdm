package VBoxAdm::Model::RFCNotify;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB '@VERSION@';
use VWebAdm::Utils '@VERSION@';

extends 'VWebAdm::Model';

sub _init_fields {
    return [qw(id email ts)];
}

sub create {
    my ( $self, $email ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return;
}

sub get_id {
    my ( $self, $email ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    if ( !&VWebAdm::Utils::is_valid_address_rfc822($email) ) {
        return;
    }

    my $sql = "SELECT id FROM rfc_notify WHERE email = ?";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, $email );
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
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return;
}

sub delete {
    my ( $self, $entry_id, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return;
}

sub read {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_read( 'rfc_notify', $id, );
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_list( 'rfc_notify', $params );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::RfcNotify - Class for RfcNotify

=cut
