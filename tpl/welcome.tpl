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
	    		<td nowrap><a target="_top" href="[% base_url %]?rm=log">[% "Log" | l10n %]</a></td>
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
