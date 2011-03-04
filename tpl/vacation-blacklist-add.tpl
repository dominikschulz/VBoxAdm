[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_vac_bl" />
    	<table>
    		<tr>
    			<td colspan="2">
    				<h3>[% "Create a Vacation Blacklist Entry" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Email:" | l10n %]</td>
				<td><input class="flat" type="text" name="email" /></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<button class="button" type="submit" name="submit">
					<img src="[% media_prefix %]/icons/fffsilk/add.png" border="0" />
					[% "Add Entry" | l10n %]
					</button>
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
