<?php
/*
 * Sieve driver
 *
 * @package	plugins
 * @uses	rcube_plugin, managesieve
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license	GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
 * 
 *
 *  
 * Based on ManageSieve plugin by Aleksander 'A.L.E.C' Machniak <alec at alec dot pl>
 * 
 */



class Sieve extends VacationDriver {

	private $sieve = null;

        private $tls = false;
        private $port = 2000;

        public function init() {
            // try to connect to managesieve server and to fetch the script
       
            $username = Q($this->user->data['username']);
            $userpass = $this->rcmail->decrypt($_SESSION['password']);

			// Standard plugin
            require 'plugins/managesieve/lib/Net/Sieve.php';

            $this->sieve = new Net_Sieve();
            $error = $this->sieve->connect("192.168.178.25", $this->cfg['port'], NULL, $this->cfg['tls']);
           
                echo $error;
                
                exit(0);
           

                if (PEAR::isError($this->sieve->login($username, $userpass))) {
                    echo "Fout";
                }
        }

	// Download .forward and .vacation.message file
	public function _get() {
		$vacArr = array("subject"=>"","aliases"=>"", "body"=>"","forward"=>"","keepcopy"=>true,"enabled"=>false);

               if ($script = $this->sieve->getScript("vacation"))
               {

               }
               

               return $vacArr;

	}

	protected function setVacation() {
            $script = "";
            if (! $this->enable)
            {
                $this->sieve->removeScript("vacation");
            }
            $this->sieve->installScript("vacation", $script);
		
	}

	// Cleans up files

	private function disable() {
		
	}

	


	


        public function __destruct()
        {
            $this->sieve->disconnect();
            $this->sieve = null;
        }
        



	

}
?>
