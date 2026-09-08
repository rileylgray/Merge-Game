import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/game_controller.dart';

/// Rebuilds its subtree on the game's income tick — and only while that
/// subtree is actually on screen.
///
/// Hearts arrive four times a second forever, so anything that redraws with
/// them is the app's single biggest standing cost. Two things keep that bill
/// small. It listens to [GameController.ticks] rather than to the controller,
/// so a tick rebuilds the running numbers and nothing else; and it drops the
/// subscription entirely when [TickerMode] is disabled, which the shell does
/// for every tab but the visible one. A meadow left on the collection screen
/// stops redrawing altogether instead of quietly running at four frames a
/// second behind another page.
class TickBuilder extends StatefulWidget {
  const TickBuilder({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, Widget? child) builder;

  /// Handed back to [builder] untouched, for the part of the subtree that does
  /// not depend on the tick.
  final Widget? child;

  @override
  State<TickBuilder> createState() => _TickBuilderState();
}

class _TickBuilderState extends State<TickBuilder> {
  TickNotifier? _ticks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Both are dependencies of this element, so this runs again if either the
    // controller or the enclosing TickerMode changes.
    final TickNotifier ticks = context.read<GameController>().ticks;
    final TickNotifier? wanted = TickerMode.of(context) ? ticks : null;
    if (identical(wanted, _ticks)) return;
    _ticks?.removeListener(_onTick);
    _ticks = wanted;
    _ticks?.addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticks?.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}
