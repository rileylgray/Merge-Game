import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/balance.dart';
import '../../core/formatters.dart';
import '../../data/accessory.dart';
import '../../data/creature_spec.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ads_service.dart';
import '../../state/game_controller.dart';
import '../accessory_labels.dart';
import '../dialogs.dart';
import '../widgets/accessory_icon.dart';
import '../widgets/creature_view.dart';

/// Spend hearts on creatures and space; spend attention on boosts.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final L l = L.of(context);
    final int maxTier = Balance.maxShopTier(game.highestTier(game.world.id));

    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(
        title: Text(l.shopTitle),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Row(
                children: <Widget>[
                  const Icon(Icons.favorite_rounded,
                      size: 18, color: AppTheme.heart),
                  const SizedBox(width: 4),
                  Text(
                    formatCount(game.hearts),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          _SectionTitle(l.shopBoosts),
          const SizedBox(height: 10),
          const _BoostCards(),
          const SizedBox(height: 24),
          _SectionTitle(l.shopAccessories),
          const SizedBox(height: 10),
          for (final Accessory item in game.accessoryCatalogue)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AccessoryOffer(item: item, game: game),
            ),
          const SizedBox(height: 14),
          _SectionTitle(l.shopFriends),
          const SizedBox(height: 10),
          _ExpandCard(game: game),
          const SizedBox(height: 10),
          for (int tier = maxTier; tier >= 1; tier--)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CreatureOffer(
                spec: game.world.creatureAt(tier),
                name: game.nameOf(game.world.creatureAt(tier)),
                cost: Balance.shopCost(tier),
                game: game,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      );
}

class _BoostCards extends StatelessWidget {
  const _BoostCards();

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final AdsService ads = context.watch<AdsService>();
    final L l = L.of(context);

    Future<void> watch(Future<void> Function() onEarned) async {
      final bool earned = await ads.showRewarded();
      if (!context.mounted) return;
      if (!earned) {
        showToast(context, l.adNotReady);
        return;
      }
      await onEarned();
      if (context.mounted) showToast(context, l.adRewardGranted);
    }

    return Column(
      children: <Widget>[
        _RewardCard(
          icon: Icons.bolt_rounded,
          color: AppTheme.heart,
          title: l.boostTitle,
          body: l.boostBody(Balance.boostDuration.inMinutes),
          enabled: ads.rewardedReady,
          buttonLabel: l.watchAd,
          onPressed: () => watch(() async => game.startBoost()),
        ),
        const SizedBox(height: 10),
        _RewardCard(
          icon: Icons.fast_forward_rounded,
          color: AppTheme.brand,
          title: l.basketBoostTitle,
          body: l.basketBoostBody(
            Balance.basketBoostMultiplier.round(),
            Balance.basketBoostDuration.inMinutes,
          ),
          enabled: ads.rewardedReady,
          buttonLabel: l.watchAd,
          onPressed: () => watch(() async => game.startBasketBoost()),
        ),
        const SizedBox(height: 10),
        _RewardCard(
          icon: Icons.card_giftcard_rounded,
          color: AppTheme.gem,
          title: l.giftTitle,
          body: l.giftBody,
          enabled: ads.rewardedReady,
          buttonLabel: l.watchAd,
          onPressed: () => watch(() async {
            if (!game.grantGiftCreature() && context.mounted) {
              showToast(context, l.hintBoardFull);
            }
          }),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.enabled,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool enabled;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppTheme.ink.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandCard extends StatelessWidget {
  const _ExpandCard({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    final bool available = game.canExpand;
    final double cost = available ? game.expandCost : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.grid_view_rounded, color: AppTheme.brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l.expandMeadow,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    available ? l.expandMeadowBody : l.meadowFullyExpanded,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.ink.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            if (available)
              _PriceButton(
                cost: cost,
                affordable: game.canAfford(cost),
                onPressed: () {
                  if (!game.expandMeadow()) {
                    showToast(context, l.notEnoughHearts);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// One wardrobe item: buy it once, then any friend can wear it.
class _AccessoryOffer extends StatelessWidget {
  const _AccessoryOffer({required this.item, required this.game});

  final Accessory item;
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    final bool owned = game.ownsAccessory(item.type);
    final bool unlocked = game.accessoryUnlocked(item);

    return Opacity(
      opacity: unlocked ? 1 : .55,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.parchment,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: AccessoryIcon(item.type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      accessoryName(l, item.type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      unlocked
                          ? l.accessoryOwnedBody
                          : l.accessoryLocked(item.unlockDiscoveries),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: AppTheme.ink.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (owned)
                const _OwnedBadge()
              else if (unlocked)
                _PriceButton(
                  cost: item.cost,
                  affordable: game.canAfford(item.cost),
                  onPressed: () {
                    if (game.buyAccessory(item)) {
                      showToast(
                        context,
                        l.accessoryBought(accessoryName(l, item.type)),
                      );
                    } else {
                      showToast(context, l.notEnoughHearts);
                    }
                  },
                )
              else
                Icon(
                  Icons.lock_rounded,
                  color: AppTheme.ink.withValues(alpha: .3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnedBadge extends StatelessWidget {
  const _OwnedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.brand.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.check_rounded, size: 16, color: AppTheme.brand),
          const SizedBox(width: 5),
          Text(
            L.of(context).accessoryOwned,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.brand,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatureOffer extends StatelessWidget {
  const _CreatureOffer({
    required this.spec,
    required this.name,
    required this.cost,
    required this.game,
  });

  final CreatureSpec spec;
  final String name;
  final double cost;
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 56,
              height: 56,
              child: CreatureView(
                spec,
                animate: false,
                accessory: game.accessoryFor(spec),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    l.tierLabel(spec.tier),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.ink.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            _PriceButton(
              cost: cost,
              affordable: game.canAfford(cost),
              onPressed: () {
                if (!game.buyCreature(spec.tier)) {
                  showToast(
                    context,
                    game.board.isFull ? l.hintBoardFull : l.notEnoughHearts,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceButton extends StatelessWidget {
  const _PriceButton({
    required this.cost,
    required this.affordable,
    required this.onPressed,
  });

  final double cost;
  final bool affordable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: affordable ? AppTheme.brand : Colors.grey.shade400,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.favorite_rounded, size: 15),
          const SizedBox(width: 4),
          Text(
            formatCount(cost),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
