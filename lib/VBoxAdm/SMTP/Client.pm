package VBoxAdm::SMTP::Client;

use strict;
use warnings;

use Carp qw(croak);
use IO::Socket::INET6;

# Not using moose for performance reasons



############################################
# Usage      : ????
# Purpose    : ????
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub new {
    my ( $this, @opts ) = @_;

    my $class = ref($this) || $this;
    my $self = bless { timeout => 300, @opts }, $class;
    $self->{sock} = IO::Socket::INET6::->new(
        PeerAddr => $self->{interface},
        PeerPort => $self->{port},
        Timeout  => $self->{timeout},
        Proto    => 'tcp',
        Type     => SOCK_STREAM,
    );

    if ( !defined( $self->{sock} ) ) {
        if ( $self->{RaiseError} ) {
            croak("$0: Socket connection failure: $!\n");    # unless defined?
        }
        else {
            return;
        }
    }
    else {
        return $self;
    }
}

############################################
# Usage      : ????
# Purpose    : Read a line from the server.
# Returns    : The response or undef upon failure.
# Parameters : none
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub hear {
    my $self = shift;

    my $line  = undef;
    my $reply = undef;

    return unless $line = $self->{sock}->getline;
    while ( $line =~ /^\d{3}-/ ) {
        $reply .= $line;
        return unless $line = $self->{sock}->getline;
    }
    $reply .= $line;
    $reply =~ s/\r\n$//;
    return $reply;
}

############################################
# Usage      : ????
# Purpose    : Write a line to the server.
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub say {
    my ( $self, @msg ) = @_;

    return unless @msg;

    $self->{sock}->print( "@msg", "\r\n" ) or croak("$0: Socket write error: $!");

    return 1;
}

############################################
# Usage      : ????
# Purpose    : Send a bunch of data to the server.
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub yammer {
    my $self = shift;
    my $fh   = shift;

    # default to SMTP-linebreaks for newlines
    local $/ = "\r\n";

    while ( my $line = <$fh> ) {

        # escape single dots at the beginning of a line
        # SMTP requires this. a single dot would end the data stage.
        $line =~ s/^\./../;
        $self->{sock}->print($line) or croak("$0: Socket write error: $!\n");
    }

    # end the data stage
    $self->{sock}->print(".\r\n") or croak("$0: Socket write error: $!\n");

    return 1;
}

1;

__END__

=head1 NAME

VBoxAdm::SMTP::Client - SMTP Client module.

=head1 DESCRIPTION

This class represents an SMTP client.

=cut
