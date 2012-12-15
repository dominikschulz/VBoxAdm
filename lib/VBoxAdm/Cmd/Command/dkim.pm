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
use File::Temp ();

# extends ...
extends 'VBoxAdm::Cmd::Command';
# has ...
has 'domain' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'd',
    'documentation' => 'Domain',
);

has 'selector' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'd',
    'documentation' => 'Domain',
);
# with ...
# initializers ...

# your code here ...

sub execute {
    my $self = shift;
    
    my $tempdir = File::Temp::tempdir( CLEANUP => 1, );
    
    # Create the private key
    # $> openssl genrsa -out mailout200903.private 1024
    my $cmd = 'openssl genrsa -out ' . $tempdir . q{/} . $self->selector() . '.private 1024';
    system($cmd);
    
    # Extract the public key
    # $> openssl rsa -in mailout200903.private -out mailout200903.public -pubout -outform PEM
    $cmd = 'openssl rsa -in '.$tempdir.q{/}.$self->selector().'.private -out '.$tempdir.q{/}.$self->selector().'.public -pubout -outform PEM';
    system($cmd);
    
    # Convert for DNS
    # $> grep -v -e "^-" mailout200903.public | tr -d"\n" > mailout200903.public_plain
    $cmd = 'grep -v -e "^-" '.$tempdir.q{/}.$self->selector().'.public';
    print "CMD: $cmd\n";
    my $pubkey_dns = `$cmd`;
    $pubkey_dns =~ s/(\012|\015)//g;
    
    $cmd = 'cat '.$tempdir.q{/}.$self->selector().'.public';
    my $pubkey = qx($cmd);
    print "DKIM Public Key:\n\n";
    print $pubkey, "\n";
    
    # Get private Key
    $cmd = 'cat '.$tempdir.q{/}.$self->selector().'.private';
    my $privkey = qx($cmd);
    
    # Set in DNS
    # mail200903._domainkey.mailout.tld IN TXT "v=DKIM1\; k=rsa\; t=y\;p=<KEY>"
    print "BIND Zone entry:\n\n";
    say $self->selector().'._domainkey.'.$self->domain().' IN TXT "v=DKIM1\; k=rsa\; t=y\; p='.$pubkey_dns.'"';
    say "DKIM Private Key:\n";
    say $privkey, "\n";
}

sub abstract {
    return 'Command';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command::dkim - 

=method abstract

Workadound.

=method execute

Command

=cut
