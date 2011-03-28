<?php

/**
 * vboxadm
 *
 * Plugin that covers the non-admin part of vboxadm web interface.
 *
 * @date 2010-12-23
 * @author Dominik Schulz
 * @url http://vboxadm.gauner.org/
 * @licence GNU GPL 2
 */

class vboxadm extends rcube_plugin
{
	public $task = 'settings';
	private $config;
	private $db;
	private $sections = array();
	private $dovecotpw;

	function init()
	{
		$rcmail = rcmail::get_instance();
		$this->add_texts('localization/', array('accountadmin'));

		$this->register_action('plugin.vboxadm', array($this, 'vboxadm_init'));
		$this->register_action('plugin.vboxadm-save', array($this, 'vboxadm_save'));

		$this->include_script('vboxadm.js');
		$this->include_stylesheet('vboxadm.css');
		
		$this->dovecotpw = new DovecotPW;
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
			ob_end_clean();
		} else {
			raise_error(array(
				'code' => 527,
				'type' => 'php',
				'message' => "Failed to load vboxadm plugin config"), true, true);
		}
	}

	private function _db_connect($mode)
	{
		$this->db = new rcube_mdb2($this->config['db_dsn'], '', false);
		$this->db->db_connect($mode);

		// check DB connections and exit on failure
		if ($err_str = $this->db->is_error()) {
			raise_error(array(
		    'code' => 603,
		    'type' => 'db',
		    'message' => $err_str), FALSE, TRUE);
		}
	}

	function vboxadm_save()
	{
		$this->add_texts('localization/');
		$this->register_handler(
			'plugin.body',
			array(
				$this,
				'vboxadm_form'
			)
		);

		$rcmail = rcmail::get_instance();
		$this->_load_config();
		$rcmail->output->set_pagetitle($this->gettext('accountadministration'));

		// Set variables and make them ready to be put into DB
		$user = $rcmail->user->data['username'];

		$sa_active = get_input_value('sa_active', RCUBE_INPUT_POST);
		if(!$sa_active)
			$sa_active = 0;

		$sa_kill_score = get_input_value('sa_kill_score', RCUBE_INPUT_POST);
		# turn , into . (metric vs. imperial)
		$sa_kill_score = str_replace(",",".",$sa_kill_score);

		$is_on_vacation = get_input_value('is_on_vacation', RCUBE_INPUT_POST);
		if(!$is_on_vacation)
			$is_on_vacation = 0;

		$vacation_subj = get_input_value('vacation_subj', RCUBE_INPUT_POST);
		$vacation_msg = get_input_value('vacation_msg', RCUBE_INPUT_POST);

		// In case someone bypass the javascript maxlength, we make vacation message
		// shorter if above treshold
		if (strlen($vacation_subj) > $this->config['vboxadm_vacation_maxlength']) {
			$vacation_subj = substr($vacation_subj, 0, $this->config['vboxadm_vacation_maxlength']);
		}

		$max_msg_size = get_input_value('max_msg_size', RCUBE_INPUT_POST);

		$res = $this->_save($user,$sa_active,$sa_kill_score,$is_on_vacation,$vacation_subj,$vacation_msg,$max_msg_size);

		if (!$res) {
			$rcmail->output->command('display_message', $this->gettext('savesuccess-config'), 'confirmation');
		} else {
			$rcmail->output->command('display_message', $res, 'error');
		}

		rcmail_overwrite_action('plugin.vboxadm');

		$this->vboxadm_init();
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
			$sa_kill_score	= $settings['sa_kill_score'];
			$is_on_vacation	= $settings['is_on_vacation'];
			$vacation_subj 	= $settings['vacation_subj'];
			$vacation_msg	= $settings['vacation_msg'];
			$max_msg_size_mb = $settings['max_msg_size']/1024;
			$user_id		= $settings['id'];
			$domain_id		= $settings['domain_id'];

			$domain_settings = $this->_get_domain_configuration($domain_id);

			$active_domain	= $domain_settings['name'];

			$rcmail->output->set_env('vacation_maxlength', $this->config['vboxadm_vacation_maxlength']);

			$out .= '<p class="introtext">' . $this->gettext('introtext') . '</p>' . "\n";

			if ($this->config['show_admin_link'] == true && ( $settings['is_domainadmin'] == true || $settings['is_superadmin'])) {
				$out .= '<p class="adminlink">';
				$out .= sprintf($this->gettext('adminlinktext'), '<a href="' . $this->config['vboxadm_url'] . '" target="_blank">', '</a>');
				$out .= "</p>\n";
			}

			// =====================================================================================================
			// Password
			$out .= '<fieldset><legend>' . $this->gettext('password') . '</legend>' . "\n";
			$out .= '<div class="fieldset-content">';
			$out .= '<p>' . $this->gettext('passwordcurrentexplanation') . '</p>';
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

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('passwordcurrent')),
				$input_passwordcurrent->show(),
				''
			);

			$field_id = 'newpasswd';
			$input_passwordnew = new html_passwordfield(
				array(
					'name' => '_newpasswd',
					'id' => $field_id,
					'class' => 'text-long',
					'autocomplete' => 'off'
				)
			);

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
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

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('passwordconfirm')),
				$input_passwordconf->show(),
				''
			);

			$out .= '</table>';
			$out .= '</div></fieldset>'."\n\n";

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

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
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

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
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
			$out .= '<table class="vboxadm-settings" cellpadding="0" cellspacing="0">';

			$field_id = 'is_on_vacation';
			$input_autoresponderenabled = new html_checkbox(
				array(
					'name' => 'is_on_vacation',
					'id' => $field_id,
					'value' => 1
				)
			);

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('autoresponderenabled')),
				$input_autoresponderenabled->show($is_on_vacation ? 1 : 0),
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

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('autorespondersubject')),
				$input_vacation_subj->show($vacation_subj),
				'<br /><span class="vboxadm-explanation">' . $this->gettext('autorespondersubjectexplanation') . '.</span>'
			);		

			$field_id = 'vacation_msg';
			$input_vacation_msg = new html_textarea(
				array(
					'name' => 'vacation_msg',
					'id' => $field_id,
					'class' => 'textarea'
				)
			);

			$out .= sprintf(
				"<tr><th><label for=\"%s\">%s</label>:</th><td>%s%s</td></tr>\n",
				$field_id,
				rep_specialchars_output($this->gettext('autorespondermessage')),
				$input_vacation_msg->show($vacation_msg),
				'<br /><span class="vboxadm-explanation">' . $this->gettext('autorespondermessageexplanation') . '</span>'
			);
				
			$out .= '</table>';
			$out .= '</div></fieldset>' . "\n\n";

			// ============================================================
			// Parameters
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
				str_replace(
					'%d',
					$active_domain,
					str_replace(
						'%m',
						$default_maxmsgsize,
						$this->gettext('messagesizeexplanation')
					)
				).
				'</span>'
			);

			$out .= '</table>';
			$out .= '</div></fieldset>' . "\n\n";

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
		$this->_db_connect('r');

		$sql = 'SELECT m.id AS user_id, d.id AS domain_id, m.local_part AS local_part,d.name AS domain,m.name AS username,m.max_msg_size,m.is_on_vacation,m.vacation_subj,m.vacation_msg,m.is_domainadmin,m.is_superadmin,m.sa_active,m.sa_kill_score FROM mailboxes AS m LEFT JOIN domains AS d ON m.domain_id = d.id WHERE CONCAT(m.local_part,\'@\',d.name) = ' . $this->db->quote($rcmail->user->data['username'],'text') . ' AND m.is_active AND d.is_active LIMIT 1';
		$res = $this->db->query($sql);

		if ($err = $this->db->is_error()){
			return $err;
		}
		$ret = $this->db->fetch_assoc($res);

		return $ret;
	}


	private function _get_domain_configuration($domain_id)
	{
		$this->_load_config();
		$rcmail = rcmail::get_instance();
		$this->_db_connect('r');

		$sql = 'SELECT id,name,is_active FROM domains WHERE id = ' . $this->db->quote($domain_id) . ' AND is_active LIMIT 1';
		$res = $this->db->query($sql);

		if ($err = $this->db->is_error()){
			return $err;
		}
		$ret = $this->db->fetch_assoc($res);

		return $ret;
	}

	private function _save($user,$sa_active,$sa_kill_score,$is_on_vacation,$vacation_subj,$vacation_msg,$max_msg_size_mb)
	{
		$rcmail = rcmail::get_instance();

		$this->_load_config();
		$this->_db_connect('w');
		$settings			= $this->_get_configuration();
		$user_id			= $settings['user_id'];
		$domain_id			= $settings['domain_id'];
		
		$max_msg_size = $max_msg_size_mb * 1024;

		$sql = 'UPDATE mailboxes SET ';
		$sql .= 'sa_active = '.$this->db->quote($sa_active,'text').', ';
		$sql .= 'sa_kill_score = '.$this->db->quote($sa_kill_score,'text').', ';
		$sql .= 'is_on_vacation = '.$this->db->quote($is_on_vacation,'text').', ';
		$sql .= 'vacation_subj = '.$this->db->quote($vacation_subj,'text').', ';
		$sql .= 'vacation_msg = '.$this->db->quote($vacation_msg,'text').', ';
		$sql .= 'max_msg_size = '.$this->db->quote($max_msg_size,'text').' ';
		$sql .= 'WHERE id = '.$this->db->quote($user_id,'text').' AND is_active LIMIT 1';

		$config_error = 0;
		$res = $this->db->query($sql);
		if ($err = $this->db->is_error()) {
			$config_error = 1;
		}
		$res = $this->db->affected_rows($res);

		$curpwd = get_input_value('_curpasswd', RCUBE_INPUT_POST);
		$newpwd = get_input_value('_newpasswd', RCUBE_INPUT_POST);
		
		/* write_log('vboxadm','_save invoked'); */

		if ($curpwd != '' and $newpwd != '') {

			$trytochangepass = 1;
			$password_change_error = 0;
			 
			# check against salted pw from db!
			if (!$this->verify_pass_by_uid($curpwd, $user_id)) {
				// Current password was not correct.
				$password_change_error = 1;
				$addtomessage .= '. ' . $this->gettext('saveerror-verify-mismatch');
				/* write_log('vboxadm',"_save - Password mismatch - verify_pass_by_uid($curpwd, $user_id) returned false."); */
			} elseif($rcmail->decrypt($_SESSION['password']) != $curpwd) {
				$password_change_error = 4;
				$addtomessage .= '. ' . $this->gettext('saveerror-pass-mismatch');
				/* write_log('vboxadm',"_save - Password mismatch - ".$_SESSION['password']." != $curpwd"); */
			} elseif(!$this->dovecotpw->check_password($newpwd, FALSE)) {
				$password_change_error = 5;
				$addtomessage .= '. ' . $this->gettext('saveerror-pass-too-weak');
				/* write_log('vboxadm',"_save - Password $newpwd too weak"); */
			} else {
				$crypted_password = $this->dovecotpw->make_pass($newpwd, 'SSHA256');
				/* write_log('vboxadm','_save - Password MATCHES! New crypted Pass: '.$crypted_password); */
				$sql_pass = "UPDATE mailboxes SET password=" . $this->db->quote($crypted_password) . " WHERE id = " . $this->db->quote($user_id,'text') . " AND is_active LIMIT 1";
				/* write_log('vboxadm',"_save - Password update query: $sql_pass"); */
				$res_pass = $this->db->query($sql_pass);
				if ($err = $this->db->is_error()) {
					$password_change_error = 2;
					$addtomessage .= '.' . $this->gettext('saveerror-pass-database');
				} else {

					$res_pass = $this->db->affected_rows($res_pass);
					if ($res_pass == 0) {
						$password_change_error = 3;
						$addtomessage .= '. ' . $this->gettext('saveerror-pass-norows');
					} elseif ($res_pass == 1) {
						$password_change_success = 1;
						$_SESSION['password'] = $rcmail->encrypt($newpwd);
					}
				}
			}
		}

		// This error handling is a bit messy, should be improved!
		// We may also want to check for $res and $res_pass to see if changes were done or not

		if ($config_error == 1) {
			// Mysql error on config update. Also print any errors from password.
			return $this->gettext('saveerror-config-database')  . $addtomessage;
		}
		if ($config_error == 0 and $trytochangepass == 1 and $password_change_error == 1) {
			// Config updated, but error in password saving due to mismatch
			return $this->gettext('savesuccess-config-saveerror-verify-mismatch');
		}
		if ($config_error == 0 and $trytochangepass == 1 and $password_change_error == 2) {
			// Config updated, but error in password saving due to mismatch
			return $this->gettext('savesuccess-config-saveerror-pass-database');
		}
		if ($config_error == 0 and $trytochangepass == 1 and $password_change_error == 3) {
			// Config updated, but error in password saving due to mismatch
			return $this->gettext('savesuccess-config-saveerror-pass-norows');
		}
		if ($config_error == 0 and $trytochangepass == 1 and $password_change_error == 4) {
			// Config updated, but error in password saving due to mismatch
			return $this->gettext('savesuccess-config-saveerror-pass-mismatch');
		}
		if ($config_error == 0 and $trytochangepass == 1 and $password_change_error == 5) {
			// Config updated, but error in password saving due to mismatch
			return $this->gettext('savesuccess-config-saveerror-pass-too-weak');
		}
		if ($config_error == 0 and $trytochangepass == 1 and $password_change_error) {
			// Config updated, but other error in password saving
			return $this->gettext('savesuccess-config') . $addtomessage;
		}

		if ($config_error == 0) {
			// Best case, no trouble reported
			return false;
		}

		// If still here - send all error messages.
		return $this->gettext('saveerror-internalerror') . $addtomessage;

	}
	
	
	private function verify_pass_by_uid($pass, $user_id) {
		$sql = "SELECT password FROM mailboxes WHERE id = ".$this->db->quote($user_id, 'text');
		$res = $this->db->query($sql);

		if ($err = $this->db->is_error()){
			return $err;
		}
		$ret = $this->db->fetch_assoc($res);
		
		return $this->dovecotpw->verify_pass($pass, $ret['password']);
	}

}

