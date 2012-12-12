package VBoxAdm::Cmd::Command::aliasadd;
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
use VBoxAdm::Model::Alias;

# extends ...
extends 'VBoxAdm::Cmd::Command';
# has ...
has 'email' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 1,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'e',
    'documentation' => 'Email address to add',
);

has '_alias' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::Alias',
    'lazy'    => 1,
    'builder' => '_init_alias',
    'accessor' => 'alias',
);


has '_domain' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::Domain',
    'lazy'    => 1,
    'builder' => '_init_domain',
    'accessor' => 'domain',
);

sub _init_alias {
    my $self = shift;

    my $Alias = VBoxAdm::Model::Alias::->new(
        {
            'dbh'    => $self->dbh(),
            'logger' => $self->logger(),
            'config' => $self->config(),
            'user'   => $self->user(),
            'msgq'   => $self->msgq(),
        }
    );

    return $Alias;
}

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
# with ...
# initializers ...

# your code here ...
sub execute {
    my $self = shift;
    
    if($self->add()) {
        return $self->add();
    } elsif($self->update()) {
        return $self->exec_update();
    } elsif($self->delete()) {
        return $self->exec_delete();
    } else {
        return $self->list();
    }
}

sub exec_add {
    my $self = shift;
    
    my $goto  = $self->goto();
    print "Add Alias.\n";
    if ( !$goto ) {
        print "Need goto address\n";
        return;
    }
    my ( $local_part, $domain ) = split /@/, $self->add();
    my $domain_id = $self->domain()->get_id($domain);
    if ( !$domain_id ) {
        print "Need valid domain\n";
        return;
    }
    my $status = $self->alias()->create( $local_part, $domain_id, $goto );
    $self->_display_messages();
    return $status;
}

sub exec_update {
    my $self = shift;

    my $params;
    $params->{'IsActive'}   = $self->active();
    $params->{'Goto'}       = $self->goto();
    say 'Update Alias';
    my $status = $self->alias()->update( $self->alias()->get_id($self->update()), $params );
    $self->_display_messages();
    
    return $status;
}

sub exec_delete {
    my $self = shift;
    
    print "Delete Alias.\n";
    my $alias_id;
    my $email = $self->delete();
    if ( $email =~ m/^\d+$/ ) {
        $alias_id = $email;
    }
    else {
        $alias_id = $self->alias()->get_id($email);
    }
    my $status = $self->alias()->delete($alias_id);
    $self->display_messages();
    
    return $status;
}

sub list {
    my $self = shift;
    
    print "Listing Aliases:\n";
    my $format = "%i\t%s\@%s\t%s\t%i\n";
    print "ID\tEmail\tGoto\tIs Active\n";
    foreach my $alias ( $self->alias()->list() ) {
        printf( $format, @{$alias}{qw(id local_part domain goto is_active)} );
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

VBoxAdm::Cmd::Command::alias - handle aliases

=method abstract

Workadound.

=method execute

Command

=cut
