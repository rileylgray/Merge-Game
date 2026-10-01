import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PathMetric, Tangent;

import 'package:flutter/material.dart';

import '../accessory_painter.dart';
import '../shading.dart';

export '../shading.dart' show fillOf, shade, strokeOf;

/// The drawing vocabulary every creature is built from.
///
/// The cast is drawn as soft, outlined stickers: each part is a flat fill with
/// one cel-shaded crescent on the side away from the light, a glossy spot
/// where the light lands, and a thick rounded outline in a deep tint of the
/// creature's own colour. That outline is what keeps a 56px friend legible on
/// every meadow backdrop, from pale grass to the night sky.
///
/// Everything is laid out in a unit square with the ground at y = 0.90 and
/// the creature centred on x = 0.5; the painter scales it to the tile.

// ------------------------------------------------------------------ geometry

/// Shorthand for a point in the unit layout.
Offset pt(double x, double y) => Offset(x, y);

/// Left then right, for mirrored pairs: `for (final double k in sides)`.
const List<double> sides = <double>[-1, 1];

Path oval(double cx, double cy, double rx, double ry) => Path()
  ..addOval(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
  );

Path circle(double cx, double cy, double r) => oval(cx, cy, r, r);

Path rrect(double l, double t, double r, double b, double radius) =>
    Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

