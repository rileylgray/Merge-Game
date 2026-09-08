import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/balance.dart';
import '../../core/formatters.dart';
import '../../data/creature_spec.dart';
import '../../data/worlds.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../render/meadow_backdrop.dart';
import '../../services/ads_service.dart';
import '../../state/game_controller.dart';
import '../dialogs.dart';
import '../widgets/board_view.dart';
import '../widgets/hud.dart';
import '../widgets/tick_builder.dart';

/// The main play surface: sky, board and basket.
class MeadowScreen extends StatelessWidget {
  const MeadowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final World world = game.world;

    return MeadowBackdrop(
      world: world,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // The wallet and the filling basket are the only two things in the
            // app that genuinely move with the income tick, so they are the
            // only two that follow it — and each gets a boundary of its own,
            // or the whole meadow's layer is marked dirty four times a second
            // on their behalf.
            RepaintBoundary(
              child: TickBuilder(
                builder: (BuildContext context, Widget? _) =>
                    _TopBar(game: game, world: world),
              ),
            ),
            // Hearts land four times a second, and every one of those used to
            // rebuild the whole meadow — every cell, painter and drag target,
            // often mid-drag. The board only cares about its own signature.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                child: Selector<GameController, BoardSignature>(
                  selector: (_, GameController g) => g.boardSignature,
                  builder: (BuildContext context, BoardSignature _, Widget? _) {
                    final L l = L.of(context);
                    return BoardView(
                      board: game.board,
                      world: game.world,
                      mergedCell: game.lastMergedCell,
                      accessoryOf: game.accessoryFor,
                      nameOf: game.nameOf,
                      onMove: (int from, int to) {
                        final MergeResult result = game.moveTile(from, to);
                        if (result == MergeResult.maxTier) {
                          showToast(context, l.meadowFullyExpanded);
                        }
                      },
                      onInspect: (int index) => _inspect(context, game, index),
                      onOpenMystery: (int index) =>
                          _openMystery(context, game, index),
                    );
                  },
                ),
              ),
            ),
            RepaintBoundary(
              child: TickBuilder(
                builder: (BuildContext context, Widget? _) =>
                    _BottomBar(game: game, world: world),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _inspect(
    BuildContext context,
    GameController game,
    int index,
  ) async {
    final BoardTile? tile = game.board.at(index);
    if (tile == null) return;
    final CreatureSpec spec = game.world.creatureAt(tile.tier);

    final bool? sell = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) => CreatureSheet(
        spec: spec,
        name: game.nameOf(spec),
        sellValue: Balance.sellValue(tile.tier),
      ),
    );

    // The board can change while the sheet is open, so re-check the cell.
    if (sell == true && game.board.at(index)?.id == tile.id) {
      game.sellTile(index);
    }
  }

  Future<void> _openMystery(
    BuildContext context,
    GameController game,
    int index,
  ) async {
    final BoardTile? tile = game.board.at(index);
    if (tile == null || !tile.mystery) return;

    final AdsService ads = context.read<AdsService>();
    final L l = L.of(context);

    final MysteryChoice? choice = await showDialog<MysteryChoice>(
      context: context,
      builder: (BuildContext context) => MysteryDialog(
        accent: game.world.accent,
        freeBand: game.mysteryFreeBand,
        rewardBand: game.mysteryRewardBand,
        canWatchAd: ads.rewardedReady,
      ),
    );
    if (choice == null) return;

    bool rewarded = false;
    if (choice == MysteryChoice.rewarded) {
      rewarded = await ads.showRewarded();
      if (!context.mounted) return;
      if (!rewarded) {
        showToast(context, l.adNotReady);
        return;
      }
    }

    // The board can change while dialogs/ads are open, so re-check the cell.
    if (game.board.at(index)?.id != tile.id) return;

    final CreatureSpec? spec = game.openMystery(index, rewarded: rewarded);
    if (spec != null && context.mounted) {
      showToast(context, l.mysteryGranted(game.nameOf(spec)));
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.game, required this.world});

  final GameController game;
  final World world;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CurrencyPill(
                icon: Icons.favorite_rounded,
                color: AppTheme.heart,
                value: game.hearts,
                // Hearts arrive every tick, so only a jump beyond the meadow's
                // own output counts as something worth flashing about.
                passiveRate: game.state.totalIncome,
                subtitle: l.perMinute(formatCount(game.state.totalIncome * 60)),
              ),
              const SizedBox(width: 8),
              CurrencyPill(
                icon: Icons.diamond_rounded,
                color: AppTheme.gem,
                value: game.gems.toDouble(),
              ),
              const Spacer(),
              // Stacked rather than side by side so both boosts still fit on
              // the narrowest phone.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (game.boostActive)
                    BoostChip(
                      label: formatDuration(game.boostRemaining),
                      semanticsLabel: l.boostActive(
                        formatDuration(game.boostRemaining),
                      ),
                    ),
                  if (game.boostActive && game.basketBoostActive)
                    const SizedBox(height: 4),
                  if (game.basketBoostActive)
                    BoostChip(
                      icon: Icons.fast_forward_rounded,
                      color: AppTheme.brand,
                      label: formatDuration(game.basketBoostRemaining),
                      semanticsLabel: l.basketBoostActive(
                        formatDuration(game.basketBoostRemaining),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.game, required this.world});

  final GameController game;
  final World world;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    final bool boardFull = game.board.isFull;
    final String hint = boardFull
        ? l.hintBoardFull
        : game.state.tutorialSeen
            ? l.hintDragToMerge
            : l.hintTapBasket;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .82),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                hint,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: AppTheme.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          BasketButton(
            progress: game.basketProgress,
            accent: world.accent,
            label: l.basket,
            full: boardFull,
            onTap: () {
              if (!game.tapBasket()) {
                showToast(context, l.hintBoardFull);
              } else {
                game.markTutorialSeen();
              }
            },
          ),
        ],
      ),
    );
  }
}
