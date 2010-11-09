[% INCLUDE header.tpl %]
    <div id="main">
	    <div id="overview">
			Search:
			<form name="search" method="GET" action="vboxadm.pl">
			<input type="hidden" name="rm" value="mailboxes" />
			<input type="textbox" name="search" size="10" value="[% search %]" />
			</form>
		</div>
		[% FOREACH line IN mailboxes %]
		[% IF loop.first %]
		<table class="sortable hilight">
			<thead>
			<tr>
				<th>Mailbox</th>
				<th>User</th>
				<th>Active</th>
				<th>Max. Msgsize</th>
				<th>Vacation</th>
				<th>Quota</th>
				<th></th>
				<th></th>
			</tr>
			</thead>
			<tbody>
		[% END %]
			<tr>
				<td>
					<a href="vboxadm.pl?rm=edit_mailbox&mailbox_id=[% line.id %]">[% line.local_part | highlight(search) %]@[% line.domain | highlight(search) %]</a>
				</td>
				<td>
					[% line.name | highlight(search) %]
				</td>
				<td>
					[% IF line.is_active == 1 %]
					<a href="vboxadm.pl?rm=update_mailbox&mailbox_id=[% line.id %]&is_active=0">Yes</a>
					[% ELSE %]
					<a href="vboxadm.pl?rm=update_mailbox&mailbox_id=[% line.id %]&is_active=1">No</a>
					[% END %]
				</td>
				<td>
					[% FILTER currency %][% line.max_msg_size_mb %][% END %] MB
				</td>
				<td>
					[% IF line.is_on_vacation == 1 %]
					Yes
					[% ELSE %]
					No
					[% END %]
				</td>
				<td>
					[% line.quota %]
				</td>
				<td>
					<a href="vboxadm.pl?rm=edit_mailbox&mailbox_id=[% line.id %]">edit</a>
				</td>
				<td>
					<a href="vboxadm.pl?rm=remove_mailbox&mailbox_id=[% line.id %]">del</a>
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
		<a href="vboxadm.pl?rm=create_mailbox">Add Mailbox</a>
    </div>
[% INCLUDE footer.tpl %]