class DovecotPW {
	private $hashlen = array(
		'smd5'    => 16,
	    'ssha'    => 20,
	    'ssha256' => 32,
	    'ssha512' => 64,
	);
	
	public function check_password($pwd, $numeric = FALSE) 
	{
		$score = 0;
		/* no too short passwords at all */
		if (strlen($pwd) < 8)
		{
			return FALSE; 
		}
	
		if (strlen($pwd) >= 8)
		{
			$score++; 
		}
		if (strlen($pwd) >= 12)
		{
			$score++; 
		}
		/* UPPER and lower case mixed */
		if (preg_match("/[a-z]/", $pwd) && preg_match("/[A-Z]/", $pwd)) 
		{
			$score++; 
		}
		/* contains numbers */
		if (preg_match("/[0-9]/", $pwd)) 
		{
			$score++; 
		}
		/* contains special chars */
		if (preg_match("/.[!,@,#,$,%,^,&,*,?,_,~,-,£,(,)]/", $pwd)) 
		{
			$score++; 
		}
		if($numeric) {
			return $score;
		} else {
			if($score > 2) {
				return TRUE;
			} else {
				return FALSE;
			}
		} 
	}		
	
	public function make_salt() {
	    $len   = 8 + rand(0,8);
	    $bytes = array();
	    for ($i = 0; $i < $len; $i++ ) {
	        $bytes[] = rand(1,255);
	    }
	    $salt_str = '';
	    foreach ($bytes as $b) {
	    	$salt_str .= pack('C', $b);
	    }
	    return $salt_str;
	}
	
