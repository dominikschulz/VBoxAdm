<?php

/*
 * this example needs the following php extensions:
 * - mcrypt
 * - mhash
 * - json
 * - curl
 */

$config['api']['key'] = 'key';

$request['mailbox']['update']['user@domain123.com']['password'] = 'password123';
$ciphertext = encrypt($config['api']['key'],$request);

// TODO send request to API endpoint via curl

function encrypt($raw_key,$request) {
	return mcrypt_cbc(MCRYPT_BLOWFISH,gen_key($raw_key),json_encode($request),MCRYPT_ENCRYPT,gen_iv($raw_key));
}

function decrypt($raw_key,$ciphertext) {
	return json_decode(mcrypt_cbc(MCRYPT_BLOWFISH,gen_key($raw_key),$ciphertext,MCRYPT_DECRYPT,gen_iv($raw_key)));
}

function gen_key($raw_key) {
	return substr(mhash(MHASH_SHA512,$raw_key),0,56);
}
function gen_iv($raw_key) {
	return substr(mhash(MHASH_SHA512,$raw_key),56);
}
?>
