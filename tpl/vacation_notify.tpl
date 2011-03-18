[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			[% "Search:" | l10n %]
			<form name="search" method="GET" action="[% base_url %]">
			<input type="hidden" name="rm" value="vac_notify" />
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
				<th>[% "Sender" | l10n %]</th>
				<th>[% "Sent at" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.on_vacation | highlight(search) %]
				</td>
				<td>
					[% line.notified | highlight(search) %]
				</td>
				<td>
					[% line.notified_at %]
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
