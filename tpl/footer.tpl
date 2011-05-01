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
  <script type="text/javascript" language="javascript" src="[% media_prefix %]/js/libs/jquery-1.5.1.js"></script>
  <script type="text/javascript" language="javascript" src="[% media_prefix %]/js/libs/jquery.dataTables.js"></script>
  <script type="text/javascript" language="javascript">
  // setup datatables
	$(document).ready(function() {
		oTable = $('.datatable').dataTable({
			"bJQueryUI": true,
			"sPaginationType": "full_numbers",
		});
	} );
  // setup popup window
  // http://www.sohtanaka.com/web-design/inline-modal-window-w-css-and-jquery/#blog
  // When you click on a link with class of poplight and the href starts with a # 
  $('a.modallight[href^=#]').click(function() {
    var popID = $(this).attr('rel'); // Get Popup Name
    var popURL = $(this).attr('href'); // Get Popup href to define size

    // Pull Query & Variables from href URL
    var query= popURL.split('?');
    var dim= query[1].split('&');
    var popWidth = dim[0].split('=')[1]; // Gets the first query string value

    // Fade in the Popup and add close button
    $('#' + popID).fadeIn().css({ 'width': Number( popWidth ) }).prepend('<a href="#" class="close"><img src="close_pop.png" class="btn_close" title="Close Window" alt="Close" /></a>');

    // Define margin for center alignment (vertical   horizontal) - we add 80px to the height/width to accomodate for the padding  and border width defined in the css
    var popMargTop = ($('#' + popID).height() + 80) / 2;
    var popMargLeft = ($('#' + popID).width() + 80) / 2;

    // Apply Margin to Popup
    $('#' + popID).css({
        'margin-top' : -popMargTop,
        'margin-left' : -popMargLeft
    });

    // Fade in Background
    $('body').append('<div id="fade"></div>'); // Add the fade layer to bottom of the body tag.
    $('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(); // Fade in the fade layer - .css({'filter' : 'alpha(opacity=80)'}) is used to fix the IE Bug on fading transparencies 

    return false;
  });

  // Close Popups and Fade Layer
  $('a.close, #fade').live('click', function() { //When clicking on the close or fade layer...
    $('#fade , .modal_block').fadeOut(function() {
        $('#fade, a.close').remove();  //fade them both out
    });
    return false;
  });
  </script>
  
  <!-- scripts concatenated and minified via ant build script-->
  <!-- <script src="[% media_prefix %]/js/plugins.js"></script> -->
  <!-- <script src="[% media_prefix %]/js/script.js"></script> -->
  <!-- <script src="[% media_prefix %]/js/sorttable.js"></script> -->
  <!-- end concatenated and minified scripts-->
  
  <!--[if lt IE 7 ]>
    <script src="[% media_prefix %]/js/libs/dd_belatedpng.js"></script>
    <script> DD_belatedPNG.fix('img, .png_bg'); //fix any <img> or .png_bg background-images </script>
  <![endif]-->
  
</body>
</html>
