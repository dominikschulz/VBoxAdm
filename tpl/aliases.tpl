[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			Search:
			<form name="search" method="GET" action="vboxadm.pl">
			<input type="hidden" name="rm" value="aliases" />
			<input type="textbox" name="search" size="10" value="[% search %]" />
			</form>
		</div>
		[% FOREACH line IN aliases %]
		[% IF loop.first %]
		<table class="sortable hilight">
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
					[% line.local_part | highlight(search) %]@[% line.domain | highlight(search) %]
				</td>
				<td>
					[% line.target.substr(0,60) | highlight(search) %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_alias&alias_id=[% line.id %]&is_active=0">Yes</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_alias&alias_id=[% line.id %]&is_active=1">No</a>
					[% END %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_alias&alias_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remove_alias&alias_id=[% line.id %]">del</a>
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
