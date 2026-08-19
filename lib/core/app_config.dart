import 'dart:io' show Platform;

/// Store and legal endpoints.
///
/// The App Store id is only known after the first App Store Connect record is
/// created, so it is injected at build time rather than hard-coded.
class AppConfig {
  const AppConfig._();

  static const String appName = 'Mergelings';
  static const String bundleId = 'com.realgamesrealfun.mergelings';

  static const String privacyPolicyUrl =
      'https://realgamesrealfun.com/mergelings/privacy';
  static const String termsUrl =
      'https://realgamesrealfun.com/mergelings/terms';
  static const String supportEmail = 'support@realgamesrealfun.com';

  static const String appStoreId =
      String.fromEnvironment('APP_STORE_ID', defaultValue: '');

  /// Deep link to the store listing for the current platform.
  static String get storeUrl => Platform.isIOS
      ? (appStoreId.isEmpty
          ? 'https://apps.apple.com/developer/real-games-real-fun'
          : 'https://apps.apple.com/app/id$appStoreId?action=write-review')
      : 'https://play.google.com/store/apps/details?id=$bundleId';
}
