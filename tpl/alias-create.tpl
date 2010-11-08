[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_alias" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>Add a new domain alias</h3>
    			</td>
    		</tr>
    		<tr>
				<td>Username:</td>
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
				<td>Target:</td>
				<td>
					<input class="flat" type="text" name="goto" size="20" />
				</td>
				<td></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input class="button" type="submit" name="submit" value="Add Alias" />
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
