// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mergelings';

  @override
  String get tagline =>
      'Fusionnez, collectionnez et remplissez cinq prairies magiques.';

  @override
  String get navMeadow => 'Prairie';

  @override
  String get navCollection => 'Collection';

  @override
  String get navShop => 'Boutique';

  @override
  String get navMeadows => 'Prairies';

  @override
  String get navSettings => 'Réglages';

  @override
  String get hearts => 'Cœurs';

  @override
  String get gems => 'Gemmes';

  @override
  String perMinute(String amount) {
    return '$amount/min';
  }

  @override
  String get basket => 'Panier';

  @override
  String get hintDragToMerge =>
      'Faites glisser deux amis identiques pour les fusionner !';

  @override
  String get hintTapBasket =>
      'Le panier se remplit tout seul — touchez-le pour aller plus vite.';

  @override
  String get hintBoardFull =>
      'Votre prairie est pleine : fusionnez ou libérez quelqu\'un d\'abord.';

  @override
  String get newDiscovery => 'Nouvel ami découvert !';

  @override
  String discoveryReward(int gems) {
    return '+$gems gemmes';
  }

  @override
  String tierLabel(int tier) {
    return 'Palier $tier';
  }

  @override
  String boardTileLabel(String name, int tier) {
    return '$name, palier $tier';
  }

  @override
  String get boardMysteryLabel => 'Panier mystère, pas encore ouvert';

  @override
  String get sell => 'Libérer';

  @override
  String sellFor(String amount) {
    return 'Libérer pour $amount';
  }

  @override
  String get sellTitle => 'Renvoyer cet ami chez lui ?';

  @override
  String sellBody(String amount) {
    return 'Vous recevrez $amount cœurs.';
  }

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopFriends => 'Amis';

  @override
  String get shopBoosts => 'Bonus';

  @override
  String get buy => 'Acheter';

  @override
  String get notEnoughHearts => 'Pas assez de cœurs.';

  @override
  String get notEnoughGems => 'Pas assez de gemmes.';

  @override
  String get expandMeadow => 'Agrandir la prairie';

  @override
  String get expandMeadowBody => 'Débloquez une rangée de plus.';

  @override
  String get meadowFullyExpanded => 'Agrandie au maximum';

  @override
  String get shopAccessories => 'Accessoires';

  @override
  String get accessoryTitle => 'Accessoire';

  @override
  String get accessoryNone => 'Aucun';

  @override
  String get accessoryOwned => 'Acheté';

  @override
  String get accessoryOwnedBody =>
      'Mettez-le à un ami depuis sa fiche de collection.';

  @override
  String accessoryLocked(int count) {
    return 'Découvrez $count amis pour le débloquer.';
  }

  @override
  String accessoryBought(String name) {
    return '$name rejoint votre garde-robe !';
  }

  @override
  String get accessoryEmptyHint =>
      'Achetez des accessoires dans la boutique pour habiller vos amis.';

  @override
  String get accessoryFlowerCrown => 'Couronne de fleurs';

  @override
  String get accessoryBowTie => 'Nœud papillon';

  @override
  String get accessoryPartyHat => 'Chapeau de fête';

  @override
  String get accessoryScarf => 'Écharpe douillette';

  @override
  String get accessoryTopHat => 'Haut-de-forme';

  @override
  String get accessorySunglasses => 'Lunettes de soleil';

  @override
  String get accessoryCape => 'Cape de héros';

  @override
  String get accessoryHeadphones => 'Casque audio';

  @override
  String get accessoryCrown => 'Couronne dorée';

  @override
  String get boostTitle => 'Cœurs doublés';

  @override
  String boostBody(int minutes) {
    return 'Double tous les cœurs pendant $minutes minutes.';
  }

  @override
  String boostActive(String time) {
    return 'Cœurs doublés — $time restantes';
  }

  @override
  String get basketBoostTitle => 'Panier rapide';

  @override
  String basketBoostBody(int times, int minutes) {
    return 'Le panier se remplit $times× plus vite pendant $minutes minutes.';
  }

  @override
  String basketBoostActive(String time) {
    return 'Panier rapide — $time restantes';
  }

  @override
  String get giftTitle => 'Ami gratuit';

  @override
  String get giftBody => 'Regardez une courte vidéo pour un ami gratuit.';

  @override
  String get mysteryTitle => 'Un panier mystère !';

  @override
  String get mysteryBody =>
      'Quelque chose remue à l\'intérieur. Choisissez comment l\'ouvrir.';

  @override
  String get mysteryOpenNow => 'Ouvrir maintenant';

  @override
  String get mysteryLater => 'Le laisser pour l\'instant';

  @override
  String mysteryTierRange(int min, int max) {
    return 'Un ami de palier $min–$max';
  }

  @override
  String mysteryGranted(String name) {
    return '$name a bondi hors du panier !';
  }

  @override
  String get watchAd => 'Voir la vidéo';

  @override
  String get adNotReady =>
      'Aucune vidéo disponible pour le moment. Réessayez bientôt.';

  @override
  String get adRewardGranted => 'Récompense reçue !';

  @override
  String get welcomeBackTitle => 'Content de vous revoir !';

  @override
  String welcomeBackBody(String amount) {
    return 'Votre prairie a gagné $amount cœurs pendant votre absence.';
  }

  @override
  String get collect => 'Récupérer';

  @override
  String get collectDouble => 'Récupérer le double';

  @override
  String get collectionTitle => 'Collection';

  @override
  String collectionProgress(int found, int total) {
    return '$found sur $total découverts';
  }

  @override
  String get undiscovered => 'Pas encore découvert';

  @override
  String get meadowsTitle => 'Prairies';

  @override
  String meadowLocked(int tier, String meadow) {
    return 'Découvrez le palier $tier dans $meadow pour débloquer.';
  }

  @override
  String get meadowUnlocked => 'Débloquée !';

  @override
  String get enterMeadow => 'Entrer';

  @override
  String get worldDay => 'Prairie du Jour';

  @override
  String get worldNight => 'Prairie de Nuit';

  @override
  String get worldWater => 'Prairie Marine';

  @override
  String get worldMythical => 'Prairie Mythique';

  @override
  String get worldPrehistoric => 'Prairie des Dinos';

  @override
  String get worldDayDesc => 'Herbe ensoleillée et amis des bois.';

  @override
  String get worldNightDesc =>
      'Bestioles au clair de lune et voyageurs étoilés.';

  @override
  String get worldWaterDesc => 'Du récif jusqu\'au grand bleu.';

  @override
  String get worldMythicalDesc => 'Folklore, légendes et dragons anciens.';

  @override
  String get worldPrehistoricDesc => 'Géants fossiles d\'un monde perdu.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSound => 'Effets sonores';

  @override
  String get settingsMusic => 'Musique';

  @override
  String get settingsHaptics => 'Vibrations';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsAdPrivacy => 'Confidentialité des publicités';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get settingsRate => 'Noter Mergelings';

  @override
  String get settingsReset => 'Réinitialiser la progression';

  @override
  String get settingsResetBody =>
      'Cela supprime définitivement chaque prairie, ami et cœur. C\'est irréversible.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsSystemLanguage => 'Langue du système';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get loading => 'Chargement…';
}
