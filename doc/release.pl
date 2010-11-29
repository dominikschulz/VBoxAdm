#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use File::Temp qw/tempdir/;

my $name = "vboxadm";
my @dists = qw(dgx-lenny-proposed-updates dgx-squeeze-proposed-updates dgx-wheezy-proposed-updates);
my @git_dests = qw(origin projects);

my $preversion = `git tag | sort -V | tail -1`;
chomp($preversion);
my $version = undef;

# --major --minor --version
my ($opt_major, $opt_minor, $opt_version, $opt_local, $cmd, $changes_file, $dry, $verbose, $nobuild);
GetOptions(
    'major!'        => \$opt_major,
    'minor!'        => \$opt_minor,
    'version=s'     => \$opt_version,
    'local'         => \$opt_local,
    'dry!'          => \$dry,
    'verbose+'      => \$verbose,
    'nobuild'       => \$nobuild,
) or die("Usage: $0 [--major] [--minor] [--version=<V>] [--nobuild]\n");

if($opt_version) {
    $version = $opt_version;
} elsif($opt_major) {
    $version = inc_version($preversion, { 'Major' => 1, });
} elsif($opt_minor) {
    $version = inc_version($preversion, { 'Minor' => 1, });
} else {
    $version = inc_version($preversion);
}

print "$0 - Creating Release ...\n";
print "Previous-Version is: $preversion\n";
print "New-Version is: $version\n";

if(!-e "Makefile") {
    die("No Makefile found! You're in the wrong directory!\n");
}

# anything to commit?
$cmd = 'git status -z | grep "nothing to commit" >/dev/null';
run_cmd($cmd);
$cmd = 'cd ../../debian/'.$name.'/; git status -z | grep "nothing to commit" >/dev/null';
run_cmd($cmd);

# create tempdir and perform DESTDIR=tmpdir fakeroot make install, continue on success
my $tempdir = tempdir( CLEANUP => 1, );
$cmd = "DESTDIR=$tempdir/ fakeroot make install";
run_cmd($cmd);

$cmd = 'sed -i "s/VERSION = '.$preversion.'/VERSION = '.$version.'/g" Makefile';
run_cmd($cmd);
#$cmd = 'git commit -a -m "Tag '.$version.'"';
#run_cmd($cmd);
$cmd = "git tag ".$version;
run_cmd($cmd);
if(!$opt_local) {
    for my $dest (@git_dests) {
        $cmd = "git push $dest master";
        run_cmd($cmd);
    }
}
$cmd = "git archive --format=tar --prefix=$name-".$version."/ $version | gzip >../../debian/$name-".$version.".tar.gz";
run_cmd($cmd);
chdir("../../debian/$name");
$cmd = "rm -rf debian/patches";
run_cmd($cmd);
$cmd = "git-import-orig ../$name-".$version.".tar.gz";
run_cmd($cmd);
if($nobuild) {
    print "Preparation for release of $version finished!\n";
    exit 0;
}
$cmd = "git-dch --release --new-version=${version}-1";
run_cmd($cmd);
$cmd = "rm -rf debian/patches/";
run_cmd($cmd);
$cmd = "rm -rf .pc/";
run_cmd($cmd);
# git commit -a to commit changelog
$cmd = "git commit -a -m \"Tag ".$version."-1\"";
run_cmd($cmd);
# TODO can we test if any file which will be installed is in a .install file?
$cmd = "git-buildpackage --git-tag --git-sign-tags --git-keyid=5ABDC246";
if($opt_local) {
    $cmd = "QUICK_TEST=1 ".$cmd;
}
run_cmd($cmd);
chdir("..");

if(!$opt_local) {
    $changes_file = `ls ${name}_*.changes | grep "$version" | sort -n | tail -1`;
    chomp($changes_file);
    for my $dist (@dists) { # dgx-squeeze ...
        $cmd = "dupload --force --to ".$dist." ".$changes_file;
        run_cmd($cmd);
    }
}

# TODO clean up old package files

print "Release of $version finished!\n";
exit 0;

sub run_cmd {
    my $cmd = shift;
    print "CMD: $cmd\n" if $verbose;
    my $rv = 1;
    $rv = system($cmd) >> 8 unless $dry;
    if(!$dry && $rv != 0) {
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

This documentation refers to release.pl version 0.0.1.

=head1 USAGE

    doc/release.pl

=head1 REQUIRED ARGUMENTS

A complete list of every argument that must appear on the command line.
when the application  is invoked, explaining what each of them does, any
restrictions on where each one may appear (i.e., flags that must appear
before or after filenames), and how the various arguments and options
may interact (e.g., mutual exclusions, required combinations, etc.)

If all of the application's arguments are optional, this section
may be omitted entirely.

=head1 OPTIONS

A complete list of every available option with which the application
can be invoked, explaining what each does, and listing any restrictions,
or interactions.

If the application has no options, this section may be omitted entirely.

=head1 DESCRIPTION

A full description of the application and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 DIAGNOSTICS

A list of every error and warning message that the application can generate
(even the ones that will "never happen"), with a full explanation of each
problem, one or more likely causes, and any suggested remedies. If the
application generates exit status codes (e.g., under Unix), then list the exit
status associated with each error.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the application,
including the names and locations of any configuration files, and the
meaning of any environment variables or properties that can be set. These
descriptions must also include details of any configuration language used.
(See also "Configuration Files" in Chapter 19.)

=head1 DEPENDENCIES

A list of all the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules are
part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for
system or program resources, or due to internal limitations of Perl
(for example, many modules that use source code filters are mutually
incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also a list of restrictions on the features the module does provide:
data types that cannot be handled, performance issues and the circumstances
in which they may arise, practical limitations on the size of data sets,
special cases that are not (yet) handled, etc.

There are no known bugs in this module.
Please report problems to

Dominik Schulz (dominik.schulz@)
Patches are welcome.

=head1 AUTHOR

Dominik Schulz (dominik.schulz@)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Dominik Schulz (dominik.schulz@). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
