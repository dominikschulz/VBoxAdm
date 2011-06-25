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

// Use the either MD5, SHA, SHA256, SMD5, SSHA or SSHA256
$vboxadm_config['vboxadm_cryptscheme'] = 'ssha256';

$vboxadm_config['vboxadm_vacation_maxlength'] = 25500;

// Show a link to vboxadm if the user is registered as domain admin
$vboxadm_config['show_admin_link'] = true;

// Let the user configure the aliases forwarding for his mail address
$vboxadm_config['user_managed_aliases'] = false;

?>
