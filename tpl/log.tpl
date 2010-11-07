[% INCLUDE header.tpl %]
    <div id="main">
		[% FOREACH line IN log %]
		[% IF loop.first %]
		<table>
			<thead>
			<tr>
				<th>Date</th>
				<th>Message</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.ts %]
				</td>
				<td>
					[% line.msg %]
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
