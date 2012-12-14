package VBoxAdm::Cmd::Command::vacbl;
# ABSTRACT: edit vacation blacklist entries

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;
# use Carp;
# use English qw( -no_match_vars );
# use Try::Tiny;
use VBoxAdm::Model::VacationBlacklist;

# extends ...
extends 'VBoxAdm::Cmd::Command';
# has ...
has 'add' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'e',
    'documentation' => 'Email address to add',
);

has 'vacationblacklist' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::VacationBlacklist',
    'lazy'    => 1,
    'builder' => '_init_vacationblacklist',
);

sub _init_vacationblacklist {
    my $self = shift;

    my $VB = VBoxAdm::Model::VacationBlacklist::->new(
        {
            'dbh'    => $self->dbh(),
            'logger' => $self->logger(),
            'config' => $self->config(),
            'user'   => $self->user(),
            'msgq'   => $self->msgq(),
        }
    );

    return $VB;
}
# with ...
# initializers ...

# your code here ...
sub execute {
    my $self = shift;

    if($self->add()) {
        return $self->exec_add();
    } elsif($self->update()) {
        return $self->exec_update();
    } elsif($self->delete()) {
        return $self->exec_delete();
    } else {
        return $self->list();
    }
    
    return;
}

sub exec_add {
    my $self = shift;
    
    my $email = shift;
    print "Add VacationBlacklist entry: $email\n";
    my $status = $self->vacationblacklist()->create($email);
    $self->display_messages();
    
    return $status;
}

sub exec_delete {
    my $self = shift;
    
    my $email = shift;
    print "Delete VacationBlacklist entry.\n";
    my $status = $self->vacationblacklist()->delete( $self->vacationblacklist()->get_id($email) );
    $self->display_messages();
    
    return $status;
}

sub list {
    my $self = shift;
    
    print "List VacationBlacklist entries:\n";
    print "ID\tEmail\n";
    my $format = "%i\t%s\@%s\n";
    foreach my $e ( $self->vacationblacklist()->list() ) {
        printf( $format, @{$e}{qw(id local_part domain)} );
    }
    $self->display_messages();
    
    return 1;
},

sub abstract {
    return 'Command';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command::vacbl - 

=method abstract

Workadound.

=method execute

Command

=cut
