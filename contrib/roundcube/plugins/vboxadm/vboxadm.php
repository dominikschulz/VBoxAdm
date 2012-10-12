<?php

/**
 * vboxadm
 *
 * Plugin that covers the non-admin part of vboxadm web interface.
 *
 * @date 2012-07-31
 * @author Dominik Schulz
 * @url http://www.vboxadm.net/
 * @licence GNU GPL 2
 */
require_once('vboxapi.php');
 
class vboxadm extends rcube_plugin
{
	public $task = 'settings';
	private $config;
	private $db;
	private $sections = array();
	private $vboxapi;

	function init()
	{
		$rcmail = rcmail::get_instance();
		$this->add_texts('localization/', array('accountadmin'));

		$this->register_action('plugin.vboxadm', array($this, 'vboxadm_init'));
		$this->register_action('plugin.vboxadm-save', array($this, 'vboxadm_save'));

		$this->include_script('vboxadm.js');
		$this->include_stylesheet('vboxadm.css');

		$this->vboxapi   = new VBoxAPI;
	}

	function vboxadm_init()
	{
		$this->add_texts('localization/');
		$this->register_handler('plugin.body', array($this, 'vboxadm_form'));

		$rcmail = rcmail::get_instance();
		$rcmail->output->set_pagetitle($this->gettext('accountadministration'));
		$rcmail->output->send('plugin');
	}


	private function _load_config()
	{

		$fpath_config_dist	= $this->home . '/config.inc.php.dist';
		$fpath_config 		= $this->home . '/config.inc.php';

		if (is_file($fpath_config_dist) and is_readable($fpath_config_dist))
		$found_config_dist = true;
		if (is_file($fpath_config) and is_readable($fpath_config))
		$found_config = true;

		if ($found_config_dist or $found_config) {
			ob_start();

			if ($found_config_dist) {
				include($fpath_config_dist);
				$vboxadm_config_dist = $vboxadm_config;
			}
			if ($found_config) {
				include($fpath_config);
			}

			$config_array = array_merge($vboxadm_config_dist, $vboxadm_config);
			$this->config = $config_array;
			$this->vboxapi->setConfig($this->config);
			//$this->vboxapi->setDebug(1);
			ob_end_clean();
		} else {
			raise_error(array(
				'code' => 527,
				'type' => 'php',
				'message' => "Failed to load vboxadm plugin config"), true, true
			);
		}
	}