/// A closed curve passing smoothly through every point (Catmull-Rom).
///
/// Points listed in [sharp] become corners instead. [tension] below 1 pulls
/// the curve tighter to the polygon, above 1 balloons it out.
Path blob(
  List<Offset> pts, {
  Set<int> sharp = const <int>{},
  double tension = 1,
}) {
  final int n = pts.length;
  final Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
  final double k = tension / 6;
  for (int i = 0; i < n; i++) {
    final Offset p0 = pts[(i - 1 + n) % n];
    final Offset p1 = pts[i];
    final Offset p2 = pts[(i + 1) % n];
    final Offset p3 = pts[(i + 2) % n];
    final Offset c1 = sharp.contains(i) ? p1 : p1 + (p2 - p0) * k;
    final Offset c2 = sharp.contains((i + 1) % n) ? p2 : p2 - (p3 - p1) * k;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

/// An open curve passing smoothly through every point.
Path curve(List<Offset> pts, {double tension = 1}) {
  final int n = pts.length;
  final Path path = Path()..moveTo(pts[0].dx, pts[0].dy);
  if (n == 2) return path..lineTo(pts[1].dx, pts[1].dy);
  final double k = tension / 6;
  for (int i = 0; i < n - 1; i++) {
    final Offset p0 = pts[math.max(i - 1, 0)];
    final Offset p1 = pts[i];
    final Offset p2 = pts[i + 1];
    final Offset p3 = pts[math.min(i + 2, n - 1)];
    final Offset c1 = p1 + (p2 - p0) * k;
    final Offset c2 = p2 - (p3 - p1) * k;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}

/// A left-right symmetric closed curve from its right half.
///
/// [half] runs from the top of the centre line, down the right-hand side, to
/// the bottom of the centre line; both ends should sit on x = [cx].
Path sym(
  List<Offset> half, {
  double cx = .5,
  Set<int> sharp = const <int>{},
  double tension = 1,
}) {
  final List<Offset> pts = <Offset>[...half];
  final Set<int> corners = <int>{...sharp};
  for (int i = half.length - 2; i >= 1; i--) {
    if (sharp.contains(i)) corners.add(pts.length);
    pts.add(Offset(2 * cx - half[i].dx, half[i].dy));
  }
  return blob(pts, sharp: corners, tension: tension);
}

/// A straight-sided polygon.
Path poly(List<Offset> pts) => Path()..addPolygon(pts, true);

/// A polygon with every corner rounded off by [radius].
Path roundPoly(List<Offset> pts, double radius) {
  final int n = pts.length;
  final Path path = Path();
  for (int i = 0; i < n; i++) {
    final Offset prev = pts[(i - 1 + n) % n];
    final Offset cur = pts[i];
    final Offset next = pts[(i + 1) % n];
    final double r1 = math.min(radius, (cur - prev).distance / 2);
    final double r2 = math.min(radius, (next - cur).distance / 2);
    final Offset a = cur + (prev - cur) / (prev - cur).distance * r1;
    final Offset b = cur + (next - cur) / (next - cur).distance * r2;
    if (i == 0) {
      path.moveTo(a.dx, a.dy);
    } else {
      path.lineTo(a.dx, a.dy);
    }
    path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
  }
  return path..close();
}

/// [p] mirrored across the vertical line x = [cx].
Path mirror(Path p, [double cx = .5]) {
  final Float64List m = Float64List(16)
    ..[0] = -1
    ..[5] = 1
    ..[10] = 1
    ..[15] = 1
    ..[12] = 2 * cx;
  return p.transform(m);
}

/// [p] rotated by [radians] about [pivot].
Path turn(Path p, Offset pivot, double radians) {
  final double c = math.cos(radians), s = math.sin(radians);
  final Float64List m = Float64List(16)
    ..[0] = c
    ..[1] = s
    ..[4] = -s
    ..[5] = c
    ..[10] = 1
    ..[15] = 1
    ..[12] = pivot.dx - c * pivot.dx + s * pivot.dy
    ..[13] = pivot.dy - s * pivot.dx - c * pivot.dy;
  return p.transform(m);
}

/// [p] scaled by [k] about [pivot].
Path grow(Path p, Offset pivot, double k, [double? ky]) {
  final Float64List m = Float64List(16)
    ..[0] = k
    ..[5] = ky ?? k
    ..[10] = 1
    ..[15] = 1
    ..[12] = pivot.dx * (1 - k)
    ..[13] = pivot.dy * (1 - (ky ?? k));
  return p.transform(m);
}

Path union(Path a, Path b) => Path.combine(PathOperation.union, a, b);

/// Several pieces fused into one silhouette, so a head, neck and body read as
/// one animal instead of parts stacked on top of each other.
Path unite(List<Path> pieces) => pieces.skip(1).fold(pieces.first, union);

Path minus(Path a, Path b) => Path.combine(PathOperation.difference, a, b);

Path both(Path a, Path b) => Path.combine(PathOperation.intersect, a, b);

/// A five-pointed star with softened tips.
Path star(
  double cx,
  double cy,
  double r, {
  double inner = .48,
  double rot = 0,
  double round = .0,
}) {
  final List<Offset> pts = <Offset>[];
  for (int i = 0; i < 10; i++) {
    final double a = -math.pi / 2 + rot + i * math.pi / 5;
    final double rr = i.isEven ? r : r * inner;
    pts.add(Offset(cx + math.cos(a) * rr, cy + math.sin(a) * rr));
  }
  return round > 0 ? roundPoly(pts, round) : poly(pts);
}

/// A teardrop leaning along [angle] (0 = point straight up).
Path tear(
  double cx,
  double cy,
  double r, {
  double angle = 0,
  double length = 1.9,
}) {
  final Path p = Path()
    ..moveTo(cx, cy - r * length)
    ..cubicTo(cx + r * .35, cy - r * 1.2, cx + r, cy - r * .55, cx + r, cy)
    ..arcToPoint(Offset(cx - r, cy), radius: Radius.circular(r))
    ..cubicTo(
      cx - r,
      cy - r * .55,
      cx - r * .35,
      cy - r * 1.2,
      cx,
      cy - r * length,
    )
    ..close();
  return angle == 0 ? p : turn(p, Offset(cx, cy), angle);
}

/// A leaf or petal from [a] to [b], [width] across at its widest.
Path leaf(Offset a, Offset b, double width, {double bend = 0}) {
  final Offset d = b - a;
  final Offset n = Offset(-d.dy, d.dx) / d.distance;
  final Offset m = (a + b) / 2 + n * bend;
  final Offset l = m + n * width / 2;
  final Offset r = m - n * width / 2;
  return Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(
      l.dx * 2 - (a.dx + b.dx) / 2,
      l.dy * 2 - (a.dy + b.dy) / 2,
      b.dx,
      b.dy,
    )
    ..quadraticBezierTo(
      r.dx * 2 - (a.dx + b.dx) / 2,
      r.dy * 2 - (a.dy + b.dy) / 2,
      a.dx,
      a.dy,
    )
    ..close();
}

/// Points evenly spaced around an ellipse, starting at [start] radians.
List<Offset> ring(
  double cx,
  double cy,
  double rx,
  double ry,
  int n, {
  double start = -math.pi / 2,
}) => <Offset>[
  for (int i = 0; i < n; i++)
    Offset(
      cx + math.cos(start + i * math.pi * 2 / n) * rx,
      cy + math.sin(start + i * math.pi * 2 / n) * ry,
    ),
];

/// A scalloped (cloud/fluff/mane) outline around an ellipse.
Path fluff(
  double cx,
  double cy,
  double rx,
  double ry,
  int lobes, {
  double depth = .16,
  double start = -math.pi / 2,
}) {
  final Path p = Path();
  for (int i = 0; i <= lobes; i++) {
    final double a = start + i * math.pi * 2 / lobes;
    final Offset q = Offset(cx + math.cos(a) * rx, cy + math.sin(a) * ry);
    if (i == 0) {
      p.moveTo(q.dx, q.dy);
      continue;
    }
    final double am = a - math.pi / lobes;
    final Offset c = Offset(
      cx + math.cos(am) * rx * (1 + depth * 2),
      cy + math.sin(am) * ry * (1 + depth * 2),
    );
    p.quadraticBezierTo(c.dx, c.dy, q.dx, q.dy);
  }
  return p..close();
}

/// A lumpy, furry mass: overlapping circles strung along a smooth curve
/// through [pts], their radii running through [radii] from end to end.
/// Bushy tails, manes and clouds. [spacing] is the gap between circles as a
/// fraction of their radius — small for a smooth edge, larger for tufts.
Path puffs(List<Offset> pts, List<double> radii, {double spacing = .45}) {
  final String key = '$pts|$radii|$spacing';
  final Path? hit = _puffCache[key];
  if (hit != null) return hit;
  if (_puffCache.length > 512) _puffCache.clear();
  return _puffCache[key] = _puffs(pts, radii, spacing);
}

/// Unions are the one expensive thing in the kit, and every creature asks for
/// the same handful of tails on every blink.
final Map<String, Path> _puffCache = <String, Path>{};

Path _puffs(List<Offset> pts, List<double> radii, double spacing) {
  final PathMetric m = curve(pts).computeMetrics().first;
  double radiusAt(double t) {
    final double f = t * (radii.length - 1);
    final int j = f.floor().clamp(0, radii.length - 2);
    return radii[j] + (radii[j + 1] - radii[j]) * (f - j);
  }

  Path out = Path();
  double d = 0;
  bool first = true;
  while (true) {
    final double t = (d / m.length).clamp(0.0, 1.0);
    final Offset c = m.getTangentForOffset(d.clamp(0.0, m.length))!.position;
    final double r = radiusAt(t);
    out = first ? circle(c.dx, c.dy, r) : union(out, circle(c.dx, c.dy, r));
    first = false;
    if (d >= m.length) break;
    d = math.min(d + math.max(r * spacing, .004), m.length);
  }
  return out;
}

/// A smooth tapering tube along a curve through [pts], its half-width
/// running through [radii] from end to end, with round ends. Tails, trunks
/// and necks that should read as one sleek shape.
Path taper(List<Offset> pts, List<double> radii, {int samples = 40}) {
  final PathMetric m = curve(pts).computeMetrics().first;
  final List<Offset> left = <Offset>[], right = <Offset>[];
  final List<double> rs = <double>[];
  for (int i = 0; i <= samples; i++) {
    final double t = i / samples;
    final Tangent tan = m.getTangentForOffset(m.length * t)!;
    final double f = t * (radii.length - 1);
    final int j = f.floor().clamp(0, radii.length - 2);
    final double r = radii[j] + (radii[j + 1] - radii[j]) * (f - j);
    final Offset n = Offset(-tan.vector.dy, tan.vector.dx);
    left.add(tan.position + n * r);
    right.add(tan.position - n * r);
    rs.add(r);
  }
  final Path path = Path()..moveTo(left.first.dx, left.first.dy);
  for (final Offset o in left.skip(1)) {
    path.lineTo(o.dx, o.dy);
  }
  path.arcToPoint(right.last, radius: Radius.circular(math.max(rs.last, .001)));
  for (final Offset o in right.reversed.skip(1)) {
    path.lineTo(o.dx, o.dy);
  }
  path.arcToPoint(
    left.first,
    radius: Radius.circular(math.max(rs.first, .001)),
  );
  return path..close();
}

/// A ring of spikes (quills, mane points, sun rays) around an ellipse.
Path spikes(
  double cx,
  double cy,
  double rx,
  double ry,
  int n,
  double len, {
  double from = 0,
  double to = math.pi * 2,
  double round = .006,
}) {
  final List<Offset> pts = <Offset>[];
  final bool closedRing = (to - from - math.pi * 2).abs() < 1e-6;
  final int steps = closedRing ? n * 2 : n * 2 + 1;
  for (int i = 0; i < steps; i++) {
    final double a = from + (to - from) * i / (n * 2);
    final double rr = i.isOdd ? 1 + len : 1;
    pts.add(Offset(cx + math.cos(a) * rx * rr, cy + math.sin(a) * ry * rr));
  }
  if (!closedRing) pts.add(Offset(cx, cy));
  return roundPoly(pts, round);
}

// -------------------------------------------------------------------- colour

/// The outline colour for a creature whose main coat is [c]: the same hue,
/// pushed deep and slightly desaturated, so every line belongs to its animal.
Color inkOf(Color c) {
  final HSLColor h = HSLColor.fromColor(c);
  final double sat = h.saturation < .08
      ? .12
      : math.min(h.saturation * .62, .55);
  return h.withLightness(.19).withSaturation(sat).toColor();
}

Color darker(Color c, [double amount = .10]) => shade(c, -amount);

Color lighter(Color c, [double amount = .10]) => shade(c, amount);

Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// Shared accent colours.
abstract final class Kit {
  static const Color eyeDark = Color(0xFF231A26);
  static const Color blush = Color(0xFFFF8FA3);
  static const Color mouth = Color(0xFF7E2F3E);
  static const Color tongue = Color(0xFFFF8E9E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color tooth = Color(0xFFFFFDF6);
  static const Color nosePink = Color(0xFFF38BA0);
  static const Color gold = Color(0xFFFFCF4A);
  static const Color leafGreen = Color(0xFF7ACB63);
}

/// How an eye is drawn.
enum Eye {
  /// Big glossy oval, the default.
  open,

  /// Upturned arc — a closed, smiling "^".
  happy,

  /// Downturned arc — peacefully shut.
  shut,

  /// Heavy lid across the top half.
  sleepy,
}

// ----------------------------------------------------------------------- pen

/// Draws one creature, and records the landmarks accessories hang from.
class Pen {
  Pen(this.canvas, {this.blink = 1, int seed = 1}) : _rng = math.Random(seed);

  final Canvas canvas;

  /// 1 = eyes open, 0 = shut.
  final double blink;

  final math.Random _rng;

  /// Outline colour. Set once per creature, usually via [inkOf].
  Color ink = const Color(0xFF3A2A38);

  /// Outline weight in unit layout.
  double lw = .024;

  /// A deterministic random number in [lo, hi).
  double rand([double lo = 0, double hi = 1]) =>
      lo + _rng.nextDouble() * (hi - lo);

  // ------------------------------------------------------------- landmarks

  Rect? _head;
  Offset? _hat;
  Offset? _face;
  double? _faceR;
  double _eyeGap = 1;
  Rect? _body;
  Offset? _collar;
  double? _collarHalf;

  /// Declares the head. A hat sits on its top edge, lifted by [hatLift] to
  /// clear horns or ears that stand above it.
  void head(Rect r, {double hatLift = 0, double? hatX}) {
    _head = r;
    _hat = Offset(hatX ?? r.center.dx, r.top - hatLift);
  }

  /// Declares the torso, which a cape drapes around.
  void torso(Rect r) => _body = r;

  /// Declares where a scarf or bow tie sits.
  void collar(Offset at, double halfWidth) {
    _collar = at;
    _collarHalf = halfWidth;
  }

  /// Declares where sunglasses go, given the two eye centres and eye radius.
  void face(Offset left, Offset right, double eyeR) {
    final double r = math.max(eyeR * 3.1, .07);
    _faceR = r;
    final double half = (right.dx - left.dx).abs() / 2;
    _eyeGap = (half / (.46 * r)).clamp(.15, 2.2);
    _face = Offset(
      (left.dx + right.dx) / 2,
      (left.dy + right.dy) / 2 + r * .08,
    );
  }

  /// The recorded landmarks, with sensible stand-ins for anything not given.
  AccessoryAnchor anchor() {
    final Rect head = _head ?? const Rect.fromLTRB(.30, .20, .70, .58);
    final Rect body =
        _body ?? Rect.fromLTRB(head.left, head.bottom - .04, head.right, .90);
    final double faceR = _faceR ?? head.shortestSide * .45;
    return AccessoryAnchor(
      headBounds: head,
      headTop: _hat ?? head.topCenter,
      faceCenter: _face ?? head.center.translate(0, head.height * .08),
      faceRadius: faceR,
      bodyBounds: body,
      neckCenter: _collar ?? Offset(head.center.dx, head.bottom),
      neckHalfWidth: _collarHalf ?? head.width * .36,
      eyeSpacing: _eyeGap,
    );
  }

  // ----------------------------------------------------------------- parts

  /// One solid piece of the creature: fill, cel shadow, optional gloss, outline.
  ///
  /// The shadow is the part itself showing through where a copy nudged toward
  /// the light fails to cover it, so it always hugs the far edge of whatever
  /// shape it is given. [shine] places a soft gloss spot; [line] overrides the
  /// outline weight (0 for none).
  void part(
    Path path,
    Color fill, {
    double shine = 0,
    double? line,
    Color? shadow,
    double depth = 1,
    Offset light = const Offset(-.75, -1),
    VoidCallback? marks,
  }) {
    final Rect b = path.getBounds();
    final Canvas c = canvas;
    if (depth > 0) {
      c.drawPath(path, fillOf(shadow ?? shade(fill, -.11)));
    }
    c.save();
    c.clipPath(path);
    if (depth > 0) {
      final double d = (b.shortestSide * .12).clamp(.005, .032) * depth;
      c.drawPath(path.shift(light * d), fillOf(fill));
    } else {
      c.drawPath(path, fillOf(fill));
    }
    if (marks != null) marks();
    if (shine > 0) _gloss(b, shine);
    c.restore();
    final double w = line ?? lw;
    if (w > 0) c.drawPath(path, strokeOf(ink, w));
  }

  /// Strokes [path] in the outline colour at outline weight.
  void outline(Path path, [double? width]) =>
      canvas.drawPath(path, strokeOf(ink, width ?? lw));

  void _gloss(Rect b, double amount) {
    final Offset at = Offset(b.left + b.width * .30, b.top + b.height * .24);
    final Rect r = Rect.fromCenter(
      center: at,
      width: b.width * .26,
      height: b.height * .15,
    );
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(-.5);
    canvas.translate(-at.dx, -at.dy);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: .55 * amount),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(r),
    );
    canvas.restore();
  }

  /// A flat marking painted only inside [within] — spots, bellies, stripes.
  void mark(Path within, Path shape, Color color, {double? line}) {
    canvas.save();
    canvas.clipPath(within);
    canvas.drawPath(shape, fillOf(color));
    if (line != null && line > 0) canvas.drawPath(shape, strokeOf(ink, line));
    canvas.restore();
  }

  /// Runs [draw] clipped to [within].
  void inside(Path within, VoidCallback draw) {
    canvas.save();
    canvas.clipPath(within);
    draw();
    canvas.restore();
  }

  /// A flat fill with no shading or outline.
  void flat(Path path, Color color) => canvas.drawPath(path, fillOf(color));

  /// An outlined stroke — legs, tails, antennae, whiskers drawn as one line.
  void tube(
    Path path,
    double width,
    Color color, {
    double? line,
    StrokeCap cap = StrokeCap.round,
  }) {
    final double w = line ?? lw;
    if (w > 0) {
      canvas.drawPath(path, strokeOf(ink, width + w * 2)..strokeCap = cap);
    }
    canvas.drawPath(path, strokeOf(color, width)..strokeCap = cap);
  }

  /// A plain line in the outline colour (or [color]).
  void line(Path path, {double? width, Color? color}) =>
      canvas.drawPath(path, strokeOf(color ?? ink, width ?? lw * .8));

  /// A soft round glow, for things that shine on their own.
  void glow(Offset c, double r, Color color, {double alpha = .55}) {
    final Rect rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            color.withValues(alpha: alpha),
            color.withValues(alpha: alpha * .35),
            color.withValues(alpha: 0),
          ],
          stops: const <double>[0, .5, 1],
        ).createShader(rect),
    );
  }

  /// A small white gloss dot.
  void sparkle(Offset c, double r, {double alpha = .9}) =>
      canvas.drawCircle(c, r, fillOf(Colors.white.withValues(alpha: alpha)));

  /// A four-point twinkle, for magic and stars.
  void twinkle(Offset c, double r, Color color, {bool outline = true}) {
    final Path p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + r * .16, c.dy - r * .16, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + r * .16, c.dy + r * .16, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * .16, c.dy + r * .16, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - r * .16, c.dy - r * .16, c.dx, c.dy - r)
      ..close();
    part(p, color, depth: 0, line: outline ? lw * .55 : 0);
  }

  // ------------------------------------------------------------------ face

  /// One eye centred at [c], [r] tall (half-height).
  ///
  /// The open eye is a near-black oval with its lower third flooded by
  /// [iris], plus two catchlights; that colour shift is what makes it read as
  /// a wet, round eye rather than a button. Blinking squashes it toward a line.
  void eye(
    Offset c,
    double r, {
    Color iris = const Color(0xFF7A4E3A),
    Eye look = Eye.open,
    double width = .80,
    Color? dark,
    double tilt = 0,
    bool highlights = true,
    Color? rim,
  }) {
    final double lineW = math.max(lw * .95, r * .30);
    switch (look) {
      case Eye.happy:
        line(
          Path()
            ..moveTo(c.dx - r * .80, c.dy + r * .30)
            ..quadraticBezierTo(
              c.dx,
              c.dy - r * .85,
              c.dx + r * .80,
              c.dy + r * .30,
            ),
          width: lineW,
        );
        return;
      case Eye.shut:
        line(
          Path()
            ..moveTo(c.dx - r * .80, c.dy - r * .10)
            ..quadraticBezierTo(
              c.dx,
              c.dy + r * .70,
              c.dx + r * .80,
              c.dy - r * .10,
            ),
          width: lineW,
        );
        return;
      case Eye.open:
      case Eye.sleepy:
        break;
    }
    if (blink < .22) {
      line(
        Path()
          ..moveTo(c.dx - r * .78, c.dy + r * .05)
          ..quadraticBezierTo(
            c.dx,
            c.dy + r * .55,
            c.dx + r * .78,
            c.dy + r * .05,
          ),
        width: lineW,
      );
      return;
    }
    final double rx = r * width;
    final Canvas k = canvas;
    k.save();
    k.translate(c.dx, c.dy);
    if (tilt != 0) k.rotate(tilt);
    k.scale(1, blink.clamp(0.0, 1.0));
    final Path ball = oval(0, 0, rx, r);
    // A pale ring, for eyes set in dark fur where the eye would vanish.
    if (rim != null) k.drawPath(oval(0, 0, rx + r * .2, r * 1.17), fillOf(rim));
    k.drawPath(ball, fillOf(dark ?? Kit.eyeDark));
    k.save();
    k.clipPath(ball);
    k.drawOval(
      Rect.fromCenter(
        center: Offset(0, r * .62),
        width: rx * 2.0,
        height: r * 1.25,
      ),
      fillOf(iris.withValues(alpha: .92)),
    );
    k.restore();
    if (look == Eye.sleepy) {
      // The lid: a band of the outline colour across the top half.
      k.save();
      k.clipPath(ball);
      k.drawRect(
        Rect.fromLTRB(-rx * 1.2, -r * 1.2, rx * 1.2, -r * .02),
        fillOf(ink),
      );
      k.restore();
    }
    if (highlights) {
      final double hy = look == Eye.sleepy ? r * .18 : -r * .36;
      k.drawOval(
        Rect.fromCenter(
          center: Offset(-rx * .30, hy),
          width: rx * .78,
          height: r * .62,
        ),
        fillOf(Colors.white),
      );
      k.drawCircle(
        Offset(rx * .36, r * .40),
        r * .15,
        fillOf(Colors.white.withValues(alpha: .95)),
      );
    }
    k.restore();
  }

  /// A matching pair of eyes, mirrored across [cx], which also records where
  /// sunglasses sit.
  void eyes(
    double cx,
    double y,
    double gap,
    double r, {
    Color iris = const Color(0xFF7A4E3A),
    Eye look = Eye.open,
    double width = .80,
    Color? dark,
    double tilt = 0,
    Color? rim,
  }) {
    final Offset l = Offset(cx - gap, y), rr = Offset(cx + gap, y);
    eye(
      l,
      r,
      iris: iris,
      look: look,
      width: width,
      dark: dark,
      tilt: -tilt,
      rim: rim,
    );
    eye(
      rr,
      r,
      iris: iris,
      look: look,
      width: width,
      dark: dark,
      tilt: tilt,
      rim: rim,
    );
    face(l, rr, r);
  }

  /// A soft rosy cheek.
  void blush(
    Offset c,
    double r, {
    Color color = Kit.blush,
    double alpha = .62,
  }) {
    final Rect rect = Rect.fromCenter(
      center: c,
      width: r * 2,
      height: r * 1.25,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            color.withValues(alpha: alpha),
            color.withValues(alpha: alpha * .6),
            color.withValues(alpha: 0),
          ],
          stops: const <double>[0, .55, 1],
        ).createShader(rect),
    );
  }

  /// A pair of cheeks mirrored across [cx].
  void cheeks(
    double cx,
    double y,
    double gap,
    double r, {
    Color color = Kit.blush,
    double alpha = .62,
  }) {
    blush(Offset(cx - gap, y), r, color: color, alpha: alpha);
    blush(Offset(cx + gap, y), r, color: color, alpha: alpha);
  }

  /// The "ω" mouth, [w] wide in each half.
  void catMouth(Offset c, double w, {double? width, Color? color}) => line(
    Path()
      ..moveTo(c.dx - w, c.dy - w * .15)
      ..quadraticBezierTo(c.dx - w * .5, c.dy + w * .85, c.dx, c.dy - w * .05)
      ..quadraticBezierTo(
        c.dx + w * .5,
        c.dy + w * .85,
        c.dx + w,
        c.dy - w * .15,
      ),
    width: width ?? lw * .8,
    color: color,
  );

  /// A small upturned arc.
  void smile(
    Offset c,
    double w, {
    double depth = .6,
    double? width,
    Color? color,
  }) => line(
    Path()
      ..moveTo(c.dx - w, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + w * depth * 2, c.dx + w, c.dy),
    width: width ?? lw * .8,
    color: color,
  );

  /// An open laughing mouth with a tongue.
  void grin(
    Offset c,
    double w,
    double h, {
    Color tongue = Kit.tongue,
    bool fangs = false,
    bool teeth = false,
  }) {
    final Path m = Path()
      ..moveTo(c.dx - w, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - h * .18, c.dx + w, c.dy)
      ..cubicTo(
        c.dx + w * .9,
        c.dy + h * .9,
        c.dx - w * .9,
        c.dy + h * .9,
        c.dx - w,
        c.dy,
      )
      ..close();
    canvas.drawPath(m, fillOf(Kit.mouth));
    inside(m, () {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + h * .78),
          width: w * 1.3,
          height: h * .8,
        ),
        fillOf(tongue),
      );
      if (teeth) {
        canvas.drawRect(
          Rect.fromLTRB(c.dx - w, c.dy - h, c.dx + w, c.dy + h * .16),
          fillOf(Kit.tooth),
        );
      }
    });
    if (fangs) {
      for (final double k in <double>[-1, 1]) {
        final Path f = poly(<Offset>[
          Offset(c.dx + k * w * .62, c.dy - h * .02),
          Offset(c.dx + k * w * .28, c.dy - h * .06),
          Offset(c.dx + k * w * .46, c.dy + h * .38),
        ]);
        canvas.drawPath(f, fillOf(Kit.tooth));
      }
    }
    canvas.drawPath(m, strokeOf(ink, lw * .8));
  }

  /// A rounded triangular nose, point down.
  void nose(Offset c, double w, {Color? color}) {
    final Path n = blob(<Offset>[
      Offset(c.dx - w, c.dy - w * .45),
      Offset(c.dx + w, c.dy - w * .45),
      Offset(c.dx, c.dy + w * .55),
    ], tension: .9);
    canvas.drawPath(n, fillOf(color ?? ink));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - w * .25, c.dy - w * .22),
        width: w * .55,
        height: w * .30,
      ),
      fillOf(Colors.white.withValues(alpha: .55)),
    );
  }

  /// A tiny fang poking down from the lip at [c].
  void fang(Offset c, double w) {
    final Path f = poly(<Offset>[
      Offset(c.dx - w, c.dy),
      Offset(c.dx + w, c.dy),
      Offset(c.dx, c.dy + w * 1.6),
    ]);
    canvas.drawPath(f, fillOf(Kit.tooth));
    canvas.drawPath(f, strokeOf(ink, lw * .45));
  }

  /// A standard sweet face: eyes, cheeks and a mouth, centred on [cx].
  ///
  /// [y] is the eye line, [gap] half the distance between the eyes and [r] the
  /// eye size; everything else is laid out from those.
  void sweetFace(
    double cx,
    double y,
    double gap,
    double r, {
    Color iris = const Color(0xFF7A4E3A),
    Eye look = Eye.open,
    bool cat = false,
    double mouthY = 0,
    bool mouth = true,
    double blushAlpha = .62,
    Color? rim,
  }) {
    eyes(cx, y, gap, r, iris: iris, look: look, rim: rim);
    cheeks(cx, y + r * 1.25, gap + r * .55, r * .85, alpha: blushAlpha);
    if (!mouth) return;
    final Offset m = Offset(cx, y + r * 1.15 + mouthY);
    if (cat) {
      catMouth(m, r * .42);
    } else {
      smile(m, r * .38);
    }
  }
}
