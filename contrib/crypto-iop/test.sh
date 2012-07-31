#!/bin/bash
INPUT="TestPlaintext"
KEY="mykey123"

# Case 1: Encode w/ perl, Decode w/ PHP
PERL_CRYPT=`perl crypt.pl 0 $KEY $INPUT`
echo "PERL_CRYPT: $PERL_CRYPT"
PHP_PLAIN=`php crypt.php 1 $KEY $PERL_CRYPT`
echo "PHP_PLAIN:  $PHP_PLAIN"

echo ""

# Case 2: Encode w/ PHP, Decode w/ Perl
PHP_CRYPT=`php crypt.php 0 $KEY $INPUT`
echo "PHP_CRYPT:  $PHP_CRYPT"
PERL_PLAIN=`perl crypt.pl 1 $KEY $PHP_CRYPT`
echo "PERL_PLAIN: $PERL_PLAIN"

