/* Vacation Javascript */

if (window.rcmail) {

	// Updates aliases 
  	rcmail.addEventListener('plugin.alias_callback',function(evt) {
		$('#vacation_aliases').val(evt.aliases);
		
	} );

    rcmail.addEventListener('init', function(evt) {
	    rcmail.register_command('plugin.vacation-save', function() { 
		    document.forms.vacationform.submit();
	
	    }, true);
    
	    // Invoke vacationdriver.class.php's methods
	    rcmail.register_command('get_vacation_aliases', function() { 
	    	rcmail.http_post('plugin.vacation_aliases','a=1');
	    }, true);
  
     var tab = $('<span>').attr('id', 'settingstabpluginvacation').addClass('tablink');
    rcmail.add_element(tab, 'tabs');

    var button = $('<a>').attr('href', rcmail.env.comm_path+'&_action=plugin.vacation').html(rcmail.gettext('vacation.vacation')).appendTo(tab);
    button.bind('click', function(e){ return rcmail.command('plugin.vacation', this); });
    
    // Only enable the button if the element exists
    if ($("#aliaslink").length) {
	    rcmail.register_button('get_vacation_aliases','aliaslink','input');
	    $("#aliaslink").bind('click', function(e){
	    	return rcmail.command('get_vacation_aliases', this); });
    }


    // add button and register command
    rcmail.register_command('plugin.vacation', function(){ rcmail.goto_url('plugin.vacation') }, true);
   
});
}