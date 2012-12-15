package VBoxAdm::Model::VacationNotify;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB;
use VWebAdm::Utils;

extends 'VWebAdm::Model';

# DGR: Well, sorry for you Perl::Critic, but you're unable to keep up with my OO style ;)
## no critic (ProhibitUnusedPrivateSubroutines)
sub _init_fields { return [qw(on_vacation notified notified_at)]; }
## use critic

sub create {
    my ( $self, $email ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return;
}

sub update {
    my ( $self, $entry_id, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return;
}

sub delete {
    my ( $self, $entry_id, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return;
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_list( 'vacation_notify', $params );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::VacationNotify - Class for VacationNotify

=cut
