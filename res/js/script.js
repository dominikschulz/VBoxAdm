/* Author: Dominik Schulz
 *
 */
// setup datatables
$(document).ready(function() {
	oTable = $('.datatable').dataTable({
		"bJQueryUI": true,
		"bStateSave": true,
		"sPaginationType": "full_numbers",
		"iDisplayLength": 25,
	});
} );
// setup popup window
// http://www.sohtanaka.com/web-design/inline-modal-window-w-css-and-jquery/#blog
// When you click on a link with class of poplight and the href starts with a # 
$('a.modallight[href*=#]').click(function() {
  var popID = $(this).attr('rel'); // Get Popup Name
  var popURL = $(this).attr('href'); // Get Popup href to define size
  // Pull Query & Variables from href URL
  var query = popURL.split('?');
  var dim = query[1].split('&');
  var popWidth = dim[0].split('=')[1]; // Gets the first query string value
  // Fade in the Popup and add close button
  $('#' + popID).fadeIn().css({ 'width': Number( popWidth ) }).prepend('<a href="#" class="close"><img src="/images/knob/knob_cancel.png" class="btn_close" title="Close Window" alt="Close" /></a>');

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
// setup navigation
(function($){

	//cache nav
	var nav = $("#topNav");

	//add indicators and hovers to submenu parents
	nav.find("li").each(function() {
		if ($(this).find("ul").length > 0) {

			$("<span>").text("^").appendTo($(this).children(":first"));

			//show subnav on hover
			$(this).mouseenter(function() {
				$(this).find("ul").stop(true, true).slideDown();
			});

			//hide submenus on exit
			$(this).mouseleave(function() {
				$(this).find("ul").stop(true, true).slideUp();
			});
		}
	});
})(jQuery);

// setup datepicker
/* http://jqueryui.com/demos/datepicker/#date-formats */
$(function() {
	/* vacation_start datepicker */
	$('#vacation_start').datepicker();
	var date_value = $('#vacation_start').val();
	$('#vacation_start').datepicker( "option", "dateFormat", "dd.mm.yy");
	$('#vacation_start').datepicker( "setDate", date_value);
	
	/* vacation_end datepicker */
	$('#vacation_end').datepicker();
	var date_value = $('#vacation_end').val();
	$('#vacation_end').datepicker( "option", "dateFormat", "dd.mm.yy");
	$('#vacation_end').datepicker( "setDate", date_value);
	
	/* according effect on various pages */
	$('#accordion').accordion();
});
