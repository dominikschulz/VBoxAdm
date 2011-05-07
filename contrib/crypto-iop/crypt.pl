#!/usr/bin/perl
use strict;
use warnings;

use Crypt::CBC;
use MIME::Base64;

my $key = "password";
$key .= '0' x (56-length($key));
print "Key: $key - Len: ".length($key)."\n";
my $iv = "1";
$iv .= '1' x (8-length($iv));
print "IV: $iv - Len: ".length($iv)."\n";

my $cipher = Crypt::CBC->new(
  -key => $key,
  -cipher => 'Blowfish',
  -iv => $iv,
  -header => 'none',
  -padding => 'null',
  -literal_key => 1,
  -keysize => length($key),
);

my $input = "cleartext";
my $crypt = $cipher->encrypt($input);
my $crypt_b64 = encode_base64($crypt);
print "Crypt: $crypt_b64\n";

# http://www.perturb.org/display/PHP_to_Perl_encryption.html
my $from_php = '9UmzStp3NxnSvWUe03Vgxg==';
$crypt = decode_base64($from_php);
my $clear = $cipher->decrypt($crypt);
print "Clear: $clear\n";
