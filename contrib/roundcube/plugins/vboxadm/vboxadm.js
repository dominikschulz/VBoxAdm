/* VBoxAdm interface (tab) */

if (window.rcmail) {
	rcmail
	.addEventListener('init', function(evt) {
		// <span id="settingstabdefault"
		// class="tablink"><roundcube:button command="preferences"
		// type="link" label="preferences" title="editpreferences"
		// /></span>
			var tab = $('<span>')
					.attr('id', 'settingstabpluginvboxadm').addClass(
							'tablink tablinkvboxadm');
			var button = $('<a>').attr('href',
					rcmail.env.comm_path + '&_action=plugin.vboxadm')
					.attr('style', 'padding-left:5px;').html(
							rcmail.gettext('accountadmin', 'vboxadm'))
					.appendTo(tab);
			button.bind('click', function(e) {
				return rcmail.command('plugin.vboxadm', this)
			});
			// add button and register commands
			rcmail.add_element(tab, 'tabs');
			rcmail.register_command('plugin.vboxadm', function() {
				rcmail.goto_url('plugin.vboxadm')
			}, true);
			rcmail
				.register_command(
					'plugin.vboxadm-save',
					function() {
						var input_curpasswd = rcube_find_object('_curpasswd');
						var input_newpasswd = rcube_find_object('_newpasswd');
						var input_confpasswd = rcube_find_object('_confpasswd');
						var input_vacation = rcube_find_object('vacation_subj');
						
						if (!input_curpasswd || input_curpasswd == '') {
							alert(rcmail.gettext(
								'entercurpass',
								'vboxadm'
							));
							input_curpasswd.focus();
						}
						else if (
								input_newpasswd.value != input_confpasswd.value
								&&
								(input_newpasswd.value == ''
								||
								input_confpasswd.value == '')
							) {
								alert(rcmail.gettext(
									'enterallpassfields',
									'vboxadm'));
								input_newpasswd.focus();
						} else if (
								input_newpasswd.value != input_confpasswd.value
								&&
								input_newpasswd.value != ''
								&&
								input_confpasswd.value != ''
							) {
								alert(rcmail.gettext(
									'passwordinconsistency',
									'vboxadm'));
								input_newpasswd.focus();
						} else if (input_vacation.value.length > rcmail.env.vacation_maxlength) {
							alert(rcmail.gettext(
								'autoresponderlong',
								'vboxadm')
								+ '\n\n'
								+ rcmail
										.gettext(
												'autoresponderlongnum',
												'vboxadm')
								+ input_vacation.value.length
								+ '\n'
								+ rcmail
										.gettext(
												'autoresponderlongmax',
												'vboxadm')
								+ rcmail.env.vacation_maxlength);
							input_vacation.focus();
						} else {
							rcmail.gui_objects.vboxadmform
									.submit();
						}
					}, true);
		})
}
