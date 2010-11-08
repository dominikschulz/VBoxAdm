[% INCLUDE header.tpl %]
    <div id="main">
		<form name="loginform" action="vboxadm.pl" method="POST">
			<div class="login">
				<div class="login_header">
					Sign In
				</div>
				<div class="login_content">
					<ul class="message">
						<li>Please enter your username and password in the fields below.</li>
					</ul>
					<fieldset>
						<label for="authen_username">User Name</label>
						<input id="authen_loginfield" tabindex="1" type="text" name="authen_username" size="20" value="" /><br />
						
						<label for="authen_password">Password</label>
						<input id="authen_passwordfield" tabindex="2" type="password" name="authen_password" size="20" /><br />
						
						<input id="authen_rememberuserfield" tabindex="3" type="checkbox" name="authen_rememberuser" value="1" />Remember User Name<br />
      				</fieldset>
    			</div>
    			<div class="login_footer">
      				<div class="buttons">
        				<input id="authen_loginbutton" tabindex="4" type="submit" name="authen_loginbutton" value="Sign In" class="button" />
      				</div>
    			</div>
    		</div>
			<input type="hidden" name="rm" value="authen_login" />
			<input type="hidden" name="destination" value="vboxadm.pl?rm=welcome" />
		</form>
    </div>
[% INCLUDE footer.tpl %]
