import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The spark ring thrown off when two friends become one.
///
/// Drawn as a foreground painter over the cell, so it reads on top of the
/// creature that just appeared rather than behind it, and it deliberately
/// paints a little past the cell edge — the board's stack is unclipped so the
/// sparks can spill onto the neighbouring perches.
///
/// Everything is derived from [t], a single 0..1 progress, so the whole effect
/// is one repaint per frame with no per-particle state to keep.
class MergeBurstPainter extends CustomPainter {
  const MergeBurstPainter({required this.t, required this.color});

  /// 0 at the instant of the merge, 1 once the last spark has faded.
  final double t;

  /// The meadow's accent, so a burst belongs to the place it happened in.
  final Color color;

  static const int _sparks = 9;

  /// Sparks sit off the grid axes; aligned with them they read as a plus sign.
  static const double _spin = math.pi / 9;

  /// The three layers run on their own clocks rather than one shared fade.
  ///
  /// The order matters: the flash has to clear before the eye lands on the new
  /// creature, and the ring has to clear before it stops reading as an impact
  /// and starts reading as a selection reticle drawn around the cell. Only the
  /// sparks are allowed to run the full length.
  static const double _flashLife = .26;
  static const double _ringLife = .55;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;

    final double unit = math.min(size.width, size.height);
    // The creature stands in the upper part of its box, so the burst is
    // centred on its body rather than on the geometric middle.
    final Offset centre = Offset(size.width / 2, size.height * .46);

    _flash(canvas, centre, unit);
    _ring(canvas, centre, unit);
    _sparkle(canvas, centre, unit);
  }

  /// A soft bloom at the point of impact.
  ///
  /// Kept faint and brief on purpose: the whole reason for the animation is to
  /// show off the creature underneath it, so a flash that hides it is working
  /// against itself.
  void _flash(Canvas canvas, Offset centre, double unit) {
    final double life = t / _flashLife;
    if (life >= 1) return;
    final double alpha = 1 - life * life;

    final double radius = unit * (.19 + .16 * Curves.easeOut.transform(life));
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: .42 * alpha),
            color.withValues(alpha: .20 * alpha),
            color.withValues(alpha: 0),
          ],
          stops: const <double>[0, .45, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
  }

  /// One expanding hoop, thinning as it goes. This is the part that carries at
  /// arm's length, and the part that overstays its welcome fastest.
  void _ring(Canvas canvas, Offset centre, double unit) {
    final double life = t / _ringLife;
    if (life >= 1) return;
    // Cubed, so the hoop is already ghosting by the time it reaches full size.
    final double alpha = math.pow(1 - life, 3).toDouble();
    final double out = Curves.easeOutCubic.transform(life);

    canvas.drawCircle(
      centre,
      unit * (.14 + .34 * out),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * .05 * (1 - out) + .3
        ..color = Colors.white.withValues(alpha: .60 * alpha),
    );
  }

  /// Short outward dashes that stretch as they leave and shorten as they land.
  /// They outlive both other layers — a couple of stray sparks still drifting
  /// is what keeps the moment from ending on a hard cut.
  void _sparkle(Canvas canvas, Offset centre, double unit) {
    final double out = Curves.easeOutCubic.transform(t);
    final double alpha = math.pow(1 - t, 1.4).toDouble();

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      // The hairline floor keeps a spark from vanishing on a small cell before
      // it has finished fading out.
      ..strokeWidth = unit * .045 * alpha + .3;

    for (int i = 0; i < _sparks; i++) {
      final double angle = i / _sparks * math.pi * 2 + _spin;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final double near = unit * (.16 + .54 * out);
      final double far = near + unit * .14 * (1 - out);

      // Alternating white and accent keeps the ring lively without needing a
      // per-spark palette.
      paint.color =
          (i.isEven ? Colors.white : color).withValues(alpha: .95 * alpha);
      canvas.drawLine(
        centre + direction * near,
        centre + direction * far,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MergeBurstPainter old) => old.t != t || old.color != color;
}
