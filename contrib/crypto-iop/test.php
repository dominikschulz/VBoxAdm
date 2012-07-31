<?php

require_once('../roundcube/plugins/vboxadm/vboxapi.php');

$config = array();

$config['api_key'] = '1234567890ab';
$config['api_url'] = 'http://vboxadm/cgi-bin/vboxapi.pl';

$API = new VBoxAPI;
$API->setConfig($config);
$API->setDebug(1);

$API->get_user_config('admin@domain123.com','1');
