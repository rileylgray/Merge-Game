import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/balance.dart';
import '../../data/accessory.dart';
import '../../data/creature_spec.dart';
import '../../data/worlds.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../render/merge_burst.dart';
import '../../render/perch_painter.dart';
import 'creature_view.dart';
import 'mystery_basket.dart';

/// The merge grid.
///
/// There is no board: the grid is a clearing, and every cell is a piece of
/// scenery a creature can stand on — a rock, a tussock, a lily pad, whatever
/// belongs to this meadow. Sized to fit its box exactly — the meadow never
/// scrolls, so a tile is always reachable with one thumb.
class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.board,
    required this.world,
    required this.onMove,
    required this.onInspect,
    required this.onOpenMystery,
    required this.mergedCell,
    required this.accessoryOf,
    required this.nameOf,
  });

  final BoardState board;
  final World world;

  /// What the creature of a given spec is wearing, if anything.
  final AccessoryType? Function(CreatureSpec spec) accessoryOf;

  /// The localized name of a creature, for the screen reader.
  final String Function(CreatureSpec spec) nameOf;

  /// Called with (from, to) when a tile is dropped on another cell.
  final void Function(int from, int to) onMove;

  /// Long-press: opens the release / details sheet.
  final void Function(int index) onInspect;

  /// Tap on a mystery basket: opens the choice popup.
  final void Function(int index) onOpenMystery;

  /// Cell that just completed a merge, so it can pop.
  final int? mergedCell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const int cols = Balance.columns;
        final int rows = board.rows;

        final double cell = (constraints.maxWidth / cols)
            .clamp(0.0, math.max(0, constraints.maxHeight / rows));

        final PerchPalette palette = PerchPalette.of(world);

        return Center(
          child: SizedBox(
            width: cell * cols,
            height: cell * rows,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int r = 0; r < rows; r++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int c = 0; c < cols; c++)
                        _Cell(
                          index: r * cols + c,
                          size: cell,
                          board: board,
                          world: world,
                          palette: palette,
                          justMerged: mergedCell == r * cols + c,
                          onMove: onMove,
                          onInspect: onInspect,
                          onOpenMystery: onOpenMystery,
                          accessoryOf: accessoryOf,
                          nameOf: nameOf,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.index,
    required this.size,
    required this.board,
    required this.world,
    required this.palette,
    required this.justMerged,
    required this.onMove,
    required this.onInspect,
    required this.onOpenMystery,
    required this.accessoryOf,
    required this.nameOf,
  });

  final int index;
  final double size;
  final BoardState board;
  final World world;
  final PerchPalette palette;
  final bool justMerged;
  final void Function(int from, int to) onMove;
  final void Function(int index) onInspect;
  final void Function(int index) onOpenMystery;
  final AccessoryType? Function(CreatureSpec spec) accessoryOf;
  final String Function(CreatureSpec spec) nameOf;

  @override
  Widget build(BuildContext context) {
    final BoardTile? tile = board.at(index);

    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> d) => d.data != index,
      onAcceptWithDetails: (DragTargetDetails<int> d) => onMove(d.data, index),
      builder: (
        BuildContext context,
        List<int?> candidates,
        List<Object?> rejected,
      ) {
        final int? incoming = candidates.isEmpty ? null : candidates.first;
        final BoardTile? dragged = incoming == null ? null : board.at(incoming);
        final bool wouldMerge = dragged != null &&
            tile != null &&
            !dragged.mystery &&
            !tile.mystery &&
            dragged.tier == tile.tier &&
            tile.tier < world.maxTier;
        // An empty perch is a legal landing too, and used to give no feedback
        // at all; it gets the same lift in a plainer colour.
        final bool wouldLand = dragged != null && tile == null;

        return SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Its own layer, and a leaf rather than the creature's parent:
              // the scenery is stone-still except for the 140ms of drop
              // feedback, so it has no business being re-rastered every time
              // the friend standing on it breathes.
              RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 140),
                  tween: Tween<double>(
                    begin: 0,
                    end: wouldMerge ? 1 : (wouldLand ? .55 : 0),
                  ),
                  builder: (BuildContext context, double lift, Widget? child) =>
                      CustomPaint(
                    painter: PerchPainter(
                      palette: palette,
                      style: perchStyleFor(world, index, Balance.columns),
                      seed: index,
                      highlight: lift,
                      highlightColor: wouldMerge ? world.accent : Colors.white,
                    ),
                    size: Size.square(size),
                    isComplex: true,
                  ),
                ),
              ),
              if (tile != null) _tileContent(context, tile),
            ],
          ),
        );
      },
    );
  }

  Widget _tileContent(BuildContext context, BoardTile tile) {
    final CreatureSpec? spec =
        tile.mystery ? null : world.creatureAt(tile.tier);
    final AccessoryType? worn = spec == null ? null : accessoryOf(spec);

    // A wrapped basket has no creature to show yet, and answers to a tap
    // rather than to the long-press that releases a friend.
    final Widget body = spec == null
        ? MysteryBasketView(accent: world.accent, key: ValueKey<int>(tile.id))
        : _MergeCelebration(
            key: ValueKey<String>('pop-$index-${tile.tier}'),
            active: justMerged,
            accent: world.accent,
            child: CreatureView(
              spec,
              accessory: worn,
              key: ValueKey<int>(tile.id),
            ),
          );

    final Widget dragImage = spec == null
        ? MysteryBasketView(accent: world.accent)
        : CreatureView(spec, accessory: worn);

    final L l = L.of(context);
    // Without this the whole meadow is silent to a screen reader: the creatures
    // are painted, so there is no text anywhere for it to read.
    final String label = spec == null
        ? l.boardMysteryLabel
        : l.boardTileLabel(nameOf(spec), tile.tier);

    return Semantics(
      container: true,
      button: true,
      label: label,
      child: Draggable<int>(
        data: index,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        // The creature under the thumb is redrawn at every pointer sample, and
        // it rides in the overlay above the whole app — without a boundary of
        // its own each move repaints the meadow behind it.
        feedback: RepaintBoundary(
          child: Transform.translate(
            offset: Offset(-size * .62, -size * .78),
            child: SizedBox.square(
              dimension: size * 1.24,
              child: IgnorePointer(child: dragImage),
            ),
          ),
        ),
        // Hides the friend on the perch it is leaving. This used to be a second
        // copy of the same idea — an Opacity driven by board-level drag state —
        // which cost a rebuild of every cell in the meadow at each drag start
        // and end, to no visible effect.
        childWhenDragging: const SizedBox.shrink(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: tile.mystery ? () => onOpenMystery(index) : null,
          onLongPress: tile.mystery
              ? () => onOpenMystery(index)
              : () => onInspect(index),
          // The creature stands *on* the perch: it takes the upper part of the
          // cell, with its feet landing on the standing surface. The gesture
          // box stays the full cell, so the perch is draggable too.
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  left: size * .10,
                  top: 0,
                  width: size * .80,
                  height: size * .80,
                  child: body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The celebration when two friends become one: a squash-and-stretch pop on
/// the newcomer, and a ring of sparks thrown past the edge of the cell.
///
/// Both run off one controller so they can never drift apart, and the sparks
/// are a foreground painter rather than a stacked widget — nothing to lay out,
/// and no cost at all on the cells that are not currently celebrating.
class _MergeCelebration extends StatefulWidget {
  const _MergeCelebration({
    super.key,
    required this.active,
    required this.accent,
    required this.child,
  });

  final bool active;
  final Color accent;
  final Widget child;

  @override
  State<_MergeCelebration> createState() => _MergeCelebrationState();
}

class _MergeCelebrationState extends State<_MergeCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  /// The pop lands in the first three quarters; the sparks outlive it slightly
  /// so the cell is never briefly still before the ring has faded.
  late final Animation<double> _scale = Tween<double>(
    begin: 1.32,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .75, curve: Curves.elasticOut),
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _MergeCelebration old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        return CustomPaint(
          // Null while idle, so a settled meadow does no burst painting at all.
          foregroundPainter: t <= 0 || t >= 1
              ? null
              : MergeBurstPainter(t: t, color: widget.accent),
          child: child,
        );
      },
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
