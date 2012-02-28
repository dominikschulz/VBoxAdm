<?php

// english

$labels = array();

$labels['accountadmin']  = 'Account Admin';
$labels['vboxadmaccountadmin']  = 'Account Admin';
$labels['accountadministration']  = 'Account Administration';

$labels['password']  = 'Password';
$labels['passwordcurrentexplanation']  = 'Leave blank to keep password unchanged.';
$labels['passwordcurrent']  = 'Current password';
$labels['passwordnew']  = 'New password';
$labels['passwordconfirm']  = 'Confirm new password';

$labels['spam']  = 'Spam filtering';
$labels['spamenabled']  = 'Enable Spam filter';
$labels['spamenabledexplanation']  = 'Scan all incoming mail for Spam';
$labels['spamscorerefuse']  = 'Spam Block score';
$labels['spamscorerefuseexplanation']  = 'The score at which to block potential spam mail and not accept for delivery';
$labels['domaindefault']  = 'Domain default';

$labels['autoresponder']  = 'Autoresponder';
$labels['autoresponderenabled']  = 'Enable autoresponder';
$labels['autorespondersubject'] = 'Autoresponder Subject';
$labels['autorespondermessage']  = 'Autoresponder message';
$labels['autorespondersubjectexplanation'] = 'The Subject line of your message';
$labels['autorespondermessageexplanation']  = 'Note: Your signature will not be automatically added';

$labels['parameters']  = 'Parameters';
$labels['messagesize']  = 'Maximum message size (MB)';
$labels['messagesizeexplanation']  = 'Messages larger than this size (in Megabytes) will be returned to sender.';
$labels['unlimited']  = 'unlimited';

$messages['autoresponderlong']  = 'Your autoresponder subject exceeds the maximum length. Please make the message shorter and then click the save button again.';
$messages['autoresponderlongnum']  = 'Number of characters in your message: ';
$messages['autoresponderlongmax']  = 'Maximum number of characters: ';

$labels['introtext']  = 'Here you can administrate your account settings. Remember that these settings are tied to the mail server itself, not only the webmail. Changes on this page will therefore also affect third-party mail clients you may use.';
$labels['adminlinktext']  = 'You are registered as a domain administrator. On this page you can only edit your own settings. To get admin access for the whole domain (add/edit accounts, aliases, lists etc.) you will need to log in to %sVBoxAdm%s.';

$messages['enterallpassfields'] = 'To change the password, you need to enter all three password fields.';
$messages['passwordinconsistency'] = 'Passwords do not match, please try again.';

$messages['saveerror-config-database'] = 'Configuration was not saved due to database error';
$messages['saveerror-internalerror'] = 'Error saving configuration';
$messages['saveerror-pass-database'] = 'New password was not set (database error)';
$messages['saveerror-pass-mismatch'] = 'New password was not set (old passord mismatch)';
$messages['saveerror-pass-norows'] = 'New password was not set (no database rows affected)';
$messages['saveerror-pass-too-weak'] = 'New password was not set (new password is too weak)';

$messages['savesuccess-config'] = 'Successfully saved configuration';
$messages['savesuccess-config-saveerror-pass-database'] = 'Successfully saved configuration, but new password was not set (database error)';
$messages['savesuccess-config-saveerror-pass-mismatch'] = 'Successfully saved configuration, but new password was not set (old password mismatch)';
$messages['savesuccess-config-saveerror-pass-norows'] = 'Successfully saved configuration, but new password was not set (no database rows affected)';
$messages['savesuccess-config-saveerror-pass-too-weak'] = 'Successfully saved configuration, but new password was not set (new password is too weak)';
$messages['savesuccess-config-saveerror-verify-mismatch'] = 'Successfully saved configuration, but new password was not set (passwords do not match)';
$messages['savesuccess-pass'] = 'New password was set successfully';
?>