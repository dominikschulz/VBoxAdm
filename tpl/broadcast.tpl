[% INCLUDE header.tpl %]
    <div id="main">
    <div id="edit_form">
    	<form action="vboxadm.pl" method="POST">
    	<input type="hidden" name="rm" value="send_broadcast" />
	    	<table>
		    	<thead>
			    	<tr>
			    		<td colspan="2"><h3>[% "Send a Broadcast Message to all users" | l10n %]</h3></td>
			    	</tr>
		    	</thead>
		    	<tbody>
		    		<tr>
		    			<td><label for="subject">[% "Subject" | l10n %]:</label></td>
		    			<td><input type="text" name="subject" size="60" /></td>
		    		</tr>
		    		<tr>
			    		<td>
			    		<label for="message">[% "Message" | l10n %]:</label>
			    		</td><td>&nbsp;</td>
		    		</tr>
		    		<tr>
			    		<td colspan="2">
			    		<textarea name="message" rows="20" cols="80"></textarea>
			    		</td>
		    		</tr>
		    		<tr>
			    		<td colspan="2" align="center">
				    		<button class="button" type="submit" name="submit" onClick="if(confirm('[% "Do you really want to send a Broadcast Message to [_1] Users?" | l10n(count) %]')) return true; else return false;">
				    			<img src="/icons/fffsilk/accept.png" border="0" />
								[% "Send Broadcast Message to [_1] Users" | l10n(count) %]
							</button>
						</td>
					</tr>
		    	</tbody>
		    	<tfoot>
		    	</tfoot>
	    	</table>
    	</form>
    </div>
    </div>
[% INCLUDE footer.tpl %]
