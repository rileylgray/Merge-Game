import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/balance.dart';
import 'ad_ids.dart';

/// Which rewarded placement a video is being watched for.
enum RewardPlacement { doubleOffline, freeCreature, heartBoost, basketBoost }

/// Owns consent, the SDK lifecycle and all three ad formats.
///
/// Every entry point degrades gracefully: if consent is refused, the SDK fails
/// to start, or an ad is not filled, the game continues and rewarded actions
/// simply report `false` so the caller can tell the player to try again.
class AdsService extends ChangeNotifier {
  bool _initialized = false;
  bool _startupComplete = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  bool _showingFullScreen = false;

  DateTime? _lastInterstitial;
  final DateTime _startedAt = DateTime.now();

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  bool get rewardedReady => _rewarded != null;

  /// True while a rewarded video could still turn up shortly: start-up has not
  /// finished, or a request is in flight.
  ///
  /// On a cold launch consent, ATT and SDK start-up all run before the first
  /// ad request even goes out, so a screen that only checks [rewardedReady]
  /// concludes there is no video seconds before one arrives. Callers that
  /// offer a rewarded choice use this to hold the offer open instead.
  bool get rewardedPending =>
      _rewarded == null && (!_startupComplete || _loadingRewarded);

  /// True while a full-screen ad owns the display — pause game timers.
  bool get showingFullScreen => _showingFullScreen;

  /// Notified when a full-screen ad takes over the screen and again when it
  /// goes away. Wired at start-up to duck the music, which would otherwise
  /// play underneath the ad's own soundtrack.
  void Function(bool showing)? onFullScreenChanged;

  void _setShowingFullScreen(bool value) {
    if (_showingFullScreen == value) return;
    _showingFullScreen = value;
    onFullScreenChanged?.call(value);
    notifyListeners();
  }

