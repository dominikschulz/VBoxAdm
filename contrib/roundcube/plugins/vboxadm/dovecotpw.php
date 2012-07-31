<?php
// dovecot compatible password handling
class DovecotPW {
	
	private $config;
	
	private $hashlen = array(
		'smd5'    => 16,
		'ssha'    => 20,
		'ssha256' => 32,
		'ssha512' => 64,
	);
	
	public function setConfig($config) {
		$this->config = $config;
	}

	public function check_password($pwd, $numeric = FALSE)
	{
		if($this->config['vboxadm_allow_weak_password']) {
			$min_pw_length = 4;
			if(isset($this->config['vboxadm_min_weak_password_length'])) {
				$min_pw_length = $this->config['vboxadm_min_weak_password_length'];
			}
			if(strlen($pwd) < $min_pw_length) {
				return FALSE;
			}
			return TRUE;
		}

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
		$len   = 4;
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
		return "{LDAP-MD5}" . base64_encode( hash('md5',$pw, TRUE) );
	}

	public function smd5($pw, $salt) {
		if(strlen($salt) < 1) {
			$salt = $this->make_salt();
		}
		return "{SMD5}" . base64_encode( hash('md5', $pw . $salt, TRUE ) . $salt );
	}

	public function sha($pw) {
		return "{SHA}" . base64_encode( hash('sha1',$pw, TRUE) );
	}
	
	public function cram_md5($pw) {
		$dovecotpw = '/usr/sbin/dovecotpw';
		if(isset($this->config['vboxadm_dovecotpw'])) {
			$dovecotpw = $this->config['vboxadm_dovecotpw'];
		}
		
		$pwscheme = 'CRAM-MD5';
		
		// write_log('vboxadm', "dovecotpw: $dovecotpw");
		
		$spec = array(
			0 => array("pipe", "r"), // childs stdin
			1 => array("pipe", "w")  // childs stdout
		);
		
		$proc = proc_open("$dovecotpw '-s' $pwscheme", $spec, $pipes);
		
		if (!$proc) {
			die("unable to open $dovecotpw");
		} else {
			// send the password twice to dovecotpw
			//
			fwrite($pipes[0], $pw . "\n", 1+strlen($pw)); usleep(500);
			fwrite($pipes[0], $pw . "\n", 1+strlen($pw));
			fclose($pipes[0]);
			
			// read the encrypted password
			//
			$encpw = fread($pipes[1], 512);
			fclose($pipes[1]);
			proc_close($proc);
			
			// strip leading or trailing whitespace.
			// dovecotpw creates a nl at the end
			$encpw = trim($encpw);
			
			// write_log('vboxadm',"cram_md5 - dovecotpw: $dovecotpw, encrypted password: $encpw");
			
			// Test if the supplied scheme matches the generated one
			//
			if ( !preg_match('/^\{'.$pwscheme.'\}/', $encpw)) { 
				die("unable to create encrypted password with $dovecotpw"); 
			}
			
			return $encpw;
		}
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
			case "cram_md5":
			case "cram-md5":
				return $this->cram_md5($pw);
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
		elseif ( preg_match("/^(plain-md5|ldap-md5|md5|sha|sha256|sha512|cram-md5|cram_md5)$/i", $pwscheme) ) {
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
			$pw_str = '';
			foreach ($hash as $h) {
				$pw_str .= pack('C', $h);
			}
			$salt_str = '';
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
