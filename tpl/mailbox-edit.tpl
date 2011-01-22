[% INCLUDE header.tpl %]
    <div id="main">
    	<div id="edit_form">
    	<form name="create_domain" method="POST">
    	<input type="hidden" name="rm" value="update_mailbox" />
    	<table>
    		<tr>
    			<td colspan="3">
    				<h3>[% "Modify a mailbox" | l10n %]</h3>
    			</td>
    		</tr>
    		<tr>
				<td>[% "Username:" | l10n %]</td>
				<td>
					[% local_part %]@[% domain %]
					<input type="hidden" name="mailbox_id" value="[% mailbox_id %]" />
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<td>[% "Password:" | l10n %]</td>
				<td><input class="flat" type="password" name="password" autocomplete="off" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Password (again):" | l10n %]</td>
				<td><input class="flat" type="password" name="password_2" autocomplete="off" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Name:" | l10n %]</td>
				<td><input class="flat" type="text" name="name" value="[% name %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Active:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="is_active"[% IF is_active %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Max. Message Size:" | l10n %]</td>
				<td><input class="flat" type="text" name="max_msg_size_mb" value="[% max_msg_size_mb %]" /> MB</td>
				<td></td>
			</tr>
			<tr>
				<td>[% "On Vacation:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="is_on_vacation"[% IF is_on_vacation %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Begin of Vacation:" | l10n %] (dd.mm.yyyy)</td>
				<td><input class="flat" type="text" name="vacation_start" value="[% vacation_start %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "End of Vacation:" | l10n %] (dd.mm.yyyy)</td>
				<td><input class="flat" type="text" name="vacation_end" value="[% vacation_end %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Vacation Subject:" | l10n %]</td>
				<td><input class="flat" type="text" name="vacation_subj" value="[% vacation_subj %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Vacation Message:" | l10n %]</td>
				<td><textarea name="vacation_msg" rows="10" cols="40">[% vacation_msg %]</textarea></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "CC:" | l10n %]</td>
				<td><a href="vboxadm.pl?rm=edit_alias&alias_id=[% cc_id %]">[% cc_goto %]</a></td>
				<td></td>
			</tr>
			[% IF user_is_superadmin %]
			<tr>
				<td>[% "Domainadmin:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="is_domainadmin"[% IF mb_is_domainadmin %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "Superadmin:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="is_superadmin"[% IF mb_is_superadmin %] checked[% END %] /></td>
				<td></td>
			</tr>
			[% END %]
			<tr>
				<td>[% "SpamAssassin:" | l10n %]</td>
				<td><input class="flat" type="checkbox" name="sa_active"[% IF sa_active %] checked[% END %] /></td>
				<td></td>
			</tr>
			<tr>
				<td>[% "SpamAssassin block score:" | l10n %]</td>
				<td><input class="flat" type="text" name="sa_kill_score" value="[% sa_kill_score %]" /></td>
				<td></td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<button class="button" type="submit" name="submit">
					<img src="/icons/fffsilk/accept.png" border="0" />
					[% "Modify Mailbox" | l10n %]
					</button>
				</td>
			</tr>
		</table>
		</form>
		</div>
    </div>
[% INCLUDE footer.tpl %]
