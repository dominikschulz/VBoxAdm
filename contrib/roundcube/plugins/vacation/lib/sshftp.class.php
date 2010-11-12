<?php
/*
 * SSHFTP driver
 *
 * @package	plugins
 * @uses	rcube_plugin
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license     GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
 *
 * Contributions by Johnson Chow
 */



class SSHFTP extends VacationDriver {
	private $ftp = false;
	private $conn = null;

	public function init() {
		$username = Q($this->user->data['username']);
		$userpass = $this->rcmail->decrypt($_SESSION['password']);

		$callback = array();
				
		if (! $this->conn = ssh2_connect($this->cfg['server'],22,null,$callback)) {
			raise_error(array('code' => 601, 'type' => 'php', 'file' => __FILE__,
                'message' => sprintf("Vacation plugin: Cannot connect to the SSH-server '%s'",$this->cfg['server'])
			),true, true);

		}
		
		// Supress error here
		if (! @ssh2_auth_password($this->conn, $username,$userpass)) {
			raise_error(array('code' => 601, 'type' => 'php', 'file' => __FILE__,
                'message' => sprintf("Vacation plugin: Cannot login to SSH-server '%s' with username: %s",$this->cfg['server'],$username)
			),true, true);
		}
		
		$this->ftp = ssh2_sftp($this->conn);

		
		// Once we have a succesfull login, discard user-sensitive data like password
		$username = $userpass = null;

	
	}

	// Download .forward and .vacation.message file
	public function _get() {
		$vacArr = array("subject"=>"","aliases"=>"", "body"=>"","forward"=>"","keepcopy"=>true,"enabled"=>false);

		// Vacation is ony
		if ($dot_vacation_msg = $this->downloadfile($this->dotforward['message'])) {
			$dot_vacation_msg = explode("\n",$dot_vacation_msg);
			$vacArr['subject'] = str_replace('Subject: ','',$dot_vacation_msg[1]);
			$vacArr['body'] = join("\n",array_slice($dot_vacation_msg,2));
		}
                
		if ($dotForwardFile = $this->downloadfile(".forward")) {
			$d = new DotForward();
                        $d->setOption("username",$this->user->data['username']);
			$vacArr = array_merge($vacArr,$d->parse($dotForwardFile));
		}
		// Load aliases using the available identities
		if (! $vacArr['enabled']) $vacArr['aliases'] = $this->vacation_aliases("method");

		return $vacArr;
	}

	protected function setVacation() {

		// Remove existing vacation files
		$this->disable();

		$d = new DotForward;
		// Enable auto-reply?
		if ($this->enable) {
			$d->mergeOptions($this->dotforward);

			$email = $this->identity['email'];

			// Set the envelop sender to the current idendity's email address
			if (isset($this->dotforward['set_envelop_sender']) && $this->dotforward['set_envelop_sender']) {
				$d->setOption("envelop_sender",$email);
			}

			$d->setOption("aliases",$this->aliases);
			


			// Create the .vacation.message file

			$full_name = $this->identity['name'];

			if (!empty($full_name)) {
				$vacation_header = sprintf("From: %s <%s>\n",$full_name,$email);
			} else {
				$vacation_header = sprintf("From: %s\n",$email);
			}
			$vacation_header .= sprintf("Subject: %s\n\n",$this->subject);
			$message = $vacation_header.$this->body;
			$this->uploadfile($message,$this->dotforward['message']);

		}
		$d->setOption("username",$this->user->data['username']);
		$d->setOption("keepcopy",$this->keepcopy);
		$d->setOption("forward",$this->forward);

		// Do we even need to upload a .forward file?
		if ($this->keepcopy || $this->enable || $this->forward != "")
		{
			if (! $this->enable) { $d->setOption("binary",""); } 
			$this->uploadfile($d->create(),".forward");
		}
		return true;

	}

	// Cleans up files

	private function disable() {
		$deleteArr = array(".forward",$this->dotforward['message'],$this->dotforward['database']);
		if (isset($this->dotforward['always_keep_message']) && $this->dotforward['always_keep_message'])
		{
			unset($deleteArr[1]);
		}
		$this->deletefiles($deleteArr);
		return true;
	}

	private function ssh2_file_exists($remoteFile)
	{
		$stat = @ssh2_sftp_stat($this->ftp,$remoteFile);
		return (is_array($stat) && $stat['size'] != 0);
	}

	/*
	 * @return boolean True if both .vacation.msg and .forward exist, false otherwise
	 */
	private function is_active() {
		return $this->ssh2_file_exists(".forward");
	}
	
	// Delete files when disabling vacation
	private function deletefiles(array $remoteFiles) {
		foreach ($remoteFiles as $file)
		{
			if ($this->ssh2_file_exists($file))
			{
				ssh2_sftp_unlink($this->ftp, $file);
			}
		}

		return true;
	}

	// Upload a file. 
	private function uploadfile($data,$remoteFile) {
            $remoteFile = ssh2_sftp_realpath($this->ftp,".")."/".$remoteFile;

          if (! file_put_contents("ssh2.sftp://".$this->ftp.$remoteFile, $data))
                {
                    raise_error(array('code' => 601,'type' => 'php','file' => __FILE__,
                'message' => "Vacation plugin: Cannot upload {$remoteFile}. Check permissions and/or server configuration"
			),true, true);
                }
                return true;

	}

	// Download a file and return its content as a string or return false if the file cannot be found
	private function downloadfile($remoteFile) {
		if ($this->ssh2_file_exists($remoteFile))
		{
			$remoteFile = ssh2_sftp_realpath($this->ftp, ".")."/".$remoteFile;
			return file_get_contents("ssh2.sftp://".$this->ftp.$remoteFile);
		}
		return false;	
	}



	public function __destruct() {
		if (is_resource($this->ftp)) {
			$this->ftp = null;
		}
		if (is_resource($this->conn)) {
			$this->conn = null;
		}
	}

}
?>
