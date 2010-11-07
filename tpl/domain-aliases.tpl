[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN domains %]
		[% IF loop.first %]
		<table>
			<thead>
			<tr>
				<th>Domain</th>
				<th>Target</th>
				<th>Active</th>
				<th></th>
				<th></th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.name %]
				</td>
				<td>
					[% line.target %]
				</td>
				<td>
					[% line.is_active %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_domain&domain_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remote_domain&domain_id=[% line.id %]">del</a>
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
		<a href="vboxadm.pl?rm=create_domain_alias">Add Domain Alias</a>
    </div>
[% INCLUDE footer.tpl %]
