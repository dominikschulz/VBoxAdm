[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			[% "Search:" | l10n %]
			<form name="search" method="GET" action="vboxadm.pl">
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
					<a onClick="if(confirm('[% "Do you really want to delete the Entry [_1]?" | l10n(line.local_part _ '@' _ line.domain) %]')) return true; else return false;" href="vboxadm.pl?rm=remove_vac_bl&entry_id=[% line.id %]">[% "del" | l10n %]</a>
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
		<a href="vboxadm.pl?rm=create_vac_bl"><img src="/icons/fffsilk/add.png" border="0" /> [% "Add Entry" | l10n %]</a>
    </div>
[% INCLUDE footer.tpl %]
