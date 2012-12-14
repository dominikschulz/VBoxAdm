package VWebAdm::Model::User;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB '@VERSION@';
use VWebAdm::Utils '@VERSION@';
use VWebAdm::SaltedHash '@VERSION@';

extends 'VWebAdm::Model';

has 'domainadmin' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'siteadmin' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'local_part' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'domain' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'id' => (
    'is'  => 'ro',
    'isa' => 'Num',
);

has 'domain_id' => (
    'is'  => 'ro',
    'isa' => 'Num',
);

has 'force' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'system_user' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'user' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $arg_ref = $class->$orig(@_);

    # SystemUser is used (only) for bootstrap where no users does exist, yet.
    if ( $arg_ref->{'SystemUser'} ) {
        $arg_ref->{'domainadmin'} = 1;
        $arg_ref->{'siteadmin'}   = 1;
        $arg_ref->{'local_part'}  = 'root';
        $arg_ref->{'domain'}      = 'localhost';
        $arg_ref->{'id'}          = 0;
        $arg_ref->{'domain_id'}   = 0;
        $arg_ref->{'system_user'} = 1;
        $arg_ref->{'user'}        = 1;
    }
    elsif ( $arg_ref->{'username'} && &VWebAdm::Utils::is_valid_address_rfc822( $arg_ref->{'username'} ) ) {
        my ( $local_part, $domain ) = split /@/, $arg_ref->{'username'};
        $arg_ref->{'local_part'} = $local_part;
        $arg_ref->{'domain'}     = $domain;
    }

    return $arg_ref;
};

sub login {
    my $self     = shift;
    my $password = shift;

    $self->msg->push( 'error', 'Not implemented' );

    return;
}

sub get_name {
    my ($self) = @_;

    return $self->local_part() . '@' . $self->domain();
}

sub get_local_part {
    my ($self) = @_;

    return $self->local_part();
}

sub get_domain {
    my ($self) = @_;

    return $self->domain();
}

sub get_domain_id {
    my ($self) = @_;

    return $self->domain_id();
}

sub get_id {
    my ($self) = @_;

    return $self->id();
}

sub is_domainadmin {
    my ($self) = @_;

    return $self->domainadmin();
}

sub is_siteadmin {
    my ($self) = @_;

    return $self->siteadmin();
}

sub is_admin {
    my ($self) = @_;

    return $self->domainadmin() + $self->siteadmin();
}

sub is_user {
    my ($self) = @_;

    return $self->user();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VWebdm::Model::User - Class for Users.

=cut
