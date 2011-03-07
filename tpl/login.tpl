[% INCLUDE header.tpl %]
    <div id="main">
		<form name="loginform" action="[% base_url %]" method="POST">
			<div class="login">
				<div class="login_header">
					[% "Sign In" | l10n %]
				</div>
				<div class="login_content">
					<ul class="message">
						<li>[% "Please enter your username and password in the fields below." | l10n %]</li>
					</ul>
					<fieldset>
						<label for="authen_username">[% "User Name" | l10n %]</label>
						<input id="authen_loginfield" tabindex="1" type="text" name="authen_username" size="30" value="" /><br />
						
						<label for="authen_password">[% "Password" | l10n %]</label>
						<input id="authen_passwordfield" tabindex="2" type="password" name="authen_password" size="30" /><br />
						
						<input id="authen_rememberuserfield" tabindex="3" type="checkbox" name="authen_rememberuser" value="1" />[% "Remember User Name" | l10n %]<br />
      				</fieldset>
    			</div>
    			<div class="login_footer">
      				<div class="buttons">
        				<input id="authen_loginbutton" tabindex="4" type="submit" name="authen_loginbutton" value="[% "Sign In" | l10n %]" class="button" />
      				</div>
    			</div>
    		</div>
			<input type="hidden" name="rm" value="authen_login" />
			<input type="hidden" name="destination" value="[% base_url %]?rm=welcome" />
		</form>
    </div>
[% INCLUDE footer.tpl %]
