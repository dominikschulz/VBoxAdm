#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use File::Basename;
use Data::Dumper;
use Text::CSV_XS;

my %lexicon = ();
my %langs   = ();

# TODO read csv
# foreach lang (except en)
# create new lang.ipm, print header,
# foreach lexicon print line
# print footer

my $csv = Text::CSV_XS->new( { binary => 1, } );
open( my $FH, "<:encoding(utf8)", 'lexicons.csv' )
  or die("Could not open file lexicons.csv: $!\n");
my $line = 0;
while ( my $row = $csv->getline($FH) ) {
    $line++;
    if ( $line == 1 ) {
        my $col = 0;
        foreach my $lang ( @{$row} ) {
            $langs{$col} = $lang;
            $col++;
        }
    }
    else {
        my $i   = 0;
        my $key = undef;
        foreach my $col ( @{$row} ) {
            if ( $i == 0 ) {
                $key = $col;
            }
            print "Col $i is lang $langs{$i} with value: $col\n";
            $lexicon{ $langs{$i} }{$key} = $col;
            $i++;
        }
    }
}
close($FH);

print Dumper(%lexicon);

foreach my $lang ( keys %lexicon ) {
    next if $lang =~ m/^en$/;
    my $lang_file = "$lang.ipm";
    open( my $FH, ">:encoding(utf8)", $lang_file )
      or die("Could not open file $lang_file: $!\n");
    print $FH get_header($lang);
    foreach my $key ( sort keys %{ $lexicon{$lang} } ) {
        print $FH "    '$key' => '$lexicon{$lang}{$key}',\n";
    }
    print $FH get_footer();
    close($FH);
}

sub get_header {
    my $lang = shift;
    my $str  = "package VBoxAdm::L10N::$lang;\n";
    $str .= <<'EOF';
use utf8;
use base qw(VBoxAdm::L10N);

our $VERSION = '@VERSION@';

our %Lexicon = (
EOF
    return $str;
}

sub get_footer {
    return <<'EOF';
);
1;
EOF
}
