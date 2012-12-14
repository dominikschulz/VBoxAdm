package VBoxAdm::Migration::Plugin;
# ABSTRACT: baseclass for any revobackup plugin

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

# extends ...
# has ...
has 'parent' => (
    'is'    => 'rw',
    'isa'   => 'VBoxAdm::Migration',
    'required' => 1,
);

has 'priority' => (
    'is'    => 'ro',
    'isa'   => 'Int',
    'lazy'  => 1,
    'builder' => '_init_priority',
);

has 'sth_new_domain' => (
    'is'    => 'ro',
    'isa'   => 'DBI::st',
    'lazy'  => 1,
    'builder' => '_init_sth_new_domain',
);

has 'sth_new_alias' => (
    'is'    => 'ro',
    'isa'   => 'DBI::st',
    'lazy'  => 1,
    'builder' => '_init_sth_new_alias',
);

has 'sth_new_mailbox' => (
    'is'    => 'ro',
    'isa'   => 'DBI::st',
    'lazy'  => 1,
    'builder' => '_init_sth_new_mailbox',
);

has 'sth_new_domainalias' => (
    'is'    => 'ro',
    'isa'   => 'DBI::st',
    'lazy'  => 1,
    'builder' => '_init_sth_new_domainalias',
);

has 'sth_set_vacation' => (
    'is'    => 'ro',
    'isa'   => 'DBI::st',
    'lazy'  => 1,
    'builder' => '_init_sth_set_vacation',
);

has 'sth_set_admin' => (
    'is'    => 'ro',
    'isa'   => 'DBI::st',
    'lazy'  => 1,
    'builder' => '_init_sth_set_domain',
);

# with ...
with qw(Config::Yak::RequiredConfig Log::Tree::RequiredLogger);
# initializers ...
sub _init_priority { return 0; }

sub _init_sth_new_domain {
    my $self = shift;
    
    my $sql_new_domain = 'INSERT INTO `'.$self->parent()->targetdb().'`.domains (name,is_active) VALUES(?,?)';
    return $self->dbh()->prepare($sql_new_domain);
}

sub _init_sth_new_alias {
    my $self = shift;
    
    my $sql_new_alias = 'INSERT INTO `'.$self->parent()->targetdb().'`.aliases (domain_id,local_part,goto,is_active) VALUES(?,?,?,?)';
    return $self->dbh()->prepare($sql_new_alias);
}

sub _init_sth_new_mailbox {
    my $self = shift;
    
    my $sql_new_mailbox = 'INSERT INTO `'.$self->parent()->targetdb().'`.mailboxes ';
    $sql_new_mailbox .= '(domain_id,local_part,password,name,is_active,max_msg_size,is_on_vacation,vacation_subj,vacation_msg,';
    $sql_new_mailbox .= 'is_domainadmin,is_siteadmin,sa_active,sa_kill_score) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)';
    return $self->dbh()->prepare($sql_new_mailbox);
}

sub _init_sth_new_domainalias {
    my $self = shift;
    
    my $sql_new_domain_alias = 'INSERT INTO `'.$self->parent()->targetdb().'`.domain_aliases (name,domain_id,is_active) VALUES(?,?,1)';
    return $self->dbh()->prepare($sql_new_domain_alias);
}

sub _init_sth_set_vacation {
    my $self = shift;

    my $sql_vacation_status = 'INSERT INTO `'.$self->parent()->targetdb().'`.vacation_notify (on_vacation,notified,notified_at) VALUES(?,?,?)';
    return $self->dbh()->prepare($sql_vacation_status);
}

sub _init_sth_set_admin {
    my $self = shift;

    my $sql_set_admin = 'UPDATE `'.$self->parent()->targetdb().'`.mailboxes SET is_domainadmin = ?, is_siteadmin = ? ';
    $sql_set_admin .= 'WHERE local_part = ? AND domain_id = (SELECT id FROM domains WHERE name = ?)';
    return $self->dbh()->prepare($sql_set_admin);
}

# your code here ...
sub run { return; }

sub DEMOLISH {
    my $self = shift;
    
    $self->sth_new_domain()->finish();
    $self->sth_new_alias()->finish();
    $self->sth_new_mailbox()->finish();
    $self->sth_vacation_status()->finish();
    $self->sth_set_admin()->finish();
    
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

VBoxAdm::Migration::Plugin - Baseclass for any VBoxAdm Migration plugin.

=method run

Import.

=cut
