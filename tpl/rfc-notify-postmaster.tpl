Dear Postmaster,

you are receiving this mail since your mailserver is probably misconfigured or someone is abusing your domainname.
You will receive this mail only once. Please act acordingly to restore full service to your users.

Below you will find detailed information about what is wrong with your mailserver and some pointers on how to fix this issue.

[% IF is_rdns %]
INVALID REVERSE DNS RECORD

Your mailserver is using a IP address for sending that has no valid reverse DNS record. This makes it very hard to determine if this
IP is eligible to send mail for your domain and thus many mailservers will reject mails coming from this IP.

How to fix this:
Contact your network department or ISP to setup a reverse DNS mapping from the IP [% ip %] to your HELO hostname [% helo %]. 
[% END %]

[% IF is_helo %]
INVALID HELO HOSTNAME

Your mailserver is using a HELO hostname during the greeting sequence of SMTP which does not resolve to a valid IP address.
This is regarded bad style and should be fixed.

How to fix this:
Set your HELO hostname to your RDNS [% rdns %] or make the reverse DNS of the IP [% ip %] match your HELO hostname [% helo %].
[% END %]

Please don't make the misconeption that because some mailservers are accepting your mail everyone will do.

You should alway make sure that the HELO name of your mailserver resolves to a valid IP whose reverse DNS resolves to your HELO name again.

Best Regards,

postmaster@[% system_domain %]
