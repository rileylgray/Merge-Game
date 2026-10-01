import 'dart:ui';

import 'kit.dart';

/// Anatomy shared by many of the cast, so a meadow full of mammals sits in
/// one consistent set of proportions: a big head, a small round body, stubby
/// feet. Everything here draws through a [Pen] and records the torso.

/// A sitting front-facing torso with a pale belly, two feet and two paws.
///
/// Returns the torso outline so callers can paint markings into it.
Path sitBody(
  Pen p, {
  required Color fur,
  Color? belly,
  Color? feet,
  Color? paws,
  double cx = .5,
  double cy = .73,
  double rx = .17,
  double ry = .16,
  double footW = .064,
  double footGap = .085,
  double pawY = .675,
  double pawGap = .085,
  bool showPaws = true,
  VoidCallback? marks,
}) {
  final Color footColor = feet ?? fur;
  for (final double k in <double>[-1, 1]) {
    p.part(
      oval(cx + k * footGap, .885, footW, footW * .56),
      footColor,
      depth: .6,
    );
  }
  final Path torso = oval(cx, cy, rx, ry);
  p.part(
    torso,
    fur,
    marks: () {
      if (belly != null) {
        p.flat(oval(cx, cy + ry * .28, rx * .64, ry * .74), belly);
      }
      if (marks != null) marks();
    },
  );
  if (showPaws) {
    for (final double k in <double>[-1, 1]) {
      p.part(
        oval(cx + k * pawGap, pawY, rx * .24, rx * .2),
        paws ?? fur,
        depth: .5,
      );
    }
  }
  p.torso(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
  );
  return torso;
}

/// One straight leg from [top] down to the ground, with a coloured hoof or
/// paw at the bottom.
void leg(
  Pen p,
  double x,
  double top,
  double w,
  Color fur, {
  Color? hoof,
  double hoofH = .045,
  double bottom = .895,
  double lean = 0,
}) {
  final Path l = roundPoly(<Offset>[
    Offset(x - w / 2, top),
    Offset(x + w / 2, top),
    Offset(x + w / 2 + lean, bottom),
    Offset(x - w / 2 + lean, bottom),
  ], w * .45);
  p.part(
    l,
    fur,
    depth: .6,
    marks: hoof == null
        ? null
        : () => p.flat(
            Rect.fromLTRB(
              x - w,
              bottom - hoofH,
              x + w + lean.abs(),
              bottom + .01,
            ).toPath(),
            hoof,
          ),
  );
}

/// A short round-footed leg for shelled and heavy-set animals: a stub with a
/// rounded pad and three toenails, rather than a square post.
void stubLeg(
  Pen p,
  double x,
  double top,
  double w,
  Color color, {
  Color? nail,
}) {
  p.part(
    union(
      rrect(x - w / 2, top, x + w / 2, .862, w * .4),
      oval(x, .87, w * .62, .026),
    ),
    color,
    depth: .5,
  );
  for (final double d in <double>[-.28, 0, .28]) {
    p.flat(oval(x + d * w, .886, w * .1, .007), nail ?? lighter(color, .14));
  }
}

/// A pointed ear on the side given by [k] (-1 left, +1 right), with an inner
/// lining. [base] is the middle of the ear's root, [tip] its point.
void pointyEar(
  Pen p,
  Offset base,
  Offset tip,
  double width,
  Color fur,
  Color inner, {
  double k = 1,
  double round = .03,
  Color? tipColor,
}) {
  final Offset d = tip - base;
  final Offset n = Offset(-d.dy, d.dx) / d.distance * (width / 2);
  final Path ear = roundPoly(<Offset>[base - n, tip, base + n], round);
  p.part(
    ear,
    fur,
    marks: () {
      if (tipColor != null) {
        p.flat(circle(tip.dx, tip.dy, d.distance * .38), tipColor);
      }
    },
  );
  final Offset ib = base + d * .12;
  final Offset it = base + d * .78;
  final Path lining = roundPoly(<Offset>[
    ib - n * .55,
    it,
    ib + n * .55,
  ], round * .8);
  p.part(lining, inner, depth: .5, line: 0);
}

