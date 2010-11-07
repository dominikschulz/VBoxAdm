[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN domains %]
		[% IF loop.first %]
		<table>
			<thead>
			<tr>
				<th>Domain</th>
				<th>Aliases</th>
				<th>Mailboxes</th>
				<th>Alias-Domains</th>
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
					[% line.num_aliases %]
				</td>
				<td>
					[% line.num_mailboxes %]
				</td>
				<td>
					[% line.num_domainaliases %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_domain&domain_id=[% line.id %]&is_active=0">Yes</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_domain&domain_id=[% line.id %]&is_active=1">No</a>
					[% END %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_domain&domain_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remove_domain&domain_id=[% line.id %]">del</a>
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
		<a href="vboxadm.pl?rm=create_domain">Add Domain</a>
    </div>
[% INCLUDE footer.tpl %]
