[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="add_mailbox" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>[% "Create a new Mailbox" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Username:" | l10n %]</td>
				<td><input class="flat" type="text" name="username" /></td>
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
				<td>[% "Password:" | l10n %]</td>
				<td><input class="flat" type="password" name="password" /></td>
				<td>[% "Leave both password fields empty to autogenerate a password." | l10n %]</td>
			</tr>
			<tr>
				<td>[% "Password (again):" | l10n %]</td>
				<td><input class="flat" type="password" name="password_2" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Name:" | l10n %]</td>
				<td><input class="flat" type="text" name="name" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Active:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="is_active" checked /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Send Welcome Mail:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="send_welcome_mail" checked /></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<button class="button" type="submit" name="submit">
					<img src="/icons/fffsilk/add.png" border="0" />
					[% "Add Mailbox" | l10n %]
					</button>
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
