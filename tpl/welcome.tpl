[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="main_menu">
    	<table>
    		[% IF is_superadmin %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=domains">[% "Domains" | l10n %]</a></td>
	    		<td>[% "List and edit your Domains" | l10n %]</td>
	    	</tr>
	    	[% END %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=domain_aliases">[% "Domain Aliases" | l10n %]</a></td>
	    		<td></td>
	    	</tr>
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=aliases">[% "Aliases" | l10n %]</a></td>
	    		<td></td>
	    	</tr>
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=mailboxes">[% "Mailboxes" | l10n %]</a></td>
	    		<td></td>
	    	</tr>
	    	[% IF is_superadmin %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=log">[% "Log" | l10n %]</a></td>
	    		<td></td>
	    	</tr>
	    	[% END %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=logout&authen_logout=1">[% "Logout" | l10n %]</a></td>
	    		<td></td>
	    	</tr>
    	</table>
    	</div>
    </div>
[% INCLUDE footer.tpl %]
