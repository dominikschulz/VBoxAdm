[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="update_mailbox" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>Modify a mailbox</h3>
    			</td>
    		</tr>
    		<tr>
				<td>Username:</td>
				<td>
					[% local_part %]@[% domain %]
					<input type="hidden" name="mailbox_id" value="[% mailbox_id %]" />
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<td>Password:</td>
				<td><input class="flat" type="password" name="password" autocomplete="off" /></td>
				<td></td>
			</tr>
			<tr>
				<td>Password (again):</td>
				<td><input class="flat" type="password" name="password_2" autocomplete="off" /></td>
				<td></td>
			</tr>
			<tr>
				<td>Name:</td>
				<td><input class="flat" type="text" name="name" value="[% name %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td>Active:</td>
				<td><input class="flat" type="checkbox" name="is_active"[% IF is_active %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>Max. Message Size:</td>
				<td><input class="flat" type="text" name="max_msg_size_mb" value="[% max_msg_size_mb %]" /> MB</td>
				<td></td>
			</tr>
			<tr>
				<td>On Vacation:</td>
				<td><input class="flat" type="checkbox" name="is_on_vacation"[% IF is_on_vacation %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>Vacation Message:</td>
				<td><textarea name="vacation_msg">[% vacation_msg %]</textarea></td>
				<td></td>
			</tr>
			<tr>
				<td>CC:</td>
				<td><a href="vboxadm.pl?rm=edit_alias&alias_id=[% cc_id %]">[% cc_goto %]</a></td>
				<td></td>
			</tr>
			[% IF user_is_superadmin %]
			<tr>
				<td>Domainadmin:</td>
				<td><input class="flat" type="checkbox" name="is_domainadmin"[% IF mb_is_domainadmin %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>Superadmin:</td>
				<td><input class="flat" type="checkbox" name="is_superadmin"[% IF mb_is_superadmin %] checked[% END %] /></td>
				<td></td>
			</tr>
			[% END %]
			<tr>
				<td>SpamAssassin:</td>
				<td><input class="flat" type="checkbox" name="sa_active"[% IF sa_active %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>SpamAssassin block score:</td>
				<td><input class="flat" type="text" name="sa_kill_score" value="[% sa_kill_score %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<input class="button" type="submit" name="submit" value="Modify Mailbox" />
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
