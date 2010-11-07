[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_domain" />
    	<table>
    		<tr>
    			<td colspan="2">
    				<h3>Add a new domain</h3>
    			</td>
    		</tr>
    		<tr>
				<td>Domain:</td>
				<td><input type="text" name="domain" /></td>
			</tr>
			<tr>
				<td>Create Domainadmin:</td>
				<td><input type="checkbox" name="create_domainadmin" checked /></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input class="button" type="submit" name="submit" value="Add Domain" />
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
