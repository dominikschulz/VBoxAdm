<?xml version="1.0" encoding="UTF-8"?>
<!-- see https://wiki.mozilla.org/Thunderbird:Autoconfiguration:ConfigFileFormat -->
<clientConfig version="1.1">
  <emailProvider id="[% domain %]">
    <domain>[% domain %]</domain>
    <displayName>[% title %]</displayName>
    <displayShortName>[% short_name %]</displayShortName>
[% IF imap_ssl %]
    <incomingServer type="imap">
      <hostname>[% imap_hostname %]</hostname>
      <port>993</port>
      <socketType>SSL</socketType>
      <authentication>password-encrypted</authentication>
      <username>[% username %]</username>
    </incomingServer>
[% END %]
[% IF imap_tls %]
    <incomingServer type="imap">
      <hostname>[% imap_hostname %]</hostname>
      <port>143</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-encrypted</authentication>
      <username>[% username %]</username>
    </incomingServer>
[% END %]
[% IF pop3_ssl %]
    <incomingServer type="pop3">
      <hostname>[% pop3_hostname %]</hostname>
      <port>995</port>
      <socketType>SSL</socketType>
      <authentication>password-cleartext</authentication>
      <username>[% username %]</username>
    </incomingServer>
[% END %]
[% IF pop3_tls %]
    <incomingServer type="pop3">
      <hostname>[% pop3_hostname %]</hostname>
      <port>110</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>[% username %]</username>
    </incomingServer>
[% END %]
[% IF smtp_ssl %]
    <outgoingServer type="smtp">
      <hostname>[% smtp_hostname %]</hostname>
      <port>465</port>
      <socketType>SSL</socketType>
      <authentication>password-encrypted</authentication>
      <username>[% username %]</username>
    </outgoingServer>
[% END %]
[% IF smtp_sma %]
    <outgoingServer type="smtp">
      <hostname>[% smtp_hostname %]</hostname>
      <port>587</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-encrypted</authentication>
      <username>[% username %]</username>
    </outgoingServer>
[% END %]
[% IF doc_url %]
[% FOREACH lang doc_langs %]
[% IF loop.first %]
    <documentation url="[% doc_url %]">
[% END %]
      <descr lang="[% lang.shortcode %]">[% lang.text %]</descr>
[% IF loop.last %]
    </documentation>
[% END %]
[% END %]
[% END %]
  </emailProvider>
</clientConfig>
