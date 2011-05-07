<?php

$key = "password";
for ($i = strlen($key); $i < 56; $i++) {
  $key .= '0';
}
print "Key: $key - Len: ".strlen($key)."\n";
$input = "cleartext";
$iv = "1";
for ($i = strlen($iv); $i < 8; $i++) {
  $iv .= '1';
}

$crypt = mcrypt_cbc(MCRYPT_BLOWFISH, $key, $input, MCRYPT_ENCRYPT, $iv);
$crypt_b64 = base64_encode($crypt);
print "Crypt: $crypt_b64\n";

?>
