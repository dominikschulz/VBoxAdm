package VBoxAdm::Model::Domain;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB '@VERSION@';
use VWebAdm::Utils '@VERSION@';

extends 'VWebAdm::Model';

sub _init_fields {
    return [qw(id name is_active)];
}

sub create {
    my ( $self, $domain ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    $domain = &VWebAdm::Utils::trim( lc($domain) );

    if ( $domain && !&VWebAdm::Utils::is_valid_domain_rfc822($domain) ) {
        $self->msg->push( 'error', 'Invalid syntax. Domain is not RFC822 compliant!' );
        return;
    }
    elsif ($domain) {
        my $query = "INSERT INTO domains (name,is_active) VALUES(?,1)";

        if ( my $sth = &VWebAdm::DB::prepexec( $self->dbh, $query, $domain ) ) {
            $self->msg->push( 'information', "Domain '[_1]' added", $domain );
            $sth->finish();
            return 1;
        }
        else {
            $self->logger()->log( 'Could not execute Query: ' . $query . ', Args: ' . $domain . ', Error: ' . $self->dbh()->errstr() );
            $self->msg->push( 'error', "Failed to add Domain '[_1]'. Database error.", $domain );
            return;
        }

    }
    else {
        $self->msg->add( 'error', "Failed to add Domain [_1]. Insufficient parameters.", $domain );
        return;
    }
}

sub delete {
    my ( $self, $domain_id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $sql = "DELETE FROM domains WHERE id = ? LIMIT 1";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, $domain_id );

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $sql . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    $sth->finish();

    return 1;
}

sub update {
    my ( $self, $domain_id, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $domain_name = $self->get_name($domain_id);

    my $sql  = "UPDATE domains SET ";
    my @args = ();

    if ( defined( $params->{'IsActive'} ) ) {
        $sql .= "is_active = ? ";
        if ( $params->{'IsActive'} ) {
            push( @args, 1 );
        }
        else {
            push( @args, 0 );
        }
    }

    if ( scalar(@args) > 0 ) {
        $sql .= "WHERE id = ?";
        push( @args, $domain_id );
        if ( my $sth = &VWebAdm::DB::prepexec( $self->dbh, $sql, @args ) ) {
            $sth->finish();
            $self->msg->push( 'information', 'Updated Domain [_1].', $domain_name );
            return 1;
        }
        else {
            $self->log( 'Could not execute Query: ' . $sql . ', Args: ' . join( ',', @args ) . ', Error: ' . $self->dbh->errstr );
            $self->msg->push( 'error', 'Failed to update Domain [_1]. Database error.', $domain_name );
            return;
        }
    }
}

sub read {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_read( 'domains', $id, );
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }
    elsif ( !$self->user->is_siteadmin() ) {

        # limit to this domain
        $params->{'id'} = $self->user->get_domain_id();
    }

    return $self->_list( 'domains', $params );
}

sub get_name {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $query = "SELECT name FROM domains WHERE id = ?";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $query, $id );

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    my $domain_name = $sth->fetchrow_array();
    $sth->finish();

    return $domain_name;
}

sub get_id {
    my ( $self, $name ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $query = "SELECT id FROM domains WHERE name = ?";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh, $query, $name );

    if ( !$sth ) {
        $self->logger()->log( message => 'Could not execute query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    my $domain_id = $sth->fetchrow_array();
    $sth->finish();

    return $domain_id;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::Domain - Class for Domains

=cut
