package VBoxAdm::SMTP::Server;

use strict;
use warnings;

use IO::Socket::INET6;
use File::Temp;
use Carp qw(carp croak);

# Not using moose for performance reasons

our $VERSION = '@VERSION@';

sub new {
    my ( $this, @opts ) = @_;

    my $class = ref($this) || $this;
    my $self = bless {@opts}, $class;
    if ( !$self->{sock} ) {
        $self->{sock} = IO::Socket::INET6::->new(
            LocalAddr => $self->{interface},
            LocalPort => $self->{port},
            Proto     => 'tcp',
            Type      => SOCK_STREAM,
            Listen    => 65536,
            Reuse     => 1,
        );
        $self->{sockmode} = 'accept';
    }
    else {
        $self->{sockmode} = 'direct';
        $self->{'s'} = $self->{sock};
    }

    if ( !defined( $self->{sock} ) ) {
        croak("$0: Socket bind failure: $!\n");
    }
    if ( $self->{sockmode} eq 'accept' ) {
        $self->{state} = 'just bound';
    }
    else {
        $self->{state} = 'accepted';
    }
    return $self;
}

sub accept {
    my ( $self, @opts ) = @_;

    if ( $self->{sockmode} ne 'accept' ) {
        carp( "Accept not available in this mode (" . $self->{sockmode} . ")!\n" );
        return;
    }

    %{$self} = ( %{$self}, @opts );

    ( $self->{'s'}, $self->{peeraddr} ) = $self->{sock}->accept
      or croak("$0: Socket accept failure: $!\n");
    $self->{state} = 'accepted';

    return 1;
}

sub chat {
    my $self = shift;

    if ( $self->{state} !~ /^data/i ) {
        return 0 unless defined( my $line = $self->getline );

        # strip any kind of newlines
        $line =~ s/[\r\n]*$//;
        $self->{state} = $line;

        if ( $line =~ s/^(he|eh|lh)lo\s+//i ) {

            # trim and unify spacings
            $line =~ s/\s*$//;
            $line =~ s/\s+/ /g;
            $self->{helo} = $line;
        }
        elsif ( $line =~ m/^rset\b/i ) {
            delete $self->{to};
            delete $self->{data};
            delete $self->{recipients};
            delete $self->{xforward};
        }
        elsif ( $line =~ s/^mail\s+from:\s*//i ) {
            delete $self->{to};
            delete $self->{data};
            delete $self->{recipients};

            #$line =~ s/\s*$//;
            $line =~ s/.*</</;
            $line =~ s/>.*$/>/;
            $self->{from} = $line;
        }
        elsif ( $line =~ s/^rcpt\s+to:\s*//i ) {

            #$line =~ s/\s*$//;
            #$line =~ s/\s+/ /g;
            $line =~ s/.*</</;
            $line =~ s/>.*$/>/;
            $self->{to} = $line;
            push( @{ $self->{recipients} }, $line );
        }
        elsif ( $line =~ m/^data/i ) {
            $self->{to} = $self->{recipients};
        }
        elsif ( $line =~ m/^xforward/i ) {
            if ( $line =~ m/name=\[?(\S+)\b/i ) {
                $self->{xforward}{name} = $1;
            }
            if ( $line =~ m/addr=\[?(\S+)\b/i ) {
                $self->{xforward}{addr} = $1;
            }
            if ( $line =~ m/port=\[?(\d+)\b/i ) {
                $self->{xforward}{port} = $1;
            }
            if ( $line =~ m/helo=\[?(\S+)\b/i ) {
                $self->{xforward}{helo} = $1;
            }
            if ( $line =~ m/proto=\[?(\S+)\b/i ) {
                $self->{xforward}{proto} = $1;
            }
            if ( $line =~ m/source=\[?(\S+)\b/i ) {
                $self->{xforward}{source} = $1;
            }
        }
    }
    else {
        if ( defined( $self->{data} ) ) {
            $self->{data}->seek( 0, 0 );
            $self->{data}->truncate(0);
        }
        else {

            # tempdir should be on a ramdisk an maybe /tmp on ramdisk is
            # undesirable
            $self->{data} = File::Temp::tempfile( DIR => $self->{tempdir} );
        }
        while ( defined( my $line = $self->getline ) ) {
            if ( $line eq ".\r\n" ) {
                $self->{data}->seek( 0, 0 );

                return $self->{state} = '.';
            }

            # unescape dot on beginning of the line
            $line =~ s/^\.\./\./;
            $self->{data}->print($line)
              or croak("$0: Write error while saving data\n");
        }
        return 0;
    }
    return $self->{state};
}

sub getline {
    my $self = shift;
    local $/ = "\r\n";

    return $self->{'s'}->getline unless defined $self->{debug};

    my $line = $self->{'s'}->getline;
    $self->{debug}->print($line) if $line;
    return $line;
}

sub print {
    my ( $self, @msg ) = @_;

    $self->{debug}->print(@msg) if defined $self->{debug};
    $self->{'s'}->print(@msg);
    return 1;
}

sub ok {
    my ( $self, @msg ) = @_;

    @msg = ("ok.") unless @msg;

    $self->print("250 @msg\r\n")
      or croak("$0: Socket write error acknowledging $self->{state}: $!\n");
    return 1;
}

sub tempfail {
    my ( $self, @msg ) = @_;

    @msg = ("temporary failure.") unless @msg;

    $self->print("450 @msg\r\n")
      or croak("$0: Socket write error acknowledging $self->{state}: $!\n");
    return 1;
}

sub fail {
    my ( $self, @msg ) = @_;

    @msg = ("no.") unless @msg;

    $self->print("550 @msg\r\n")
      or croak("$0: Socket write error acknowledging $self->{state}: $!\n");
    return 1;
}

1;

__END__

=head1 NAME

VBoxAdm::SMTP::Server - An SMTP Server.

=head1 SYNOPSIS

    use VBoxAdm::SMTP::Server;
		my $server = VBoxAdm::SMTP::Server->new(
			interface => $interface,
			port			=> $port,
		);

=head1 DESCRIPTION

This class implements the protocol stage necessary to implement a minimal SMTP server.

=cut
