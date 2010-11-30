[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN admins %]
		[% IF loop.first %]
		<table class="sortable hilight">
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
			<tr>
				<td>
					<a href="vboxadm.pl?rm=edit_mailbox&domain_id=[% line.id %]">[% line.local_part %]@[% line.domain %]</a>
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
					<a href="vboxadm.pl?rm=edit_mailbox&mailbox_id=[% line.id %]">[% "edit" | l10n %]</a>
				</td>
				<td>
					<a onClick="if(confirm('Do you really want to delete the Account [% line.local_part %]@[% line.domain %]?')) return true; else return false;" href="vboxadm.pl?rm=remove_mailbox&mailbox_id=[% line.id %]">[% "del" | l10n %]</a>
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
[% INCLUDE footer.tpl %]
