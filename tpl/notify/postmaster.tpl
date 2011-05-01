Dear Postmaster,

you are receiving this mail since your mailserver is probably misconfigured
or someone is abusing your domainname.

This message was sent to you automatically.

This Mailserver applies very strict rules to incoming mails as a measure
against spam. These rules may cause some side-effects. This mail was
sent to inform you that you may be affected by this.

Some mail coming from one of your mail relays or from one of your
customers was rejected due to one or more of the following reasons:

---------------------------------------------------------------------------
[% IF is_rdns %]
= INVALID REVERSE DNS RECORD ==============================================

Your mailserver is using a IP address for sending that has no valid reverse
DNS record. This makes it very hard to determine if this IP is eligible to
send mail for your domain and thus many mailservers will reject mails
coming from this IP.

How to fix this:
Contact your network department or ISP to setup a reverse DNS mapping
from the IP [% ip %] to your HELO hostname [% helo %].

--------------------------------------------------------------------------- 
[% END %]
[% IF is_helo %]
= INVALID HELO HOSTNAME ===================================================

Your mailserver is using a HELO hostname during the greeting sequence of
SMTP which does not resolve to a valid IP address. This is regarded bad
style and should be fixed.

How to fix this:
Set your HELO hostname to your RDNS [% rdns %] or make the reverse DNS
of the IP [% ip %] match your HELO hostname [% helo %].

---------------------------------------------------------------------------
[% END %]
= GENERAL INFORMATION =====================================================

[% logline %]

The rejected email probably still resides on the machine with the
IP-Address: [% ip %], calling itself [% helo %].

Investigations at my end show:

Sender    = [% from %]
Recipient = [% to %]
From-IP   = [% ip %]
From-Host = [% rdns %]
Helo      = [% helo %]

'dig [% helo %]' resulted in : [% helo_ip %]
'dig -x [% ip %]' resulted in: [% rdns %]
'dig [% rdns %]' resulted in : [% fdns %]

---------------------------------------------------------------------------

The recipient(s), to which this message was addressed, has already received
a notification about this.

To make sure you mail gets delivery to all users of this mailserver please
fix all issues listed above.

You will receive this mail only once. Please act acordingly to restore full service to your users.

Best Regards,

postmaster@[% system_domain %]
