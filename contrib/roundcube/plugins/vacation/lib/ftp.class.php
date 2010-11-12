<?php
/*
 * FTP driver
 *
 * @package	plugins
 * @uses	rcube_plugin
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license     GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
 */

class FTP extends VacationDriver {
	private $ftp = false;

	public function init() {
		$username = Q($this->user->data['username']);
		$userpass = $this->rcmail->decrypt($_SESSION['password']);

		// 15 second time-out
		if (! $this->ftp = ftp_connect($this->cfg['server'],21,15)) {
			raise_error(array('code' => 601, 'type' => 'php', 'file' => __FILE__,
                'message' => sprintf("Vacation plugin: Cannot connect to the FTP-server '%s'",$this->cfg['server'])
			),true, true);

		}

		// Supress error here
		if (! @ftp_login($this->ftp, $username,$userpass)) {
			raise_error(array(
                'code' => 601, 'type' => 'php','file' => __FILE__,
                'message' => sprintf("Vacation plugin: Cannot login to FTP-server '%s' with username: %s",$this->cfg['server'],$username)
			),true, true);
		}

		// Once we have a succesfull login, discard user-sensitive data like password
		$username = $userpass = null;

		// Enable passive mode
		if (isset($this->cfg['passive']) && !ftp_pasv($this->ftp, TRUE)) {
			raise_error(array(
                'code' => 601,'type' => 'php','file' => __FILE__,
                'message' => "Vacation plugin: Cannot enable PASV mode on {$this->cfg['server']}"
			),true, true);
		}
	}

	// Download .forward and .vacation.message file
	public function _get() {
		$vacArr = array("subject"=>"","aliases"=>"", "body"=>"","forward"=>"","keepcopy"=>true,"enabled"=>false);

		// Load current subject and body if it exists
		if ($dot_vacation_msg = $this->downloadfile($this->dotforward['message'])) {
			$dot_vacation_msg = explode("\n",$dot_vacation_msg);
			$vacArr['subject'] = str_replace('Subject: ','',$dot_vacation_msg[1]);
			$vacArr['body'] = join("\n",array_slice($dot_vacation_msg,2));
		} 

                // Use dotforward if it exists
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
		$d->mergeOptions($this->dotforward);
		// Enable auto-reply?
		if ($this->enable) {


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
		$d->setOption("forward",$this->forward);
                $d->setOption("keepcopy",$this->keepcopy);

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

	// Delete files when disabling vacation
	private function deletefiles(array $remoteFiles) {
		foreach ($remoteFiles as $file)
		{
			 
			if (ftp_size($this->ftp, $file) > 0)
			{
				@ftp_delete($this->ftp, $file);
			}
		}

		return true;
	}

	// Upload a file. 
	private function uploadfile($data,$remoteFile) {
		$localFile = tempnam(sys_get_temp_dir(), 'Vac');
		file_put_contents($localFile,trim($data));
		$result = @ftp_put($this->ftp, $remoteFile, $localFile, FTP_ASCII);

		unlink($localFile);
		if (! $result)
		{
			raise_error(array(
                'code' => 601,'type' => 'php', 'file' => __FILE__,
                'message' => "Vacation plugin: Cannot upload {$remoteFile}. Check permissions and/or server configuration"
			),true, true);

		}
		return $result;
	}

	// Download a file and return its content as a string or return false if the file cannot be found
	private function downloadfile($remoteFile) {
		$localFile = tempnam(sys_get_temp_dir(), 'Vac');
		if (ftp_size($this->ftp,$remoteFile) > 0 && ftp_get($this->ftp,$localFile,$remoteFile,FTP_ASCII)) {
			$content = trim(file_get_contents($localFile));
		} else {
			$content = false;
		}
		unlink($localFile);
		return $content;
	}



	public function __destruct() {
		if (is_resource($this->ftp)) {
			ftp_close($this->ftp);
		}
	}

}
?>
