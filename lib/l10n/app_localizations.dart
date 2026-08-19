import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mergelings'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Merge, collect, and fill five magical meadows.'**
  String get tagline;

  /// No description provided for @navMeadow.
  ///
  /// In en, this message translates to:
  /// **'Meadow'**
  String get navMeadow;

  /// No description provided for @navCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get navCollection;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navMeadows.
  ///
  /// In en, this message translates to:
  /// **'Meadows'**
  String get navMeadows;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @hearts.
  ///
  /// In en, this message translates to:
  /// **'Hearts'**
  String get hearts;

  /// No description provided for @gems.
  ///
  /// In en, this message translates to:
  /// **'Gems'**
  String get gems;

  /// No description provided for @perMinute.
  ///
  /// In en, this message translates to:
  /// **'{amount}/min'**
  String perMinute(String amount);

  /// No description provided for @basket.
  ///
  /// In en, this message translates to:
  /// **'Basket'**
  String get basket;

  /// No description provided for @hintDragToMerge.
  ///
  /// In en, this message translates to:
  /// **'Drag two matching friends together to merge them!'**
  String get hintDragToMerge;

  /// No description provided for @hintTapBasket.
  ///
  /// In en, this message translates to:
  /// **'The basket fills by itself — tap it to hurry a new friend along.'**
  String get hintTapBasket;

  /// No description provided for @hintBoardFull.
  ///
  /// In en, this message translates to:
  /// **'Your meadow is full — merge or sell someone first.'**
  String get hintBoardFull;

  /// No description provided for @newDiscovery.
  ///
  /// In en, this message translates to:
  /// **'New friend discovered!'**
  String get newDiscovery;

  /// No description provided for @discoveryReward.
  ///
  /// In en, this message translates to:
  /// **'+{gems} gems'**
  String discoveryReward(int gems);

  /// No description provided for @tierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier}'**
  String tierLabel(int tier);

  /// Screen reader label for a creature standing on the board.
  ///
  /// In en, this message translates to:
  /// **'{name}, tier {tier}'**
  String boardTileLabel(String name, int tier);

  /// Screen reader label for an unopened mystery basket on the board.
  ///
  /// In en, this message translates to:
  /// **'Mystery basket, not yet opened'**
  String get boardMysteryLabel;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @sellFor.
  ///
  /// In en, this message translates to:
  /// **'Sell for {amount}'**
  String sellFor(String amount);

  /// No description provided for @sellTitle.
  ///
  /// In en, this message translates to:
  /// **'Send this friend home?'**
  String get sellTitle;

  /// No description provided for @sellBody.
  ///
  /// In en, this message translates to:
  /// **'You will receive {amount} hearts.'**
  String sellBody(String amount);

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get shopFriends;

  /// No description provided for @shopBoosts.
  ///
  /// In en, this message translates to:
  /// **'Boosts'**
  String get shopBoosts;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @notEnoughHearts.
  ///
  /// In en, this message translates to:
  /// **'Not enough hearts.'**
  String get notEnoughHearts;

  /// No description provided for @notEnoughGems.
  ///
  /// In en, this message translates to:
  /// **'Not enough gems.'**
  String get notEnoughGems;

  /// No description provided for @expandMeadow.
  ///
  /// In en, this message translates to:
  /// **'Expand meadow'**
  String get expandMeadow;

  /// No description provided for @expandMeadowBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock another row of space.'**
  String get expandMeadowBody;

  /// No description provided for @meadowFullyExpanded.
  ///
  /// In en, this message translates to:
  /// **'Fully expanded'**
  String get meadowFullyExpanded;

  /// No description provided for @shopAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get shopAccessories;

  /// No description provided for @accessoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessory'**
  String get accessoryTitle;

  /// No description provided for @accessoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get accessoryNone;

  /// No description provided for @accessoryOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get accessoryOwned;

  /// No description provided for @accessoryOwnedBody.
  ///
  /// In en, this message translates to:
  /// **'Put it on any friend from their collection card.'**
  String get accessoryOwnedBody;

  /// No description provided for @accessoryLocked.
  ///
  /// In en, this message translates to:
  /// **'Discover {count} friends to unlock.'**
  String accessoryLocked(int count);

  /// No description provided for @accessoryBought.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your wardrobe!'**
  String accessoryBought(String name);

  /// No description provided for @accessoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Buy accessories in the shop to dress your friends up.'**
  String get accessoryEmptyHint;

  /// No description provided for @accessoryFlowerCrown.
  ///
  /// In en, this message translates to:
  /// **'Flower crown'**
  String get accessoryFlowerCrown;

  /// No description provided for @accessoryBowTie.
  ///
  /// In en, this message translates to:
  /// **'Bow tie'**
  String get accessoryBowTie;

  /// No description provided for @accessoryPartyHat.
  ///
  /// In en, this message translates to:
  /// **'Party hat'**
  String get accessoryPartyHat;

  /// No description provided for @accessoryScarf.
  ///
  /// In en, this message translates to:
  /// **'Cosy scarf'**
  String get accessoryScarf;

  /// No description provided for @accessoryTopHat.
  ///
  /// In en, this message translates to:
  /// **'Top hat'**
  String get accessoryTopHat;

  /// No description provided for @accessorySunglasses.
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get accessorySunglasses;

  /// No description provided for @accessoryCape.
  ///
  /// In en, this message translates to:
  /// **'Hero cape'**
  String get accessoryCape;

  /// No description provided for @accessoryHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get accessoryHeadphones;

  /// No description provided for @accessoryCrown.
  ///
  /// In en, this message translates to:
  /// **'Golden crown'**
  String get accessoryCrown;

  /// No description provided for @boostTitle.
  ///
  /// In en, this message translates to:
  /// **'Double hearts'**
  String get boostTitle;

  /// No description provided for @boostBody.
  ///
  /// In en, this message translates to:
  /// **'Double all heart income for {minutes} minutes.'**
  String boostBody(int minutes);

  /// No description provided for @boostActive.
  ///
  /// In en, this message translates to:
  /// **'Double hearts — {time} left'**
  String boostActive(String time);

  /// No description provided for @basketBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'Speedy basket'**
  String get basketBoostTitle;

  /// No description provided for @basketBoostBody.
  ///
  /// In en, this message translates to:
  /// **'The basket fills {times}× faster for {minutes} minutes.'**
  String basketBoostBody(int times, int minutes);

  /// No description provided for @basketBoostActive.
  ///
  /// In en, this message translates to:
  /// **'Speedy basket — {time} left'**
  String basketBoostActive(String time);

  /// No description provided for @giftTitle.
  ///
  /// In en, this message translates to:
  /// **'Free friend'**
  String get giftTitle;

  /// No description provided for @giftBody.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video for a free friend.'**
  String get giftBody;

  /// No description provided for @mysteryTitle.
  ///
  /// In en, this message translates to:
  /// **'A mystery basket!'**
  String get mysteryTitle;

  /// No description provided for @mysteryBody.
  ///
  /// In en, this message translates to:
  /// **'Something is rustling inside. Choose how to open it.'**
  String get mysteryBody;

  /// No description provided for @mysteryOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get mysteryOpenNow;

  /// No description provided for @mysteryLater.
  ///
  /// In en, this message translates to:
  /// **'Leave it for now'**
  String get mysteryLater;

  /// No description provided for @mysteryTierRange.
  ///
  /// In en, this message translates to:
  /// **'A friend from tier {min}–{max}'**
  String mysteryTierRange(int min, int max);

  /// No description provided for @mysteryGranted.
  ///
  /// In en, this message translates to:
  /// **'{name} hopped out of the basket!'**
  String mysteryGranted(String name);

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch video'**
  String get watchAd;

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'No video available right now. Try again shortly.'**
  String get adNotReady;

  /// No description provided for @adRewardGranted.
  ///
  /// In en, this message translates to:
  /// **'Reward collected!'**
  String get adRewardGranted;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBackTitle;

  /// No description provided for @welcomeBackBody.
  ///
  /// In en, this message translates to:
  /// **'Your meadow earned {amount} hearts while you were away.'**
  String welcomeBackBody(String amount);

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @collectDouble.
  ///
  /// In en, this message translates to:
  /// **'Collect double'**
  String get collectDouble;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionTitle;

  /// No description provided for @collectionProgress.
  ///
  /// In en, this message translates to:
  /// **'{found} of {total} discovered'**
  String collectionProgress(int found, int total);

  /// No description provided for @undiscovered.
  ///
  /// In en, this message translates to:
  /// **'Not yet discovered'**
  String get undiscovered;

  /// No description provided for @meadowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meadows'**
  String get meadowsTitle;

  /// No description provided for @meadowLocked.
  ///
  /// In en, this message translates to:
  /// **'Discover tier {tier} in {meadow} to unlock.'**
  String meadowLocked(int tier, String meadow);

  /// No description provided for @meadowUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked!'**
  String get meadowUnlocked;

  /// No description provided for @enterMeadow.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enterMeadow;

  /// No description provided for @worldDay.
  ///
  /// In en, this message translates to:
  /// **'Day Meadow'**
  String get worldDay;

  /// No description provided for @worldNight.
  ///
  /// In en, this message translates to:
  /// **'Night Meadow'**
  String get worldNight;

  /// No description provided for @worldWater.
  ///
  /// In en, this message translates to:
  /// **'Sea Meadow'**
  String get worldWater;

  /// No description provided for @worldMythical.
  ///
  /// In en, this message translates to:
  /// **'Myth Meadow'**
  String get worldMythical;

  /// No description provided for @worldPrehistoric.
  ///
  /// In en, this message translates to:
  /// **'Dino Meadow'**
  String get worldPrehistoric;

  /// No description provided for @worldDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Sun-warmed grass and woodland friends.'**
  String get worldDayDesc;

  /// No description provided for @worldNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Moonlit critters and starry wanderers.'**
  String get worldNightDesc;

  /// No description provided for @worldWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reef shallows down to the deep blue.'**
  String get worldWaterDesc;

  /// No description provided for @worldMythicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Folklore, legend and elder dragons.'**
  String get worldMythicalDesc;

  /// No description provided for @worldPrehistoricDesc.
  ///
  /// In en, this message translates to:
  /// **'Fossil giants from a lost world.'**
  String get worldPrehistoricDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSound;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsAdPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy settings'**
  String get settingsAdPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTerms;

  /// No description provided for @settingsRate.
  ///
  /// In en, this message translates to:
  /// **'Rate Mergelings'**
  String get settingsRate;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsReset;

  /// No description provided for @settingsResetBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every meadow, friend and heart. This cannot be undone.'**
  String get settingsResetBody;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsSystemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsSystemLanguage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return LDe();
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'fr':
      return LFr();
    case 'pt':
      return LPt();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
