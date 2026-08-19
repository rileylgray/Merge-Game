// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mergelings';

  @override
  String get tagline => 'Kombiniere, sammle und fülle fünf magische Wiesen.';

  @override
  String get navMeadow => 'Wiese';

  @override
  String get navCollection => 'Sammlung';

  @override
  String get navShop => 'Shop';

  @override
  String get navMeadows => 'Wiesen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get hearts => 'Herzen';

  @override
  String get gems => 'Edelsteine';

  @override
  String perMinute(String amount) {
    return '$amount/Min.';
  }

  @override
  String get basket => 'Korb';

  @override
  String get hintDragToMerge =>
      'Ziehe zwei gleiche Freunde zusammen, um sie zu kombinieren!';

  @override
  String get hintTapBasket =>
      'Der Korb füllt sich von selbst — tippe darauf, um es zu beschleunigen.';

  @override
  String get hintBoardFull =>
      'Deine Wiese ist voll — kombiniere oder verabschiede erst jemanden.';

  @override
  String get newDiscovery => 'Neuer Freund entdeckt!';

  @override
  String discoveryReward(int gems) {
    return '+$gems Edelsteine';
  }

  @override
  String tierLabel(int tier) {
    return 'Stufe $tier';
  }

  @override
  String boardTileLabel(String name, int tier) {
    return '$name, Stufe $tier';
  }

  @override
  String get boardMysteryLabel => 'Überraschungskorb, noch ungeöffnet';

  @override
  String get sell => 'Verabschieden';

  @override
  String sellFor(String amount) {
    return 'Für $amount verabschieden';
  }

  @override
  String get sellTitle => 'Diesen Freund nach Hause schicken?';

  @override
  String sellBody(String amount) {
    return 'Du erhältst $amount Herzen.';
  }

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopFriends => 'Freunde';

  @override
  String get shopBoosts => 'Boosts';

  @override
  String get buy => 'Kaufen';

  @override
  String get notEnoughHearts => 'Nicht genug Herzen.';

  @override
  String get notEnoughGems => 'Nicht genug Edelsteine.';

  @override
  String get expandMeadow => 'Wiese erweitern';

  @override
  String get expandMeadowBody => 'Schalte eine weitere Reihe frei.';

  @override
  String get meadowFullyExpanded => 'Voll ausgebaut';

  @override
  String get shopAccessories => 'Accessoires';

  @override
  String get accessoryTitle => 'Accessoire';

  @override
  String get accessoryNone => 'Keins';

  @override
  String get accessoryOwned => 'Gekauft';

  @override
  String get accessoryOwnedBody =>
      'Setz es einem Freund über seine Sammelkarte auf.';

  @override
  String accessoryLocked(int count) {
    return 'Entdecke $count Freunde, um es freizuschalten.';
  }

  @override
  String accessoryBought(String name) {
    return '$name ist jetzt in deiner Garderobe!';
  }

  @override
  String get accessoryEmptyHint =>
      'Kaufe Accessoires im Shop, um deine Freunde zu verkleiden.';

  @override
  String get accessoryFlowerCrown => 'Blumenkranz';

  @override
  String get accessoryBowTie => 'Fliege';

  @override
  String get accessoryPartyHat => 'Partyhut';

  @override
  String get accessoryScarf => 'Kuschelschal';

  @override
  String get accessoryTopHat => 'Zylinder';

  @override
  String get accessorySunglasses => 'Sonnenbrille';

  @override
  String get accessoryCape => 'Heldenumhang';

  @override
  String get accessoryHeadphones => 'Kopfhörer';

  @override
  String get accessoryCrown => 'Goldene Krone';

  @override
  String get boostTitle => 'Doppelte Herzen';

  @override
  String boostBody(int minutes) {
    return 'Verdoppelt alle Herzen für $minutes Minuten.';
  }

  @override
  String boostActive(String time) {
    return 'Doppelte Herzen — noch $time';
  }

  @override
  String get basketBoostTitle => 'Schneller Korb';

  @override
  String basketBoostBody(int times, int minutes) {
    return 'Der Korb füllt sich $minutes Minuten lang $times× schneller.';
  }

  @override
  String basketBoostActive(String time) {
    return 'Schneller Korb — noch $time';
  }

  @override
  String get giftTitle => 'Gratis-Freund';

  @override
  String get giftBody =>
      'Sieh dir ein kurzes Video an und erhalte einen Freund gratis.';

  @override
  String get mysteryTitle => 'Ein Überraschungskorb!';

  @override
  String get mysteryBody => 'Darin raschelt etwas. Wähle, wie du ihn öffnest.';

  @override
  String get mysteryOpenNow => 'Jetzt öffnen';

  @override
  String get mysteryLater => 'Erst mal liegen lassen';

  @override
  String mysteryTierRange(int min, int max) {
    return 'Ein Freund der Stufen $min–$max';
  }

  @override
  String mysteryGranted(String name) {
    return '$name ist aus dem Korb gehüpft!';
  }

  @override
  String get watchAd => 'Video ansehen';

  @override
  String get adNotReady =>
      'Gerade kein Video verfügbar. Versuch es gleich noch einmal.';

  @override
  String get adRewardGranted => 'Belohnung erhalten!';

  @override
  String get welcomeBackTitle => 'Willkommen zurück!';

  @override
  String welcomeBackBody(String amount) {
    return 'Deine Wiese hat $amount Herzen verdient, während du weg warst.';
  }

  @override
  String get collect => 'Einsammeln';

  @override
  String get collectDouble => 'Doppelt einsammeln';

  @override
  String get collectionTitle => 'Sammlung';

  @override
  String collectionProgress(int found, int total) {
    return '$found von $total entdeckt';
  }

  @override
  String get undiscovered => 'Noch nicht entdeckt';

  @override
  String get meadowsTitle => 'Wiesen';

  @override
  String meadowLocked(int tier, String meadow) {
    return 'Entdecke Stufe $tier in $meadow, um freizuschalten.';
  }

  @override
  String get meadowUnlocked => 'Freigeschaltet!';

  @override
  String get enterMeadow => 'Betreten';

  @override
  String get worldDay => 'Tageswiese';

  @override
  String get worldNight => 'Nachtwiese';

  @override
  String get worldWater => 'Meereswiese';

  @override
  String get worldMythical => 'Mythenwiese';

  @override
  String get worldPrehistoric => 'Dinowiese';

  @override
  String get worldDayDesc => 'Sonnenwarmes Gras und Waldfreunde.';

  @override
  String get worldNightDesc => 'Mondbeschienene Tiere und Sternenwanderer.';

  @override
  String get worldWaterDesc => 'Vom flachen Riff bis in die tiefe Blaue.';

  @override
  String get worldMythicalDesc => 'Sagen, Legenden und uralte Drachen.';

  @override
  String get worldPrehistoricDesc =>
      'Fossile Riesen aus einer verlorenen Welt.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSound => 'Soundeffekte';

  @override
  String get settingsMusic => 'Musik';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsPrivacy => 'Datenschutzerklärung';

  @override
  String get settingsAdPrivacy => 'Werbe-Datenschutz';

  @override
  String get settingsTerms => 'Nutzungsbedingungen';

  @override
  String get settingsRate => 'Mergelings bewerten';

  @override
  String get settingsReset => 'Fortschritt zurücksetzen';

  @override
  String get settingsResetBody =>
      'Damit werden alle Wiesen, Freunde und Herzen unwiderruflich gelöscht.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsSystemLanguage => 'Systemsprache';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get loading => 'Wird geladen…';
}