	function vboxadm_save()
	{
		$this->add_texts('localization/');
		$this->register_handler('plugin.body', array($this,'vboxadm_form'));
		
		$rcmail = rcmail::get_instance();
		$this->_load_config();
		$rcmail->output->set_pagetitle($this->gettext('accountadministration'));
		
		// Set variables and make them ready to be put into DB
		$user = $rcmail->user->data['username'];
		
		$sa_active = get_input_value('sa_active', RCUBE_INPUT_POST);
		if(!$sa_active) {
			$sa_active = 0;
		}
		
		$sa_kill_score = get_input_value('sa_kill_score', RCUBE_INPUT_POST);
		if (!preg_match('/^\d{1,3}[,.]\d{0,2}$/',$sa_kill_score)) {
			$error[] = $this->gettext('spamscorerefuseformat');
		}
		
		# turn , into . (metric vs. imperial)
		$sa_kill_score = str_replace(",",".",$sa_kill_score);
		
		$is_on_vacation = get_input_value('is_on_vacation', RCUBE_INPUT_POST);
		if(!$is_on_vacation) {
			$is_on_vacation = 0;
		}
		
		$vacation_start = get_input_value('vacation_start', RCUBE_INPUT_POST);
		$vacation_start = preg_replace('/^\s*(\d\d)\.(\d\d)\.(\d\d\d\d)\s*$/','$3-$2-$1',$vacation_start,-1,$subst_count);
		if ($subst_count == 0 && trim($vacation_start) != '') {
			$error[] = $this->gettext('autoresponderdateformat');
		}
		
		$vacation_end = get_input_value('vacation_end', RCUBE_INPUT_POST);
		$vacation_end = preg_replace('/^\s*(\d\d)\.(\d\d)\.(\d\d\d\d)\s*$/','$3-$2-$1',$vacation_end,-1,$subst_count);
		if ($subst_count == 0 && trim($vacation_end) != '') {
			$error[] = $this->gettext('autoresponderdateformat');
		}
		
		$vacation_subj = get_input_value('vacation_subj', RCUBE_INPUT_POST);
		$vacation_msg = get_input_value('vacation_msg', RCUBE_INPUT_POST);
		
		// In case someone bypass the javascript maxlength, we make vacation message
		// shorter if above treshold
		if (strlen($vacation_subj) > $this->config['vboxadm_vacation_maxlength']) {
			$vacation_subj = substr($vacation_subj, 0, $this->config['vboxadm_vacation_maxlength']);
		}
		
		$max_msg_size = get_input_value('max_msg_size', RCUBE_INPUT_POST);
		if (!ctype_digit($max_msg_size)) {
			$error[] = $this->gettext('messagesizeformat');
		}
		
		$save_success = FALSE;
		$save_message = '';
		if (empty($error)) {
			$result_array = $this->_save($user,$sa_active,$sa_kill_score,$is_on_vacation,$vacation_start,$vacation_end,$vacation_subj,$vacation_msg,$max_msg_size,$alias_active,$alias_goto);
			if($result_array[0] === TRUE) {
				$save_success = TRUE;
				$save_message = $result_array[1];
			} else {
				$save_success = FALSE;
				$save_message = $result_array[1];
			}
		}
		else {
			$save_success = FALSE;
			$save_message = implode("\n",$error);
		}

		if ($save_success) {
			$rcmail->output->command('display_message', $this->gettext('savesuccess-config'), 'confirmation');
		} else {
			$rcmail->output->command('display_message', $save_message, 'error');
		}

		rcmail_overwrite_action('plugin.vboxadm');
		$this->vboxadm_init();
	}

	function _is_valid_addresses_rfc822($list)
	{
		$list = explode(',',$list);
		foreach ($list as $addr) {
			if (!preg_match('/\\s*[a-z0-9!#$%&\'*+\\/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+\\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-  z0-9-]*[a-z0-9])?\\.)+(?:[A-Z0-9]{2,10})\\s*/i',$addr)) {
				return false;
			}
		}
		return true;
	}

	function vboxadm_form()
	{

		$rcmail = rcmail::get_instance();
		$this->_load_config();

		// add labels to client - to be used in JS alerts
		$rcmail->output->add_label(
			'vboxadm.enterallpassfields',
			'vboxadm.passwordinconsistency',
			'vboxadm.autoresponderlong',
			'vboxadm.autoresponderlongnum',
			'vboxadm.autoresponderlongmax'
		);

		$rcmail->output->set_env('product_name', $rcmail->config->get('product_name'));

		$settings = $this->_get_configuration();

		$sa_active		= $settings['sa_active'];
		$sa_kill_score		= $settings['sa_kill_score'];
		$is_on_vacation		= $settings['is_on_vacation'];
		$vacation_subj		= $settings['vacation_subj'];
		$vacation_msg		= $settings['vacation_msg'];
		$vacation_start		= $settings['vacation_start'];
		$vacation_end		= $settings['vacation_end'];
		$max_msg_size_mb	= $settings['max_msg_size']/(1024*1024);
		$user_id		= $settings['id'];
		$domain_id		= $settings['domain_id'];
		$alias_active		= $settings['alias_active'];
		$alias_goto		= $settings['alias_goto'];

		$domain_settings = $this->_get_domain_configuration($domain_id);

		$active_domain	= $domain_settings['name'];

		$rcmail->output->set_env('vacation_maxlength', $this->config['vboxadm_vacation_maxlength']);

		$out .= '<p class="introtext">' . $this->gettext('introtext') . '</p>' . "\n";

		if ($this->config['show_admin_link'] == true && ( $settings['is_domainadmin'] == true || $settings['is_siteadmin'])) {
			$out .= '<p class="adminlink">';
			$out .= sprintf($this->gettext('adminlinktext'), '<a href="' . $this->config['vboxadm_url'] . '" target="_blank">', '</a>');
			$out .= "</p>\n";
		}

		// =====================================================================================================
		// SpamAssassin
		$out .= '<fieldset><legend>' . $this->gettext('spam') . '</legend>' . "\n";
		$out .= '<div class="fieldset-content">';
		$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

		$field_id = 'sa_active';
		$input_spamenabled = new html_checkbox(
			array(
				'name' => 'sa_active',
				'id' => $field_id,
				'value' => 1
			)
		);

//		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td>\n",
			$field_id,
			rep_specialchars_output($this->gettext('spamenabled')),
			$input_spamenabled->show($sa_active ? 1 : 0 ),
			'<br /><span class="vboxadm-explanation">' . $this->gettext('spamenabledexplanation') . '</span>'
		);

