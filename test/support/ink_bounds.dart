import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/render/creature_painter.dart';

/// Alpha below this is glow and blur fringe, not something the eye reads as
/// part of the creature.
const int kInkAlpha = 28;

/// Clear space kept between the ink and each edge of the box. The board gives
/// a creature box a tenth of the cell spare on either side, so this is
/// breathing room rather than the only thing stopping a collision.
const double kMargin = 0.02;

/// The fit that brings ink measured with [CreatureFit.raw] inside the box.
///
/// Scale is capped at [CreatureFit.maxScale] and otherwise set by whichever of
/// width and headroom runs out first; the ground line stays where every other
/// creature's is. Only then does the art shift sideways, and only by as much as
/// it has to — a fox is drawn over its perch, not over the midpoint of its
/// tail.
CreatureFit fitFromInk(Rect raw) {
  const double g = CreatureFit.groundY;
  const double target = CreatureFit.kGroundTarget;
  // The idle lifts the body by up to kBob, and the crown must clear the top
  // edge at the top of that lift too.
  final double top = (target - kMargin) / (g - raw.top + CreaturePainter.kBob);
  final double bottom = raw.bottom <= g
      ? double.infinity
      : (1 - kMargin - target) / (raw.bottom - g);
  final double wide = (1 - 2 * kMargin) / raw.width;
  double k = CreatureFit.maxScale;
  for (final double limit in <double>[top, bottom, wide]) {
    if (limit < k) k = limit;
  }
  // Truncated, not rounded, so the stored value never overshoots.
  k = (k * 1000).floorToDouble() / 1000;

  final double lo = kMargin - .5 - k * (raw.left - .5);
  final double hi = 1 - kMargin - .5 - k * (raw.right - .5);
  // Equal when width was the binding limit, and then rounding can cross them.
  final double dx = lo >= hi ? (lo + hi) / 2 : 0.0.clamp(lo, hi);
  return CreatureFit(k, (dx * 1000).roundToDouble() / 1000);
}

/// Where [spec] actually puts paint, as fractions of its paint box, when drawn
/// with [fit] (the real fit when null).
///
/// Rendered onto a canvas three boxes wide so ink that runs off the box is
/// measured rather than cropped — that overflow is the whole point.
Future<Rect> measureInk(
  CreatureSpec spec, {
  CreatureFit? fit,
  double box = 240,
  double bob = 0,
}) async {
  final int px = (box * 3).round();
  final ui.PictureRecorder rec = ui.PictureRecorder();
  final Canvas canvas = Canvas(rec);
  canvas.translate(box, box);
  CreaturePainter(spec, fitOverride: fit, bob: bob).paint(
    canvas,
    Size.square(box),
  );
  final ui.Image img = await rec.endRecording().toImage(px, px);
  final ByteData data = (await img.toByteData())!;
  img.dispose();

  int minX = px, minY = px, maxX = -1, maxY = -1;
  for (int y = 0; y < px; y++) {
    final int row = y * px * 4;
    for (int x = 0; x < px; x++) {
      if (data.getUint8(row + x * 4 + 3) < kInkAlpha) continue;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }
  if (maxX < 0) return Rect.zero;
  return Rect.fromLTRB(
    (minX - box) / box,
    (minY - box) / box,
    (maxX + 1 - box) / box,
    (maxY + 1 - box) / box,
  );
}
