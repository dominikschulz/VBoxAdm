<?php

/*
 * Setuid driver
 *
 * @package	plugins
 * @uses	rcube_plugin
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license     GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
*/
class setuid extends VacationDriver {

    private $webserver_user = null;
    
    public function init() {

        // The setuid executable needs to be executable
        $this->webserver_user = getenv('APACHE_RUN_USER');
        if (empty($this->webserver_user)) {
            $this->webserver_user = getenv("USER");
        }

        if (!is_executable($this->cfg['executable'])) {

            raise_error(array('code' => 601, 'type' => 'php', 'file' => __FILE__,
                        'message' => sprintf("Vacation plugin: %s cannot be executed by user '%s'", $this->cfg['executable'], $this->webserver_user)
                    ), true, true);

        } else {
            // Setuid ?
            $fstat = stat($this->cfg['executable']);

            if (!$fstat['mode'] & 0004000) {
                raise_error(array(
                            'code' => 601, 'type' => 'php', 'file' => __FILE__, 'message' => "Vacation plugin: {$this->cfg['executable']} has no setuid bit"
                        ), true, true);

            }
        }
    }

// Download .forward and .vacation.msg file
    public function _get() {
        $vacArr = array("subject"=>"", "body"=>"", "forward"=>"", "keepcopy"=>true, "enabled"=>false);

        if ($vacation_msg = $this->downloadfile($this->dotforward['message'])) {
            $dot_vacation_msg = explode("\n", $vacation_msg);
            $vacArr['subject'] = str_replace('Subject: ', '', $dot_vacation_msg[1]);
            $vacArr['body'] = join("\n", array_slice($dot_vacation_msg, 2));
        }

        if ($dotForwardFile = $this->downloadfile(".forward")) {
            $d = new DotForward();
            $d->setOption("username", $this->user->data['username']);
            $vacArr = array_merge($vacArr, $d->parse($dotForwardFile));
        }

        // Load aliases using the available identities
        if (!$vacArr['enabled']) $vacArr['aliases'] = $this->vacation_aliases("method");

        return $vacArr;
    }
    
    protected function setVacation() {

        // Remove existing vacation files
        $this->disable();

        $d = new DotForward;
        // Enable auto-reply?
        if ($this->enable) {
            $d->mergeOptions($this->dotforward);

            // Create the .vacation.message file
            $email = $this->identity['email'];
            $full_name = $this->identity['name'];

            if (isset($this->dotforward['set_envelop_sender']) && $this->dotforward['set_envelop_sender']) {
                $d->setOption("envelop_sender", $email);
            }

            if (!empty($full_name)) {
                $vacation_header = sprintf("From: %s <%s>\n", $full_name, $email);
            } else {
                $vacation_header = sprintf("From: %s\n", $email);
            }
            $vacation_header .= sprintf("Subject: %s\n\n", $this->subject);
            $message = $vacation_header . $this->body;
            $this->uploadfile($message, $this->dotforward['message']);

        }
        $d->setOption("username", $this->user->data['username']);
        $d->setOption("keepcopy", $this->keepcopy);
        $d->setOption("forward", $this->forward);

        $d->setOption("aliases", $this->aliases);

        // Do we even need to upload a .forward file?
        if ($this->keepcopy || $this->enable || $this->forward != "") {
            if (!$this->enable) {
                $d->setOption("binary", "");
            }
            $this->uploadfile($d->create(), ".forward");
        }
        return true;
    }
    
    private function disable() {
        /*
		 * Syntax:	squirrelmail_vacation_proxy  server user password action source destination
        */
        $deleteFiles = array($this->dotforward['message'], ".forward", $this->dotforward['database']);
        if (isset($this->dotforward['always_keep_message']) && $this->dotforward['always_keep_message']) {
            unset($deleteFiles[0]);
        }

        // Deleting a file still requires a destination. Silly bug in the setuid binary?
        $dummy = 'foobar';

        foreach ($deleteFiles as $file) {
            $command = sprintf('%s localhost %s "%s" delete %s %s',
                    $this->cfg['executable'],
                    Q($this->user->data['username']),
                    $this->rcmail->decrypt($_SESSION['password']), $file, $dummy);
            exec($command);
        }

        return true;
    }

    /*Removes the aliases
	 *
	 * @param string data
	 * @param string remoteFile
	 * @return boolean
    */
    private function uploadfile($data, $remoteFile) {
        $result = 0;
        $localFile = tempnam(sys_get_temp_dir(), 'Vac');
        file_put_contents($localFile, trim($data));
        $command = sprintf('%s localhost %s "%s" put %s %s',
                $this->cfg['executable'],
                Q($this->user->data['username']),
                $this->rcmail->decrypt($_SESSION['password']), $localFile, $remoteFile);
        exec($command, $resArr, $result);
        unlink($localFile);
        return $result;
    }
    
    private function downloadfile($remoteFile) {
        $result = 0;
        $localFile = tempnam(sys_get_temp_dir(), 'Vac');
        $command = sprintf('%s localhost %s "%s"  get %s %s',
                $this->cfg['executable'],
                Q($this->user->data['username']),
                $this->rcmail->decrypt($_SESSION['password']), $remoteFile, $localFile);


        exec($command, $resArr, $result);

        if ($result == 0) {
            $content = file_get_contents($localFile);
        } else {

            if (!empty($resArr) && ($resArr[0] == 'Invalid user') || ($resArr[0] == 'Invalid webuser')) {
                raise_error(array(
                            'code' => 601, 'type' => 'php', 'file' => __FILE__, 'message' => "Vacation plugin: {$this->cfg['executable']} is not configured for user \"{$this->webserver_user}\".<br/> Check config.mk in plugins/vacation/extra/vacation_binary."
                        ), true, true);
            }

            $content = false;
        }
        unlink($localFile);
        return $content;
    }
}

?>