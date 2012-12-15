package VBoxAdm::Cron::Command;
# ABSTRACT: VBoxAdm cron baseclass for any command

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;
# use Carp;
use English qw( -no_match_vars );
# use Try::Tiny;
use Config::Yak;
use Log::Tree;

# extends ...
extends 'MooseX::App::Cmd::Command';
# has ...
has '_config' => (
    'is'    => 'rw',
    'isa'   => 'Config::Yak',
    'lazy'  => 1,
    'builder' => '_init_config',
    'accessor' => 'config',
);

has '_logger' => (
    'is'    => 'rw',
    'isa'   => 'Log::Tree',
    'lazy'  => 1,
    'builder' => '_init_logger',
    'accessor' => 'logger',
);

has '_dbh' => (
    'is'      => 'ro',
    'isa'     => 'Object',
    'lazy'    => 1,
    'builder' => '_init_dbh',
);

has '_msgq' => (
    'is'      => 'ro',
    'isa'     => 'VWebAdm::Model::MessageQueue',
    'lazy'    => 1,
    'builder' => '_init_msgq',
);
# with ...
# initializers ...
sub _init_config {
    my $self = shift;

    my $Config = Config::Yak::->new({
        'locations' => [qw(conf/vboxadm.conf /etc/vboxadm/vboxadm.conf)],
    });

    return $Config;
}

sub _init_logger {
    my $self = shift;

    my $Logger = Log::Tree::->new('vboxadm-cli');

    return $Logger;
}

# your code here ...
binmode( STDIN, ':utf8' );

sub _display_messages {
    my $self = shift;

    my $format = "[%10s] %s\n";
    foreach my $msg ( $self->_msgq()->pop() ) {
        printf( $format, uc( $msg->{'severity'} ), $msg->{'en'} );
    }

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command - Base class for any VBoxAdm command.

=cut
