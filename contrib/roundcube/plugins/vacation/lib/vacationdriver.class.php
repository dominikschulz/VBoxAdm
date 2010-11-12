<?php
/*
 * VacationDriver base class
 *
 * @package	plugins
 * @uses	rcube_plugin
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license     GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
 */

abstract class VacationDriver {
	protected $cfg,$dotforward = array();
	protected $rcmail,$user,$forward,$body,$subject,$aliases = "";
	protected $enable,$keepcopy = false;

	abstract public function _get();
	abstract public function init();
	abstract protected function setVacation();

	// Provide easy access for the drivers to frequently used objects
	public function __construct() {
		$this->rcmail = rcmail::get_instance();
		$this->user = $this->rcmail->user;
		$this->identity = $this->user->get_identity();
		$child_class = strtolower( get_class($this));
	}

        /*
        
         */
	public final function setIniConfig(array $inicfg)
	{
		$this->cfg = $inicfg;
	}


	public final function setDotForwardConfig($child_class,$config) {
		// forward settings are shared by ftp,sshftp and setuid driver. 
		if (in_array($child_class ,array('ftp','sshftp','setuid'))) {
			$this->dotforward = $config;
		}
	}

	// Helper method for the template to determine if user is allowed to enter aliases
	public final function useAliases()
	{

		return (isset($this->dotforward['alias_identities']) && $this->dotforward['alias_identities']);
	}

public function loadDefaults() {
    // Load default subject and body.

    if (empty($this->cfg['body'])) return false;


    $file = "plugins/vacation/" . $this->cfg['body'];
    

    if (is_readable($file)) {
        $defaults = array('subject'=>$this->cfg['subject']);
        $defaults['body'] = file_get_contents($file);
        return $defaults;
    } else {
        raise_error(array('code' => 601, 'type' => 'php', 'file' => __FILE__,
                    'message' => sprintf("Vacation plugin: s cannot be opened", $file)
                ), true, true);
    }
}
	
	

	// This method will be used from vacation.js as an JSON/Ajax call or directly
	public final function vacation_aliases($method=null)
	{
		$aliases = "";
		$identities = $this->user->list_identities();
		// Strip off the default identity, no need to alias that.
		array_shift($identities);
	  
		

		foreach($identities as $identity)
		{
			// Strip domainname off. /usr/bin/vacation only deals with system users
			
			$aliases.=array_shift(explode("@",$identity['email'])).",";
		}

		$str = substr($aliases,0,-1);

		// We use this method in both ftp.class.php and as Ajax callback

		if (empty($identities))
		{
			// No identities found.
//			$str = "To use aliases, add more identities.";
		}

		if ($method != null)
		{
			return $str;
		} else {
			// Calls the alias_callback as defined in vacation.js
			$this->rcmail->output->command('plugin.alias_callback',  array('aliases'=>$str));
		}
	}


	/*
	 * @return boolean True on succes, false on failure
	 */
	final public function save() {
		$this->enable = (NULL != get_input_value('_vacation_enabled', RCUBE_INPUT_POST));
		$this->subject = get_input_value('_vacation_subject', RCUBE_INPUT_POST);
		$this->body = get_input_value('_vacation_body', RCUBE_INPUT_POST);
		$this->keepcopy = (NULL != get_input_value('_vacation_keepcopy', RCUBE_INPUT_POST));
		$this->forward = get_input_value('_vacation_forward', RCUBE_INPUT_POST);
		$this->aliases = get_input_value('_vacation_aliases', RCUBE_INPUT_POST);

		// This method performs the actual work
		return $this->setVacation();
	}

	final public function getActionText()
	{
		if ($this->enable && empty($this->forward)) { return "enabled_and_no_forward"; };
		if ($this->enable && !empty($this->forward)) {  return "enabled_and_forward"; };
		if (! $this->enable && !empty($this->forward)) { return "disabled_and_forward"; };
		if (! $this->enable && empty($this->forward)) { return "disabled_and_no_forward"; };
		
	}
}?>