	public function verify_pass($pass, $pwentry) {
	    $pwinfo = $this->split_pass($pwentry);
	
	    $passh = $this->make_pass( $pass, $pwinfo[0], $pwinfo[2] );
	
	    if ( $pwentry == $passh ) {
	        return TRUE;
	    }
	    else {
	        return FALSE;
	    }
	}
	
	public function ldap_md5($pw) {
	    return "{SHA}" . base64_encode( hash('md5',$pw, TRUE) );
	}
	
	public function smd5($pw, $salt) {
		if(strlen($salt) < 1) {
			$salt = $this->make_salt();
		}
	    return "{SSHA}" . base64_encode( hash('md5', $pw . $salt, TRUE ) . $salt );
	}
	
	public function sha($pw) {
	    return "{SHA}" . base64_encode( hash('sha1',$pw, TRUE) );
	}
	
	public function ssha($pw, $salt) {
		if(strlen($salt) < 1) {
			$salt = $this->make_salt();
		}
	    return "{SSHA}" . base64_encode( hash('sha1', $pw . $salt, TRUE ) . $salt );
	}
	
	public function sha256($pw) {
	    return "{SHA256}" . base64_encode( hash('sha256',$pw, TRUE) );
	}
	
	public function ssha256($pw, $salt) {
		if(strlen($salt) < 1) {
			$salt = $this->make_salt();
		}
	    return "{SSHA256}" . base64_encode( hash('sha256', $pw . $salt, TRUE ) . $salt );
	}
	
