import 'dart:io' show Platform;

/// AdMob unit ids.
///
/// Defaults are Google's public *test* units so debug builds never risk a
/// policy strike. Release builds must supply the real ids at build time:
///
/// ```
/// flutter build appbundle --release \
///   --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-XXX/YYY \
///   --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXX/YYY \
///   --dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-XXX/YYY
/// ```
///
/// The matching app id also has to be set in `AndroidManifest.xml` and
/// `Info.plist` — see README.
class AdIds {
  const AdIds._();

  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  static const String _bannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ANDROID', defaultValue: _testBannerAndroid);
  static const String _bannerIos =
      String.fromEnvironment('ADMOB_BANNER_IOS', defaultValue: _testBannerIos);
  static const String _interstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: _testInterstitialAndroid,
  );
  static const String _interstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: _testInterstitialIos,
  );
  static const String _rewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: _testRewardedAndroid,
  );
  static const String _rewardedIos = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
    defaultValue: _testRewardedIos,
  );

  static String get banner => Platform.isIOS ? _bannerIos : _bannerAndroid;
  static String get interstitial =>
      Platform.isIOS ? _interstitialIos : _interstitialAndroid;
  static String get rewarded => Platform.isIOS ? _rewardedIos : _rewardedAndroid;

  /// True when the build is still pointing at Google's test inventory.
  static bool get usingTestUnits =>
      banner == _testBannerAndroid || banner == _testBannerIos;
}
