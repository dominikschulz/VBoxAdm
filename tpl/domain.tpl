[% INCLUDE header.tpl %]
	<h2>Domain: [% domain %]</h2>
	<br />
    <div id="main">
		[% FOREACH line IN domain_aliases %]
		[% IF loop.first %]
		<h2>Domain-Aliases</h2>
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>[% "Alias" | l10n %]</th>
				<th>[% "Active" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.name %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_domain&domain_id=[% line.id %]&is_active=0">[% "Yes" | l10n %]</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_domain&domain_id=[% line.id %]&is_active=1">[% "No" | l10n %]</a>
					[% END %]
				</td>
			</tr>
		[% IF loop.last %]
		</tbody>
		<tfoot>
		</tfoot>
		</table>
		[% END %]
		[% END %]
		<br />
		[% FOREACH line IN aliases %]
		[% IF loop.first %]
		<h2>Aliases</h2>
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>[% "Alias" | l10n %]</th>
				<th>[% "Ziel" | l10n %]</th>
				<th>[% "Aktiv" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.local_part %]@[% domain %]
				</td>
				<td>
					[% line.goto %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_alias&alias_id=[% line.id %]&is_active=0">[% "Yes" | l10n %]</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_alias&alias_id=[% line.id %]&is_active=1">[% "No" | l10n %]</a>
					[% END %]
				</td>
			</tr>
		[% IF loop.last %]
		</tbody>
		<tfoot>
		</tfoot>
		</table>
		[% END %]
		[% END %]
		<br />
		[% FOREACH line IN mailboxes %]
		[% IF loop.first %]
		<h2>Mailboxes</h2>
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>[% "Mailbox" | l10n %]</th>
				<th>[% "User" | l10n %]</th>
				<th>[% "Active" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.local_part %]@[% domain %]
				</td>
				<td>
					[% line.name %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_mailbox&mailbox_id=[% line.id %]&is_active=0">[% "Yes" | l10n %]</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_mailbox&mailbox_id=[% line.id %]&is_active=1">[% "No" | l10n %]</a>
					[% END %]
				</td>
			</tr>
		[% IF loop.last %]
		</tbody>
		<tfoot>
		</tfoot>
		</table>
		[% END %]
		[% END %]
		<br />
    </div>
[% INCLUDE footer.tpl %]
