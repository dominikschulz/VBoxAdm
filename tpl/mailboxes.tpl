[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN mailboxes %]
		[% IF loop.first %]
		<table>
			<thead>
			<tr>
				<th>Mailbox</th>
				<th>Active</th>
				<th>Max. Msgsize</th>
				<th>Vacation</th>
				<th>Quota</th>
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
					[% line.max_msg_size %]
				</td>
				<td>
					[% line.is_on_vacation %]
				</td>
				<td>
					[% line.quota %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_alias&domain_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remote_alias&domain_id=[% line.id %]">del</a>
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
