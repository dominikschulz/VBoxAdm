<?php

/*
 vboxadm options
 default config last updated in version 2009-11-12
 */

$vboxadm_config = array();

// PEAR database DSN for performing the query
// change this to your vboxadm database info, e.g.
//    mysql://vboxadm:password@localhost/vboxadm
$vboxadm_config['db_dsn'] = 'mysql://vboxadm_user:vboxadm@localhost/vboxadm';

// Use the either MD5, SHA, SHA256, SMD5, SSHA, SSHA256 or CRAM-MD5
$vboxadm_config['vboxadm_cryptscheme'] = 'ssha256';

// for CRAM-MD5 we have to use external dovecotpw
$vboxadm_config['vboxadm_dovecotpw'] = '/usr/sbin/dovecotpw';

// allow weak passwords
$vboxadm_config['vboxadm_allow_weak_password'] = false;

// minimun weak password length
$vboxadm_config['vboxadm_min_weak_password_length'] = 6;

$vboxadm_config['vboxadm_vacation_maxlength'] = 25500;

// Show a link to vboxadm if the user is registered as domain admin
$vboxadm_config['show_admin_link'] = true;

$vboxadm_config['api_key'] = '1234567890ab';
$vboxadm_config['api_url'] = 'http://vboxadm/cgi-bin/vboxapi.pl';

?>
