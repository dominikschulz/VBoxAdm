[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="main_menu">
    	<table>
    		[% IF is_superadmin %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=domains">Domains</a></td>
	    		<td>List and edit your Domains</td>
	    	</tr>
	    	[% END %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=domain_aliases">Domain Aliases</a></td>
	    		<td></td>
	    	</tr>
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=aliases">Aliases</a></td>
	    		<td></td>
	    	</tr>
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=mailboxes">Mailboxes</a></td>
	    		<td></td>
	    	</tr>
	    	[% IF is_superadmin %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=log">Log</a></td>
	    		<td></td>
	    	</tr>
	    	[% END %]
	    	<tr>
	    		<td nowrap><a target="_top" href="vboxadm.pl?rm=logout&authen_logout=1">Logout</a></td>
	    		<td></td>
	    	</tr>
    	</table>
    	</div>
    </div>
[% INCLUDE footer.tpl %]