	public function sha512($pw) {
	    return "{SHA512}" . base64_encode( hash('sha512',$pw, TRUE) );
	}
	
	public function ssha512($pw, $salt) {
		if(strlen($salt) < 1) {
			$salt = $this->make_salt();
		}
	    return "{SSHA512}" . base64_encode( hash('sha512', $pw . $salt, TRUE ) . $salt );
	}
	
	public function make_pass($pw, $pwscheme, $salt) {
		if(strlen($salt) < 1) {
			$salt = $this->make_salt();
		}
		if(strlen($pwscheme) < 1) {
			$pwscheme = $this->config['vboxadm_cryptscheme'];
		}
		$pwscheme = strtolower($pwscheme);
		switch($pwscheme) {
			case "ldap_md5":
				return $this->ldap_md5($pw);
				break;
			case "plain_md5":
				return $this->plain_md5($pw);
				break;
			case "sha":
				return $this->sha($pw);
				break;
			case "sha256":
				return $this->sha256($pw);
				break;
			case "sha512":
				return $this->sha512($pw);
				break;
			case "smd5":
				return $this->smd5($pw,$salt);
				break;
			case "ssha":
				return $this->ssha($pw,$salt);
				break;
			case "ssha256":
				return $this->ssha256($pw,$salt);
				break;
			case "ssha512":
				return $this->ssha512($pw,$salt);
				break;
			default:
				return "{CLEARTEXT}".$pw;
		}
	}
	
