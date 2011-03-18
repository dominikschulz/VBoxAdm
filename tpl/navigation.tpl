<nav>
	<ul>
		<li><a[% IF current == 'welcome' %] class="current"[% END %] href="[% base_url %]?rm=welcome">[% "Overview" | l10n %]</a></li>
		[% IF is_superadmin %]
		<li><a[% IF current == 'admins' %] class="current"[% END %] href="[% base_url %]?rm=admins">[% "Admin List" | l10n %]</a></li>
		<li><a[% IF current == 'domains' %] class="current"[% END %] href="[% base_url %]?rm=domains">[% "Domain List" | l10n %]</a></li>
		[% END %]
		<li><a[% IF current == 'domain_aliases' %] class="current"[% END %] href="[% base_url %]?rm=domain_aliases">[% "Domain Aliases" | l10n %]</a></li>
		<li><a[% IF current == 'aliases' %] class="current"[% END %] href="[% base_url %]?rm=aliases">[% "Aliases" | l10n %]</a></li>
		<li><a[% IF current == 'mailboxes' %] class="current"[% END %] href="[% base_url %]?rm=mailboxes">[% "Mailboxes" | l10n %]</a></li>
		[% IF is_superadmin %]
		<li><a[% IF current == 'broadcast' %] class="current"[% END %] href="[% base_url %]?rm=broadcast">[% "Send Broadcast" | l10n %]</a></li>
		<li><a[% IF current == 'vacation' %] class="current"[% END %] href="[% base_url %]?rm=vac_bl">[% "Vacation Blacklist" | l10n %]</a></li>
		<li><a[% IF current == 'awl' %] class="current"[% END %] href="[% base_url %]?rm=awl">[% "Auto-Whitelist" | l10n %]</a></li>
		<li><a[% IF current == 'log' %] class="current"[% END %] href="[% base_url %]?rm=log">[% "View Log" | l10n %]</a></li>
		[% END %]
		<li><a[% IF current == 'logout' %] class="current"[% END %] href="[% base_url %]?rm=login&authen_logout=1">[% "Logout" | l10n %]</a></li>
	</ul>
</nav>
<br clear="all" />
<br />
