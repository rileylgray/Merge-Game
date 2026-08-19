import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/worlds.dart';

// The things creatures stand on.
//
// The board used to be a grid of identical rounded rectangles, which read as UI
// sitting *on top of* the meadow rather than as part of it. Each cell now gets a
// piece of scenery instead — a rock, a grassy tussock, a lily pad — mixed from
// the meadow's own palette, so the board reads as a clearing full of perches
// with a creature on each one. Like the creatures and the backdrop it is all
// drawn in code: a new world only has to name which perches belong to it.

/// Where a creature's feet land, as a fraction of the cell's height.
///
/// Every style puts its standing surface here, so a creature can be placed the
/// same way no matter what it happens to be sitting on.
const double kPerchSurface = .72;

/// One piece of scenery a creature can stand on.
enum PerchStyle { rock, mound, stump, lilyPad, mushroom, crystal, slab, log }

/// The perches that belong to each meadow. First entry is the most common.
const Map<String, List<PerchStyle>> _kWorldPerches = <String, List<PerchStyle>>{
  'day': <PerchStyle>[PerchStyle.mound, PerchStyle.rock, PerchStyle.stump],
  'night': <PerchStyle>[PerchStyle.rock, PerchStyle.mushroom, PerchStyle.log],
  'water': <PerchStyle>[PerchStyle.lilyPad, PerchStyle.rock, PerchStyle.log],
  'mythical': <PerchStyle>[
    PerchStyle.crystal,
    PerchStyle.mound,
    PerchStyle.mushroom,
  ],
  'prehistoric': <PerchStyle>[PerchStyle.slab, PerchStyle.rock, PerchStyle.log],
};

/// Picks the perch for one cell.
///
/// Deterministic, so a meadow looks the same every time it is opened, and
/// nudged away from whatever the cell to the left drew so the board never
/// stripes.
PerchStyle perchStyleFor(World world, int index, int columns) {
  final List<PerchStyle> styles =
      _kWorldPerches[world.id] ?? const <PerchStyle>[PerchStyle.mound];
  int pick(int i) =>
      (_hash(i ^ world.id.hashCode) ~/ 7) % styles.length;
  int choice = pick(index);
  if (index % columns != 0 && choice == pick(index - 1)) {
    choice = (choice + 1) % styles.length;
  }
  return styles[choice];
}

/// A cheap, stable scrambler. Only needs to look unpatterned, not be random.
int _hash(int v) {
  int x = v & 0x7FFFFFFF;
  x = (x ^ (x >> 15)) * 0x2C1B3C6D & 0x7FFFFFFF;
  x = (x ^ (x >> 12)) * 0x297A2D39 & 0x7FFFFFFF;
  return x ^ (x >> 15);
}

// ------------------------------------------------------------------ palette

/// Scenery colours for one meadow.
///
/// Everything is mixed from the meadow's own ground colour so a perch always
/// belongs to the world it stands in, and always separates from it: on a pale
/// meadow the stone goes darker, on a dark meadow it goes lighter.
@immutable
class PerchPalette {
  const PerchPalette({
    required this.stone,
    required this.stoneLit,
    required this.stoneDark,
    required this.grass,
    required this.grassLit,
    required this.grassDark,
    required this.wood,
    required this.woodLit,
    required this.woodDark,
    required this.pale,
    required this.accent,
    required this.darkMeadow,
  });

