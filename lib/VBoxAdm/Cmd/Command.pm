package VBoxAdm::Cmd::Command;
# ABSTRACT: VBoxAdm CLI baseclass for any command

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

use VBoxAdm::Model::User;

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

has '_user' => (
    'is'      => 'rw',
    'isa'     => 'VBoxAdm::Model::User',
    'lazy'    => 1,
    'builder' => '_init_user',
);

sub _init_user {
    my $self = shift;
    my $opts = shift || {};

    if ( $self->opts()->{'Bootstrap'} && $EUID == 0 ) {
        my $User = VBoxAdm::Model::User->new(
            {
                'dbh'        => $self->dbh(),
                'logger'     => $self->logger(),
                'config'     => $self->config(),
                'msgq'       => $self->msgq(),
                'SystemUser' => 1,
            }
        );
        return $User;
    }

    my $conf = $ENV{'HOME'} . '/.vboxadm.cnf';
    my %user_config;
    if ( -f $conf || $self->config()->{'quiet'} ) {
        print "check_login - Reading config from $conf ...\n" if $self->opts()->{'Verbose'};
        read_config $conf => %user_config;
    }
    else {
        print "No .vboxadm.cnf found in your home.\n";
        $user_config{'auth'}{'username'} = $self->ask_string('Please enter the email of an site-admin');
        $user_config{'auth'}{'password'} = $self->ask_string('Please enter the password');
        if ( $self->ask_yesno('Should I create a .vboxadm.cnf for you?') ) {
            write_config %user_config => $conf;
        }
    }

    # check if login works
    if ( !VWebAdm::Utils::is_valid_address_rfc822( $user_config{'auth'}{'username'} ) ) {
        print "Invalid email address given.\n" unless $self->opts()->{'Quiet'};
        return;
    }
    my $User = VBoxAdm::Model::User::->new(
        {
            'dbh'      => $self->dbh(),
            'logger'   => $self->logger(),
            'config'   => $self->config(),
            'username' => $user_config{'auth'}{'username'},
            'msgq'     => $self->msgq(),
        }
    );
    if ( !$User ) {
        confess("Could not create User object!\n");
    }
    if ( !$User->login( $user_config{'auth'}{'password'} ) ) {
        confess("Password invalid!\n");
    }
    if ( !$User->is_siteadmin() ) {
        confess("You are no siteadmin!\n");
    }
    print "Authorized as site-admin " . $user_config{'auth'}{'username'} . "\n" if $self->opts()->{'Verbose'};
    return $User;
}
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

sub _ask_yesno {
    my ( $self, $msg ) = @_;
    print $msg. " [y/N]: ";
    ## no critic (ProhibitExplicitStdin)
    my $resp = <STDIN>;
    ## use critic
    chomp($resp);
    if ( $resp =~ m/(1|Yes|Ja|Y)/i ) {
        return 1;
    }
    return;
}

sub _ask_number {
    my ( $self, $msg ) = @_;
    print $msg. ": ";
    ## no critic (ProhibitExplicitStdin)
    my $resp = <STDIN>;
    ## use critic
    chomp($resp);
    if ( $resp =~ m/^\s*(\d+)\s*$/ ) {
        return $1;
    }
    return;
}

sub _ask_string {
    my ( $self, $msg ) = @_;
    print $msg. ": ";
    ## no critic (ProhibitExplicitStdin)
    my $resp = <STDIN>;
    ## use critic
    chomp($resp);
    return $resp;
}

sub _ask_select {
    my ( $self, $msg, @options ) = @_;

    # let user select on of the options provided
    while (1) {
        print $msg. "\n";
        my $i = 0;
        foreach my $opt (@options) {
            print "[$i] $opt\n";
            $i++;
        }
        my $num = $self->_ask_number( 'Print enter any number between 0 and ' . $i . '. Press enter to abort' );
        if ( defined($num) && $options[$num] ) {
            return wantarray ? ( $num, $options[$num] ) : $options[$num];
        }
        else {
            return;
        }
    }
    return;
}

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
