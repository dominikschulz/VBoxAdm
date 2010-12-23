<?php

// norwegian

$labels = array();

$labels['accountadmin']  = 'Kontoadmin';
$labels['vboxadmaccountadmin']  = 'Kontoadministrasjon';
$labels['accountadministration']  = 'Kontoadministrasjon';

$labels['password']  = 'Passord';
$labels['passwordcurrentexplanation']  = 'La feltene stå tomme hvis du ikke ønsker å endre passordet.';
$labels['passwordcurrent']  = 'Nåværende passord';
$labels['passwordnew']  = 'Nytt passord';
$labels['passwordconfirm']  = 'Nytt passord';

$labels['spamvirus']  = 'Spamfilter';
$labels['spamenabled']  = 'Aktiver spamfilter';
$labels['spamenabledexplanation']  = 'Sjekk all inngående e-post for spam';
$labels['spamscorerefuse']  = 'Spamverdi for sletting';
$labels['spamscorerefuseexplanation']  = 'Meldinger med denne spamverdien eller høyere vil bli automatisk slettet';
$labels['domaindefault']  = 'Standardinnstilling';

$labels['autoresponder']  = 'Autosvar';
$labels['autoresponderenabled']  = 'Aktiver autosvar';
$labels['autorespondersubject'] = 'Autoresponder Subject'; # TODO translate
$labels['autorespondermessage']  = 'Autosvarmelding';
$labels['autorespondersubjectexplanation'] = 'The Subject line of your message';
$labels['autorespondermessageexplanation']  = 'Merk: Din signatur vil ikke bli lagt til automatisk';

$labels['parameters']  = 'Parametere';
$labels['messagesize']  = 'Maksimal størrelse (kb)';
$labels['messagesizeexplanation']  = 'Meldinger større enn dette (i kilobytes) vil bli returnert til avsender. Standardinnstilling: 0 (bruk domenetinnstillingen til %d, som er %m).';
$labels['unlimited']  = 'ubegrenset';

$messages['autoresponderlong']  = 'Din autosvarmelding overstiger maksimal tillatt lengde. Vennligst forkort teksten og trykk deretter lagre på nytt.';
$messages['autoresponderlongnum']  = 'Antall tegn i din melding: ';
$messages['autoresponderlongmax']  = 'Maksimalt antall tegn: ';

$labels['introtext']  = 'Her kan du administrere dine kontoinnstillinger. Husk at disse innstillingene er knyttet til mailserveren, ikke bare webmailen. Endringer du gjør på denne siden vil derfor også påvirke andre mailprogrammer du bruker for denne adressen.';
$labels['adminlinktext']  = 'Du er oppført som domeneadministrator. Fra denne siden kan du kun endre dine egne kontoinnstillinger, du kan ikke legge til/endre konti, videresendinger, lister osv. For å få slik administratortilgang må du logge på med %sVBoxAdm%s.';

$messages['enterallpassfields'] = 'Du må fylle inn alle tre passordfeltene hvis du vil endre passordet.';
$messages['passwordinconsistency'] = 'Passordene stemmer ikke over ens, vennligst prøv igjen.';

$messages['savesuccess-config'] = 'Kontoinnstillingene er lagret';
$messages['savesuccess-config-saveerror-pass-mismatch'] = 'Kontoinnstillingene er lagret, men passordet er ikke endret (gammelt passord skrevet inn feil)';

$messages['saveerror-internalerror'] = 'Feil under lagring av kontoinnstillinger';
$messages['saveerror-config-database'] = 'Databasefeil førte til at kontoinnstillingene ikke ble lagret';

$messages['savesuccess-pass'] = 'Passordet er endret';
$messages['saveerror-pass-mismatch'] = 'Passordet er ikke endret (gammelt passord skrevet inn feil)';
$messages['saveerror-pass-database'] = 'Passordet er ikke endret (databasefeil)';
$messages['saveerror-pass-norows'] = 'Passordet er ikke endret (ingen databaserader funnet)';
$messages['saveerror-pass-too-weak'] = 'New password was not set (new password is too weak)'; # TODO translate

?>