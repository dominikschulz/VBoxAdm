package VBoxAdm::Cmd::Command::migrate;
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
use VBoxAdm::Migration;

# extends ...
extends 'VBoxAdm::Cmd::Command';
# has ...
has 'type' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 't',
    'documentation' => 'Source type',
);

has 'sourcedb' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 's',
    'documentation' => 'Source database',
);

has 'targetdb' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'd',
    'documentation' => 'Target database',
);

has 'truncate' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'required'      => 0,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 't',
    'documentation' => 'Truncate target database',
);

has '_mig' => (
    'is'    => 'ro',
    'isa'   => 'VBoxAdm::Migration',
    'lazy'  => 1,
    'builder' => '_init_mig',
);
# with ...
# initializers ...
sub _init_mig {
    my $self = shift;
    
    my $MiG = VBoxAdm::Migration::->new({
        'dbh' => undef, # TODO this not work!!
        'type' => $self->type(),
        'sourcedb' => $self->sourcedb(),
        'targetdb' => $self->targetdb(),
    });
    
    return $MiG;
}

# your code here ...
sub execute {
    my $self = shift;
    
    if($self->truncate()) {
        $self->_mig->truncate();
    }

    return $self->_mig()->migrate();
}

sub abstract {
    return 'Command';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command::aliasadd - 

=method abstract

Workadound.

=method execute

Command

=cut
