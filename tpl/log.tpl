[% INCLUDE header.tpl %]
    <div id="main">
	<div id="overview">
		[% "Search:" | l10n %]
		<form name="search" method="GET" action="vboxadm.pl">
		<input type="hidden" name="rm" value="log" />
		<input type="textbox" name="search" size="10" value="[% search %]" />
		</form>
	</div>
		[% FOREACH line IN log %]
		[% IF loop.first %]
		<table class="hilight">
			<thead>
			<tr>
				<th>[% "Date" | l10n %]</th>
				<th>[% "Message" | l10n %]</th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					[% line.ts %]
				</td>
				<td>
					[% line.msg | highlight(search) %]
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
