#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use File::Basename;
use Data::Dumper;
use Text::CSV_XS;

my %lexicon = ();
my %langs   = ();

my $l10ndir = "../lib/VBoxAdm/L10N";
foreach my $file ( glob( $l10ndir . "/*.ipm" ) ) {
    my $lang = basename($file);
    $lang =~ s/\.ipm$//;
    open( my $FH, "<:encoding(utf8)", $file )
      or die("Could not open file $file: $!\n");
    my $start = 0;
    while (<$FH>) {
        chomp();
        if (m/our %Lexicon = \(/) {
            $start = 1;
            next;
        }
        if ( $start && m/\);/ ) {
            $start = 0;
            next;
        }
        if (m/'([^']+)'\s*=>\s*'([^']+)'\s*,/) {
            my $en = $1;
            my $t  = $2;

            #print "EN: $en => $t\n";
            $lexicon{$en}{$lang} = $t;
            $langs{$lang} = 1;
        }
    }
    close($FH);
}

print Dumper(%lexicon);
my $csv = Text::CSV_XS->new( { binary => 1 } );
open( my $FH, ">:encoding(utf8)", "lexicons.csv" )
  or die("Could not open file lexicons.csv for writing: $!\n");
$csv->combine( ( 'en', sort keys %langs ) );
print $FH $csv->string(), "\n";
foreach my $en ( sort keys %lexicon ) {
    my @cols = ($en);
    foreach my $lang ( sort keys %langs ) {
        if ( $lexicon{$en}{$lang} ) {
            push( @cols, $lexicon{$en}{$lang} );
        }
        else {
            push( @cols, '' );
        }
    }
    $csv->combine(@cols);
    print $FH $csv->string(), "\n";
}
close($FH);
