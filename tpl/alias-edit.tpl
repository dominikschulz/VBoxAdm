[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="update_alias" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>Modify an alias</h3>
    			</td>
    		</tr>
    		<tr>
				<td>Alias:</td>
				<td>
					[% local_part %]@[% domain %]
					<input type="hidden" name="alias_id" value="[% alias_id %]" />
				</td>
				<td></td>
			</tr>
			<tr>
				<td>Target:</td>
				<td>
					<input class="flat" type="text" name="goto" size="80" value="[% goto %]" />
				</td>
				<td></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input class="button" type="submit" name="submit" value="Modify Alias" />
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
