[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN admins %]
		[% IF loop.first %]
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>User</th>
				<th>Active</th>
				<th>Domainadmin</th>
				<th>Superadmin</th>
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
					Yes
					[% ELSE %]
					No
					[% END %]
				</td>
				<td>
					[% IF line.is_domainadmin == 1 %]
					Yes
					[% ELSE %]
					No
					[% END %]
				</td>
				<td>
					[% IF line.is_superadmin == 1 %]
					Yes
					[% ELSE %]
					No
					[% END %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_mailbox&mailbox_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remove_mailbox&mailbox_id=[% line.id %]">del</a>
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
