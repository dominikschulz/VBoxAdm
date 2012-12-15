package VBoxAdm::Cmd::Command::mailbox;
# ABSTRACT: modify mailboxes

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
    'required'      => 0,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'a',
    'documentation' => 'Email address to add',
);

has 'update' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 0,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'u',
    'documentation' => 'Email address to update',
);

has 'delete' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'required'      => 0,
    'default'       => 0,
    'traits'        => [qw(Getopt)],
    'cmd_aliases'   => 'd',
    'documentation' => 'Email address to delete',
);

has '_domain' => (
    'is'      => 'ro',
    'isa'     => 'VBoxAdm::Model::Domain',
    'lazy'    => 1,
    'builder' => '_init_domain',
    'reader'  => 'domain',
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
    my ( $local_part, $domain ) = split /@/, $email;
    my $domain_id = $self->domain()->get_id($domain);
    if ( !$domain_id ) {

        # Try to create domain first
        $self->domain()->create($domain);
        $domain_id = $self->domain()->get_id($domain);
    }
    if ( !$domain_id ) {
        print "Unknown Domain. Please create Domain first.\n";
        return;
    }
    my $params;
    foreach my $key (
        qw(
        Password PasswordAgain
        Name IsActive MaxMsgSize IsSiteadmin IsDomainadmin
        SAKillScore SAActive
        IsOnVacation VacationSubject VacationMessage VacationStart VacationEnd
        )
      )
    {
        $params->{$key} = $self->opts()->{$key} if defined( $self->opts()->{$key} );
    }
    print "Add User: $email\n";
    my $status = $self->mailbox()->create( $local_part, $domain_id, $params );
    $self->display_messages();
    
    return $status;
}

sub exec_update {
    my $self = shift;

    my $email = shift;
    my $mailbox_id;
    if ( $email =~ m/^\d+$/ ) {
        $mailbox_id = $email;
    }
    else {
        $mailbox_id = $self->mailbox()->get_id($email);
    }
    my $params;
    foreach my $key (
        qw(
        Password PasswordAgain
        Name IsActive MaxMsgSize IsSiteadmin IsDomainadmin
        SAKillScore SAActive
        IsOnVacation VacationSubject VacationMessage VacationStart VacationEnd
        ForcePassword
        )
      )
    {
        $params->{$key} = $self->opts()->{$key} if defined( $self->opts()->{$key} );
    }

    # Longer vacation messages can not be given on the commandline, they may also be a file
    if ( $params->{VacationMessage} && -f $params->{VacationMessage} ) {
        $params->{VacationMessage} = File::Blarf::slurp( $params->{VacationMessage} );
    }
    print "Update User: $email\n";

    # locked passwords can not be changed in the web gui but on the CLI
    if ( $self->opts()->{ForcePassword} ) {
        $params->{'pw_lock_override'} = 1;
    }
    my $status = $self->mailbox()->update( $mailbox_id, $params );
    $self->display_messages();
    
    return $status;
}

sub exec_delete {
    my $self = shift;

    say 'Delete User: '.$self->delete();
    my $mailbox_id;
    if ( $self->delete() =~ m/^\d+$/ ) {
        $mailbox_id = $self->delete();
    }
    else {
        $mailbox_id = $self->mailbox()->get_id($self->delete());
    }
    my $status = $self->mailbox()->delete($mailbox_id);
    $self->display_messages();
    
    return $status;
}

sub list {
    my $self = shift;
    
    print "Listing Mailboxes:\n";
    my $format = "%i\t%s\@%s\t%s\t%i\t%f\t%i\t%i\t%i\n";
    print "ID\tEmail\tName\tSA-Kill-Score\tSA-Active\tMax-Msg-Size\tActive\tSiteadmin\tDomainadmin\tVacation\n";
    foreach my $mailbox ( $self->mailbox()->list() ) {
        printf( $format,
            @{$mailbox}{qw(id local_part domain sa_kill_score sa_active max_msg_size is_active is_siteadmin is_domainadmin is_on_vacation)} );
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

VBoxAdm::Cmd::Command::aliasadd - 

=method abstract

Workadound.

=method execute

Command

=cut
