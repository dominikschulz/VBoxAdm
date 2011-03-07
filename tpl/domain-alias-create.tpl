[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_domain_alias" />
    	<table>
    		<tr>
    			<td colspan="2">
    				<h3>[% "Add a new domain alias" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Alias-Domain:" | l10n %]</td>
				<td><input class="flat" type="text" name="domain_alias" size="20" /></td>
			</tr>
			<tr>
				<td>[% "Target:" | l10n %]</td>
				<td>
					[% FOREACH line IN domains %]
						[% IF loop.first %]
						<select name="domain">
						[% END %]
							<option value="[% line.id %]">[% line.name %]</option>
						[% IF loop.last %]
						</select>
						[% END %]
					[% END %]
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<button class="button" type="submit" name="submit">
					<img src="[% media_prefix %]/icons/fffsilk/add.png" border="0" />
					[% "Add Domain Alias" | l10n %]
					</button>
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
