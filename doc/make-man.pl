#!/usr/bin/perl
use strict;
use warnings;

my $verbose = 0;

my $in = shift;
my $out = shift;
my $alias = shift;
exit 0 unless -f $in;
print "make-man - in: $in - out: $out\n" if $verbose;

my $section = 1;
if($out =~ m/\.(\d)$/) {
	$section = $1;
}
my $release = 'vboxadm';
my @path = split /\//, $in;
if($path[-1] =~ m/\.pm$/) {
	$alias = join('/',@path[0 .. $#path-1]);
	shift @path; # remove leading lib/
	$alias .= '/'.join("::",@path);
	$alias =~ s/\.pm$/.3/;
	print "Alias: ".$alias."\n" if $verbose;
}
my $cmd = '/usr/bin/pod2man --center=" " --section='.$section.' --release="'.$release.'" '.$in.' > '.$out;
my $rv = system($cmd) >> 8;
if($rv == 0) {
	# ok
	if($alias && !-e $alias) {
		print "Hardlinking $out to $alias ...\n" if $verbose;
		link($out,$alias);
	}
	exit 0;
} else {
	exit 1;
}