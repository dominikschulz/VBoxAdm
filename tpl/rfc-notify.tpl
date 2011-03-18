[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			[% "Search:" | l10n %]
			<form name="search" method="GET" action="[% base_url %]">
			<input type="hidden" name="rm" value="rfc_notify" />
			<input type="textbox" name="search" size="20" value="[% search %]" />
			</form>
		</div>
		[% FOREACH line IN blacklist %]
		[% IF loop.first %]
		[% INCLUDE "page-navigation.tpl" %]
		<table class="sortable hilight">
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
		[% INCLUDE "page-navigation.tpl" %]
		[% END %]
		[% END %]
		<br />
    </div>
[% INCLUDE footer.tpl %]