/// A round ear with an inner lining.
void roundEar(
  Pen p,
  Offset c,
  double r,
  Color fur,
  Color inner, {
  double innerScale = .6,
  Offset innerShift = const Offset(0, .006),
}) {
  p.part(circle(c.dx, c.dy, r), fur, shine: .4);
  p.part(
    circle(c.dx + innerShift.dx, c.dy + innerShift.dy, r * innerScale),
    inner,
    depth: .5,
    line: 0,
  );
}

/// Thin whisker lines fanning out from either side of [c].
void whiskers(
  Pen p,
  Offset c,
  double gap,
  double len, {
  double spread = .018,
  Color? color,
}) {
  for (final double k in <double>[-1, 1]) {
    for (final double a in <double>[-1, 1]) {
      p.line(
        Path()
          ..moveTo(c.dx + k * gap, c.dy + a * spread * .3)
          ..lineTo(c.dx + k * (gap + len), c.dy + a * spread),
        width: p.lw * .45,
        color: color,
      );
    }
  }
}

/// A three-quarter standing body facing the viewer: the torso runs back to
/// the left, the head sits up and to the right on a short neck.
Path standBody(
  Pen p, {
  required Color fur,
  required Color hoof,
  Color? belly,
  double cx = .42,
  double cy = .62,
  double rx = .23,
  double ry = .135,
  double legTop = .64,
  double legW = .058,
  List<double> farLegs = const <double>[.34, .60],
  List<double> nearLegs = const <double>[.26, .52],
  VoidCallback? marks,
  VoidCallback? legMarks,
  Path? neck,
}) {
  // Every leg goes in behind the torso, so the belly line runs across their
  // tops and they grow out of the body instead of being stuck onto it.
  for (final double x in farLegs) {
    leg(p, x, legTop, legW, darker(fur, .07), hoof: darker(hoof, .05));
  }
  for (final double x in nearLegs) {
    leg(p, x, legTop, legW, fur, hoof: hoof);
  }
  if (legMarks != null) legMarks();
  final Path torso = neck == null
      ? oval(cx, cy, rx, ry)
      : union(oval(cx, cy, rx, ry), neck);
  p.part(
    torso,
    fur,
    shine: .6,
    marks: () {
      if (belly != null) {
        p.flat(oval(cx + rx * .1, cy + ry * .75, rx * .75, ry * .45), belly);
      }
      if (marks != null) marks();
    },
  );
  p.torso(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
  );
  return torso;
}

/// The short neck a [standBody] head sits on, rising from the chest.
Path standNeck({double top = .46}) => blob(<Offset>[
  pt(.53, .60),
  pt(.56, top),
  pt(.68, top),
  pt(.69, .62),
  pt(.62, .68),
]);

/// A cat's lower face: a two-lobed muzzle, a pink nose, the "ω" mouth and
/// whiskers, laid out under eyes at [eyeY].
void catMuzzle(
  Pen p,
  double cx,
  double eyeY, {
  Color muzzle = const Color(0xFFFFFBF5),
  Color nose = Kit.nosePink,
  double size = 1,
  Color? whisker,
}) {
  final double y = eyeY + .075 * size;
  p.part(
    union(
      oval(cx - .034 * size, y, .042 * size, .034 * size),
      oval(cx + .034 * size, y, .042 * size, .034 * size),
    ),
    muzzle,
    depth: 0,
    line: 0,
  );
  p.nose(Offset(cx, y - .02 * size), .019 * size, color: nose);
  p.catMouth(Offset(cx, y + .004 * size), .019 * size);
  whiskers(
    p,
    Offset(cx, y + .004 * size),
    .07 * size,
    .1 * size,
    color: whisker,
  );
}

/// Three-toed bird feet standing on the ground at [x].
void birdFoot(Pen p, double x, Color color, {double size = 1}) {
  for (final double a in <double>[-.5, 0, .5]) {
    p.tube(
      Path()
        ..moveTo(x, .855)
        ..lineTo(x + a * .05 * size, .89),
      .018 * size,
      color,
    );
  }
}

extension on Rect {
  Path toPath() => Path()..addRect(this);
}
