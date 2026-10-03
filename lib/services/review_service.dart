import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';

/// Asks for a store rating at a high point: right after a new creature's
/// fanfare, once the player has a few discoveries behind them. No
/// pre-question of our own (Play and App Store policy); pacing is the only
/// filter, and the stores add their own quota on top.
///
/// The counters live under their own keys, outside the save, so resetting
/// progress does not start the asks over.
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  /// A service as a new app launch would see it, for tests.
  @visibleForTesting
  factory ReviewService.newSession() => ReviewService._();

  static const String _asksKey = 'review_asks';
  static const String _nextAtKey = 'review_next_at';

  /// Discoveries before the first ask, then the extra discoveries before each
  /// later one. Three asks in all, ever.
  static const int _minDiscoveries = 8;
  static const List<int> _gaps = <int>[15, 30];

  bool _askedThisSession = false;

  /// Call once a discovery dialog has closed. [discovered] is the lifetime
  /// discovery count across every meadow.
  Future<void> onDiscovery({required int discovered}) async {
    if (_askedThisSession) return;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int asks = prefs.getInt(_asksKey) ?? 0;
      if (asks > _gaps.length) return;
      final int next = prefs.getInt(_nextAtKey) ?? _minDiscoveries;
      if (discovered < next) return;

      _askedThisSession = true;
      final InAppReview review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      await review.requestReview();
      await prefs.setInt(_asksKey, asks + 1);
      if (asks < _gaps.length) {
        await prefs.setInt(_nextAtKey, discovered + _gaps[asks]);
      }
    } on Object catch (e) {
      debugPrint('Mergelings: review request failed — $e');
    }
  }

  /// Settings → Rate Mergelings.
  Future<void> openStore() async {
    try {
      // Without an App Store id there is no listing to open, so the native
      // sheet is the only way to a rating on iOS.
      if (Platform.isIOS && AppConfig.appStoreId.isEmpty) {
        await InAppReview.instance.requestReview();
        return;
      }
      await InAppReview.instance
          .openStoreListing(appStoreId: AppConfig.appStoreId);
    } on Object catch (_) {
      try {
        await launchUrl(
          Uri.parse(AppConfig.storeUrl),
          mode: LaunchMode.externalApplication,
        );
      } on Object catch (_) {}
    }
  }
}
