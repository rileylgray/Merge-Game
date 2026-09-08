import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Samples a continuous animation on a coarse grid, and reports a change only
/// when the sample actually moves.
///
/// The ambient animations in this game — a creature breathing, a mote of
/// pollen drifting across the sky — travel a couple of pixels a second. Driven
/// straight off an [Animation] they rebuild and recomposite at the display's
/// refresh rate anyway, which on a 120Hz phone is six times a second of real
/// work for every visible creature to move a tenth of a pixel. Sampling them
/// at [kIdleFps] costs nothing visible on motion this slow and cuts the
/// standing frame cost of a full meadow by the same factor.
///
/// It also decides how often the expensive things repaint: a creature's blink
/// is derived from this clock, and every distinct blink value re-records the
/// whole creature's picture. Stepping the clock steps that too.
class SteppedAnimation extends ValueNotifier<double> {
  SteppedAnimation(this.parent, {required this.steps}) : super(0) {
    parent.addListener(_sample);
    _sample();
  }

  /// Samples [parent] often enough for [fps] updates over one [cycle] of it.
  factory SteppedAnimation.fps(
    Animation<double> parent, {
    required Duration cycle,
    int fps = kIdleFps,
  }) =>
      SteppedAnimation(
        parent,
        steps: (cycle.inMilliseconds * fps / 1000).round().clamp(1, 100000),
      );

  final Animation<double> parent;

  /// How many samples one full 0..1 pass of [parent] is divided into.
  final int steps;

  void _sample() {
    // ValueNotifier is already silent when the value is unchanged, which is
    // the whole point: most frames land in the same step as the last one and
    // nothing downstream hears about them.
    value = (parent.value * steps).floorToDouble() / steps;
  }

  @override
  void dispose() {
    parent.removeListener(_sample);
    super.dispose();
  }
}

/// The update rate for purely ambient motion.
///
/// Deliberately well under the display's refresh rate. Nothing that uses it
/// moves fast enough for the difference to be visible, and everything that
/// uses it is on screen in bulk.
const int kIdleFps = 20;
