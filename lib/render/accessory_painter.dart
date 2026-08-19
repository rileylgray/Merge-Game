import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/accessory.dart';
import 'shading.dart';

/// Where on a creature an accessory may hang itself.
///
/// The creature painter builds one of these from its own anatomy so accessory
/// art never has to know anything about body plans; the shop icons build a
/// synthetic one so the same drawing code renders an item on its own.
class AccessoryAnchor {
  const AccessoryAnchor({
    required this.headBounds,
    required this.headTop,
    required this.faceCenter,
    required this.faceRadius,
    required this.bodyBounds,
    required this.neckCenter,
    required this.neckHalfWidth,
    this.eyeSpacing = 1.0,
  });

  /// A headless stand-in used to draw an item by itself, sized to [s].
  factory AccessoryAnchor.preview(double s) => AccessoryAnchor(
        headBounds: Rect.fromCenter(
          center: Offset(.5 * s, .40 * s),
          width: .50 * s,
          height: .48 * s,
        ),
        headTop: Offset(.5 * s, .16 * s),
        faceCenter: Offset(.5 * s, .42 * s),
        faceRadius: .24 * s,
        bodyBounds: Rect.fromLTRB(.24 * s, .56 * s, .76 * s, .96 * s),
        neckCenter: Offset(.5 * s, .64 * s),
        neckHalfWidth: .26 * s,
      );

  final Rect headBounds;

  /// Top of the head, already lifted clear of horns, antlers and tall ears —
  /// a hat rests here.
  final Offset headTop;

  final Offset faceCenter;
  final double faceRadius;
  final Rect bodyBounds;

  /// Where a collar sits: the top of the torso, on the centre line.
  final Offset neckCenter;
  final double neckHalfWidth;

  /// Copied from the spec so eyewear tracks eyes that are set wide or narrow.
  final double eyeSpacing;
}

/// Draws the things creatures wear.
///
/// Accessories keep their own fixed colours rather than borrowing the
/// creature's palette: a top hat that recolours per creature stops reading as
/// an object the friend picked up and starts reading as part of its body.
class AccessoryArt {
  const AccessoryArt._();

  // Wardrobe colours.
  static const Color _hatBlack = Color(0xFF37324A);
  static const Color _ribbonRed = Color(0xFFE0576E);
  static const Color _gold = Color(0xFFF3C33F);
  static const Color _partyPink = Color(0xFFFF8FB1);
  static const Color _pompomYellow = Color(0xFFFFD75E);
  static const Color _lensInk = Color(0xFF2A2733);
  static const Color _knitBlue = Color(0xFF6FBFE8);
  static const Color _capeCrimson = Color(0xFFC0392B);
  static const Color _leafGreen = Color(0xFF7FC97F);
  static const Color _petalWhite = Color(0xFFFFF6FA);
  static const Color _petalPink = Color(0xFFFFB3C7);

  /// Layer drawn before the body, for anything that hangs behind it.
  static void paintBack(
    Canvas canvas,
    double s,
    AccessoryType? type,
    AccessoryAnchor a,
  ) {
    if (type == AccessoryType.cape) _capeCloth(canvas, s, a);
  }

  /// Layer drawn over the finished creature.
  static void paintFront(
    Canvas canvas,
    double s,
    AccessoryType? type,
    AccessoryAnchor a,
  ) {
    switch (type) {
      case null:
        return;
      case AccessoryType.topHat:
        _topHat(canvas, s, a);
      case AccessoryType.partyHat:
        _partyHat(canvas, s, a);
      case AccessoryType.flowerCrown:
        _flowerCrown(canvas, s, a);
      case AccessoryType.crown:
        _crown(canvas, s, a);
      case AccessoryType.sunglasses:
        _sunglasses(canvas, s, a);
      case AccessoryType.bowTie:
        _bowTie(canvas, s, a);
      case AccessoryType.scarf:
        _scarf(canvas, s, a);
      case AccessoryType.headphones:
        _headphones(canvas, s, a);
      case AccessoryType.cape:
        _capeCollar(canvas, s, a);
    }
  }

