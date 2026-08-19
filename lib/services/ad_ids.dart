import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kReleaseMode;

/// AdMob unit ids.
///
/// Release builds serve the live units below. Debug and profile builds serve
/// Google's public *test* units instead, so development never touches real
/// inventory — impressions and clicks on your own live ads are grounds for a
/// policy strike.
///
/// A `--dart-define` overrides both, on any build mode. That is the way to
/// smoke-test a live unit from a debug build, or to swap an id without a code
/// change:
///
/// ```
/// flutter run --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-XXX/YYY
/// ```
///
/// The matching **app** ids are not used from Dart; they live in
/// `AndroidManifest.xml` and `Info.plist`, and a mismatch crashes the SDK at
/// launch:
///
/// - Android — `ca-app-pub-7855071425983459~1539772329`
/// - iOS — `ca-app-pub-7855071425983459~9295702361`
class AdIds {
  const AdIds._();

  // Live units (AdMob publisher 7855071425983459).
  static const String _liveBannerAndroid = 'ca-app-pub-7855071425983459/7913608986';
  static const String _liveBannerIos = 'ca-app-pub-7855071425983459/2405347619';
  static const String _liveInterstitialAndroid = 'ca-app-pub-7855071425983459/5886211445';
  static const String _liveInterstitialIos = 'ca-app-pub-7855071425983459/7474625287';
  static const String _liveRewardedAndroid = 'ca-app-pub-7855071425983459/3718429286';
  static const String _liveRewardedIos = 'ca-app-pub-7855071425983459/1744515409';

  // Google's public test units.
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // Build-time overrides; empty when not supplied.
  static const String _overrideBannerAndroid =
      String.fromEnvironment('ADMOB_BANNER_ANDROID');
  static const String _overrideBannerIos =
      String.fromEnvironment('ADMOB_BANNER_IOS');
  static const String _overrideInterstitialAndroid =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ANDROID');
  static const String _overrideInterstitialIos =
      String.fromEnvironment('ADMOB_INTERSTITIAL_IOS');
  static const String _overrideRewardedAndroid =
      String.fromEnvironment('ADMOB_REWARDED_ANDROID');
  static const String _overrideRewardedIos =
      String.fromEnvironment('ADMOB_REWARDED_IOS');

  static String _pick(String override, String live, String test) {
    if (override.isNotEmpty) return override;
    return kReleaseMode ? live : test;
  }

  static String get banner => Platform.isIOS
      ? _pick(_overrideBannerIos, _liveBannerIos, _testBannerIos)
      : _pick(_overrideBannerAndroid, _liveBannerAndroid, _testBannerAndroid);

  static String get interstitial => Platform.isIOS
      ? _pick(_overrideInterstitialIos, _liveInterstitialIos, _testInterstitialIos)
      : _pick(
          _overrideInterstitialAndroid,
          _liveInterstitialAndroid,
          _testInterstitialAndroid,
        );

  static String get rewarded => Platform.isIOS
      ? _pick(_overrideRewardedIos, _liveRewardedIos, _testRewardedIos)
      : _pick(_overrideRewardedAndroid, _liveRewardedAndroid, _testRewardedAndroid);

  /// True when the build is serving Google's test inventory rather than the
  /// live units.
  static bool get usingTestUnits =>
      banner == _testBannerAndroid || banner == _testBannerIos;
}
