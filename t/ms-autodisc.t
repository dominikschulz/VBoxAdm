#!perl
use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;

# Microsoft Outlook 2010+ Autodiscover Test

use LWP::UserAgent;

my $url = "http://localhost/cgi-bin/autodiscover.pl";
my $xml = <<'HERE';
<?xml version="1.0" encoding="utf-8" ?>
<Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/outlook/requestschema/2006">
<Request>
<AcceptableResponseSchema>http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a</AcceptableResponseSchema>
<EMailAddress>user@domain.tld</EMailAddress>
</Request>
</Autodiscover>
HERE
my $request  = POST $url, Content_Type => 'text/xml; charset=utf-8', Content => $xml;
my $ua       = LWP::UserAgent->new();
my $response = $ua->request($request);
if ( $response->is_success() ) {
    print $response->content();
}
else {
    warn $response->status_line, $/;
    print $response->content();
}

# TODO test web app w/ Plack::Test

plan( skip_all => "Not yet implemented" );