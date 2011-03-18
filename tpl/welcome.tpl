[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="main_menu">
    	<table>
    		[% IF is_superadmin %]
	    	<tr>
	    		<td nowrap><a target="_top" href="[% base_url %]?rm=domains">[% "Domains" | l10n %]</a></td>
	    		<td>[% "List and edit your Domains" | l10n %]</td>
	    	</tr>
	    	[% END %]
	    	<tr>
	    		<td nowrap><a target="_top" href="[% base_url %]?rm=domain_aliases">[% "Domain Aliases" | l10n %]</a></td>
	    		<td>[% "Manage your Domain Aliases" | l10n %]</td>
	    	</tr>
	    	<tr>
	    		<td nowrap><a target="_top" href="[% base_url %]?rm=aliases">[% "Aliases" | l10n %]</a></td>
	    		<td>[% "Manage your Email Aliases" | l10n %]</td>
	    	</tr>
	    	<tr>
	    		<td nowrap><a target="_top" href="[% base_url %]?rm=mailboxes">[% "Mailboxes" | l10n %]</a></td>
	    		<td>[% "Manage your Mailboxes" | l10n %]</td>
	    	</tr>
	    	[% IF is_superadmin %]
	    	<tr>
	    		<td nowrap><a[% IF current == 'broadcast' %] class="current"[% END %] href="[% base_url %]?rm=broadcast">[% "Send Broadcast" | l10n %]</a></td>
	    		<td>[% "Send a broadcast message to all users" | l10n %]</td>
	    	</tr>
	    	<tr>
				<td nowrap><a[% IF current == 'vacation' %] class="current"[% END %] href="[% base_url %]?rm=vac_bl">[% "Vacation Blacklist" | l10n %]</a></td>
				<td>[% "Show the Vacation Blacklist" | l10n %]</td>
			</tr>
	    	<tr>
				<td nowrap><a[% IF current == 'vac_repl' %] class="current"[% END %] href="[% base_url %]?rm=vac_repl">[% "Vacation Replies" | l10n %]</a></td>
				<td>[% "Show any Vacation Notifications sent" | l10n %]</td>
			</tr>
	    	<tr>
				<td nowrap><a[% IF current == 'awl' %] class="current"[% END %] href="[% base_url %]?rm=awl">[% "Auto-Whitelist" | l10n %]</a></td>
				<td>[% "Show the Auto-Whitelist" | l10n %]</td>
			</tr>
	    	<tr>
				<td nowrap><a[% IF current == 'notify' %] class="current"[% END %] href="[% base_url %]?rm=notify">[% "RFC-Notify" | l10n %]</a></td>
				<td>[% "Show the list of RFC Notifications sent" | l10n %]</td>
			</tr>
	    	<tr>
				<td nowrap><a[% IF current == 'log' %] class="current"[% END %] href="[% base_url %]?rm=log">[% "View Log" | l10n %]</a></td>
	    		<td>[% "View the transaction log" | l10n %]</td>
	    	</tr>
	    	[% END %]
	    	<tr>
	    		<td nowrap><a target="_top" href="[% base_url %]?rm=logout&authen_logout=1">[% "Logout" | l10n %]</a></td>
	    		<td>[% "Quit your session" | l10n %]</td>
	    	</tr>
    	</table>
    	</div>
    </div>
[% INCLUDE footer.tpl %]
