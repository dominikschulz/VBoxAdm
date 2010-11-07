[% INCLUDE header.tpl %]
    <div id="main">
		<h2>Please login to VBoxAdm</h2>
		<form action="vboxadm.pl" method="POST">
		<input type="hidden" name="rm" value="login" />
		User: <input type="text" name="user" /><br />
		Password: <input type="password" name="pw" /><br />
		<input type="submit" name="submit" value="Login" /><br />
		Please enter the security code in the box below:<br />
		<img src="vboxadm.pl?rm=create_captcha" /><br />
		Code: <input type="text" name="captcha" />
		</form>
    </div>
[% INCLUDE footer.tpl %]
