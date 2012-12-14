#!/usr/bin/perl -w
# gen_dkim.pl
# Written by Dominik Schulz <dominik.schulz@gauner.org>
# This script assists in creation of DKIM keypairs.
use strict;
use warnings;
use File::Temp qw/tempdir/;

my $domain   = shift || "";
my $selector = shift || "";

if ( !$domain || !$selector ) {
    die("Please specify a domain and a selector: $0 <domain> <selector>");
}

my $dir = tempdir( CLEANUP => 0 );

# Create the private key
# $> openssl genrsa -out mailout200903.private 1024
my $cmd = "openssl genrsa -out $dir/$selector.private 1024";
system($cmd);

# Extract the public key
# $> openssl rsa -in mailout200903.private -out mailout200903.public -pubout -outform PEM
$cmd = "openssl rsa -in $dir/$selector.private -out $dir/$selector.public -pubout -outform PEM";
system($cmd);

# Convert for DNS
# $> grep -v -e "^-" mailout200903.public | tr -d"\n" > mailout200903.public_plain
$cmd = "grep -v -e \"^-\" $dir/$selector.public";
print "CMD: $cmd\n";
my $pubkey_dns = `$cmd`;
$pubkey_dns =~ s/(\012|\015)//g;

my $pubkey = `cat $dir/$selector.public`;
print "DKIM Public Key:\n\n";
print $pubkey, "\n";

# Get private Key
#my $privkey = `grep -v -e "^-" $dir/$selector.private`;
my $privkey = `cat $dir/$selector.private`;

# Set in DNS
# mail200903._domainkey.mailout.tld IN TXT "v=DKIM1\; k=rsa\; t=y\;p=<KEY>"
print "BIND Zone entry:\n\n";
print "$selector._domainkey.$domain IN TXT \"v=DKIM1\; k=rsa\; t=y\; p=$pubkey_dns\"\n\n";
print "DKIM Private Key:\n\n";
print $privkey, "\n";