  factory PerchPalette.of(World world) {
    final HSLColor ground = HSLColor.fromColor(world.ground);
    final bool dark = ground.lightness < .40;
    final double lift = dark ? .26 : -.18;

    HSLColor shift(HSLColor c, double amount) =>
        c.withLightness((c.lightness + amount).clamp(0.0, 1.0));

    final HSLColor stone = ground
        .withSaturation((ground.saturation * .34).clamp(0.0, 1.0))
        .withLightness((ground.lightness + lift).clamp(0.0, 1.0));
    final HSLColor grass = ground
        .withSaturation((ground.saturation * 1.1).clamp(0.0, 1.0))
        .withLightness((ground.lightness + lift * .55).clamp(0.0, 1.0));
    final HSLColor wood = HSLColor.fromAHSL(1, 26, .40, dark ? .34 : .40);

    return PerchPalette(
      stone: stone.toColor(),
      stoneLit: shift(stone, .11).toColor(),
      stoneDark: shift(stone, -.13).toColor(),
      grass: grass.toColor(),
      grassLit: shift(grass, .11).toColor(),
      grassDark: shift(grass, -.15).toColor(),
      wood: wood.toColor(),
      woodLit: shift(wood, .11).toColor(),
      woodDark: shift(wood, -.13).toColor(),
      pale: HSLColor.fromAHSL(1, 38, .34, dark ? .78 : .88).toColor(),
      accent: world.accent,
      darkMeadow: dark,
    );
  }

  final Color stone;
  final Color stoneLit;
  final Color stoneDark;
  final Color grass;
  final Color grassLit;
  final Color grassDark;
  final Color wood;
  final Color woodLit;
  final Color woodDark;

  /// Mushroom stalks and lily blooms.
  final Color pale;

  final Color accent;

  /// True when the meadow floor is dark, which flips how perches are shaded.
  final bool darkMeadow;

  @override
  bool operator ==(Object other) =>
      other is PerchPalette &&
      other.stone == stone &&
      other.grass == grass &&
      other.wood == wood &&
      other.accent == accent;

  @override
  int get hashCode => Object.hash(stone, grass, wood, accent);
}

// ------------------------------------------------------------------ painter

class PerchPainter extends CustomPainter {
  const PerchPainter({
    required this.palette,
    required this.style,
    required this.seed,
    this.highlight = 0,
    this.highlightColor,
  });

  final PerchPalette palette;
  final PerchStyle style;

  /// Varies size, offset and mirroring so two neighbours of the same style
  /// never look stamped from the same mould.
  final int seed;

  /// 0..1 drop feedback: 1 is a merge landing here.
  final double highlight;

