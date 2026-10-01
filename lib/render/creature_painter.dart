import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/accessory.dart';
import '../data/creature_spec.dart';
import 'accessory_painter.dart';
import 'creature_art/creature_art.dart';
import 'creature_art/kit.dart';
import 'creature_fit.dart';
import 'smooth_stroke_canvas.dart';

export 'creature_fit.dart' show CreatureFit;

/// Paints a creature from its hand-drawn vector artwork.
///
/// Every one of the 150 is drawn by its own routine in `creature_art/`, out of
/// the shared sticker vocabulary in `kit.dart`. Layout is a unit square scaled
/// to whatever box it is given, so the same painter serves the 56px board
/// tiles and the 260px collection hero.
class CreaturePainter extends CustomPainter {
  const CreaturePainter(
    this.spec, {
    this.shadow = true,
    this.body = true,
    this.bob = 0,
    this.blink = 1,
    this.accessory,
    this.fitOverride,
  });

  final CreatureSpec spec;

  /// Worn over the finished creature, or null for an undressed one.
  final AccessoryType? accessory;

  /// Soft contact shadow under the creature.
  final bool shadow;

  /// The creature itself. Switching it off leaves nothing but the shadow.
  ///
  /// The two halves are separable because the body is the expensive one and
  /// the only thing the idle does to it is slide it up and down. Drawn into its
  /// own layer it can be rastered once and merely nudged thereafter, while the
  /// shadow stays put on the ground.
  final bool body;

  /// -1..1 idle bob offset, applied to everything except the shadow.
  final double bob;

  /// 1 = eyes open, 0 = fully closed.
  final double blink;

  /// Replaces the measured fit — the tool that measures it draws with
  /// [CreatureFit.raw] to see where the ink really lands.
  @visibleForTesting
  final CreatureFit? fitOverride;

  /// How far [bob] of 1 lifts the body, in unit layout before the fit scale.
  static const double kBob = 0.022;

  /// The artwork for [spec].
  static CreatureArt artFor(CreatureSpec spec) {
    return kCreatureArt[spec.id] ?? _missing;
  }

  /// A plain stand-in, so a creature added without artwork still draws.
  /// `test/widget_test.dart` fails until it has some.
  static const CreatureArt _missing = CreatureArt(_drawMissing);

  static void _drawMissing(Pen p) {
    p.part(circle(.5, .62, .26), const Color(0xFFDDD6E8), shine: 1);
    p.eyes(.5, .60, .09, .045);
  }

  /// How this creature is sized and placed in its tile.
  ///
  /// Measured from the rendered ink rather than guessed from its parts: a
  /// crab's claws, a dragon's wings and a swordfish's bill all run sideways,
  /// and only the real ink knows where they end.
  static CreatureFit fitFor(CreatureSpec spec) =>
      kCreatureFits[spec.id] ?? const CreatureFit(.84, 0);

  CreatureFit get _fit => fitOverride ?? fitFor(spec);

  /// How far [bob] of 1 lifts the body, as a fraction of the paint box's short
  /// side. Public so a caller that would rather translate the body itself lands
  /// it in exactly the same place.
  static double bobTravelFor(CreatureSpec spec) => kBob * fitFor(spec).scale;

  /// A stable per-creature seed. `String.hashCode` is not promised to be the
  /// same from one run to the next, and freckles should not move.
  static int _seed(String id) {
    int h = 0x811C9DC5;
    for (final int unit in id.codeUnits) {
      h = ((h ^ unit) * 0x01000193) & 0x7FFFFFFF;
    }
    return h;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    final CreatureFit fit = _fit;
    canvas.translate(s * (.5 + fit.dx), s * fit.groundTarget);
    canvas.scale(fit.scale);
    canvas.translate(-s * .5, -s * CreatureFit.groundY);
    // From here on everything is drawn in the unit layout.
    canvas.scale(s);

    final CreatureArt art = artFor(spec);
    if (shadow) _drawShadow(canvas, art);

    if (body) {
      canvas.save();
      canvas.translate(0, bob * kBob);
      final _Drawn drawn = _drawn(art);
      final AccessoryType? worn = accessory;
      // Accessories are drawn in the unit layout too, so their outlines need
      // the same help as the creature's.
      final Canvas dressed = SmoothStrokeCanvas(canvas);
      // The cape hangs *behind* the creature but is placed from landmarks only
      // the drawing knows, which is one more reason the drawing is recorded.
      if (worn != null) AccessoryArt.paintBack(dressed, 1, worn, drawn.anchor);
      canvas.drawPicture(drawn.picture);
      if (worn != null) AccessoryArt.paintFront(dressed, 1, worn, drawn.anchor);
      canvas.restore();
    }
    canvas.restore();
  }

  /// Recorded drawings, keyed by creature and eye state.
  ///
  /// The art fuses shapes with path boolean ops, and a meadow repaints each
  /// friend every time it blinks. A recording keeps the fused geometry, so
  /// replaying it costs a fraction of drawing it afresh — and being vector it
  /// serves every size the creature is shown at.
  static final Map<String, _Drawn> _recordings = <String, _Drawn>{};

  _Drawn _drawn(CreatureArt art) {
    // Blink only ever changes the eyes, and nobody can tell eleven steps of a
    // blink from a hundred.
    final int lid = (blink.clamp(0.0, 1.0) * 10).round();
    final String key = '${spec.id}|$lid';
    final _Drawn? hit = _recordings[key];
    if (hit != null) return hit;
    // Bounded so it cannot grow without limit; 150 creatures by a handful of
    // lid positions fits comfortably. Dropped rather than disposed: a
    // recording may still be referenced by a layer not yet composited.
    if (_recordings.length > 900) _recordings.clear();
    final ui.PictureRecorder rec = ui.PictureRecorder();
    // The art is drawn in a unit square, which Impeller would stroke as
    // polygons; see SmoothStrokeCanvas.
    final Pen pen = Pen(
      SmoothStrokeCanvas(Canvas(rec)),
      blink: lid / 10,
      seed: _seed(spec.id),
    );
    art.draw(pen);
    return _recordings[key] = _Drawn(rec.endRecording(), pen.anchor());
  }

  void _drawShadow(Canvas canvas, CreatureArt art) {
    final Rect r = Rect.fromCenter(
      center: Offset(.5 + art.shadowDx, CreatureFit.groundY + .012),
      width: art.shadow * 2,
      height: .075,
    );
    const Color ink = Color(0xFF2C2A3A);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            ink.withValues(alpha: .26),
            ink.withValues(alpha: .15),
            ink.withValues(alpha: 0),
          ],
          stops: const <double>[0, .58, 1],
        ).createShader(r),
    );
  }

  @override
  bool shouldRepaint(covariant CreaturePainter old) =>
      old.spec.id != spec.id ||
      old.bob != bob ||
      old.blink != blink ||
      old.shadow != shadow ||
      old.body != body ||
      old.accessory != accessory ||
      old.fitOverride != fitOverride;
}

/// One creature drawn once, with the landmarks its accessories hang from.
class _Drawn {
  const _Drawn(this.picture, this.anchor);

  final ui.Picture picture;
  final AccessoryAnchor anchor;
}
