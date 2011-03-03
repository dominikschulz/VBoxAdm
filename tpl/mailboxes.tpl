[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			[% "Search:" | l10n %]
			<form name="search" method="GET" action="[% base_url %]">
			<input type="hidden" name="rm" value="mailboxes" />
			<input type="textbox" name="search" size="20" value="[% search %]" />
			</form>
		</div>
		[% FOREACH line IN mailboxes %]
		[% IF loop.first %]
		[% INCLUDE "page-navigation.tpl" %]
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>[% "Mailbox" | l10n %]</th>
				<th>[% "User" | l10n %]</th>
				<th>[% "Active" | l10n %]</th>
				<th>[% "Max. Msgsize" | l10n %]</th>
				<th>[% "Vacation" | l10n %]</th>
				<th>[% "Quota" | l10n %]</th>
				<th></th>
				<th></th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					<a href="[% base_url %]?rm=edit_mailbox&mailbox_id=[% line.id %]">[% line.local_part | highlight(search) %]@[% line.domain | highlight(search) %]</a>
				</td>
				<td>
					[% line.name | highlight(search) %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="[% base_url %]?rm=update_mailbox&mailbox_id=[% line.id %]&is_active=0">[% "Yes" | l10n %]</a>
					[% ELSE %]
					<a href="[% base_url %]?rm=update_mailbox&mailbox_id=[% line.id %]&is_active=1">[% "No" | l10n %]</a>
					[% END %]
				</td>
				<td>
					[% FILTER currency %][% line.max_msg_size_mb %][% END %] MB
				</td>
				<td>
					[% IF line.is_on_vacation == 1 %]
					[% "Yes" | l10n %]
					[% ELSE %]
					[% "No" | l10n %]
					[% END %]
				</td>
				<td>
					[% line.quota %]
				</td>
				<td>
					<a href="[% base_url %]?rm=edit_mailbox&mailbox_id=[% line.id %]">[% "edit" | l10n %]</a>
				</td>
				<td>
					<a onClick="if(confirm('[% "Do you really want to delete the Account [_1]@[_2]?" | l10n(line.local_part,line.domain) %]')) return true; else return false;" href="[% base_url %]?rm=remove_mailbox&mailbox_id=[% line.id %]">[% "del" | l10n %]</a>
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
		<a href="[% base_url %]?rm=create_mailbox"><img src="/icons/fffsilk/add.png" border="0" /> [% "Add Mailbox" | l10n %]</a>
    </div>
[% INCLUDE footer.tpl %]
