import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/creature_spec.dart';
import '../../data/worlds.dart';
import '../../l10n/app_localizations.dart';
import '../../state/game_controller.dart';
import '../widgets/creature_view.dart';
import '../world_labels.dart';

/// Meadow picker: shows progress per meadow and what unlocks the next one.
class MeadowsScreen extends StatelessWidget {
  const MeadowsScreen({super.key, required this.onEnterMeadow});

  /// Called after a successful switch so the shell can jump to the board.
  final VoidCallback onEnterMeadow;

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final L l = L.of(context);

    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(title: Text(l.meadowsTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: kWorlds.length,
        separatorBuilder: (BuildContext context, int i) =>
            const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int i) {
          final World world = kWorlds[i];
          return _MeadowCard(
            world: world,
            game: game,
            active: game.world.id == world.id,
            onEnter: () {
              if (game.switchWorld(world.id)) onEnterMeadow();
            },
          );
        },
      ),
    );
  }
}

class _MeadowCard extends StatelessWidget {
  const _MeadowCard({
    required this.world,
    required this.game,
    required this.active,
    required this.onEnter,
  });

  final World world;
  final GameController game;
  final bool active;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);
    final bool unlocked = game.isWorldUnlocked(world);
    final int found = game.discoveredCount(world.id);
    // The meadow's best-known friend stands in as its cover art.
    final CreatureSpec cover =
        world.creatureAt(found > 0 ? found.clamp(1, world.maxTier) : 1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[world.skyTop, world.skyBottom],
        ),
        border: Border.all(
          color: active ? world.accent : Colors.transparent,
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 64,
                  height: 64,
                  child: unlocked
                      ? CreatureView(
                          cover,
                          animate: false,
                          accessory: game.accessoryFor(cover),
                        )
                      : Icon(
                          Icons.lock_rounded,
                          size: 34,
                          color: Colors.white.withValues(alpha: .85),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        worldName(l, world.id),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                      ),
                      Text(
                        worldDescription(l, world.id),
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.25,
                          color: Colors.white.withValues(alpha: .92),
                          shadows: const <Shadow>[
                            Shadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(16),
              ),
              child: unlocked
                  ? Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                l.collectionProgress(found, world.maxTier),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: active ? null : onEnter,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                backgroundColor: world.accent,
                                foregroundColor: world.onAccent,
                              ),
                              child: Text(l.enterMeadow),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: found / world.maxTier,
                            minHeight: 7,
                            backgroundColor: Colors.black.withValues(alpha: .07),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(world.accent),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        const Icon(Icons.lock_rounded, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.meadowLocked(
                              world.unlockRequirement,
                              worldName(l, kWorlds[world.order - 1].id),
                            ),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
