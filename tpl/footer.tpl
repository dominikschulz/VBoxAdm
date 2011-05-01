    <footer>
	<a href="http://www.vboxadm.net/?version=[% version %]" target="_blank">VBoxAdm [% version %]</a>
	&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	[% IF username %]
	[% "Logged in as [_1]" | l10n(username) %]
	[% ELSE %]
	[% "Not logged in" | l10n %]
	[% END %]
	&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="http://www.vboxadm.net/?versioncheck=[% version %]">[% "Check for updates" | l10n %]</a>
	&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="http://[% system_domain %]/">[% "Return to [_1]" | l10n(system_domain) %]</a>
    </footer>
    [% IF debug_msg %]
    <div id="debug">
    	[% debug_msg %]
    </div>
    [% END %]
  </div> <!--! end of #container -->

  <!-- Javascript at the bottom for fast page loading -->
  <script type="text/javascript" language="javascript" src="[% media_prefix %]/js/libs/jquery-1.5.1.js?v=@VERSION@"></script>
  <script type="text/javascript" language="javascript" src="[% media_prefix %]/js/libs/jquery.dataTables.js?v=@VERSION@"></script>
  
  <!-- scripts concatenated and minified via ant build script-->
  <!-- <script src="[% media_prefix %]/js/plugins.js"></script> -->
  <script type="text/javascript" language="javascript" src="[% media_prefix %]/js/script.min.js?v=@VERSION@"></script>
  <!-- end concatenated and minified scripts-->
  
  <!--[if lt IE 7 ]>
    <script src="[% media_prefix %]/js/libs/dd_belatedpng.js"></script>
    <script> DD_belatedPNG.fix('img, .png_bg'); //fix any <img> or .png_bg background-images </script>
  <![endif]-->
  
</body>
</html>
