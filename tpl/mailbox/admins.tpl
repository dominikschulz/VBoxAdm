[% INCLUDE includes/header.tpl %]
    <div id="main" role="main">
    	<h1>Admins</h1>
		[% FOREACH line IN admins %]
		[% IF loop.first %]
		<table class="datatable">
			<thead>
			<tr>
				<th>[% "User" | l10n %]</th>
				<th>[% "Active" | l10n %]</th>
				<th>[% "Domainadmin" | l10n %]</th>
				<th>[% "Superadmin" | l10n %]</th>
				<th></th>
				<th></th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr class="[% loop.parity %] [% IF line.is_active %]enabled[% ELSE %]disabled[% END %]">
				<td>
					<a href="[% base_url %]?rm=edit_mailbox&mailbox_id=[% line.id %]">[% line.local_part %]@[% line.domain %]</a>
				</td>
				<td>
					[% IF line.is_active == 1 %]
					[% "Yes" | l10n %]
					[% ELSE %]
					[% "No" | l10n %]
					[% END %]
				</td>
				<td>
					[% IF line.is_domainadmin == 1 %]
					[% "Yes" | l10n %]
					[% ELSE %]
					[% "No" | l10n %]
					[% END %]
				</td>
				<td>
					[% IF line.is_superadmin == 1 %]
					[% "Yes" | l10n %]
					[% ELSE %]
					[% "No" | l10n %]
					[% END %]
				</td>
				<td>
					<a href="[% base_url %]?rm=edit_mailbox&mailbox_id=[% line.id %]">[% "edit" | l10n %]</a>
				</td>
				<td>
					<a onClick="if(confirm('Do you really want to delete the Account [% line.local_part %]@[% line.domain %]?')) return true; else return false;" href="[% base_url %]?rm=remove_mailbox&mailbox_id=[% line.id %]">[% "del" | l10n %]</a>
				</td>
			</tr>
		[% IF loop.last %]
		</tbody>
		<tfoot>
		</tfoot>
		</table>
		[% END %]
		[% END %]
    </div>
[% INCLUDE includes/footer.tpl %]
