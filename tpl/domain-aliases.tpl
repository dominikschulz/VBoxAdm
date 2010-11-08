[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN domains %]
		[% IF loop.first %]
		<table class="sortable hilight">
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
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_domain_alias&domain_alias_id=[% line.id %]&is_active=0">Yes</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_domain_alias&domain_alias_id=[% line.id %]&is_active=1">No</a>
					[% END %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_domain_alias&domain_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remote_domain_alias&domain_id=[% line.id %]">del</a>
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
