package VBoxAdm::Model::DMARCRecord;

use Moose;
use namespace::autoclean;

use Carp;

use VWebAdm::DB '@VERSION@';
use VWebAdm::Utils '@VERSION@';

extends 'VWebAdm::Model';

sub _init_fields {
    return [qw(id report_id ip count disposition reason dkimdomain dkimresult spfdomain spfresult)];
}

sub create {
    my ( $self, $report_id, $ip, $count, $disposition, $reason, $dkimdomain, $dkimresult, $spfdomin, $spfresult ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    my $sql = 'INSERT INTO dmarc_records (report_id,ip,count,disposition,reason,dkimdomain,dkimresult,spfdomain,spfresult) VALUES(?,?,?,?,?,?,?,?,?)';
    my $sth = $self->dbh()->prepare($sql);
    
    if(!$sth) {
        $self->logger()->log( message => 'Failed to prepare SQL '.$sql.' w/ error: '.$self->dbh()->errstr(), level => 'error', );
        return;
    }
    
    $sth->execute($report_id, $ip, $count, $disposition, $reason, $dkimdomain, $dkimresult, $spfdomin, $spfresult);
    
    my $id = $self->dbh()->last_insert_id(undef, undef, undef, undef);
    
    $sth->finish();

    return $id;
}

sub update {
    my ( $self ) = @_;
    
    # No need to update those after creation

    return;
}

sub delete {
    my ( $self, $entry_id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_siteadmin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    # delete role account
    if ( $entry_id && $entry_id =~ m/^\d+$/ ) {
        
        my $query = "DELETE FROM dmarc_records WHERE id = ?";
        if ( my $sth = $self->dbh->prepare($query) ) {
            if ( $sth->execute($entry_id) ) {
                $sth->finish();
                $self->msg->push( 'information', "Deleted entry [_1].", $entry_id );
                return 1;
            }
            else {
                $self->logger()->log( message => 'Could not execute query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
                return;
            }
        }
        else {
            $self->logger()->log( message => 'Could not prepare query ' . $query . ' due to error: ' . $self->dbh()->errstr, level => 'error', );
            $self->msg->push( 'error', "Unable to delete RoleAccount $entry_id. Database Error." );
            return;
        }
    }

    return;
}

sub read {
    my ( $self, $id ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_read( 'dmarc_records', $id );
}

sub list {
    my ( $self, $params ) = @_;

    # Authorization - No access for regular users
    if ( !$self->user->is_admin() ) {
        $self->msg->push( 'error', 'Sorry. No access for regular users.' );
        return;
    }

    return $self->_list( 'dmarc_records', $params );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

VBoxAdm::Model::AWL - Class for AWL

=cut
