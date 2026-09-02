import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/accessory.dart';
import '../../data/creature_spec.dart';
import '../../render/creature_painter.dart';

/// A creature with a gentle idle: it breathes, bobs and blinks.
///
/// Each instance derives its phase from the creature id so a meadow full of
/// friends never moves in lockstep.
class CreatureView extends StatefulWidget {
  const CreatureView(
    this.spec, {
    super.key,
    this.size,
    this.animate = true,
    this.shadow = true,
    this.accessory,
  });

  final CreatureSpec spec;
  final double? size;
  final bool animate;
  final bool shadow;

  /// What this friend is wearing, if anything.
  final AccessoryType? accessory;

  @override
  State<CreatureView> createState() => _CreatureViewState();
}

class _CreatureViewState extends State<CreatureView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _phase;
  late final double _blinkOffset;

  @override
  void initState() {
    super.initState();
    final int seed = widget.spec.id.hashCode;
    _phase = (seed % 1000) / 1000 * math.pi * 2;
    _blinkOffset = (seed % 397) / 397;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  /// The idle is pure decoration, so it is the first thing to go when the
  /// platform asks for less motion — and a meadow of creatures breathing in
  /// place is exactly the sort of thing that setting exists for.
  bool get _animating =>
      widget.animate && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  void _syncAnimation() {
    if (_animating) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  // Reads MediaQuery, so the decision cannot be made in initState.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant CreatureView old) {
    super.didUpdateWidget(old);
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 1 = open, 0 = shut. A quick double-dip once per cycle.
  double _blink(double t) {
    final double local = (t + _blinkOffset) % 1.0;
    const double start = 0.86;
    const double length = 0.07;
    if (local < start || local > start + length) return 1;
    final double p = (local - start) / length;
    return (math.cos(p * math.pi * 2) * .5 + .5).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool animating = _animating;

    // The bob is a translation, so it is handed to the compositor rather than
    // to the painter: the body is drawn once, cached as a layer, and slid up
    // and down for free. Baked into the canvas instead it would redraw every
    // path, gradient and blur sixty times a second, for every friend on the
    // board at once — which is what made dragging feel like wading.
    final Widget bobbing = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        final double bob = animating ? math.sin(t * math.pi * 2 + _phase) : 0;
        return FractionalTranslation(
          translation: Offset(0, bob * CreaturePainter.bobTravelFor(widget.spec)),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: CreaturePainter(
                widget.spec,
                accessory: widget.accessory,
                shadow: false,
                // Blink is the only thing left that genuinely needs new paint,
                // and it is off for all but a moment of each six-second cycle.
                blink: animating ? _blink(t) : 1,
              ),
              // A childless CustomPaint shrinks to the smallest allowed size,
              // so without this it collapses on any axis the parent leaves
              // loose.
              size: Size.infinite,
              isComplex: true,
              willChange: false,
            ),
          ),
        );
      },
    );

    // The contact shadow stays on the ground while the body rises off it, so it
    // is a second, permanently still painter rather than part of the first.
    final Widget painted = !widget.shadow
        ? bobbing
        : Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(
                painter: CreaturePainter(widget.spec, body: false),
                size: Size.infinite,
                willChange: false,
              ),
              bobbing,
            ],
          );

    // Keeps the idle from dirtying whatever the creature is standing on — the
    // perch, the rest of the meadow and the HUD all share one layer otherwise.
    final Widget bounded = RepaintBoundary(child: painted);

    return widget.size == null
        ? bounded
        : SizedBox.square(dimension: widget.size, child: bounded);
  }
}
