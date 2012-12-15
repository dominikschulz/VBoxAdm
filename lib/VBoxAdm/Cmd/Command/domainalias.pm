package VBoxAdm::Cmd::Command::domainalias;
# ABSTRACT: add a new alias

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
use VBoxAdm::Model::Domain;

# extends ...
extends 'VBoxAdm::Cmd::Command';
# has ...
has 'add' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'a',
    'documentation' => 'Domainalias to add',
);

has 'update' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'a',
    'documentation' => 'Domainalias to add',
);

has 'delete' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'a',
    'documentation' => 'Domainalias to add',
);

has 'goto' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'g',
    'documentation' => 'Domainalias destination',
);

has '_domain' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::Domain',
    'lazy'    => 1,
    'builder' => '_init_domain',
    'reader'  => 'domain',
);

has '_domainalias' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::DomainAlias',
    'lazy'    => 1,
    'builder' => '_init_domainalias',
    'reader'  => 'domainalias',
);

sub _init_domain {
    my $self = shift;

    my $Domain = VBoxAdm::Model::Domain::->new(
        {
            'dbh'    => $self->dbh(),
            'logger' => $self->logger(),
            'config' => $self->config(),
            'user'   => $self->user(),
            'msgq'   => $self->msgq(),
        }
    );

    return $Domain;
}

sub _init_domainalias {
    my $self = shift;

    my $DomainAlias = VBoxAdm::Model::DomainAlias::->new(
        {
            'dbh'    => $self->dbh(),
            'logger' => $self->logger(),
            'config' => $self->config(),
            'user'   => $self->user(),
            'msgq'   => $self->msgq(),
        }
    );

    return $DomainAlias;
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

    my $domain_id = $self->domain()->get_id($self->goto());
    if ( !$domain_id ) {    # no known domain
        print "Error. Unknown Target Domain.\n";
        return;
    }
    print "Add DomainAlias.\n";
    my $status = $self->domainalias()->create( $self->add(), $domain_id );
    $self->display_messages();
    
    return $status;
}

sub exec_update {
    my $self = shift;

    my $params;
    $params->{'IsActive'}   = $self->active();
    $params->{'Goto'}       = $self->goto();

    say 'Update DomainAlias '.$self->update();
    my $status = $self->domainalias()->update( $self->domainalias()->get_id($self->update()), $params );
    $self->display_messages();
    
    return $status;
}

sub exec_delete {
    my $self = shift;

    say 'Delete DomainAlias';
    my $status = $self->domainalias()->delete( $self->domainalias()->get_id($self->delete()) );
    $self->display_messages();
    
    return $status;
}

sub list {
    my $self = shift;
    
    print "Listing DomainAliases:\n";
    my $format = "%i\t%s\t%s\t%i\n";
    print "ID\tDomain\tGoto\tIs Active\n";
    foreach my $domain ( $self->domainalias()->list() ) {
        printf( $format, @{$domain}{qw(id name domain_id is_active)} );
    }
    $self->display_messages();
    
    return 1;
}

sub abstract {
    return 'Command';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Cmd::Command::domainalias - 

=method abstract

Workadound.

=method execute

Command

=cut