  /// Colour of the drop feedback. Defaults to the meadow accent.
  final Color? highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height);
    final int h = _hash(seed);
    final double scale = .93 + (h % 100) / 100 * .13;
    final double dx = ((h ~/ 100) % 100) / 100 * .06 - .03;
    final bool flip = (h ~/ 10000).isOdd;

    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    _groundShadow(canvas, s, scale, dx);

    // Scale about the standing surface, so jitter never moves the spot a
    // creature's feet have to land on.
    canvas
      ..translate(s * (.5 + dx), s * kPerchSurface)
      ..scale(flip ? -scale : scale, scale)
      ..translate(-s * .5, -s * kPerchSurface);

    if (highlight > 0) _glow(canvas, s);

    final Path outline = switch (style) {
      PerchStyle.rock => _rock(canvas, s),
      PerchStyle.mound => _mound(canvas, s),
      PerchStyle.stump => _stump(canvas, s),
      PerchStyle.lilyPad => _lilyPad(canvas, s),
      PerchStyle.mushroom => _mushroom(canvas, s),
      PerchStyle.crystal => _crystal(canvas, s),
      PerchStyle.slab => _slab(canvas, s),
      PerchStyle.log => _log(canvas, s),
    };

    if (highlight > 0) {
      canvas.drawPath(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * .028 * highlight
          ..color = Colors.white.withValues(alpha: .85 * highlight),
      );
    }

    canvas.restore();
  }

  Color get _highlight => highlightColor ?? palette.accent;

  /// The perch's own contact shadow on the meadow floor.
  void _groundShadow(Canvas canvas, double s, double scale, double dx) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * (.5 + dx), s * .915),
        width: s * .78 * scale,
        height: s * .13 * scale,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: .17)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .035),
    );
  }

  void _glow(Canvas canvas, double s) {
    final Rect r = Rect.fromCenter(
      center: Offset(s * .5, s * .78),
      width: s * 1.15,
      height: s * .85,
    );
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            _highlight.withValues(alpha: .70 * highlight),
            _highlight.withValues(alpha: 0),
          ],
        ).createShader(r),
    );
  }

  // -------------------------------------------------------------- utilities

  Paint _vertical(double s, Color top, Color bottom, double from, double to) =>
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[top, bottom],
        ).createShader(Rect.fromLTRB(0, s * from, s, s * to));

  Paint _line(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width;

  /// A clump of moss or grass, used to bed a hard perch into the meadow.
  void _moss(Canvas canvas, double s, List<Offset> blobs) {
    final Paint paint = Paint()..color = palette.grass.withValues(alpha: .92);
    for (final Offset b in blobs) {
      canvas.drawCircle(Offset(b.dx * s, b.dy * s), s * .045, paint);
    }
  }

  /// Blades sprouting from [x], [y] and leaning [lean].
  void _blades(Canvas canvas, double s, List<Offset> roots) {
    final Paint paint = _line(palette.grassDark, s * .017);
    for (int i = 0; i < roots.length; i++) {
      final Offset r = roots[i];
      final double lean = i.isEven ? -1 : 1;
      final double h = s * (.075 + (i % 3) * .015);
      canvas.drawPath(
        Path()
          ..moveTo(r.dx * s, r.dy * s)
          ..quadraticBezierTo(
            r.dx * s + lean * h * .18,
            r.dy * s - h * .62,
            r.dx * s + lean * h * .60,
            r.dy * s - h,
          ),
        paint,
      );
    }
  }

  void _bloom(Canvas canvas, double s, Offset at, double r) {
    final Paint petal = Paint()..color = palette.accent.withValues(alpha: .92);
    final Offset c = Offset(at.dx * s, at.dy * s);
    for (int p = 0; p < 5; p++) {
      final double a = p * math.pi * 2 / 5;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, r * .78, petal);
    }
    canvas.drawCircle(c, r * .6, Paint()..color = const Color(0xFFFFE9A3));
  }

  // ----------------------------------------------------------------- styles

  Path _rock(Canvas canvas, double s) {
    final Path body = Path()
      ..moveTo(.11 * s, .87 * s)
      ..cubicTo(.09 * s, .79 * s, .15 * s, .72 * s, .27 * s, .70 * s)
      ..cubicTo(.40 * s, .675 * s, .55 * s, .675 * s, .69 * s, .705 * s)
      ..cubicTo(.82 * s, .735 * s, .92 * s, .79 * s, .90 * s, .87 * s)
      ..cubicTo(.885 * s, .945 * s, .125 * s, .945 * s, .11 * s, .87 * s)
      ..close();

    canvas.drawPath(body, _vertical(s, palette.stoneLit, palette.stoneDark, .66, .95));

    // A lit cap along the top, clipped to the rock, is what makes it read as a
    // surface a creature can stand on rather than a flat blob.
    canvas
      ..save()
      ..clipPath(body)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(.48 * s, .70 * s),
          width: .58 * s,
          height: .14 * s,
        ),
        Paint()..color = palette.stoneLit,
      )
      ..drawPath(
        Path()
          ..moveTo(.34 * s, .79 * s)
          ..lineTo(.39 * s, .87 * s),
        _line(palette.stoneDark.withValues(alpha: .55), s * .012),
      )
      ..drawPath(
        Path()
          ..moveTo(.64 * s, .77 * s)
          ..lineTo(.60 * s, .85 * s),
        _line(palette.stoneDark.withValues(alpha: .45), s * .010),
      )
      ..restore();

    _moss(canvas, s, const <Offset>[
      Offset(.17, .855),
      Offset(.25, .885),
      Offset(.11, .895),
    ]);
    _blades(canvas, s, const <Offset>[Offset(.20, .845), Offset(.85, .875)]);
    return body;
  }

  Path _mound(Canvas canvas, double s) {
    final Path body = Path()
      ..moveTo(.06 * s, .90 * s)
      ..cubicTo(.07 * s, .78 * s, .22 * s, .69 * s, .50 * s, .69 * s)
      ..cubicTo(.78 * s, .69 * s, .93 * s, .78 * s, .94 * s, .90 * s)
      ..cubicTo(.94 * s, .96 * s, .06 * s, .96 * s, .06 * s, .90 * s)
      ..close();

    canvas.drawPath(body, _vertical(s, palette.grassLit, palette.grassDark, .66, .96));
    canvas
      ..save()
      ..clipPath(body)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(.50 * s, .715 * s),
          width: .64 * s,
          height: .13 * s,
        ),
        Paint()..color = palette.grassLit,
      )
      ..restore();

    // Blades only around the rim, so nothing grows through the creature.
    _blades(canvas, s, const <Offset>[
      Offset(.13, .855),
      Offset(.21, .785),
      Offset(.30, .735),
      Offset(.71, .735),
      Offset(.81, .79),
      Offset(.89, .86),
    ]);
    if (seed.isEven) _bloom(canvas, s, const Offset(.16, .77), s * .036);
    return body;
  }

  Path _stump(Canvas canvas, double s) {
    final Rect top = Rect.fromCenter(
      center: Offset(.5 * s, .72 * s),
      width: .64 * s,
      height: .18 * s,
    );
    final Path body = Path()
      ..addArc(top, math.pi, math.pi)
      ..lineTo(.82 * s, .855 * s)
      ..cubicTo(.82 * s, .925 * s, .18 * s, .925 * s, .18 * s, .855 * s)
      ..close();

    canvas.drawPath(body, _vertical(s, palette.wood, palette.woodDark, .70, .93));

    // Bark striations before the cap, so they stop cleanly at the rim.
    canvas.save();
    canvas.clipPath(body);
    for (int i = 0; i < 5; i++) {
      final double x = (.24 + i * .13) * s;
      canvas.drawPath(
        Path()
          ..moveTo(x, .74 * s)
          ..quadraticBezierTo(x + s * .012, .82 * s, x, .90 * s),
        _line(palette.woodDark.withValues(alpha: .38), s * .014),
      );
    }
    canvas.restore();

    canvas.drawOval(top, Paint()..color = palette.woodLit);
    for (double f in const <double>[.66, .36]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: top.center,
          width: top.width * f,
          height: top.height * f,
        ),
        _line(palette.wood.withValues(alpha: .55), s * .010),
      );
    }

    _moss(canvas, s, const <Offset>[Offset(.20, .875), Offset(.27, .90)]);
    return body;
  }

  Path _lilyPad(Canvas canvas, double s) {
    final Rect pad = Rect.fromCenter(
      center: Offset(.5 * s, .755 * s),
      width: .84 * s,
      height: .30 * s,
    );

    // Ripples first: the pad floats on them.
    for (final double f in const <double>[1.32, 1.14]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: pad.center.translate(0, s * .02),
          width: pad.width * f,
          height: pad.height * f,
        ),
        _line(Colors.white.withValues(alpha: .18), s * .011),
      );
    }

    // The notch is what says "lily pad" rather than "green disc".
    final Path body = Path.combine(
      PathOperation.difference,
      Path()..addOval(pad),
      Path()
        ..moveTo(.5 * s, .755 * s)
        ..lineTo(.99 * s, .705 * s)
        ..lineTo(.99 * s, .80 * s)
        ..close(),
    );

    canvas.drawPath(body, _vertical(s, palette.grassLit, palette.grassDark, .60, .92));
    canvas.save();
    canvas.clipPath(body);
    for (int i = 0; i < 9; i++) {
      final double a = math.pi * 2 * i / 9 + .35;
      canvas.drawPath(
        Path()
          ..moveTo(.5 * s, .755 * s)
          ..lineTo(
            .5 * s + math.cos(a) * .44 * s,
            .755 * s + math.sin(a) * .16 * s,
          ),
        _line(palette.grassDark.withValues(alpha: .40), s * .009),
      );
    }
    canvas.restore();
    canvas.drawPath(body, _line(palette.grassLit.withValues(alpha: .65), s * .010));

    if (seed.isEven) _bloom(canvas, s, const Offset(.19, .705), s * .040);
    return body;
  }

  Path _mushroom(Canvas canvas, double s) {
    final Path stalk = Path()
      ..moveTo(.42 * s, .76 * s)
      ..cubicTo(.405 * s, .86 * s, .43 * s, .91 * s, .45 * s, .925 * s)
      ..lineTo(.55 * s, .925 * s)
      ..cubicTo(.57 * s, .91 * s, .595 * s, .86 * s, .58 * s, .76 * s)
      ..close();
    canvas.drawPath(stalk, _vertical(s, palette.pale, _mix(palette.pale, Colors.black, .18), .74, .94));

    final Path cap = Path()
      ..moveTo(.13 * s, .775 * s)
      ..cubicTo(.15 * s, .705 * s, .32 * s, .672 * s, .50 * s, .672 * s)
      ..cubicTo(.68 * s, .672 * s, .85 * s, .705 * s, .87 * s, .775 * s)
      ..cubicTo(.80 * s, .818 * s, .20 * s, .818 * s, .13 * s, .775 * s)
      ..close();

    final Color capColor = palette.accent;
    canvas.drawPath(
      cap,
      _vertical(s, _mix(capColor, Colors.white, .22), _mix(capColor, Colors.black, .26), .66, .82),
    );
    canvas.save();
    canvas.clipPath(cap);
    for (final (Offset at, double r) spot in <(Offset, double)>[
      (const Offset(.24, .725), .048),
      (const Offset(.75, .720), .042),
      (const Offset(.39, .698), .030),
      (const Offset(.63, .762), .034),
    ]) {
      canvas.drawCircle(
        Offset(spot.$1.dx * s, spot.$1.dy * s),
        spot.$2 * s,
        Paint()..color = palette.pale.withValues(alpha: .88),
      );
    }
    canvas.restore();

    _moss(canvas, s, const <Offset>[Offset(.30, .905), Offset(.68, .90)]);
    return cap;
  }

  Path _crystal(Canvas canvas, double s) {
    final Path body = Path()
      ..moveTo(.5 * s, .655 * s)
      ..lineTo(.79 * s, .715 * s)
      ..lineTo(.71 * s, .905 * s)
      ..lineTo(.5 * s, .945 * s)
      ..lineTo(.29 * s, .905 * s)
      ..lineTo(.21 * s, .715 * s)
      ..close();

    final Rect halo = Rect.fromCenter(
      center: Offset(.5 * s, .79 * s),
      width: 1.1 * s,
      height: .8 * s,
    );
    canvas.drawOval(
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            palette.accent.withValues(alpha: .34),
            palette.accent.withValues(alpha: 0),
          ],
        ).createShader(halo),
    );

    // Two body facets meeting at a front edge, then a bright top face: three
    // flat tones are enough to read as faceted glass.
    canvas.drawPath(
      Path()
        ..moveTo(.21 * s, .715 * s)
        ..lineTo(.5 * s, .775 * s)
        ..lineTo(.5 * s, .945 * s)
        ..lineTo(.29 * s, .905 * s)
        ..close(),
      Paint()..color = _mix(palette.accent, Colors.black, .30),
    );
    canvas.drawPath(
      Path()
        ..moveTo(.79 * s, .715 * s)
        ..lineTo(.5 * s, .775 * s)
        ..lineTo(.5 * s, .945 * s)
        ..lineTo(.71 * s, .905 * s)
        ..close(),
      Paint()..color = _mix(palette.accent, Colors.black, .10),
    );
    canvas.drawPath(
      Path()
        ..moveTo(.5 * s, .655 * s)
        ..lineTo(.79 * s, .715 * s)
        ..lineTo(.5 * s, .775 * s)
        ..lineTo(.21 * s, .715 * s)
        ..close(),
      Paint()..color = _mix(palette.accent, Colors.white, .55),
    );

    // A shard leaning against the base keeps the silhouette from being a
    // perfectly symmetrical gem.
    canvas.drawPath(
      Path()
        ..moveTo(.16 * s, .945 * s)
        ..lineTo(.24 * s, .805 * s)
        ..lineTo(.31 * s, .945 * s)
        ..close(),
      Paint()..color = _mix(palette.accent, Colors.white, .30),
    );
    return body;
  }

  Path _slab(Canvas canvas, double s) {
    final Path body = Path()
      ..moveTo(.13 * s, .755 * s)
      ..lineTo(.30 * s, .682 * s)
      ..lineTo(.72 * s, .682 * s)
      ..lineTo(.89 * s, .755 * s)
      ..lineTo(.87 * s, .845 * s)
      ..lineTo(.74 * s, .898 * s)
      ..lineTo(.28 * s, .898 * s)
      ..lineTo(.15 * s, .845 * s)
      ..close();
    canvas.drawPath(body, _vertical(s, palette.stone, palette.stoneDark, .74, .91));

    final Path face = Path()
      ..moveTo(.13 * s, .755 * s)
      ..lineTo(.30 * s, .682 * s)
      ..lineTo(.72 * s, .682 * s)
      ..lineTo(.89 * s, .755 * s)
      ..lineTo(.74 * s, .818 * s)
      ..lineTo(.28 * s, .818 * s)
      ..close();
    canvas.drawPath(face, Paint()..color = palette.stoneLit);

    canvas.save();
    canvas.clipPath(face);
    canvas.drawPath(
      Path()
        ..moveTo(.18 * s, .77 * s)
        ..lineTo(.33 * s, .735 * s)
        ..lineTo(.31 * s, .70 * s),
      _line(palette.stoneDark.withValues(alpha: .50), s * .011),
    );
    canvas.drawPath(
      Path()
        ..moveTo(.86 * s, .765 * s)
        ..lineTo(.70 * s, .79 * s)
        ..lineTo(.66 * s, .818 * s),
      _line(palette.stoneDark.withValues(alpha: .40), s * .010),
    );
    canvas.restore();

    // Rubble at the foot, so the slab looks fallen rather than placed.
    final Paint pebble = Paint()..color = palette.stone;
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(.13 * s, .905 * s),
          width: .12 * s,
          height: .07 * s,
        ),
        pebble,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(.87 * s, .893 * s),
          width: .09 * s,
          height: .055 * s,
        ),
        pebble,
      );
    return body;
  }

  Path _log(Canvas canvas, double s) {
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTRB(.06 * s, .72 * s, .94 * s, .875 * s),
      Radius.circular(.077 * s),
    );
    canvas.drawRRect(body, _vertical(s, palette.woodLit, palette.woodDark, .70, .89));

    canvas.save();
    canvas.clipRRect(body);
    for (int i = 0; i < 3; i++) {
      final double y = (.775 + i * .035) * s;
      canvas.drawPath(
        Path()
          ..moveTo(.08 * s, y)
          ..quadraticBezierTo(.45 * s, y - s * .012, .82 * s, y),
        _line(palette.woodDark.withValues(alpha: .30), s * .012),
      );
    }
    canvas.restore();

    // The sawn end, with rings, is the tell that this is a log and not a bar.
    final Rect end = Rect.fromCenter(
      center: Offset(.855 * s, .7975 * s),
      width: .13 * s,
      height: .155 * s,
    );
    canvas.drawOval(end, Paint()..color = palette.wood);
    canvas.drawOval(
      Rect.fromCenter(
        center: end.center,
        width: end.width * .5,
        height: end.height * .5,
      ),
      _line(palette.woodDark.withValues(alpha: .55), s * .009),
    );

    _moss(canvas, s, const <Offset>[Offset(.14, .735), Offset(.24, .725)]);
    _blades(canvas, s, const <Offset>[Offset(.19, .72), Offset(.30, .725)]);
    return Path()..addRRect(body);
  }

  @override
  bool shouldRepaint(covariant PerchPainter old) =>
      old.style != style ||
      old.seed != seed ||
      old.highlight != highlight ||
      old.palette != palette ||
      old.highlightColor != highlightColor;
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
