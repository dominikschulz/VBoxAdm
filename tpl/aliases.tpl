[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN aliases %]
		[% IF loop.first %]
		<table class="sortable">
			<thead>
			<tr>
				<th>Alias</th>
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
					[% line.local_part %]@[% line.domain %]
				</td>
				<td>
					[% line.target %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					Yes
					[% ELSE %]
					No
					[% END %]
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
		<br />
		<a href="vboxadm.pl?rm=create_alias">Add Alias</a>
    </div>
[% INCLUDE footer.tpl %]
