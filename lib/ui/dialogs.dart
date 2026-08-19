import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../data/creature_spec.dart';
import '../l10n/app_localizations.dart';
import '../services/ads_service.dart';
import '../state/game_controller.dart';
import 'widgets/accessory_picker.dart';
import 'widgets/creature_view.dart';
import 'widgets/mystery_basket.dart';

/// Celebration shown the first time a creature appears.
class DiscoveryDialog extends StatelessWidget {
  const DiscoveryDialog({
    super.key,
    required this.spec,
    required this.name,
    required this.gems,
  });

  final CreatureSpec spec;
  final String name;
  final int gems;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    final Color rarity = AppTheme.rarityColors[spec.rarity];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l.newDiscovery,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: rarity,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    rarity.withValues(alpha: .28),
                    rarity.withValues(alpha: .02),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: CreatureView(spec, shadow: false),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              l.tierLabel(spec.tier),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink.withValues(alpha: .55),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.gem.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l.discoveryReward(gems),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gem,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.ok),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offered on return: hearts banked while away, with a rewarded double.
///
/// This is the first thing most players see on a cold launch, and it lands
/// while consent and the ad SDK are still starting up. So the double offer is
/// drawn from the start in a loading state and lights up the moment a video is
/// ready, and Collect is held for a beat — otherwise the button players are
/// about to tap simply is not there yet, and the reward is skipped unseen.
class OfflineDialog extends StatefulWidget {
  const OfflineDialog({
    super.key,
    required this.hearts,
    required this.away,
  });

  final double hearts;
  final Duration away;

  /// How long the offer stays on screen waiting for a video before giving up.
  static const Duration wait = Duration(seconds: 6);

  /// How long Collect stays held while that wait is still running.
  static const Duration hold = Duration(milliseconds: 1600);

  @override
  State<OfflineDialog> createState() => _OfflineDialogState();
}

class _OfflineDialogState extends State<OfflineDialog> {
  Timer? _waitTimer;
  Timer? _holdTimer;
  bool _gaveUp = false;
  bool _held = true;

  @override
  void initState() {
    super.initState();
    _holdTimer = Timer(
      OfflineDialog.hold,
      () => setState(() => _held = false),
    );
    _waitTimer = Timer(
      OfflineDialog.wait,
      () => setState(() => _gaveUp = true),
    );
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    final AdsService ads = context.watch<AdsService>();

    final bool ready = ads.rewardedReady;
    final bool loading = !ready && !_gaveUp && ads.rewardedPending;
    // Nothing to wait for once we know no video is coming.
    final bool canCollect = !loading || !_held;

    return AlertDialog(
      title: Text(l.welcomeBackTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.favorite_rounded, size: 52, color: AppTheme.heart),
          const SizedBox(height: 12),
          Text(
            l.welcomeBackBody(formatCount(widget.hearts)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        Column(
          children: <Widget>[
            if (ready || loading) ...<Widget>[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      ready ? () => Navigator.of(context).pop(true) : null,
                  icon: ready
                      ? const Icon(Icons.play_circle_fill_rounded)
                      : const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                  label: Text(l.collectDouble),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed:
                    canCollect ? () => Navigator.of(context).pop(false) : null,
                child: Text(l.collect),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// How the player chose to open a mystery basket.
enum MysteryChoice { free, rewarded }

/// Opened by tapping a mystery basket: take the friend inside now, or watch a
/// video for one from a better tier band.
class MysteryDialog extends StatelessWidget {
  const MysteryDialog({
    super.key,
    required this.accent,
    required this.freeBand,
    required this.rewardBand,
    required this.canWatchAd,
  });

  final Color accent;

  /// Inclusive (low, high) tier band each option draws from.
  final (int, int) freeBand;
  final (int, int) rewardBand;
  final bool canWatchAd;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l.mysteryTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 132,
              child: MysteryBasketView(accent: accent),
            ),
            const SizedBox(height: 6),
            Text(
              l.mysteryBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppTheme.ink.withValues(alpha: .65),
              ),
            ),
            const SizedBox(height: 18),
            _MysteryOption(
              icon: Icons.card_giftcard_rounded,
              color: accent,
              title: l.mysteryOpenNow,
              subtitle: _bandLabel(l, freeBand),
              onPressed: () =>
                  Navigator.of(context).pop(MysteryChoice.free),
            ),
            const SizedBox(height: 10),
            _MysteryOption(
              icon: Icons.play_circle_fill_rounded,
              color: AppTheme.gem,
              title: l.watchAd,
              subtitle: _bandLabel(l, rewardBand),
              highlight: true,
              onPressed: canWatchAd
                  ? () => Navigator.of(context).pop(MysteryChoice.rewarded)
                  : null,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.mysteryLater),
            ),
          ],
        ),
      ),
    );
  }

  /// A one-tier band reads better as "Tier 12" than as "Tier 12–12".
  String _bandLabel(L l, (int, int) band) {
    final (int low, int high) = band;
    return low == high ? l.tierLabel(low) : l.mysteryTierRange(low, high);
  }
}

class _MysteryOption extends StatelessWidget {
  const _MysteryOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.highlight = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color tint = enabled ? color : Colors.grey;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: tint.withValues(alpha: highlight ? .14 : .08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(icon, color: tint),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: enabled ? AppTheme.ink : Colors.grey,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: tint.withValues(alpha: enabled ? 1 : .8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.ink.withValues(alpha: .35),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Long-press sheet for a creature already on the board.
class CreatureSheet extends StatelessWidget {
  const CreatureSheet({
    super.key,
    required this.spec,
    required this.name,
    required this.sellValue,
  });

  final CreatureSpec spec;
  final String name;
  final double sellValue;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            // Watches the controller so the friend re-dresses the instant a
            // different accessory is picked below.
            Consumer<GameController>(
              builder: (BuildContext context, GameController game, Widget? _) =>
                  SizedBox(
                height: 120,
                child: CreatureView(spec, accessory: game.accessoryFor(spec)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              l.tierLabel(spec.tier),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink.withValues(alpha: .55),
              ),
            ),
            const SizedBox(height: 16),
            AccessoryPicker(spec: spec),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.favorite_rounded, color: AppTheme.heart),
                label: Text(l.sellFor(formatCount(sellValue))),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small helper so screens can flash a message without repeating boilerplate.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
}
