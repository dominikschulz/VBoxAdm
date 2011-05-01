[% INCLUDE includes/header.tpl %]
    <div id="main" class="datatable_container">
		[% FOREACH line IN blacklist %]
		[% IF loop.first %]
		<table id="datatable">
			<thead>
			<tr>
				<th>[% "Recipient" | l10n %]</th>
				<th>[% "Sent at" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.email | highlight(search) %]
				</td>
				<td>
				</td>
				<td>
					[% line.ts %]
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
    </div>
[% INCLUDE includes/footer.tpl %]
