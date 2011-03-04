[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_domain" />
    	<table>
    		<tr>
    			<td colspan="2">
    				<h3>[% "Add a new domain" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Domain:" | l10n %]</td>
				<td><input type="text" name="domain" /></td>
			</tr>
			<tr>
				<td>[% "Create Domainadmin:" | l10n %]</td>
				<td><input type="checkbox" name="create_domainadmin" checked /></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<button class="button" type="submit" name="submit">
					<img src="[% media_prefix %]/icons/fffsilk/add.png" border="0" />
					[% "Add Domain" | l10n %]
					</button>
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
