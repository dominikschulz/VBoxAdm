[% INCLUDE includes/header.tpl %]
    <div id="main" class="datatable_container">
		[% FOREACH line IN awl %]
		[% IF loop.first %]
		<table id="datatable">
			<thead>
			<tr>
				<th>[% "Email" | l10n %]</th>
				<th>[% "Last Seen" | l10n %]</th>
				<th>[% "Disabled" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.email | highlight(search) %]
				</td>
				<td>
					[% line.last_seen %]
				</td>
				<td>
					[% IF line.disabled %]
					Yes. <a onClick="if(confirm('[% "Do you really want to enable the Entry [_1]?" | l10n(line.email) %]')) return true; else return false;" href="[% base_url %]?rm=update_awl&entry_id=[% line.id %]&disabled=0">[% "enable" | l10n %]</a>
					[% ELSE %]
					No. <a onClick="if(confirm('[% "Do you really want to disable the Entry [_1]?" | l10n(line.email) %]')) return true; else return false;" href="[% base_url %]?rm=update_awl&entry_id=[% line.id %]&disabled=1">[% "disable" | l10n %]</a>
					[% END %]
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
[% INCLUDE includes/footer.tpl %]
