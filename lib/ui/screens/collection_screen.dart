import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/accessory.dart';
import '../../data/creature_spec.dart';
import '../../data/worlds.dart';
import '../../l10n/app_localizations.dart';
import '../../state/game_controller.dart';
import '../widgets/accessory_picker.dart';
import '../widgets/creature_view.dart';
import '../world_labels.dart';

/// The catalogue: every creature in every meadow, silhouetted until found.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final L l = L.of(context);

    return DefaultTabController(
      length: kWorlds.length,
      initialIndex: kWorlds.indexWhere((World w) => w.id == game.world.id),
      child: Scaffold(
        backgroundColor: AppTheme.parchment,
        appBar: AppBar(
          title: Text(l.collectionTitle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _OverallProgress(
                    found: game.discoveredCount(),
                    total: kTotalCreatures,
                    label: l.collectionProgress(
                      game.discoveredCount(),
                      kTotalCreatures,
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  tabs: <Widget>[
                    for (final World w in kWorlds)
                      Tab(text: worldName(l, w.id)),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            for (final World w in kWorlds) _WorldGrid(world: w, game: game),
          ],
        ),
      ),
    );
  }
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({
    required this.found,
    required this.total,
    required this.label,
  });

  final int found;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink.withValues(alpha: .7),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : found / total,
            minHeight: 8,
            backgroundColor: Colors.black.withValues(alpha: .07),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brand),
          ),
        ),
      ],
    );
  }
}

class _WorldGrid extends StatelessWidget {
  const _WorldGrid({required this.world, required this.game});

  final World world;
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 128,
        childAspectRatio: .82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: world.creatures.length,
      itemBuilder: (BuildContext context, int i) {
        final CreatureSpec spec = world.creatures[i];
        return _CollectionCard(
          spec: spec,
          discovered: game.isDiscovered(spec),
          name: game.nameOf(spec),
          accessory: game.accessoryFor(spec),
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.spec,
    required this.discovered,
    required this.name,
    required this.accessory,
  });

  final CreatureSpec spec;
  final bool discovered;
  final String name;
  final AccessoryType? accessory;

  @override
  Widget build(BuildContext context) {
    final Color rarity = AppTheme.rarityColors[spec.rarity];

    return GestureDetector(
      onTap: discovered ? () => _showDetail(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: discovered
                ? rarity.withValues(alpha: .55)
                : Colors.black.withValues(alpha: .06),
            width: discovered ? 2 : 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: discovered
                    ? CreatureView(
                        spec,
                        animate: false,
                        shadow: false,
                        accessory: accessory,
                      )
                    : Opacity(
                        opacity: .16,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcATop,
                          ),
                          child: CreatureView(spec, animate: false, shadow: false),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(
                discovered ? name : '???',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: discovered
                      ? AppTheme.ink
                      : AppTheme.ink.withValues(alpha: .35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final L l = L.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 44),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Watches the controller so the hero re-dresses the instant a
              // different accessory is picked below it.
              Consumer<GameController>(
                builder: (BuildContext context, GameController game, Widget? _) =>
                    SizedBox(
                  height: 170,
                  child: CreatureView(spec, accessory: game.accessoryFor(spec)),
                ),
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
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
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