	public function split_pass($pw) {
	    $pwscheme = 'cleartext';
	
	    # get use password scheme and remove leading block
	    if ( preg_match("/^\{([^}]+)\}/", $pw, $matches) ) {
	        $pwscheme = strtolower($matches[1]);
	        $pw = preg_replace("/^\{([^}]+)\}/",'',$pw);
	
	        # turn - into _ so we can feed pwscheme to make_pass
	        $pwscheme = preg_replace("/-/",'_',$pwscheme);
	    }
	
	    # We have 3 major cases:
	    # 1 - cleartext pw, return pw and empty salt
	    # 2 - hashed pw, no salt
	    # 3 - hashed pw with salt
	    if ( !$pwscheme || $pwscheme == 'cleartext' || $pwscheme == 'plain' ) {
	        return array('cleartext', $pw, '' );
	    }
	    elseif ( preg_match("/^(plain-md5|ldap-md5|md5|sha|sha256|sha512)$/i", $pwscheme) ) {
	        $pw = base64_decode($pw);
	        return array( $pwscheme, $pw, '' );
	    }
	    elseif ( preg_match("/^(smd5|ssha|ssha256|ssha512)/", $pwscheme) ) {
	
	        # now get hashed pass and salt
	        # hashlen can be computed by doing
	        # $hashlen = length(Digest::*::digest('string'));
	        $hashlen = $this->hashlen[$pwscheme];
	
	        # pwscheme could also specify an encoding
	        # like hex or base64, but right now we assume its b64
	        $pw = base64_decode($pw);
	
	        # unpack byte-by-byte, the hash uses the full eight bit of each byte,
	        # the salt may do so, too.
	        $tmp  = unpack( 'C*', $pw );
	        $i    = 1;
	        $hash = array();
	
	        # the salted hash has the form: $saltedhash.$salt,
	        # so the first bytes (# $hashlen) are the hash, the rest
	        # is the variable length salt
	        while ( $i <= $hashlen ) {
	            $hash[] = $tmp[$i++];
	        }
	
	        # as I've said: the rest is the salt
	        $salt = array();
	        for(; $i <= sizeof($tmp); $i++) {
	            $salt[] = $tmp[$i];
	        }
	
	        # pack it again, byte-by-byte
	        foreach ($hash as $h) {
	        	$pw_str .= pack('C', $h);
	        }
	        foreach ($salt as $s) {
	        	$salt_str .= pack('C', $s);
	        }
	
	        return array( $pwscheme, $pw_str, $salt_str );
	    }
	    else {
	
	        # unknown pw scheme
	        return FALSE;
	    }
	}
}