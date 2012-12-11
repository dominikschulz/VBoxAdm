package VWebAdm::API;

use Moose;
use namespace::autoclean;

use LWP::UserAgent;
use MIME::Base64;
use Crypt::CBC;
use Digest::SHA;
use JSON;
use URI::Escape;
use Encode;
use Log::Tree '@VERSION@';

has 'key'   => (
    'is'    => 'ro',
    'isa'   => 'Str',
    'required' => 1,
);

has 'logger' => (
    'is'      => 'rw',
    'isa'     => 'Log::Tree',
    'required'    => 1,
);

has '_ua' => (
    'is'      => 'rw',
    'isa'     => 'LWP::UserAgent',
    'lazy'    => 1,
    'builder' => '_init_ua',
);

has 'json' => (
    'is'      => 'rw',
    'isa'     => 'JSON',
    'lazy'    => 1,
    'builder' => '_init_json',
);

sub _init_ua {
    my $self = shift;

    my $UA = LWP::UserAgent::->new();
    $UA->agent('VWebAdm/RemoteCLI @VERSION@');

    return $UA;
}

sub _init_json {
    my $self = shift;

    my $JSON = JSON::->new->utf8();

    return $JSON;
}

sub http_request {
    my $self = shift;
    my $url  = shift;
    my $post = shift;
    my $opts = shift || {};

    my $req;
    my $req_content = '';
    if ($post) {
        $req = HTTP::Request->new( POST => $url );
        $req->content_type('application/x-www-form-urlencoded');
        $req->content($req_content);
        $self->logger()->log( message => "http_request($url) - INFO - POST Content: " . $req_content, level => 'debug', );
    }
    else {
        $req = HTTP::Request->new( GET => $url );
    }

    if ( $opts->{'User'} && $opts->{'Pass'} ) {
        $req->authorization_basic( $opts->{'User'}, $opts->{'Pass'} );
    }

    my $content;
    my $response;
    my $timeout = $opts->{Timeout} || 10;
    my $prev_timeout = 0;
    eval {
        local $SIG{ALRM} = sub { die "alarm\n"; };
        $prev_timeout = alarm $timeout;
        $response     = $self->_ua()->request($req);
        $content      = $response->content;
        if ( !$response->is_success ) {
            die( "ERROR " . $response->code . " - " . $content . "\n" );
        }
        if ( !$content ) {
            die("HTTP request failed!");
        }
    };
    alarm $prev_timeout;
    if ($@) {
        warn "http_request($url) - WARNING: $@";
        return;
    }
    else {
        $self->logger()->log( message => "http_request($url) - SUCCESS!", level => 'debug', );
        return wantarray ? ( $content, $response ) : $content;
    }
}

sub decrypt {
    my $self       = shift;
    my $ciphertext = shift;

    $ciphertext = MIME::Base64::decode_base64( URI::Escape::uri_unescape($ciphertext) );

    if ( !$self->key() || length($self->key()) < 12 ) {
        $self->logger()->log( message => "Misconfigured Server. Invalid Key Length.", level => 'error', );
        return;
    }

    my $key = $self->gen_key($self->key());
    my $iv  = $self->gen_iv($self->key());

    # the Crypt::CBC parameters are important,
    # this set of parameters makes the ciphertext
    # compatible with PHP's mcrypt_cbc method.
    my $cipher = Crypt::CBC::->new(
        -key         => $key,
        -cipher      => 'Blowfish',
        -iv          => $iv,
        -header      => 'none',
        -padding     => 'null',
        -literal_key => 1,
        -keysize     => length($key),
    );

    my $plaintext = undef;
    eval { $plaintext = $cipher->decrypt($ciphertext); };
    if ( $@ || !$plaintext ) {
        $self->logger()->log( message => "Failed to decrypt ciphertext: $@", level => 'warning', );
        return;
    }

    # plaintext should now contain a JSON string
    my $hash_ref = undef;
    eval { $hash_ref = $self->json()->decode($plaintext); };
    if ( $@ || !$hash_ref ) {
        $self->logger()->log( message => "Failed to decode JSON to hash_ref: $@", level => 'warning', );
        return;
    }
    return $hash_ref;
}

sub encrypt {
    my $self     = shift;
    my $hash_ref = shift;

    my $plaintext = undef;
    eval { $plaintext = $self->json()->encode($hash_ref); };
    if ( $@ || !$plaintext ) {
        $self->logger()->log( message => "Failed to encode hashref to JSON: $@", level => 'warning', );
        return;
    }

    if ( !$self->key() || length($self->key()) < 12 ) {
        $self->logger()->log( message => "Misconfigured Server. Invalid Key Length.", level => 'warning', );
        return;
    }

    my $key = $self->gen_key($self->key());
    my $iv  = $self->gen_iv($self->key());

    # the Crypt::CBC parameters are important,
    # this set of parameters makes the ciphertext
    # compatible with PHP's mcrypt_cbc method.
    my $cipher = Crypt::CBC::->new(
        -key         => $key,
        -cipher      => 'Blowfish',
        -iv          => $iv,
        -header      => 'none',
        -padding     => 'null',
        -literal_key => 1,
        -keysize     => length($key),
    );

    my $ciphertext = undef;
    eval { $ciphertext = $cipher->encrypt($plaintext); };
    if ( $@ || !$ciphertext ) {
        $self->logger()->log( message => "Failed to encrypt the plaintext: $@", level => 'warning', );
        return;
    }
    else {
        return URI::Escape::uri_escape( encode_base64($ciphertext) );
    }
}

sub gen_key {
    my $self = shift;
    my $key  = shift;
    return substr( Digest::SHA::sha512($key), 0, 56 );
}

sub gen_iv {
    my $self = shift;
    my $key  = shift;
    return substr( Digest::SHA::sha512($key), 56 );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

VWebAdm::API - Common API methods

=head1 DESCRIPTION

This module implements a simple HTTP-API to remote controll VBoxAdm.

=cut
