package VWebAdm::DNS;

use strict;
use warnings;

use Net::DNS;



{
    my $res;
    sub get_a {
        my $hostname = shift || return;
        if ( !$res ) {
            $res = Net::DNS::Resolver::->new;
        }

        my $query = $res->search($hostname);

        if ($query) {
            my @ips = ();
            foreach my $rr ( $query->answer ) {
                next unless $rr->type eq 'A';
                my $ip = $rr->address;
                push( @ips, $ip );
            }
            return wantarray ? @ips : $ips[0];
        }
        return;
    }
    sub get_ptr {
        my $ip = shift || return;
        if ( !$res ) {
            $res = Net::DNS::Resolver::->new;
        }
        my $query = $res->query( $ip, 'PTR' );

        if ($query) {
            foreach my $rr ( $query->answer ) {
                next unless $rr->type eq 'PTR';
                return $rr->ptrdname;
            }
        }
        return;
    }
    sub get_mx {
        my $hostname = shift || return;
        if ( !$res ) {
            $res = Net::DNS::Resolver::->new;
        }

        my $query = $res->search($hostname);

        my @mx = mx( $res, $hostname );

        return wantarray ? @mx : $mx[0];
    }
    sub get_ns {
        my $hostname = shift || return;
        if ( !$res ) {
            $res = Net::DNS::Resolver::->new;
        }

        my $query = $res->query( $hostname, 'NS' );

        if ($query) {
            my @ns = ();
            foreach my $rr ( $query->answer ) {
                next unless $rr->type eq 'NS';
                my $ns = $rr->nsdname;
                push( @ns, $ns );
            }
            return wantarray ? @ns : $ns[0];
        }
        return;
    }

}

sub is_ip {
    my $str = shift;
    if ( $str =~ m/^\d+\.\d+\.\d+\.\d+$/ ) {
        return 4;    # IPv4
    }
    elsif ( $str =~ m/^[0-9A-F:]+$/i ) {
        return 6;    # IPv6
    }
    else {
        return;      # No IP
    }
}

1;

__END__

=head1 NAME

VWebAdm::DNS - DNS Utility Methods

=cut
