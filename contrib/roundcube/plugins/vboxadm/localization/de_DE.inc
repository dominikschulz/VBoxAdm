<?php

$labels = array();

$labels['accountadmin']  = 'Postfach verwalten';
$labels['vboxadmaccountadmin']  = 'Postfach verwalten';
$labels['accountadministration']  = 'Postfach verwalten';

$labels['password']  = 'Passwort';
$labels['passwordchange']  = 'Passwort ändern';
$labels['passwordexplanation'] = 'Geben Sie hier ihr aktuelles Passwort ein um Ihre Änderungen zu bestätigen.';
$labels['passwordcurrentexplanation']  = 'Lassen Sie die Felder leer um das alte Passwort zu übernehmen.';
$labels['passwordcurrent']  = 'Aktuelles Passwort';
$labels['passwordnew']  = 'Neues Passwort';
$labels['passwordconfirm']  = 'Neues Passwort bestätigen';

$labels['spam']  = 'Spam Filter';
$labels['spamenabled']  = 'Spam Filter aktivieren';
$labels['spamenabledexplanation']  = 'Alle eingehenden Nachrichten auf Spam überprüfen';
$labels['spamscorerefuse']  = 'Spam block Wert';
$labels['spamscorerefuseformat']  = 'Kill-Score muss eine Zahl kleiner als 1000 mit höchstens zwei Nachkommastellen sein.';
$labels['spamscorerefuseexplanation']  = 'Der Wert ab dem möglicher Spam nicht akzeptiert wird. Der Absender erhält eine Fehlermeldung.';
$labels['domaindefault']  = 'Domain Vorgabe';

$labels['autoresponder']  = 'Abwesenheitsnachricht';
$labels['autoresponderenabled']  = 'Abwesenheitsnachricht aktivieren';
$labels['autoresponderstartdate']  = 'Abwesend ab';
$labels['autoresponderenddate']  = 'Abwesend bis';
$labels['autoresponderdateformat']  = 'Datumsformat: dd.mm.yyyy oder leeres Feld für keine Begrenzung.';
$labels['autorespondersubject'] = 'Betreff der Abwesenheitsnachricht';
$labels['autorespondermessage']  = 'Text der Abwesenheitsnachricht';
$labels['autorespondersubjectexplanation'] = 'Die Betreff Zeile Ihrer Nachricht';
$labels['autorespondermessageexplanation']  = 'Achtung: Ihre Signatur wird nicht automatisch angehängt.';

$labels['parameters']  = 'Parameter';
$labels['messagesize']  = 'Maximale Nachrichten-Größe (MB)';
$labels['messagesizeformat']  = 'Maximale Nachrichten-Größe muss eine ganze Zahl sein.';
$labels['messagesizeexplanation']  = 'Nachrichten größer als dieser Wert (in Megabyte) werden abgewiesen.';
$labels['unlimited']  = 'unbegrenzt';

$labels['aliases']  = 'Weiterleitungen';
$labels['aliasesexplanation']  = 'Nachrichten, die an ihr Mailkonto adressiert sind, werden zusätzlich an die folgenden Adressen       weitergeleitet.';
$labels['aliasesenabled']  = 'Weiterleitungen aktiv';
$labels['aliasaddresses']  = 'Weiterleitung an folgende Adressen';
$labels['emailformat']  = 'Emailadressen als kommagetrennte Liste angeben.';

$messages['autoresponderlong']  = 'Your autoresponder subject exceeds the maximum length. Please make the message shorter and then click the save button again.';
$messages['autoresponderlongnum']  = 'Number of characters in your message: ';
$messages['autoresponderlongmax']  = 'Maximum number of characters: ';

$labels['introtext']  = 'Hier können Sie Ihr Postfach verwalten. Bitte beachten Sie, dass sich diese Einstellungen nicht nur auf die Webmail Schnittstelle auswirken sondern auf jegliche Mail-Clients die Sie möglicherweise nutzen.';
$labels['adminlinktext']  = 'You are registered as a domain administrator. On this page you can only edit your own settings. To get admin access for the whole domain (add/edit accounts, aliases, lists etc.) you will need to log in to %sVBoxAdm%s.';

$messages['enterallpassfields'] = 'To change the password, you need to enter all three password fields.';
$messages['passwordinconsistency'] = 'Passwords do not match, please try again.';

$messages['saveerror-config-database'] = 'Die Konfiguration konnte wegen eines Datenbankfehlers nicht gespeichert werden';
$messages['saveerror-internalerror'] = 'Interner Fehler beim speichern der Konfiguration';
$messages['saveerror-pass-database'] = 'Das neue Passwort konnte nicht gespeichert werden (Datenbankfehler)';
$messages['saveerror-pass-mismatch'] = 'Das neue Passwort wurde nicht gespeichert, da das aktuelle Passwort nicht stimmt';
$messages['saveerror-pass-norows'] = 'Das neue Passwort konnte nicht gespeichert werden (Datenbankfehler: keine Eintraege gefunden)';
$messages['saveerror-pass-too-weak'] = 'Das neue Passwort konnte nicht gespeichert werden (Das neue Passwort ist zu einfach)';

$messages['savesuccess-config'] = 'Konfiguration erfolgreich gespeichert.';
$messages['savesuccess-config-saveerror-pass-database'] = 'Konfiguration erfolgreich gespeichert, aber Passwort nicht geändert (Datenbankfehler)';
$messages['savesuccess-config-saveerror-pass-mismatch'] = 'Konfiguration erfolgreich gespeichert, aber Passwort nicht geändert (altes Passwort falsch)';
$messages['savesuccess-config-saveerror-pass-norows'] = 'Konfiguration erfolgreich gespeichert, aber Passwort nicht geändert (keine passenden Einträge in DB)';
$messages['savesuccess-config-saveerror-pass-too-weak'] = 'Konfiguration erfolgreich gespeichert, aber Passwort nicht geändert (neues Passwort zu unsicher)';
$messages['savesuccess-config-saveerror-verify-mismatch'] = 'Konfiguration erfolgreich gespeichert, aber Passwort nicht geändert (Passwörter stimmen nicht überein)';

$messages['savesuccess-pass'] = 'Das neue Passwort wurde erfolgreiche gespeichert';
?>
