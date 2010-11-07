[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN admins %]
		[% IF loop.first %]
		<table>
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
					[% line.local_part %]@[% line.domain %]
				</td>
				<td>
					[% line.is_active %]
				</td>
				<td>
					[% line.is_domainadmin %]
				</td>
				<td>
					[% line.is_superadmin %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_mailbox&domain_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remove_mailbox&domain_id=[% line.id %]">del</a>
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
