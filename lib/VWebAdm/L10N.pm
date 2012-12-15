package VWebAdm::L10N;

use strict;
use warnings;

use base qw(Locale::Maketext);



our %Lexicon = ( '_AUTO' => 1, );

sub encoding {
    return "utf-8";
}

sub left {
    return 'left';
}

sub right {
    return 'right';
}

sub direction {
    return 'ltr';
}

1;

__END__
see http://search.cpan.org/~toddr/Locale-Maketext-1.17/lib/Locale/Maketext.pod

=head1 NAME

VDnsAdm::L10N - Local::Maketext baseclass for VBoxAdm

=head1 DESCRIPTION

This class provides a base class for the loclization.

=cut