		$field_id = 'sa_kill_score';
		$input_spamscorerefuse = new html_inputfield(
			array(
				'name' => 'sa_kill_score',
				'id' => $field_id,
				'maxlength' => 8,
				'size' => 8,
			)
		);

//		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
		$out .= sprintf("<th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('spamscorerefuse')),
			$input_spamscorerefuse->show($sa_kill_score),
			'<br /><span class="vboxadm-explanation">' . $this->gettext('spamscorerefuseexplanation') . '. <span class="sameline">' . $this->gettext('domaindefault') . ': ' . $default_sa_refuse . '.</span></span>'
		);

		$out .= '</table>';
		$out .= '</div></fieldset>'."\n\n";

		// =====================================================================================================
		// Autoresponder
		$out .= '<fieldset><legend>' . $this->gettext('autoresponder') . '</legend>' . "\n";
		$out .= '<div class="fieldset-content">';
		$out .= '<table><tr><td>';
		$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

		$field_id = 'is_on_vacation';
		$input_autoresponderenabled = new html_checkbox(
			array(
				'name' => 'is_on_vacation',
				'id' => $field_id,
				'value' => 1
			)
		);

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('autoresponderenabled')),
			$input_autoresponderenabled->show($is_on_vacation ? 1 : 0),
			''
		);
					
		$field_id = 'vacation_start';
		$input_vacation_start = new html_inputfield(
			array(
				'name' => 'vacation_start',
				'id' => $field_id,
				'maxlength' => 10,
				'class' => 'text-long'
			)
		);

		if ($vacation_start == '0000-00-00') {
			$vacation_start = '';
		}
		else {
			$vacation_start = preg_replace('/^(\d\d\d\d)-(\d\d)-(\d\d)$/','$3.$2.$1',$vacation_start);
		}

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('autoresponderstartdate')),
			$input_vacation_start->show($vacation_start),
			''
		);

		$field_id = 'vacation_end';
		$input_vacation_end = new html_inputfield(
			array(
				'name' => 'vacation_end',
				'id' => $field_id,
				'maxlength' => 10,
				'class' => 'text-long'
			)
		);

		if ($vacation_end == '0000-00-00') {
			$vacation_end = '';
		}
		else {
			$vacation_end = preg_replace('/^(\d\d\d\d)-(\d\d)-(\d\d)$/','$3.$2.$1',$vacation_end);
		}

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('autoresponderenddate')),
			$input_vacation_end->show($vacation_end),
			''
		);

		$field_id = 'vacation_subj';
		$input_vacation_subj = new html_inputfield(
			array(
				'name' => 'vacation_subj',
				'id' => $field_id,
				'maxlength' => 255,
				'class' => 'text-long'
			)
		);

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('autorespondersubject')),
			$input_vacation_subj->show($vacation_subj),
			'<br /><span class="vboxadm-explanation">' . $this->gettext('autorespondersubjectexplanation') . '.</span>'
		);

		$out .= '</table></td>';
		$out .= '<td><table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

		$field_id = 'vacation_msg';
		$input_vacation_msg = new html_textarea(
			array(
				'name' => 'vacation_msg',
				'id' => $field_id,
				'class' => 'textarea'
			)
		);

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('autorespondermessage')),
			$input_vacation_msg->show($vacation_msg),
			'<br /><span class="vboxadm-explanation">' . $this->gettext('autorespondermessageexplanation') . '</span>'
		);

		$out .= '</table></td></tr></table>';
		$out .= '</div></fieldset>' . "\n\n";

		// ============================================================
		// Parameters
		$out .= '<table><tr><td>';
		$out .= '<fieldset><legend>' . $this->gettext('parameters') . '</legend>' . "\n";

		$out .= '<div class="fieldset-content">';
		$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

		$field_id = 'max_msg_size';
		$input_messagesize = new html_inputfield(
			array(
				'name' => 'max_msg_size',
				'id' => $field_id,
				'maxlength' => 16,
				'class' => 'text-long',
			)
		);

		if ($default_maxmsgsize == 0) {
			$default_maxmsgsize = $this->gettext('unlimited');
		} else {
			$default_maxmsgsize = $default_maxmsgsize . ' MB';
		}

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('messagesize')),
			$input_messagesize->show($max_msg_size_mb),
			'<br /><span class="vboxadm-explanation">'.
			str_replace('%d',$active_domain,
				str_replace('%m',
					$default_maxmsgsize,
					$this->gettext('messagesizeexplanation')
				)
			).
			'</span>'
		);

		$out .= '</table>';
		$out .= '</div></fieldset>' . "\n\n";

		// ============================================================
		// Aliases
		if ($this->config['user_managed_aliases']) {
			// user can edit aliases for his mail address

			$out .= '<fieldset><legend>' . $this->gettext('aliases') . '</legend>' . "\n";

			$out .= '<div class="fieldset-content">';
			$out .= '<span class="vboxadm-explanation">'.$this->gettext('aliasesexplanation').'</span>';
			$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

			$field_id = 'alias_active';
			$input_alias_active = new html_checkbox(
				array(
					'name' => 'alias_active',
					'id' => $field_id,
					'value' => 1
				)
			);

			$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('aliasesenabled')),
				$input_alias_active->show($alias_active ? 1 : 0),
				''
			);

			$field_id = 'alias_goto';
			$input_alias_goto = new html_inputfield(
				array(
					'name' => 'alias_goto',
					'id' => $field_id,
					'maxlength' => 255,
					'class' => 'text-long',
				)
			);

			$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('aliasaddresses')),
				$input_alias_goto->show($alias_goto),
				''
			);

			$out .= '</table>';
			$out .= '</div></fieldset>' . "\n\n";
		}
		// ============================================================
		$out .= '</td><td>';	
		// =====================================================================================================
		// Password change
		$out .= '<fieldset><legend>' . $this->gettext('passwordchange') . '</legend>' . "\n";
		$out .= '<div class="fieldset-content">';
		$out .= '<p>' . $this->gettext('passwordcurrentexplanation') . '</p>';
		$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

		$field_id = 'newpasswd';
		$input_passwordnew = new html_passwordfield(
			array(
				'name' => '_newpasswd',
				'id' => $field_id,
				'class' => 'text-long',
				'autocomplete' => 'off'
			)
		);

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('passwordnew')),
			$input_passwordnew->show(),
			''
		);

		$field_id = 'confpasswd';
		$input_passwordconf = new html_passwordfield(
			array(
				'name' => '_confpasswd',
				'id' => $field_id,
				'class' => 'text-long',
				'autocomplete' => 'off'
			)
		);

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('passwordconfirm')),
			$input_passwordconf->show(),
			''
		);

		$out .= '</table>';
		$out .= '</div></fieldset>'."\n\n";
		
		// ============================================================
		$out .= '</td></tr></table>';
		// =====================================================================================================
		// Password
		$out .= '<fieldset><legend>' . $this->gettext('password') . '</legend>' . "\n";
		$out .= '<div class="fieldset-content">';
		$out .= '<p>' . $this->gettext('passwordexplanation') . '</p>';
		$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

		$field_id = 'curpasswd';
		$input_passwordcurrent = new html_passwordfield(
			array(
				'name' => '_curpasswd',
				'id' => $field_id,
				'class' => 'text-long',
				'autocomplete' => 'off'
				)
		);

		$out .= sprintf("<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
			$field_id,
			rep_specialchars_output($this->gettext('passwordcurrent')),
			$input_passwordcurrent->show(),
			''
		);

		$out .= '</table>';
		$out .= '</div></fieldset>'."\n\n";
		
		// ============================================================

		$out .= html::p(
			null,
			$rcmail->output->button(
				array(
					'command' => 'plugin.vboxadm-save',
					'type' => 'input',
					'class' => 'button mainaction',
					'label' => 'save'
				)
			)
		);

		$rcmail->output->add_gui_object(
			'vboxadmform',
			'vboxadmform'
		);
		
		$out = $rcmail->output->form_tag(
			array(
				'id' => 'vboxadmform',
				'name' => 'vboxadmform',
				'method' => 'post',
				'action' => './?_task=settings&_action=plugin.vboxadm-save'
			),
			$out
		);
		
		$out = html::div(
			array(
				'class' => 'settingsbox',
				'style' => 'margin:0 0 15px 0;'
			),
			html::div(
				array(
					'class' => 'boxtitle'
				),
				$this->gettext('accountadministration')
				) .
			html::div(
				array(
					'style' => 'padding:15px'
				),
				$outtop . "\n" . $out . "\n" . $outbottom
			)
		);

		return $out;

	}


	private function _get_configuration()
	{
		$this->_load_config();
		$rcmail = rcmail::get_instance();
		return $this->vboxapi->get_user_config($rcmail->user->data['username']);
	}


	private function _get_domain_configuration($domain_id)
	{
		$this->_load_config();
		$rcmail = rcmail::get_instance();
		return $this->vboxapi->get_domain_config($domain_id);
	}

	private function _save(
		$user,$sa_active,$sa_kill_score,
		$is_on_vacation,$vacation_start,$vacation_end,$vacation_subj,$vacation_msg,
		$max_msg_size_mb,$alias_active,$alias_goto
	)
	{
		$rcmail = rcmail::get_instance();

		$this->_load_config();
		$settings			= $this->_get_configuration();
		$user_id			= $settings['user_id'];
		$domain_id			= $settings['domain_id'];
		$local_part			= $settings['local_part'];
		
		$curpwd = get_input_value('_curpasswd', RCUBE_INPUT_POST);
		$newpwd = get_input_value('_newpasswd', RCUBE_INPUT_POST);
		$newpwd2 = get_input_value('_confpasswd', RCUBE_INPUT_POST);
		
		$settings['SAActive'] 		= $sa_active;
		$settings['SAKillScore'] 	= $sa_kill_score;
		$settings['IsOnVacation'] 	= $is_on_vacation;
		$settings['VacationStart'] 	= $vacation_start;
		$settings['VacationEnd'] 	= $vacation_end;
		$settings['VacationSubject'] 	= $vacation_subj;
		$settings['VacationMessage']  	= $vacation_msg;
		$settings['MaxMsgSize']  	= $msg_msg_size_mb;
		if($newpwd == $newpwd2) {
			$settings['Password']		= $newpwd;
			$settings['PasswordAgain']	= $newpwd2;
		}
		
		return $this->vboxapi->set_user_config($user,$curpwd,$settings);
	}
}