  /// Draws [type] on its own, framed to fill [size] — the shop's swatch.
  static void paintIcon(Canvas canvas, Size size, AccessoryType type) {
    final double s = math.min(size.width, size.height);
    final Rect focus = _iconFocus(type);
    final double zoom =
        math.min(1 / focus.width, 1 / focus.height).clamp(1.0, 2.6);

    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    // Pull the item's own region into the middle of the box, then zoom in on
    // it: drawn at anchor scale a bow tie would sit marooned near the bottom.
    canvas.translate(s / 2, s / 2);
    canvas.scale(zoom);
    canvas.translate(-focus.center.dx * s, -focus.center.dy * s);
    paintBack(canvas, s, type, AccessoryAnchor.preview(s));
    paintFront(canvas, s, type, AccessoryAnchor.preview(s));
    canvas.restore();
  }

  /// Unit-square region of a preview anchor that each item actually covers.
  static Rect _iconFocus(AccessoryType type) => switch (type) {
        AccessoryType.topHat => const Rect.fromLTRB(.20, .00, .80, .34),
        AccessoryType.partyHat => const Rect.fromLTRB(.24, .00, .82, .32),
        AccessoryType.flowerCrown => const Rect.fromLTRB(.16, .02, .84, .34),
        AccessoryType.crown => const Rect.fromLTRB(.20, .00, .80, .30),
        AccessoryType.headphones => const Rect.fromLTRB(.14, .04, .86, .52),
        AccessoryType.sunglasses => const Rect.fromLTRB(.16, .30, .84, .56),
        AccessoryType.bowTie => const Rect.fromLTRB(.24, .50, .76, .78),
        AccessoryType.scarf => const Rect.fromLTRB(.18, .52, .82, .94),
        AccessoryType.cape => const Rect.fromLTRB(.14, .50, .86, .98),
      };

  // ------------------------------------------------------------------- hats

