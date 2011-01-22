#!/usr/bin/perl
#
# Release script
#
# This script can help with creating releases from git projects
# and also update debian packages if they are managed
# with git-buildpackage.
#
# Pragmas
use strict;
use warnings;

# Modules
use Getopt::Long;
use Cwd;
use File::Temp qw/tempdir/;
use Config::Std;

# Determine the name of the package
my $name = undef;
{
    my @path = split(/\//, getcwd());
    $name = $path[-1];
}

# Vars for config loading
my ( $conffile_used, @hooks, %hook, %config );

# Valid config file locations to try
my @conffile_locations = qw(
  release.conf
  /etc/release.conf
);
# Prepend config in users home dir (~/.release.conf)
unshift(@conffile_locations,$ENV{'HOME'}.'/.release.conf');

# Get Options
my ($opt_major, $opt_minor, $opt_version, $opt_local, $cmd, $changes_file, $dry, $verbose, $nobuild, $keyid, $nodeb);
GetOptions(
    'major!'        => \$opt_major,
    'minor!'        => \$opt_minor,
    'version=s'     => \$opt_version,
    'local'         => \$opt_local,
    'dry!'          => \$dry,
    'verbose+'      => \$verbose,
    'nobuild'       => \$nobuild,
    'nodeb'         => \$nodeb,
    'name=s'        => \$name,
    'keyid=s'       => \$keyid,
    # shift removes name of the option (config) and leaves the value for unshift
    # unshift prepends to the list of valid config files so it is tried first
    'config=s' => sub { shift; unshift( @conffile_locations, @_ ); },
) or die("Usage: $0 [--major] [--minor] [--version=<V>] [--nobuild] [--name=<STR>] [--keyid=<KEY>] [--config=<CFG>]\n");

# Try all config file locations
foreach my $loc (@conffile_locations) {
    if ( -r $loc ) {
        $conffile_used = $loc;
        read_config $loc => %config;
        last;
    }
}

$keyid = $keyid || $config{$name}{'keyid'} || $config{'default'}{'keyid'};
$nobuild = $nobuild || $config{$name}{'nobuild'} || $config{'default'}{'nobuild'};
$nodeb = $nodeb || $config{$name}{'nodeb'} || $config{'default'}{'nodeb'};

# Debian distributions to upload to (must be configured for dupload)
my @dists = qw(lenny squeeze);
# Git Destinations to push to
my @git_dests = qw();

if($config{'default'}{'dist'}) {
    if(ref($config{'default'}{'dist'}) eq 'ARRAY') {
        push(@dists, @{$config{'default'}{'dist'}});
    } else {
        push(@dists, $config{'default'}{'dist'});
    }
}
if($config{$name}{'dist'}) {
    if(ref($config{$name}{'dist'}) eq 'ARRAY') {
        push(@dists, @{$config{$name}{'dist'}});
    } else {
        push(@dists, $config{$name}{'dist'});
    }
}
if($config{'default'}{'git_dest'}) {
    if(ref($config{'default'}{'git_dest'}) eq 'ARRAY') {
        push(@git_dests, @{$config{'default'}{'git_dest'}});
    } else {
        push(@git_dests, $config{'default'}{'git_dest'});
    }
}
if($config{$name}{'git_dest'}) {
    if(ref($config{$name}{'git_dest'}) eq 'ARRAY') {
        push(@git_dests, @{$config{$name}{'git_dest'}});
    } else {
        push(@git_dests, $config{$name}{'git_dest'});
    }
}

die("Need name for this package!") unless $name;

# This script only works with Makefile built packages
# WARNING: The Makefile must recognize DESTDIR!
if(!-e "./Makefile") {
    die("No Makefile found! You're in the wrong directory!\n");
}
# We can only build a .deb if there is prepared debian packaging dir
if(!-e "../../debian/$name/") {
    warn("No Debian package dir found. Only creating release tar.gz.\n");
    $nodeb = 1;
}

# Determine the current and next version of this package
my $preversion = `git tag | sort -V | tail -1`;
chomp($preversion);
my $version = undef;

if($opt_version) {
    $version = $opt_version;
} elsif($opt_major) {
    $version = inc_version($preversion, { 'Major' => 1, });
} elsif($opt_minor) {
    $version = inc_version($preversion, { 'Minor' => 1, });
} else {
    $version = inc_version($preversion);
}

print "$0\n";
print "\n";
print "Package: $name\n";
print "Previous-Version is: $preversion\n";
print "New-Version will be: $version\n";
print "\n";

# Abort if there are uncommited changes
# either in this repository ...
$cmd = 'git status -z | grep "nothing to commit" >/dev/null';
run_cmd($cmd);
# or the debian package repo
$cmd = 'cd ../../debian/'.$name.'/; git status -z | grep "nothing to commit" >/dev/null';
run_cmd($cmd) unless $nodeb;

# Do a testinstall to catch any Makefile errors
# create tempdir and perform DESTDIR=tmpdir fakeroot make install, continue on success
$cmd = "make clean";
run_cmd($cmd);
my $tempdir = tempdir( CLEANUP => 1, );
$cmd = "DESTDIR=$tempdir/ fakeroot make install";
run_cmd($cmd);

# Increase Version number in Makefile
$cmd = 'sed -i "s/^VERSION = .*$/VERSION = '.$version.'/g" Makefile';
run_cmd($cmd);

# Commit the increased Version number
$cmd = 'git commit -a -m "Tag '.$version.'"';
# command may fail if sed didnt yield any changes
run_cmd($cmd, { MayFail => 1, });

# Tag the new release
$cmd = "git tag ".$version;
run_cmd($cmd);

# Push to origins
if(!$opt_local) {
    for my $dest (@git_dests) {
        $cmd = "git push $dest master";
        run_cmd($cmd);
    }
}

# Export tagged version from git
$cmd = "git archive --format=tar --prefix=$name-".$version."/ $version | gzip >../../debian/$name-".$version.".tar.gz";
run_cmd($cmd);
if($nodeb) {
  print "No debian packaging found. Only prepared tar.gz\n";
  exit 0;
}

# Go to debian package dir
chdir("../../debian/$name");

# Remove patches ...
$cmd = "rm -rf debian/patches";
run_cmd($cmd);

# Import new version
$cmd = "git-import-orig ../$name-".$version.".tar.gz";
run_cmd($cmd);
if($nobuild) {
    print "Preparation for release of $version finished!\n";
    exit 0;
}

# Tag new version
$cmd = "git-dch --release --new-version=${version}-1";
run_cmd($cmd);

# Remove patches ... again
$cmd = "rm -rf debian/patches/";
run_cmd($cmd);

# Remove .pc ...
$cmd = "rm -rf .pc/";
run_cmd($cmd);

# Commit changelog changes
$cmd = "git commit -a -m \"Tag ".$version."-1\"";
run_cmd($cmd);
# TODO can we test if any file which will be installed is in a .install file?

# Build the new package
$cmd = "git-buildpackage --git-tag --git-sign-tags";
if($keyid) {
  $cmd .= " --git-keyid=".$keyid;
}
if($opt_local) {
    $cmd = "QUICK_TEST=1 ".$cmd;
}
run_cmd($cmd);

# .deb file will be placed one level above the package dir
chdir("..");

# Upload to reposity
if(!$opt_local) {
    $changes_file = `ls ${name}_*.changes | grep "$version" | sort -n | tail -1`;
    chomp($changes_file);
    for my $dist (@dists) {
      #$cmd = "dupload --force --to ".$dist." ".$changes_file;
        $cmd = "reprepro -Vb /srv/media/public.packages/ include ".$dist." ".$changes_file;
        run_cmd($cmd);
    }
    $cmd = "/srv/media/public.packages/rsync.sh";
    run_cmd($cmd);
    # TODO add to homepage
}

# TODO clean up old package files

print "Release of $version finished!\n";
exit 0;

sub run_cmd {
    my $cmd = shift;
    my $opts = shift || {};
    print "CMD: $cmd\n" if $verbose;
    my $rv = 1;
    $rv = system($cmd) >> 8 unless $dry;
    if(!$dry && $rv != 0 && !$opts->{MayFail}) {
        die("Command ($cmd) failed with non-zero exit status: $rv!\n");
    } else {
        return 1;
    }
}

sub inc_version {
    my $version = shift;
    my $opts = shift || {};

    # increase last part infinite until requested by switch
    # no switch -> increase last part, tag
    # --minor -> reset last part, increase middle part, create new branch, tag
    # --major -> reset last two parts, increase first part, create new branch tag

    # increase a three component version number
    if($version && $version =~ m/^(\d+)\.(\d+)\.(\d+)$/) {
        my ($major, $minor, $patch) = ($1, $2, $3);
        $patch++;
        if($opts->{Major}) {
            $patch = 0;
            $minor = 0;
            $major++;
        } elsif($opts->{Minor}) {
            $patch = 0;
            $minor++;
        }
        return "$major.$minor.$patch";
    } else {
        die "No three-part version string given. Aborting.\n";
    }
}

__END__
=head1 NAME

release.pl - Tag and package releases

=head1 VERSION

This documentation refers to release.pl version 0.0.5.

=head1 USAGE

    doc/release.pl

=head1 REQUIRED ARGUMENTS

None.

=head1 OPTIONS

Specifying neither major nor minor will increase the patch level, i.e. Z from X.Y.Z.

=head2 major

Increase major version number part, i.e. X from X.Y.Z.

=head2 minor

Increate minor version number part, i.e. Y from X.Y.Z.

=head2 version

Specify the new version manually. Be carefull not to give an existing version number!

=head2 local

Local Operation only. No git push or dupload.

=head2 dry

Dry mode. Only tell what would be done.

=head2 verbose

Increase verbosity.

=head2 nobuild

Do not build the debian package.

=head1 DESCRIPTION

Create a new relelase of the given application.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the application,
including the names and locations of any configuration files, and the
meaning of any environment variables or properties that can be set. These
descriptions must also include details of any configuration language used.
(See also "Configuration Files" in Chapter 19.)

=head1 DEPENDENCIES

File::Temp, Cwd, Getopt::Long.

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS
There are no known bugs in this module.
Please report problems to Dominik Schulz (dominik.schulz@gauner.org)
Patches are welcome.

=head1 AUTHOR

Dominik Schulz (dominik.schulz@gauner.org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Dominik Schulz (dominik.schulz@gauner.org). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
