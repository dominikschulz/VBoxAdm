package VBoxAdm::Cmd::Command::domain;
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
use VBoxAdm::Model::Domain;

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
    'documentation' => 'Domain to add',
);

has 'update' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'u',
    'documentation' => 'Domain to update',
);

has 'delete' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'd',
    'documentation' => 'Domain to delete',
);

has '_domain' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::Domain',
    'lazy'    => 1,
    'builder' => '_init_domain',
    'reader'  => 'domain',
);

sub _init_domain {
    my $self = shift;

    my $Domain = VBoxAdm::Model::Domain::->new(
        {
            'dbh'    => $self->dbh(),
            'logger' => $self->logger(),
            'config' => $self->config(),
            'user'   => $self->user(),
            'msgq'   => $self->msgq(),
        }
    );

    return $Domain;
}
# with ...
# initializers ...

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
    
    return;
}

sub exec_add {
    my $self = shift;
    
    print "Add Domain.\n";
    my $status = $self->domain()->create($self->add());
    $self->display_messages();
    
    return $status;
}

sub exec_update {
    my $self = shift;
    
    my $params;
    foreach my $key (qw(IsActive)) {
        $params->{$key} = $self->opts()->{$key} if defined( $self->opts()->{$key} );
    }
    print "Update Domain.\n";
    my $status = $self->domain()->update( $self->domain()->get_id($self->update()), $params );
    $self->display_messages();
    
    return $status;
}

sub exec_delete {
    my $self = shift;
    
    print "Delete Domain.\n";
    my $status = $self->domain()->delete( $self->domain()->get_id($self->delete()) );
    $self->display_messages();
    
    return $status;
}

sub list {
    my $self = shift;
    
    print "Listing Domains:\n";
    my $format = "%i\t%s\t%i\n";
    print "ID\tDomain\tIs Active\n";
    foreach my $domain ( $self->domain()->list() ) {
        printf( $format, @{$domain}{qw(id name is_active)} );
    }
    $self->display_messages();
    
    return 1;
}

sub abstract {
    return 'Command';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command::domain - 

=method abstract

Workadound.

=method execute

Command

=cut
