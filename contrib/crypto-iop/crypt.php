<?php

/*
 * this example needs the following php extensions:
 * - mcrypt
 * - mhash
 * - json
 * - curl
 * TODO turn this class into a proper php library, integrate into roundcube plugin
 */

$config['api']['key'] = '1234567890ab';
$request['user']['username'] = 'admin@domain123.com';
$request['user']['password'] = '123';
$request['mailbox']['update']['fred@domain.com']['IsOnVacation'] = '1';
$ciphertext = encrypt($config['api']['key'],$request,0);

$url = 'http://vboxadm/cgi-bin/vboxapi.pl?rm=api&v=1&p='.$ciphertext;
echo "Requesting URL: <a href='$url'>$url</a><br />\n";
$resp = get_url($url);
echo "<br />\nRaw-Response: ".$resp[0]."<br />\n";
$array = decrypt($config['api']['key'],$resp[0],1);
echo "Decoded Response: <pre>".print_r($array,TRUE)."</pre><br />\n";

function encrypt($raw_key,$request,$debug = 0) {
	$json_string = json_encode($request);
	$key = gen_key($raw_key);
	$iv = gen_iv($raw_key);
	$ciphertext = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$json_string,MCRYPT_ENCRYPT,$iv);
	$b64 = base64_encode($ciphertext);
	$urlenc = urlencode($b64);
	if($debug) {
		print "<h2>encrypt</h2>\n";
		print "<pre>Request:\n";
		print_r($request);
		print "Raw-Key: $raw_key\n";
		print "Key: $key\n";
		print "IV: $iv\n";
		//print "Ciphertext: $ciphertext\n";
		print "Base64: $b64\n";
		print "Urlenc: $urlenc\n";
		print "JSON: $json_string\n";
		print "</pre>";
	}
	return $urlenc;
}

function decrypt($raw_key,$ciphertext,$debug = 0) {
	$key = gen_key($raw_key);
	$iv = gen_iv($raw_key);
	$urldec = urldecode($ciphertext);
	$b64dec = base64_decode($urldec);
	$json_string = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$b64dec,MCRYPT_DECRYPT,$iv);
	$json_string_trimmed = rtrim($json_string);
	$array = json_decode($json_string_trimmed);
	if($debug) {
		print "<h2>decrypt</h2>\n";
		print "<pre>Array:\n";
		print_r($array);
		print "Raw-Key: $raw_key\n";
		print "Key: $key\n";
		print "IV: $iv\n";
		print "Ciphertext: $ciphertext\n";
		print "Base64: $b64dec\n";
		print "Urlenc: $urldec\n";
		print "JSON: $json_string\n";
		print "JSON-rtrim: $json_string_trimmed\n";
		print "</pre>";
	}
	return $array;
}

function gen_key($raw_key) {
	return substr(mhash(MHASH_SHA512,$raw_key),0,56);
}
function gen_iv($raw_key) {
	return substr(mhash(MHASH_SHA512,$raw_key),56);
}

/* http://de.php.net/manual/en/ref.curl.php */
function get_url($url, $redirect_loop = 0, $timeout = 30) {
	$ch = curl_init();
	curl_setopt( $ch, CURLOPT_USERAGENT, "VBoxAdm/Curl-PHP" );
	curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
	curl_setopt( $ch, CURLOPT_URL, $url );
    curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, $timeout );
    curl_setopt( $ch, CURLOPT_TIMEOUT, $timeout );
    curl_setopt( $ch, CURLOPT_MAXREDIRS, 10 );
    $content = curl_exec( $ch );
    $response = curl_getinfo( $ch );
    curl_close ( $ch );
    return array( $content, $response );
}
?>
