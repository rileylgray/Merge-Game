// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mergelings';

  @override
  String get tagline => 'Merge, collect, and fill five magical meadows.';

  @override
  String get navMeadow => 'Meadow';

  @override
  String get navCollection => 'Collection';

  @override
  String get navShop => 'Shop';

  @override
  String get navMeadows => 'Meadows';

  @override
  String get navSettings => 'Settings';

  @override
  String get hearts => 'Hearts';

  @override
  String get gems => 'Gems';

  @override
  String perMinute(String amount) {
    return '$amount/min';
  }

  @override
  String get basket => 'Basket';

  @override
  String get hintDragToMerge =>
      'Drag two matching friends together to merge them!';

  @override
  String get hintTapBasket =>
      'The basket fills by itself — tap it to hurry a new friend along.';

  @override
  String get hintBoardFull =>
      'Your meadow is full — merge or sell someone first.';

  @override
  String get newDiscovery => 'New friend discovered!';

  @override
  String discoveryReward(int gems) {
    return '+$gems gems';
  }

  @override
  String tierLabel(int tier) {
    return 'Tier $tier';
  }

  @override
  String boardTileLabel(String name, int tier) {
    return '$name, tier $tier';
  }

  @override
  String get boardMysteryLabel => 'Mystery basket, not yet opened';

  @override
  String get sell => 'Sell';

  @override
  String sellFor(String amount) {
    return 'Sell for $amount';
  }

  @override
  String get sellTitle => 'Send this friend home?';

  @override
  String sellBody(String amount) {
    return 'You will receive $amount hearts.';
  }

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopFriends => 'Friends';

  @override
  String get shopBoosts => 'Boosts';

  @override
  String get buy => 'Buy';

  @override
  String get notEnoughHearts => 'Not enough hearts.';

  @override
  String get notEnoughGems => 'Not enough gems.';

  @override
  String get expandMeadow => 'Expand meadow';

  @override
  String get expandMeadowBody => 'Unlock another row of space.';

  @override
  String get meadowFullyExpanded => 'Fully expanded';

  @override
  String get shopAccessories => 'Accessories';

  @override
  String get accessoryTitle => 'Accessory';

  @override
  String get accessoryNone => 'None';

  @override
  String get accessoryOwned => 'Owned';

  @override
  String get accessoryOwnedBody =>
      'Put it on any friend from their collection card.';

  @override
  String accessoryLocked(int count) {
    return 'Discover $count friends to unlock.';
  }

  @override
  String accessoryBought(String name) {
    return '$name added to your wardrobe!';
  }

  @override
  String get accessoryEmptyHint =>
      'Buy accessories in the shop to dress your friends up.';

  @override
  String get accessoryFlowerCrown => 'Flower crown';

  @override
  String get accessoryBowTie => 'Bow tie';

  @override
  String get accessoryPartyHat => 'Party hat';

  @override
  String get accessoryScarf => 'Cosy scarf';

  @override
  String get accessoryTopHat => 'Top hat';

  @override
  String get accessorySunglasses => 'Sunglasses';

  @override
  String get accessoryCape => 'Hero cape';

  @override
  String get accessoryHeadphones => 'Headphones';

  @override
  String get accessoryCrown => 'Golden crown';

  @override
  String get boostTitle => 'Double hearts';

  @override
  String boostBody(int minutes) {
    return 'Double all heart income for $minutes minutes.';
  }

  @override
  String boostActive(String time) {
    return 'Double hearts — $time left';
  }

  @override
  String get basketBoostTitle => 'Speedy basket';

  @override
  String basketBoostBody(int times, int minutes) {
    return 'The basket fills $times× faster for $minutes minutes.';
  }

  @override
  String basketBoostActive(String time) {
    return 'Speedy basket — $time left';
  }

  @override
  String get giftTitle => 'Free friend';

  @override
  String get giftBody => 'Watch a short video for a free friend.';

  @override
  String get mysteryTitle => 'A mystery basket!';

  @override
  String get mysteryBody =>
      'Something is rustling inside. Choose how to open it.';

  @override
  String get mysteryOpenNow => 'Open now';

  @override
  String get mysteryLater => 'Leave it for now';

  @override
  String mysteryTierRange(int min, int max) {
    return 'A friend from tier $min–$max';
  }

  @override
  String mysteryGranted(String name) {
    return '$name hopped out of the basket!';
  }

  @override
  String get watchAd => 'Watch video';

  @override
  String get adNotReady => 'No video available right now. Try again shortly.';

  @override
  String get adRewardGranted => 'Reward collected!';

  @override
  String get welcomeBackTitle => 'Welcome back!';

  @override
  String welcomeBackBody(String amount) {
    return 'Your meadow earned $amount hearts while you were away.';
  }

  @override
  String get collect => 'Collect';

  @override
  String get collectDouble => 'Collect double';

  @override
  String get collectionTitle => 'Collection';

  @override
  String collectionProgress(int found, int total) {
    return '$found of $total discovered';
  }

  @override
  String get undiscovered => 'Not yet discovered';

  @override
  String get meadowsTitle => 'Meadows';

  @override
  String meadowLocked(int tier, String meadow) {
    return 'Discover tier $tier in $meadow to unlock.';
  }

  @override
  String get meadowUnlocked => 'Unlocked!';

  @override
  String get enterMeadow => 'Enter';

  @override
  String get worldDay => 'Day Meadow';

  @override
  String get worldNight => 'Night Meadow';

  @override
  String get worldWater => 'Sea Meadow';

  @override
  String get worldMythical => 'Myth Meadow';

  @override
  String get worldPrehistoric => 'Dino Meadow';

  @override
  String get worldDayDesc => 'Sun-warmed grass and woodland friends.';

  @override
  String get worldNightDesc => 'Moonlit critters and starry wanderers.';

  @override
  String get worldWaterDesc => 'Reef shallows down to the deep blue.';

  @override
  String get worldMythicalDesc => 'Folklore, legend and elder dragons.';

  @override
  String get worldPrehistoricDesc => 'Fossil giants from a lost world.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSound => 'Sound effects';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsAdPrivacy => 'Ad privacy settings';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsRate => 'Rate Mergelings';

  @override
  String get settingsReset => 'Reset progress';

  @override
  String get settingsResetBody =>
      'This permanently deletes every meadow, friend and heart. This cannot be undone.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsSystemLanguage => 'System default';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get reset => 'Reset';

  @override
  String get loading => 'Loading…';
}
