<?xml version="1.0" encoding="utf-8" ?>
<!-- see http://technet.microsoft.com/en-us/library/cc511507.aspx#AutodiscoverXMLSchema -->
<Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/responseschema/2006">
	<Response xmlns="http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a">
		<Account>
			<AccountType>email</AccountType>
			<Action>settings</Action>
[% IF imap_ssl %]
			<Protocol>
				<Type>IMAP</Type>
				<Server>[% imap_hostname %]</Server>
				<LoginName>[% username %]</LoginName>
				<Port>993</Port>
				<DomainRequired>on</DomainRequired>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<AuthRequired>on</AuthRequired>
			</Protocol>
[% END %]
[% IF pop3_ssl %]
			<Protocol>
				<Type>POP3</Type>
				<Server>[% pop3_hostname %]</Server>
				<LoginName>[% username %]</LoginName>
				<Port>995</Port>
				<DomainRequired>off</DomainRequired>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<AuthRequired>on</AuthRequired>
			</Protocol>
[% END %]
[% IF smtp_plain %]
			<Protocol>
				<Type>SMTP</Type>
				<Server>[% smtp_hostname %]</Server>
				<LoginName>[% username %]</LoginName>
				<Port>25</Port>
				<DomainRequired>off</DomainRequired>
				<SPA>off</SPA>
				<SSL>off</SSL>
				<AuthRequired>on</AuthRequired>
				<UsePOPAuth>off</UsePOPAuth>
				<SMTPLast>off</SMTPLast>
			</Protocol>
[% END %]
[% IF smtp_ssl %]
			<Protocol>
				<Type>SMTP</Type>
				<Server>[% smtp_hostname %]</Server>
				<LoginName>[% username %]</LoginName>
				<Port>465</Port>
				<DomainRequired>off</DomainRequired>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<AuthRequired>on</AuthRequired>
				<UsePOPAuth>off</UsePOPAuth>
				<SMTPLast>off</SMTPLast>
			</Protocol>
[% END %]
[% IF smtp_sma %]
			<Protocol>
				<Type>SMTP</Type>
				<Server>[% smtp_hostname %]</Server>
				<LoginName>[% username %]</LoginName>
				<Port>587</Port>
				<DomainRequired>off</DomainRequired>
				<SPA>off</SPA>
				<SSL>on</SSL>
				<AuthRequired>on</AuthRequired>
				<UsePOPAuth>off</UsePOPAuth>
				<SMTPLast>off</SMTPLast>
			</Protocol>
[% END %]
		</Account>
	</Response>
</Autodiscover>
