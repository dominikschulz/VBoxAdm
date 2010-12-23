<?php

// French translation by Bertrand Cherrier

$labels = array();

$labels['accountadmin']  = 'Compte Mail';
$labels['vboxadmaccountadmin']  = 'Administrateur du compte';
$labels['accountadministration']  = 'Administration du compte';

$labels['password']  = 'mot de passe';
$labels['passwordcurrentexplanation']  = 'laisser le champ vide pour conserver le mot de passe actuel.';
$labels['passwordcurrent']  = 'mot de passe actuel';
$labels['passwordnew']  = 'nouveau mot de passe';
$labels['passwordconfirm']  = 'Confirmer nouveau mot de passe';

$labels['spamvirus']  = 'Filtrage Spam';
$labels['spamenabled']  = 'activer le filtre anti-spam';
$labels['spamenabledexplanation']  = 'Vérifier la présence de spams à l\'arrivée de nouveaux messages';
$labels['spamscorerefuse']  = 'Valeur de refus du spam';
$labels['spamscorerefuseexplanation']  = 'le message obtenant cette valeur sera refusé et ne sera pas délivré';
$labels['domaindefault']  = 'réglages par défaut';

$labels['autoresponder']  = 'Répondeur Automatique';
$labels['autoresponderenabled']  = 'Activer le répondeur automatique';
$labels['autorespondersubject']  = 'Sujet du répondeur automatique';
$labels['autorespondermessage']  = 'Message du répondeur automatique';
$labels['autorespondermessageexplanation']  = 'Note: votre signature ne sera pas ajoutée automatiquement';

$labels['parameters']  = 'paramètres';
$labels['messagesize']  = 'Taille maximale du message (MO)';
$labels['messagesizeexplanation']  = 'les messages dépassant cette taille (en mega-octets) seront renvoyés à l\'expéditeur. Default: 0 (Utilise les réglages par défaut du domaine %d, qui sont %m).';
$labels['unlimited']  = 'Illimité';

$messages['autoresponderlong']  = 'Your autoresponder subject exceeds the maximum length. Please make the message shorter and then click the save button again.'; # TODO translate
$messages['autoresponderlongnum']  = 'Number of characters in your message: '; # TODO translate
$messages['autoresponderlongmax']  = 'Maximum number of characters: '; # TODO translate

$labels['introtext']  = 'Ici, vous pouvez administrer vos paramètres de compte. Attention, ces paramètres sont liés au serveur de mail, pas seulement au webmail. De ce fait, les modifications effectuées sur cette page s\'appliqueront également à tout client de messagerie tiers avec lequel vous récupérez vos messages sur votre ordinateur.';
$labels['adminlinktext']  = 'Vous êtes enregistré en tant qu\'administrateur de domaine. Sur cette page, vous pouvez seulement éditer vos propres paramètres. Pour obtenir un accès administrateur pour le domaine entier (ajout/édition de comptes, alias, listes etc.) vous devez vous identifier sur %sVBoxAdm%s.';

$messages['enterallpassfields'] = 'Pour modifier votre mot de passe, vous devez remplir les trois champs.';
$messages['passwordinconsistency'] = 'les mots de passe ne correspondent pas, veuillez réessayer.';

$messages['savesuccess-config'] = 'Configuration sauvegardée avec succès';
$messages['savesuccess-config-saveerror-pass-mismatch'] = 'Configuration sauvegardée avec succès, mais impossible de modifier le mot de passe (ancien mot de passe incorrect)';

$messages['saveerror-internalerror'] = 'Erreur pendant la sauvegarde';
$messages['saveerror-config-database'] = 'La configuration n\'a pas été sauvée à cause d\'une erreur sur la base';

$messages['savesuccess-pass'] = 'Mot de passe modifié avec succès';
$messages['saveerror-pass-mismatch'] = 'Impossible de modifier le mot de passe (ancien mot de passe incorrect)';
$messages['saveerror-pass-database'] = 'Nouveau mot de passe non définit (erreur sur la base)';
$messages['saveerror-pass-norows'] = 'Impossible de modifier le mot de passe (aucune base de données trouvée)';
$messages['saveerror-pass-too-weak'] = 'New password was not set (new password is too weak)'; # TODO translate

?>