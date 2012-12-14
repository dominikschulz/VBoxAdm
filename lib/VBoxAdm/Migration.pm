package VBoxAdm::Migration;

use Moose;
use namespace::autoclean;

has 'dbh' => (
    'is'      => 'ro',
    'isa'     => 'DBI::db',
    'lazy'    => 1,
    'builder' => '_init_dbh',
);

has 'type' => (
    'is'    => 'ro',
    'isa'   => 'Str',
    'require' => 1,
);

has 'sourcedb' => (
    'is'    => 'ro',
    'isa'   => 'Str',
    'required' => 1,
);

has 'targetdb' => (
    'is'    => 'ro',
    'isa'   => 'Str',
    'required' => 1,
);

with qw(Config::Yak::NamedPlugins);

sub _plugin_base_class { return 'VBoxAdm::Migration::Plugin'; }

sub truncate {
    my $self = shift;
    
    my @queries = ();
    push( @queries, 'TRUNCATE TABLE `' . $self->target_db . '`.aliases' );
    push( @queries, 'TRUNCATE TABLE `' . $self->target_db . '`.mailboxes' );
    push( @queries, 'TRUNCATE TABLE `' . $self->target_db . '`.domains' );
    push( @queries, 'TRUNCATE TABLE `' . $self->target_db . '`.domain_aliases' );
    foreach my $q (@queries) {
        $self->dbh()->do($q)
          or die( "Could not execut query $q: " . $self->dbh()->errstr );
    }
    
    return 1;
}

sub migrate {
    my $self = shift;
    
    return $self->_plugins()->{$self->type()}();
}

1;
__END__

=head1 NAME

VBoxAdm::Migration - migration methods to VBoxAdm

=head1 DESCRIPTION

This class provides migration methods.

=cut
