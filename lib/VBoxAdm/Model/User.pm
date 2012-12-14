package VBoxAdm::Model::User;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB '@VERSION@';
use VWebAdm::SaltedHash '@VERSION@';

extends 'VWebAdm::Model::User';

sub login {
    my $self     = shift;
    my $password = shift;

    # check if login works
    my $sql = "SELECT m.id,m.password,m.is_domainadmin,m.is_siteadmin,d.id FROM mailboxes AS m ";
    $sql .= "LEFT JOIN domains AS d ON m.domain_id = d.id WHERE m.local_part = ? AND d.name = ?";
    my $sth = &VWebAdm::DB::prepexec( $self->dbh(), $sql, $self->local_part(), $self->domain() );
    #$self->logger()->log( message => 'SQL: '.$sql.' - Args: '.$self->local_part().' - '.$self->domain(), level => 'debug', );

    if ( !$sth ) {
        $self->logger()->log( message => "Database error during query ($sql): " . $self->dbh()->errstr(), level => 'error', );
        $self->msg->push( 'error', 'Database error.' );
        return;
    }

    my ( $id, $pw, $is_da, $is_sa, $domain_id ) = $sth->fetchrow_array();
    $sth->finish();
    if ( !$self->force && !&VWebAdm::SaltedHash::verify_pass( $password, $pw ) ) {
        $self->logger()->log( message => "Password invalid!", level => 'warning', );
        return;
    }
    
    $self->{'domainadmin'} = $is_da;
    $self->{'siteadmin'}   = $is_sa;
    $self->{'id'}          = $id;
    $self->{'domain_id'}   = $domain_id;
    $self->{'user'}        = 1;
    
    #$self->logger()->log( message => "User logged in. id: $id, domain_id: $domain_id, domainadmin: $is_da, siteadmin: $is_sa, pw: $pw, force: ".$self->force(), level => 'debug', );

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::User - Class for Users.

=cut
