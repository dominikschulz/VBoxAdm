package VBoxAdm::Cmd::Command::awl;
# ABSTRACT: add a new alias

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
# use Try::Tiny;
use VBoxAdm::Model::AWL;

# extends ...
extends 'VBoxAdm::Cmd::Command';
# has ...
has 'add' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'a',
    'documentation' => 'Email address to add',
);

has 'update' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'u',
    'documentation' => 'Email address to update',
);

has 'active' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'i',
    'documentation' => 'Set this item to active?',
);

has '_awl' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::AWL',
    'lazy'    => 1,
    'builder' => '_init_awl',
    'accessor' => 'awl',
);
# with ...
# initializers ...
sub _init_awl {
    my $self = shift;

    my $AWL = VBoxAdm::Model::AWL::->new(
        {
            'dbh'    => $self->dbh(),
            'logger' => $self->logger(),
            'config' => $self->config(),
            'user'   => $self->user(),
            'msgq'   => $self->msgq(),
        }
    );

    return $AWL;
}

# your code here ...
sub execute {
    my $self = shift;
    
    if($self->add()) {
        return $self->exec_add();
    } elsif($self->update()) {
        return $self->exec_update();
    } elsif($self->delete()) {
        return $self->exec_delete();
    } else {
        return $self->list();
    }
}

sub exec_add {
    my $self = shift;
    
    print "Add AWL.\n";
    $self->awl()->create($self->add());
    $self->display_messages();
}
sub exec_update {
    my $self = shift;
    
    my $params;
    $params->{Disabled} = !$self->opts()->{IsActive} if defined( $self->opts()->{IsActive} );
    print "Update AWL.\n";
    
    my $status = $self->awl()->update( $self->awl()->get_id($self->update()), $params );
    $self->display_messages();
    
    return $status;
}

sub list {
    my $self = shift;
    
    print "Listing AWL entries:\n";
    my $format = "%i\t%s\t%i\t%s\n";
    print "ID\tEmail\tDisabled\tLast Seen\n";
    foreach my $awl ( $self->awl()->list() ) {
        printf( $format, @{$awl}{qw(id email disabled last_seen)} );
    }
    $self->display_messages();
}

sub abstract {
    return 'Command';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command::awl - 

=method abstract

Workadound.

=method execute

Command

=cut
