[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_alias" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>[% "Add a new alias" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Username:" | l10n %]</td>
				<td><input class="flat" type="text" name="local_part" /></td>
				<td>@
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
				<td>[% "Target:" | l10n %]</td>
				<td colspan="2">
					<input class="flat" type="text" name="goto" size="50" />
				</td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<button class="button" type="submit" name="submit">
					<img src="/icons/fffsilk/add.png" border="0" />
					[% "Add Alias" | l10n %]
					</button>
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
