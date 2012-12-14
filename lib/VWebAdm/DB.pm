package VWebAdm::DB;

use strict;
use warnings;

use Carp;
use DBI qw(:sql_types);

our $VERSION = '@VERSION@';

############################################
# Usage      : VWebAdm::DB->show_child_handles($dbh);
# Purpose    : Recursively prints all child handles of the given handle.
# Returns    : nothing
# Parameters : One DBI handle
# Throws     : no exceptions
# Comments   : none
# See Also   : http://search.cpan.org/~timb/DBI-1.611/DBI.pm#ChildHandles_%28array_ref%29
sub show_child_handles {
    my $h = shift;
    my $level = shift || 0;
    printf "%sh %s %s\n", $h->{Type}, "\t" x $level, $h;
    for ( grep { defined } @{ $h->{ChildHandles} } ) {
        &show_child_handles( $_, $level + 1 );
    }
    return;
}

############################################
# Usage      : VWebAdm::DB->finish_child_handles($dbh);
# Purpose    : Recursivly (up to 10 levels of nesting) visit all child handles an call finish() on them.
# Returns    : nothing
# Parameters : One DBI handle
# Throws     : no exceptions
# Comments   : none
# See Also   : http://search.cpan.org/~timb/DBI-1.611/DBI.pm#ChildHandles_%28array_ref%29
sub finish_child_handles {
    my $handle = shift;
    my $level = shift || 0;

    # prevent infinite loops
    return if $level > 10;
    foreach my $child ( grep { defined } @{ $handle->{ChildHandles} } ) {
        if ( $child->{Type} eq "st" ) {    # st -> (prepared) Statement
            $child->finish();
        }
        else {
            &finish_child_handles( $child, $level + 1 );
        }
    }
    return;
}

############################################
# Usage      : my $dbh = VWebAdm::DB->connect($dsn);
# Purpose    : Connect to a Database
# Returns    : a valid DBI database handle
# Parameters : $dsn - the dsn
# Throws     : Exception if connection fails
# Comments   : none
# See Also   : n/a
sub connect {
    my $dsn  = shift;
    my $opts = shift || {};
    my $dbh  = undef;

    my $timeout = $opts->{ConnectTimeout} || 30;
    my $prev_timeout = 0;
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        $prev_timeout = alarm $timeout;
        $dbh = DBI->connect_cached( $dsn, undef, undef, { RaiseError => 0, PrintError => 0, } );
    };
    alarm $prev_timeout;

    # No eval error handling. If the connection timed out $dbh will be undef anyway ...
    if ($dbh) {
        if ( $opts->{RaiseError} ) {
            $dbh->{HandleError} = sub { confess(shift) };
        }
        if ( !$opts->{NoUTF8} ) {
            $dbh->do('SET NAMES utf8');
        }
        return $dbh;
    }
    else {
        my $msg = "Connection to DB failed with DSN $dsn: " . DBI->errstr;
        warn $msg;
        return;
    }
}

############################################
# Usage      : my $sth = VBoxAdm::prepexec($dbh, $query, @params);
# Purpose    : Prepare and execute a statement
# Returns    : ????
# Parameters : ????
# Throws     : Exception on error
# Comments   : none
# See Also   : n/a
sub prepexec {
    my ( $dbh, $sqlstr, @params ) = @_;
    my $sth;
    if ( $sth = $dbh->prepare($sqlstr) ) {
        if ( $sth->execute(@params) ) {
            return $sth;
        }
    }
    return;
}

1;
__END__

=head1 NAME

VWebAdm::DB - common DB methods for VBoxAdm

=head1 DESCRIPTION

This class provides common DB methods.

=cut
