<nav>
	<ul>
		<li><a href="vboxadm.pl?rm=welcome">[% "Overview" | l10n %]</a></li>
		[% IF is_superadmin %]
		<li><a href="vboxadm.pl?rm=admins">[% "Admin List" | l10n %]</a></li>
		<li><a href="vboxadm.pl?rm=domains">[% "Domain List" | l10n %]</a></li>
		[% END %]
		<li><a href="vboxadm.pl?rm=domain_aliases">[% "Domain Aliases" | l10n %]</a></li>
		<li><a href="vboxadm.pl?rm=aliases">[% "Aliases" | l10n %]</a></li>
		<li><a href="vboxadm.pl?rm=mailboxes">[% "Mailboxes" | l10n %]</a></li>
		[% IF is_superadmin %]
		<li><a href="vboxadm.pl?rm=log">[% "View Log" | l10n %]</a></li>
		[% END %]
		<li><a href="vboxadm.pl?rm=login&authen_logout=1">[% "Logout" | l10n %]</a></li>
	</ul>
</nav>
<br clear="all" />
<br />
