<?php

$labels = array();

$labels['accountadmin']  = 'Account Admin';
$labels['veximaccountadmin']  = 'Account Admin';
$labels['accountadministration']  = 'Account Administration';

$labels['password']  = 'Password';
$labels['passwordcurrentexplanation']  = 'Leave blank to keep password unchanged.';
$labels['passwordcurrent']  = 'Current password';
$labels['passwordnew']  = 'New password';
$labels['passwordconfirm']  = 'Confirm new password';

$labels['spamvirus']  = 'Spam/Virus filtering';
$labels['virusenabled']  = 'Enable virus filter';
$labels['virusenabledexplanation']  = 'Delete all virus infected mail';
$labels['spamenabled']  = 'Enable spam filter';
$labels['spamenabledexplanation']  = 'Scan all incoming mail for spam';
$labels['spamscoretag']  = 'Spam tag score';
$labels['spamscoretagexplanation']  = 'The score at which to tag potential spam but still deliver';
$labels['spamscorerefuse']  = 'Spam refuse score';
$labels['spamscorerefuseexplanation']  = 'The score at which to refuse potential spam mail and not deliver';
$labels['spammove']  = 'Move tagged spam to subfolder';
$labels['domaindefault']  = 'Domain default';

// %italicstart and %italicend will be replaced by <i> and </i>
$labels['spammoveexplanation_part1']  = 'Tagged spam will automatically be put in IMAP folders %italicstartFilter-Spam-Low%italicend and %italicstartFilter-Spam-High%italicend, depending on spam probability.';
$labels['spammoveexplanation_part2']  = 'Mail older than 90 or 30 days, respectively, will be auto-deleted.';
$labels['spammoveexplanation_part3']  = 'If this setting is enabled when using POP insted of IMAP, no spam will be sent to your mail client at all.';
$labels['spamtip']  = 'Tip: You can make the folder %italicstartLearnAsSpam%italicend and put spam mail that were not catched by the filter in it. (%italicstartLearnAsHam%italicend for the opposite.) Every midnight, the spam filter will parse these folders and learn by your examples, and then delete them.';

$labels['autoresponder']  = 'Autoresponder';
$labels['autoresponderenabled']  = 'Enable autoresponder';
$labels['autorespondermessage']  = 'Autoresponder message';
$labels['autorespondermessageexplanation']  = 'Note: Your signature will not be automatically added';

$labels['forwarding']  = 'Forwarding';
$labels['forwardingenabled']  = 'Enable forwarding';
$labels['forwardingaddress']  = 'Forward mail to';
$labels['forwardinglocal']  = 'Store forwarded mail locally';

$labels['parameters']  = 'Parameters';
$labels['messagesize']  = 'Maximum message size (kb)';
$labels['messagesizeexplanation']  = 'Messages larger than this size (in kilobytes) will be returned to sender. Default: 0 (use domain setting for %d, which is %m).';
$labels['unlimited']  = 'unlimited';

$labels['blockbyheader']  = 'Block by header';
$labels['blockbyheaderexplanation']  = 'The rules below will be checked against the mail header fields, and mail that matches will be automatically deleted. Note that the match must be excact, not partial.';
$labels['addrule']  = 'Add block rule';
$labels['deleteall']  = 'Delete all';
$labels['field']  = 'Header Field';
$labels['value']  = 'Value';
$labels['headerfrom']  = 'From';
$labels['headerto']  = 'To';
$labels['headersubject']  = 'Subject';
$labels['headerxmailer']  = 'X-Mailer';
$labels['noaddressrules']  = 'No block rules';

$messages['headerblockdelete']  = 'Are you sure you want to delete this rule?';
$messages['headerblockdeleteall']  = 'Are you sure you want to delete all block rules?';
$messages['headerblockexists']  = 'This rule already exists';
$messages['headerblockentervalue']  = 'You have to enter a value to the rule';

$messages['autoresponderlong']  = 'Your autoresponder message exceeds the maximum length. Please make the message shorter and then click the save button again.';
$messages['autoresponderlongnum']  = 'Number of characters in your message: ';
$messages['autoresponderlongmax']  = 'Maximum number of characters: ';

$labels['introtext']  = 'Here you can administrate your account settings. Remember that these settings are tied to the mail server itself, not only the webmail. Changes on this page will therefore also affect third-party mail clients you may use.';
$labels['adminlinktext']  = 'You are registered as a domain administrator. On this page you can only edit your own settings. To get admin access for the whole domain (add/edit accounts, aliases, lists etc.) you will need to log in to %sVexim%s.';

$messages['enterallpassfields'] = 'To change the password, you need to enter all three password fields.';
$messages['passwordinconsistency'] = 'Passwords do not match, please try again.';

$messages['savesuccess-config'] = 'Successfully saved configuration';
$messages['savesuccess-config-saveerror-pass-mismatch'] = 'Successfully saved configuration, but new password was not set (old password mismatch)';

$messages['saveerror-internalerror'] = 'Error saving configuration';
$messages['saveerror-config-database'] = 'Configuration was not saved due to database error';

$messages['savesuccess-pass'] = 'New password was set successfully';
$messages['saveerror-pass-mismatch'] = 'New password was not set (old passord mismatch)';
$messages['saveerror-pass-database'] = 'New password was not set (database error)';
$messages['saveerror-pass-norows'] = 'New password was not set (no database rows affected)';


?>