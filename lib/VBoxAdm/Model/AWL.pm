package VBoxAdm::Model::AWL;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB '@VERSION@';
use VWebAdm::Utils '@VERSION@';

extends 'VWebAdm::Model';

sub _init_fields {
    return [qw(id email last_seen disabled)];
}

sub create {
    my ( $self, $email ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $sql = "INSERT IGNORE INTO awl (email,last_seen,disabled) VALUES(?,NOW(),0)";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, $email );

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $sql . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    $sth->finish();

    return 1;
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

    my $sql = "SELECT id FROM awl WHERE email = ?";
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

    my $disabled = $params->{'Disabled'};

    if ( $entry_id && defined($disabled) ) {
        if ( $disabled =~ m/^(?:yes|1|true|on)$/i ) {
            $disabled = 1;
        }
        else {
            $disabled = 0;
        }
        my $query = "UPDATE awl SET disabled = ? WHERE id = ?";
        if ( my $sth = $self->dbh->prepare($query) ) {
            if ( $sth->execute( $disabled, $entry_id ) ) {
                $sth->finish();
                $self->msg->push( 'information', "Updated entry [_1]. Set disabled = [_2].", $entry_id, $disabled );
                return 1;
            }
        }
        else {
            $self->logger()->log( message => 'Could not execute query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
            $self->msg->push( 'error', "Unable to update awl. Database Error." );
            return;
        }
    }

    return;
}

# There will be no AWL::delete - ever. Why?
# Either an entry is disabled which will prevent this address
# from being blacklisted forever or it will expire by itself.
sub delete {
    die("There will be no AWL::delete - ever.");
}

sub read {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_read( 'awl', $id );
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_list( 'awl', $params );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::AWL - Class for AWL

=cut
