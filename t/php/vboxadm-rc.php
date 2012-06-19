#!/usr/bin/php5
<?php
class rcube_plugin {
    
}

require_once('contrib/roundcube/plugins/vboxadm/vboxadm.php');

$DPW = new DovecotPW;

$STDERR = fopen('php://stderr', 'w+');
fwrite($STDERR, print_r($argv,TRUE));

if($argv[1] == "verify") {
    // vboxadm-rc.php verify <plaintext password> <crypted password>
    $plainpw = $argv[2];
    $cryptpw = $argv[3];
    if($DPW->verify_pass($plainpw, $cryptpw) === TRUE) {
	echo "ok\n";
	exit(0);
    } else {
	echo "err\n";
	exit(1);
    }
} elseif($argv[1] == "make") {
    // vboxadm-rc.php make <plaintext password> <pw schema> [<salt>]
    $pw = $argv[2];
    $pwscheme = $argv[3];
    $salt = $argv[4];
    echo $DPW->make_pass($pw,$pwscheme,$salt)."\n";
    exit(0);
} elseif($argv[1] == "split") {
    // vboxadm-rc.php split <crypted password>
    $pw = $argv[2];
    $arr = $DPW->split_pass($pw);
    echo $arr[0]."\n"; // pwscheme
    echo $arr[1]."\n"; // pw
    echo $arr[2]."\n"; // salt
    exit(0);
} else {
    echo "Usage error\n";
    exit(1);
}

?>