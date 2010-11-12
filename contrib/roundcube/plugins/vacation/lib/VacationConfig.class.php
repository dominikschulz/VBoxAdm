<?php
/*
 * VacationConfig helper class
 *
 * @package	plugins
 * @uses	rcube_plugin
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license     GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
 */

class VacationConfig
{
	private $currentHost = null;
	private $iniArr,$currentArr = array();
	private $hasError = false;
	private $allowedOptions = array('none'=>array(),'ftp'=>array(),'sshftp'=>array(),'virtual'=>array(),'sieve'=>array(),'setuid'=>array(), 'vboxadm'=>array());

	public function __construct()
	{
		// Allowed options in config.ini per driver
		$this->allowedOptions['ftp'] = array('server'=>'optional','passive'=>'optional','disable_forward'=>'optional');
		$this->allowedOptions['sshftp'] = array('server'=>'optional','disable_forward'=>'optional');
		$this->allowedOptions['virtual'] = array('dsn'=>'optional','transport'=>'required','dbase'=>'required','always_keep_copy'=>'optional',
			'domain_lookup_query'=>'optional', 'select_query'=>'required','delete_query'=>'required', 'insert_query'=>'required','createvacationconf'=>'optional','always_keep_message'=>'optional','disable_forward'=>'optional');
		$this->allowedOptions['setuid'] = array('executable'=>'required','disable_forward'=>'optional');
		$this->allowedOptions['sieve'] = array('server'=>'optional','disable_forward'=>'optional',
                                                        'port'=>'optional','tls'=>'optional');
		$this->allowedOptions['vboxadm'] = array('dsn'=>'optional','dbase'=>'required');
		$this->parseIni();
	}

        public function getDefaultText()
        {
            if (empty($this->iniArr['default']['body']) || empty($this->iniArr['default']['body'])) {
                $defaults = array('body'=>"","subject"=>"");
            } else {
                $defaults = array('body'=>$this->iniArr['default']['body'],"subject"=>$this->iniArr['default']['subject']);
            }
            return $defaults;

        }
	
	private function parseIni()
	{
		$configini = "plugins/vacation/config.ini";		
		if (! is_readable($configini))
		{
			$this->hasError = $configini." is not readable";
		} else {

			$this->iniArr = parse_ini_file($configini, true);
			
			if (! $this->iniArr)
			{
				$this->hasError = "Failed to parse config.ini";
			}
		}
	}
	
	public function hasError()
	{
            return $this->hasError;
	}

        // Get normalized hostname
	public function setCurrentHost($host)
	{
		if (! $this->currentHost = parse_url($host,PHP_URL_HOST))
		{
			$this->currentHost = parse_url($host,PHP_URL_PATH);
		}
	}

        public function getDotForwardCfg()
        {
            return $this->iniArr['dotforward'];

        }

	public function hasVacationEnabled()
	{
		
		return ( $this->currentArr['driver'] != 'none');
	}

	private function setServer()
	{
		if (in_array($this->currentArr['driver'],array('ftp','sshftp','sieve')) && empty($this->currentArr['server']))
		{
			$this->currentArr['server'] = $this->currentHost;
		}
	}

	public function getCurrentConfig()
	{
		// If parsing the ini has failed, hasError is no longer false.
		// Return here as to avoid errors with array_key_exists
		if ($this->hasError !== false)
		{
			return false;
		}


		// No host specific config for current host
		if (array_key_exists($this->currentHost,$this->iniArr))
		{
			$this->currentArr = $this->iniArr[$this->currentHost];
		} else {
			// No default either
			if (array_key_exists('default',$this->iniArr))
			{
				$this->currentArr = $this->iniArr['default'];
			} else {
				// No usable config
				$this->hasError = sprintf("No [default] or [%s] found in config.ini",$this->currentHost);
				return false;
			}
		}

		

		$this->setServer();

		if (! array_key_exists($this->currentArr['driver'],$this->allowedOptions))
		{
			$this->hasError = sprintf($this->currentArr['driver']." is not a valid choice. Please edit config.ini");
			return false;
		}


		
		if (! $this->checkAllowedParameters())
		{
			   
			   
			return false;
		}



		if (! $this->checkRequiredOptions())
		{
			return false;
		}

		
		
		return $this->currentArr;
	}

	private function checkRequiredOptions()
	{
		foreach($this->allowedOptions[$this->currentArr['driver']] as $key=>$required)
		{
			if ($required=='required' && empty($this->currentArr[$key]))
			{
				$this->hasError = sprintf("Driver %s does not allow %s to be empty. Please edit config.ini",$this->currentArr['driver'],$key);
				return false;
			}
		}
		return true;
	}

	private function checkAllowedParameters()
	{

		$keys = $this->allowedOptions[$this->currentArr['driver']];
		$diff = array_diff_key($this->currentArr,array_flip(array_keys($keys)));
	
             
		if (! empty($diff) && !in_array(key($diff),array('driver','body','subject')))
		{
			// Invalid options found
			$this->hasError = sprintf("Invalid option found in config.ini for %s driver and section [%s]: %s is not supported",
			$this->currentArr['driver'],$this->currentHost,key($diff));
			
		}
		return (empty($this->hasError));
	}


	public function __destruct()
	{
		unset($this->iniArr);
	}
}
?>
