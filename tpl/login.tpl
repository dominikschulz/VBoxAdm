[% INCLUDE header.tpl %]

<h2>Please login</h2>
<form action="vboxadm.pl" method="POST">
<input type="hidden" name="rm" value="login" />
User: <input type="text" name="user" /><br />
Password: <input type="password" name="pw" /><br />
<input type="submit" name="Login" /><br />
<img src="vboxadm.pl?rm=create_captcha" /><br />
<input type="text" name="captcha" />
</form>

[% INCLUDE footer.tpl %]
