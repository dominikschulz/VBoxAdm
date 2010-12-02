[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="update_alias" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>[% "Modify an alias" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Alias:" | l10n %]</td>
				<td>
					[% local_part %]@[% domain %]
					<input type="hidden" name="alias_id" value="[% alias_id %]" />
				</td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Target:" | l10n %]</td>
				<td>
					[% IF goto.length > 80 %]
					<textarea class="flat" name="goto" cols="80" rows="20">[% goto %]</textarea>
					[% ELSE %]
					<input class="flat" type="text" name="goto" size="80" value="[% goto %]" />
					[% END %]
				</td>
				<td></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input class="button" type="submit" name="submit" value="[% "Modify Alias" | l10n %]" />
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
