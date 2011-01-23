[% INCLUDE header.tpl %]
    <div id="main">
    	<!-- TODO form with subject and body field. on submit send message to all enlisted users of the system. -->
    	<form action="vboxadm.pl" method="POST">
    		<input type="hidden" name="rm" value="send_broadcast" />
    		<label for="subject">[% "Subject" | l10n %]:</label><input type="text" name="subject" size="20" /><br />
    		<label for="message">[% "Message" | l10n %]:</label><br />
    		<textarea name="message" rows="20" cols="80"></textarea><br />
    		<button class="button" type="submit" name="submit">
					<img src="/icons/fffsilk/accept.png" border="0" />
					[% "Submit" | l10n %]
					</button>
    	</form>
    </div>
[% INCLUDE footer.tpl %]
