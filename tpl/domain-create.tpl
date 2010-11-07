[% INCLUDE header.tpl %]
    <div id="main">
		<form name="create_domain" method="POST">
		<input type="hidden" name="rm" value="add_domain" />
		Domain: <input type="text" name="domain" /><br />
		Create Domainadmin: <input type="checkbox" name="create_domainadmin" checked /><br />
		<input type="submit" value="Add Domain" />
		</form>
    </div>
[% INCLUDE footer.tpl %]