  /// A hat is drawn upright then tilted a few degrees around where it meets
  /// the head, which is the whole difference between "worn" and "balanced on".
  static void _tilted(
    Canvas canvas,
    Offset pivot,
    double radians,
    VoidCallback body,
  ) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(radians);
    canvas.translate(-pivot.dx, -pivot.dy);
    body();
    canvas.restore();
  }

  static void _topHat(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset t = a.headTop;
    final double hw = a.headBounds.width * .5;

    _tilted(canvas, t, -.10, () {
      // The brim sits a little *below* the crown of the skull: a hat resting
      // exactly on the outline reads as balanced there rather than worn.
      final Rect brim = Rect.fromCenter(
        center: Offset(t.dx, t.dy + hw * .24),
        width: hw * 1.58,
        height: hw * .36,
      );
      final Rect crown = Rect.fromCenter(
        center: Offset(t.dx, brim.center.dy - hw * .44),
        width: hw * .90,
        height: hw * .88,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(crown, Radius.circular(hw * .12)),
        volumeOf(_hatBlack, crown, lift: .16, drop: -.10),
      );
      // Band first, then the brim over it, so the ribbon tucks under the rim.
      final Rect band = Rect.fromLTRB(
        crown.left,
        crown.bottom - hw * .30,
        crown.right,
        crown.bottom - hw * .10,
      );
      canvas.drawRect(band, volumeOf(_ribbonRed, band, lift: .14));
      canvas.drawOval(brim, volumeOf(_hatBlack, brim, lift: .20, drop: -.16));
      canvas.drawOval(
        brim,
        strokeOf(shade(_hatBlack, -.20).withValues(alpha: .5), s * .008),
      );
      // Sheen across the crown so a very dark mass still shows its shape.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            crown.left + crown.width * .16,
            crown.top + crown.height * .14,
            crown.width * .16,
            crown.height * .52,
          ),
          Radius.circular(hw * .08),
        ),
        fillOf(Colors.white.withValues(alpha: .16)),
      );
    });
  }

  static void _partyHat(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset t = a.headTop;
    final double hw = a.headBounds.width * .5;

    _tilted(canvas, t, .16, () {
      final Offset apex = Offset(t.dx, t.dy - hw * .96);
      final Offset left = Offset(t.dx - hw * .50, t.dy + hw * .26);
      final Offset right = Offset(t.dx + hw * .50, t.dy + hw * .26);

      final Path cone = Path()
        ..moveTo(apex.dx, apex.dy)
        ..lineTo(right.dx, right.dy)
        // A cone sitting on a round head meets it along a curve, not a chord.
        ..quadraticBezierTo(t.dx, t.dy + hw * .48, left.dx, left.dy)
        ..close();
      canvas.drawPath(
        cone,
        volumeOf(_partyPink, cone.getBounds(), lift: .18, drop: -.14),
      );

      // Two chevrons following the taper, so the stripes wrap the cone.
      for (int i = 1; i <= 2; i++) {
        final double f = i / 3.0;
        final double y = apex.dy + (t.dy + hw * .28 - apex.dy) * f;
        final double half = hw * .52 * f;
        canvas.drawPath(
          Path()
            ..moveTo(t.dx - half, y)
            ..quadraticBezierTo(t.dx, y + hw * .14, t.dx + half, y),
          strokeOf(Colors.white.withValues(alpha: .85), s * .013),
        );
      }
      canvas.drawPath(
        cone,
        strokeOf(shade(_partyPink, -.26).withValues(alpha: .45), s * .008),
      );
      canvas.drawCircle(
        apex,
        hw * .17,
        volumeOf(
          _pompomYellow,
          Rect.fromCircle(center: apex, radius: hw * .20),
          lift: .18,
        ),
      );
    });
  }

  static void _flowerCrown(Canvas canvas, double s, AccessoryAnchor a) {
    final Rect h = a.headBounds;
    final double rx = h.width * .52;
    final double ry = h.height * .52;
    final Offset c = Offset(h.center.dx, h.center.dy - (h.top - a.headTop.dy));

    Offset onHead(double ang) =>
        Offset(c.dx + math.cos(ang) * rx, c.dy + math.sin(ang) * ry);

    // Vine first: a single arc the flowers are then threaded onto.
    canvas.drawPath(
      Path()
        ..moveTo(onHead(math.pi).dx, onHead(math.pi).dy)
        ..quadraticBezierTo(
          c.dx,
          c.dy - ry * 1.42,
          onHead(0).dx,
          onHead(0).dy,
        ),
      strokeOf(shade(_leafGreen, -.10), s * .012),
    );

    const int count = 5;
    for (int i = 0; i < count; i++) {
      final double ang = math.pi + math.pi * (i + .5) / count;
      final Offset p = onHead(ang);
      final double r = h.width * (i == count ~/ 2 ? .10 : .085);
      final Color petal = i.isEven ? _petalWhite : _petalPink;
      for (int k = 0; k < 5; k++) {
        final double pa = k * math.pi * 2 / 5 + i;
        final Offset pc =
            Offset(p.dx + math.cos(pa) * r * .62, p.dy + math.sin(pa) * r * .62);
        canvas.drawCircle(
          pc,
          r * .52,
          volumeOf(petal, Rect.fromCircle(center: pc, radius: r * .52),
              lift: .10),
        );
      }
      canvas.drawCircle(p, r * .34, fillOf(_pompomYellow));
    }
  }

  static void _crown(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset t = a.headTop;
    final double hw = a.headBounds.width * .5;
    final double half = hw * .70;
    final double baseY = t.dy + hw * .38;
    final double peakY = baseY - hw * .66;
    final double dipY = baseY - hw * .26;

    final Path p = Path()..moveTo(t.dx - half, baseY);
    for (int i = 0; i < 3; i++) {
      final double x0 = t.dx - half + (half * 2) * i / 3;
      final double x1 = t.dx - half + (half * 2) * (i + 1) / 3;
      p
        ..lineTo((x0 + x1) / 2, i == 1 ? peakY - hw * .16 : peakY)
        ..lineTo(x1, i == 2 ? baseY : dipY);
    }
    p.close();

    canvas.drawPath(p, volumeOf(_gold, p.getBounds(), lift: .22, drop: -.16));
    canvas.drawPath(p, strokeOf(shade(_gold, -.28), s * .008));

    // Band across the base, so the points sit on something.
    final Rect band = Rect.fromLTRB(
      t.dx - half,
      baseY - hw * .18,
      t.dx + half,
      baseY + hw * .06,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(band, Radius.circular(hw * .06)),
      volumeOf(shade(_gold, .04), band, lift: .18),
    );
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(
        Offset(t.dx + i * half * .58, band.center.dy),
        hw * .09,
        fillOf(i == 0 ? _ribbonRed : const Color(0xFF5BC8F5)),
      );
    }
  }

  // ------------------------------------------------------------------ face

  static void _sunglasses(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset f = a.faceCenter;
    final double r = a.faceRadius;
    final double dx = r * .46 * a.eyeSpacing;
    final double lensW = r * .74;
    final double lensH = r * .54;
    final double y = f.dy - r * .08;

    for (final int sign in const <int>[-1, 1]) {
      final Rect lens = Rect.fromCenter(
        center: Offset(f.dx + sign * dx, y),
        width: lensW,
        height: lensH,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(lens, Radius.circular(lensH * .42)),
        volumeOf(_lensInk, lens, lift: .22, drop: -.06),
      );
      // A single raking highlight is what makes a dark lens read as glass.
      canvas.drawPath(
        Path()
          ..moveTo(lens.left + lens.width * .18, lens.bottom - lens.height * .18)
          ..lineTo(lens.left + lens.width * .52, lens.top + lens.height * .16)
          ..lineTo(lens.left + lens.width * .70, lens.top + lens.height * .16)
          ..lineTo(lens.left + lens.width * .36, lens.bottom - lens.height * .18)
          ..close(),
        fillOf(Colors.white.withValues(alpha: .26)),
      );
    }
    final Paint frame = strokeOf(shade(_lensInk, -.06), s * .014);
    canvas.drawLine(
      Offset(f.dx - dx + lensW * .42, y - lensH * .12),
      Offset(f.dx + dx - lensW * .42, y - lensH * .12),
      frame,
    );
    // Temples, running back toward the ears.
    for (final int sign in const <int>[-1, 1]) {
      canvas.drawLine(
        Offset(f.dx + sign * (dx + lensW * .46), y - lensH * .16),
        Offset(f.dx + sign * (r * 1.02), y - lensH * .30),
        frame,
      );
    }
  }

  static void _headphones(Canvas canvas, double s, AccessoryAnchor a) {
    final Rect h = a.headBounds;
    final double lift = h.top - a.headTop.dy;
    final Rect band = Rect.fromCenter(
      center: Offset(h.center.dx, h.center.dy - lift * .5),
      width: h.width * 1.14,
      height: h.height * 1.10,
    );
    canvas.drawArc(band, math.pi * 1.06, math.pi * .88, false,
        strokeOf(shade(_hatBlack, .06), s * .036));
    canvas.drawArc(band, math.pi * 1.10, math.pi * .40, false,
        strokeOf(Colors.white.withValues(alpha: .22), s * .012));

    for (final int sign in const <int>[-1, 1]) {
      final Offset c = Offset(
        h.center.dx + sign * h.width * .56,
        h.center.dy + h.height * .06,
      );
      final Rect cup = Rect.fromCenter(
        center: c,
        width: h.width * .30,
        height: h.height * .44,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cup, Radius.circular(cup.width * .46)),
        volumeOf(_hatBlack, cup, lift: .18),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cup.deflate(cup.width * .24),
            Radius.circular(cup.width * .30)),
        fillOf(_ribbonRed.withValues(alpha: .85)),
      );
    }
  }

  // ------------------------------------------------------------------ neck

  static void _bowTie(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset c = a.neckCenter;
    final double w = a.neckHalfWidth * .58;
    final double h = w * .78;

    for (final int sign in const <int>[-1, 1]) {
      final Path wing = Path()
        ..moveTo(c.dx + sign * w * .16, c.dy)
        ..quadraticBezierTo(
          c.dx + sign * w * .90,
          c.dy - h * 1.06,
          c.dx + sign * w * 1.04,
          c.dy - h * .52,
        )
        ..quadraticBezierTo(
          c.dx + sign * w * 1.12,
          c.dy + h * .58,
          c.dx + sign * w * .92,
          c.dy + h * .92,
        )
        ..quadraticBezierTo(
          c.dx + sign * w * .52,
          c.dy + h * .60,
          c.dx + sign * w * .16,
          c.dy,
        )
        ..close();
      canvas.drawPath(
        wing,
        volumeOf(_ribbonRed, wing.getBounds(), lift: .18, drop: -.14),
      );
      canvas.drawPath(
        wing,
        strokeOf(shade(_ribbonRed, -.28).withValues(alpha: .55), s * .008),
      );
    }
    final Rect knot = Rect.fromCenter(
      center: c,
      width: w * .46,
      height: h * .92,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(knot, Radius.circular(w * .16)),
      volumeOf(shade(_ribbonRed, -.10), knot, lift: .20),
    );
  }

  static void _scarf(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset c = a.neckCenter;
    final double half = a.neckHalfWidth * .92;
    final double h = half * .52;

    final Rect band = Rect.fromCenter(
      center: c,
      width: half * 2,
      height: h,
    );
    final RRect wrap = RRect.fromRectAndRadius(band, Radius.circular(h * .44));
    canvas.drawRRect(wrap, volumeOf(_knitBlue, band, lift: .16, drop: -.14));

    // Knit ribs, clipped to the band so they never overshoot the ends.
    canvas.save();
    canvas.clipRRect(wrap);
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(c.dx + i * half * .34, band.top),
        Offset(c.dx + i * half * .34 - h * .18, band.bottom),
        strokeOf(Colors.white.withValues(alpha: .28), s * .010),
      );
    }
    canvas.restore();

    // One end hangs down the front, with a fringe on the bottom.
    final Rect tail = Rect.fromLTWH(
      c.dx + half * .18,
      band.bottom - h * .18,
      half * .48,
      h * 1.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tail, Radius.circular(h * .22)),
      volumeOf(shade(_knitBlue, -.06), tail, lift: .12),
    );
    for (int i = 0; i < 3; i++) {
      final double x = tail.left + tail.width * (.22 + i * .28);
      canvas.drawLine(
        Offset(x, tail.bottom - h * .06),
        Offset(x, tail.bottom + h * .30),
        strokeOf(shade(_knitBlue, -.14), s * .009),
      );
    }
    canvas.drawRRect(wrap,
        strokeOf(shade(_knitBlue, -.28).withValues(alpha: .45), s * .008));
  }

  static void _capeCloth(Canvas canvas, double s, AccessoryAnchor a) {
    final Rect b = a.bodyBounds;
    final Offset c = a.neckCenter;
    final double top = c.dy + b.height * .02;
    final double bottom = b.bottom + b.height * .06;

    // Flares wider than the body and ends in two soft scallops, so it reads as
    // cloth falling rather than a rectangle taped on behind.
    final Path cloth = Path()
      ..moveTo(c.dx - a.neckHalfWidth * .78, top)
      ..cubicTo(
        b.left - b.width * .30,
        top + b.height * .40,
        b.left - b.width * .26,
        bottom - b.height * .18,
        b.left - b.width * .18,
        bottom,
      )
      ..quadraticBezierTo(
        b.center.dx - b.width * .18,
        bottom - b.height * .16,
        b.center.dx,
        bottom - b.height * .02,
      )
      ..quadraticBezierTo(
        b.center.dx + b.width * .18,
        bottom - b.height * .16,
        b.right + b.width * .18,
        bottom,
      )
      ..cubicTo(
        b.right + b.width * .26,
        bottom - b.height * .18,
        b.right + b.width * .30,
        top + b.height * .40,
        c.dx + a.neckHalfWidth * .78,
        top,
      )
      ..close();

    canvas.drawPath(
      cloth,
      volumeOf(_capeCrimson, cloth.getBounds(), lift: .14, drop: -.20),
    );
    canvas.drawPath(
      cloth,
      strokeOf(shade(_capeCrimson, -.26).withValues(alpha: .5), s * .009),
    );
    // Two folds, to give the drape somewhere to catch light.
    for (final int sign in const <int>[-1, 1]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + sign * a.neckHalfWidth * .40, top + b.height * .08)
          ..quadraticBezierTo(
            c.dx + sign * b.width * .52,
            top + b.height * .52,
            c.dx + sign * b.width * .60,
            bottom - b.height * .12,
          ),
        strokeOf(shade(_capeCrimson, -.16).withValues(alpha: .55), s * .010),
      );
    }
  }

  static void _capeCollar(Canvas canvas, double s, AccessoryAnchor a) {
    final Offset c = a.neckCenter;
    final double half = a.neckHalfWidth * .80;
    final Rect strap = Rect.fromCenter(
      center: c,
      width: half * 2,
      height: half * .34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(strap, Radius.circular(strap.height * .5)),
      volumeOf(_capeCrimson, strap, lift: .18),
    );
    canvas.drawCircle(
      c,
      half * .26,
      volumeOf(_gold, Rect.fromCircle(center: c, radius: half * .26),
          lift: .24),
    );
    canvas.drawCircle(
      Offset(c.dx - half * .08, c.dy - half * .08),
      half * .07,
      fillOf(Colors.white.withValues(alpha: .6)),
    );
  }
}
