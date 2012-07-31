#!/usr/bin/perl
use strict;
use warnings;

use Crypt::CBC;
use Digest::SHA;
use MIME::Base64;
use URI::Escape;
use JSON;
use Data::Dumper;

my $mode = shift; # 0 - encrypt, 1 - decrypt
my $raw_key = shift;
my $input = shift;

if(!defined($mode) || !$raw_key || !$input) {
    &usage();
}

my $key = &gen_key($raw_key);
my $iv  = &gen_iv($raw_key);

my $cipher = Crypt::CBC->new(
  -key => $key,
  -cipher => 'Blowfish',
  -iv => $iv,
  -header => 'none',
  -padding => 'null',
  -literal_key => 1,
  -keysize => length($key),
);

my $json = JSON->new->utf8();

if($mode == 0) {
    my $ref = {};
    $ref->{'payload'} = $input;
    my $jse   = $json->encode($ref);
    my $crypt = $cipher->encrypt( $jse );
    my $crypt_b64 = encode_base64($crypt);
    my $crypt_ue  = uri_escape($crypt_b64);
    print $crypt_ue."\n";
    exit 0;
} elsif($mode && $mode == 1) {
    my $crypt_b64_2 = uri_unescape($input);
    my $crypt = decode_base64($crypt_b64_2);
    my $clear = $cipher->decrypt($crypt);
    my $ref   = $json->decode($clear);
    print $ref->{'payload'}."\n";
    exit 0;
} else {
    &usage();
}

sub gen_key {
    my $key  = shift;
    return substr( Digest::SHA::sha512($key), 0, 56 );
}

sub gen_iv {
    my $key  = shift;
    return substr( Digest::SHA::sha512($key), 56 );
}

sub usage {
    print "Usage: $0 [1|0] <key> <plaintext>\n";
    exit 1; 
}
# http://www.perturb.org/display/PHP_to_Perl_encryption.html