  /// Runs consent, ATT and SDK start-up. Never throws.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _gatherConsent();
    } on Object catch (e) {
      debugPrint('Mergelings: consent flow failed — $e');
    }

    // iOS requires the ATT prompt after the UMP form, and only once the app
    // is actually in the foreground.
    if (Platform.isIOS) {
      try {
        final TrackingStatus status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } on Object catch (e) {
        debugPrint('Mergelings: ATT prompt failed — $e');
      }
    }

    if (!_canRequestAds) {
      _startupComplete = true;
      notifyListeners();
      return;
    }

    try {
      await MobileAds.instance.initialize();
      // The whole cast is cute animals; keep the inventory family-safe.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        ),
      );
    } on Object catch (e) {
      debugPrint('Mergelings: ad SDK init failed — $e');
      _canRequestAds = false;
      _startupComplete = true;
      notifyListeners();
      return;
    }

    // The rewarded request goes out before the interstitial one: it is the
    // only ad the player is ever asked to wait for, and the welcome-back
    // offer is usually already on screen by the time we get here.
    unawaited(_loadRewarded());
    _startupComplete = true;
    notifyListeners();
    unawaited(_loadInterstitial());
  }

  Future<void> _gatherConsent() async {
    final Completer<void> done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
            if (error != null) {
              debugPrint('Mergelings: consent form error — ${error.message}');
            }
            if (!done.isCompleted) done.complete();
          });
        } on Object catch (e) {
          debugPrint('Mergelings: consent form failed — $e');
          if (!done.isCompleted) done.complete();
        }
      },
      (FormError error) {
        debugPrint('Mergelings: consent update failed — ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );

    // Do not block start-up indefinitely on a consent request that never
    // returns (offline first launch, for instance).
    await done.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {},
    );

    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    _privacyOptionsRequired =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
  }

  /// Re-opens the consent form from Settings (required in the EEA/UK).
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) {
          debugPrint('Mergelings: privacy form error — ${error.message}');
        }
      });
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      notifyListeners();
    } on Object catch (e) {
      debugPrint('Mergelings: privacy options failed — $e');
    }
  }

  // ------------------------------------------------------------------ banner

  /// Builds an anchored adaptive banner sized to [screenWidth].
  ///
  /// Returns null when ads cannot be requested; the caller then renders
  /// nothing and the layout simply reclaims the space.
  Future<BannerAd?> createBanner(int screenWidth) async {
    if (!_canRequestAds) return null;
    try {
      final AdSize size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSize(screenWidth) ??
              AdSize.banner;
      final Completer<BannerAd?> completer = Completer<BannerAd?>();
      final BannerAd ad = BannerAd(
        adUnitId: AdIds.banner,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (!completer.isCompleted) completer.complete(ad as BannerAd);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Mergelings: banner failed — ${error.message}');
            ad.dispose();
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
      await ad.load();
      return completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => null,
      );
    } on Object catch (e) {
      debugPrint('Mergelings: banner build failed — $e');
      return null;
    }
  }

  // ------------------------------------------------------------ interstitial

  Future<void> _loadInterstitial() async {
    if (!_canRequestAds || _loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    try {
      await InterstitialAd.load(
        adUnitId: AdIds.interstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _loadingInterstitial = false;
            _interstitial = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _loadingInterstitial = false;
            debugPrint('Mergelings: interstitial failed — ${error.message}');
          },
        ),
      );
    } on Object catch (e) {
      _loadingInterstitial = false;
      debugPrint('Mergelings: interstitial load threw — $e');
    }
  }

  /// True if an interstitial is allowed right now by the frequency rules.
  bool get _interstitialAllowed {
    if (DateTime.now().difference(_startedAt) < Balance.interstitialWarmup) {
      return false;
    }
    final DateTime? last = _lastInterstitial;
    return last == null ||
        DateTime.now().difference(last) >= Balance.interstitialCooldown;
  }

  /// Shows an interstitial if one is loaded and the cooldown has elapsed.
  /// Returns true if an ad was actually shown.
  Future<bool> maybeShowInterstitial() async {
    final InterstitialAd? ad = _interstitial;
    if (!_canRequestAds || ad == null || !_interstitialAllowed) {
      unawaited(_loadInterstitial());
      return false;
    }

    _interstitial = null;
    _lastInterstitial = DateTime.now();
    final Completer<void> dismissed = Completer<void>();
    _setShowingFullScreen(true);

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        if (!dismissed.isCompleted) dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('Mergelings: interstitial show failed — ${error.message}');
        ad.dispose();
        if (!dismissed.isCompleted) dismissed.complete();
      },
    );

    try {
      await ad.show();
      await dismissed.future.timeout(const Duration(minutes: 2), onTimeout: () {});
    } on Object catch (e) {
      debugPrint('Mergelings: interstitial show threw — $e');
    } finally {
      _setShowingFullScreen(false);
      unawaited(_loadInterstitial());
    }
    return true;
  }

  // ---------------------------------------------------------------- rewarded

  Future<void> _loadRewarded() async {
    if (!_canRequestAds || _loadingRewarded || _rewarded != null) return;
    _loadingRewarded = true;
    try {
      await RewardedAd.load(
        adUnitId: AdIds.rewarded,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _loadingRewarded = false;
            _rewarded = ad;
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _loadingRewarded = false;
            debugPrint('Mergelings: rewarded failed — ${error.message}');
            notifyListeners();
          },
        ),
      );
    } on Object catch (e) {
      _loadingRewarded = false;
      debugPrint('Mergelings: rewarded load threw — $e');
    }
  }

  /// Shows a rewarded video. Resolves true only when the user actually earned
  /// the reward, so callers can grant it without further checks.
  Future<bool> showRewarded() async {
    final RewardedAd? ad = _rewarded;
    if (!_canRequestAds || ad == null) {
      unawaited(_loadRewarded());
      return false;
    }

    _rewarded = null;
    notifyListeners();

    bool earned = false;
    final Completer<void> dismissed = Completer<void>();
    _setShowingFullScreen(true);

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        if (!dismissed.isCompleted) dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Mergelings: rewarded show failed — ${error.message}');
        ad.dispose();
        if (!dismissed.isCompleted) dismissed.complete();
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) => earned = true,
      );
      await dismissed.future.timeout(const Duration(minutes: 5), onTimeout: () {});
    } on Object catch (e) {
      debugPrint('Mergelings: rewarded show threw — $e');
    } finally {
      _setShowingFullScreen(false);
      unawaited(_loadRewarded());
    }
    return earned;
  }

  /// Keeps a rewarded ad warm so the shop button is rarely greyed out.
  void prewarm() {
    unawaited(_loadRewarded());
    unawaited(_loadInterstitial());
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    super.dispose();
  }
}
