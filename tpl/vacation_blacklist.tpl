[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			[% "Search:" | l10n %]
			<form name="search" method="GET" action="[% base_url %]">
			<input type="hidden" name="rm" value="vac_bl" />
			<input type="textbox" name="search" size="20" value="[% search %]" />
			</form>
		</div>
		[% FOREACH line IN blacklist %]
		[% IF loop.first %]
		[% INCLUDE "page-navigation.tpl" %]
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>[% "Email" | l10n %]</th>
				<th>[% "Remove" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.local_part | highlight(search) %]@[% line.domain | highlight(search) %]
				</td>
				<td>
					<a onClick="if(confirm('[% "Do you really want to delete the Entry [_1]?" | l10n(line.local_part _ '@' _ line.domain) %]')) return true; else return false;" href="[% base_url %]?rm=remove_vac_bl&entry_id=[% line.id %]">[% "del" | l10n %]</a>
				</td>
			</tr>
		[% IF loop.last %]
		</tbody>
		<tfoot>
		</tfoot>
		</table>
		[% INCLUDE "page-navigation.tpl" %]
		[% END %]
		[% END %]
		<br />
		<a href="[% base_url %]?rm=create_vac_bl"><img src="[% media_prefix %]/icons/fffsilk/add.png" border="0" /> [% "Add Entry" | l10n %]</a>
    </div>
[% INCLUDE footer.tpl %]
