import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/painting.dart';

import 'creature_art.dart';
import 'kit.dart';
import 'parts.dart';

/// Sea Meadow — reef shallows down to the deep, cold blue, from a speck of
/// krill to a whale that calls the tides.
const Map<String, CreatureArt> waterArt = <String, CreatureArt>{
  'water_01': CreatureArt(_krill, shadow: .3),
  'water_02': CreatureArt(_seaSnail, shadow: .36),
  'water_03': CreatureArt(_clam, shadow: .34),
  'water_04': CreatureArt(_shrimp, shadow: .3),
  'water_05': CreatureArt(_seahorse, shadow: .18),
  'water_06': CreatureArt(_starfish, shadow: .3),
  'water_07': CreatureArt(_jellyfish, shadow: .22),
  'water_08': CreatureArt(_clownfish, shadow: .28),
  'water_09': CreatureArt(_puffer, shadow: .28),
  'water_10': CreatureArt(_crab, shadow: .34),
  'water_11': CreatureArt(_octopus, shadow: .32),
  'water_12': CreatureArt(_seaTurtle, shadow: .34),
  'water_13': CreatureArt(_angelfish, shadow: .24),
  'water_14': CreatureArt(_eel, shadow: .3),
  'water_15': CreatureArt(_lobster, shadow: .28),
  'water_16': CreatureArt(_stingray, shadow: .32),
  'water_17': CreatureArt(_penguin, shadow: .24),
  'water_18': CreatureArt(_sealPup, shadow: .36),
  'water_19': CreatureArt(_walrus, shadow: .32),
  'water_20': CreatureArt(_dolphin, shadow: .3),
  'water_21': CreatureArt(_swordfish, shadow: .32),
  'water_22': CreatureArt(_hammerhead, shadow: .3),
  'water_23': CreatureArt(_angler, shadow: .3),
  'water_24': CreatureArt(_manta, shadow: .36),
  'water_25': CreatureArt(_narwhal, shadow: .32),
  'water_26': CreatureArt(_orca, shadow: .34),
  'water_27': CreatureArt(_greatWhite, shadow: .34),
  'water_28': CreatureArt(_squid, shadow: .26),
  'water_29': CreatureArt(_blueWhale, shadow: .38),
  'water_30': CreatureArt(_tidecaller, shadow: .38),
};

/// One side-on eye, which still records where sunglasses would sit.
void _sideEye(
  Pen p,
  Offset c,
  double r, {
  Color iris = const Color(0xFF3A6A9A),
  Color? rim,
}) {
  p.eye(c, r, iris: iris, rim: rim);
  p.face(c.translate(-r * .4, 0), c.translate(r * .4, 0), r);
}

/// A scalloped fan — shells, tails, fins — opening from [hinge] between the
/// angles [from] and [to], with [lobes] bumps round the rim.
Path _fan(
  Offset hinge,
  double r,
  double from,
  double to,
  int lobes, {
  double depth = .1,
}) {
  final Path p = Path()..moveTo(hinge.dx, hinge.dy);
  final Offset start = hinge + Offset(math.cos(from), math.sin(from)) * r;
  p.lineTo(start.dx, start.dy);
  for (int i = 1; i <= lobes; i++) {
    final double a = from + (to - from) * i / lobes;
    final double am = from + (to - from) * (i - .5) / lobes;
    final Offset q = hinge + Offset(math.cos(a), math.sin(a)) * r;
    final Offset c =
        hinge + Offset(math.cos(am), math.sin(am)) * r * (1 + depth * 2);
    p.quadraticBezierTo(c.dx, c.dy, q.dx, q.dy);
  }
  return p..close();
}

/// A two-lobed whale or shark tail fluke at [c], pointing back to the left.
Path _flukes(Offset c, double size, {double tilt = 0}) {
  final Path f = blob(
    <Offset>[
      c.translate(size * .2, -size * .1),
      c.translate(-size * .5, -size * .9),
      c.translate(-size * .35, -size * .05),
      c.translate(-size * .5, size * .9),
      c.translate(size * .2, size * .1),
    ],
    sharp: <int>{1, 2, 3},
  );
  return tilt == 0 ? f : turn(f, c, tilt);
}

// -------------------------------------------------------------------- 1 krill

void _krill(Pen p) {
  const Color body = Color(0xFFFFC2B4);
  const Color stripe = Color(0xFFFF9C88);
  const Color glow = Color(0xFF7AE8FF);
  p.ink = const Color(0xFF6A2A28);

  for (final double d in <double>[0, .035]) {
    p.tube(
      curve(<Offset>[
        pt(.78, .44),
        pt(.86 + d, .32),
        pt(.90 + d * 1.5, .20),
        pt(.94 + d, .14),
      ]),
      .009,
      stripe,
    );
  }
  for (double x = .34; x < .62; x += .055) {
    p.tube(
      curve(<Offset>[pt(x, .72), pt(x - .01, .80), pt(x - .03, .845)]),
      .012,
      stripe,
    );
  }
  for (final double a in <double>[-.5, 0, .5]) {
    p.part(
      turn(leaf(pt(.20, .66), pt(.08, .66), .06), pt(.20, .66), a),
      stripe,
      depth: .4,
    );
  }
  // Tail and head in one piece, so the head grows out of the body.
  final Path animal = union(
    taper(
      <Offset>[pt(.19, .66), pt(.34, .72), pt(.50, .70), pt(.64, .60)],
      <double>[.035, .065, .085, .11],
    ),
    circle(.70, .53, .15),
  );
  p.part(
    animal,
    body,
    shine: 1,
    marks: () {
      for (double x = .30; x < .58; x += .065) {
        p.line(
          Path()
            ..moveTo(x, .60)
            ..lineTo(x + .015, .80),
          width: .012,
          color: stripe,
        );
      }
    },
  );
  for (final Offset c in <Offset>[pt(.36, .73), pt(.47, .735), pt(.57, .70)]) {
    p.glow(c, .03, glow, alpha: .9);
    p.flat(circle(c.dx, c.dy, .009), Kit.white);
  }
  p.eyes(.71, .52, .062, .046, iris: const Color(0xFF3A7ABA));
  p.cheeks(.71, .58, .1, .03);
  p.smile(pt(.71, .585), .02);

  p.head(const Rect.fromLTRB(.55, .38, .85, .68), hatLift: .02);
  p.torso(const Rect.fromLTRB(.16, .58, .64, .80));
  p.collar(pt(.64, .67), .1);
}

// ---------------------------------------------------------------- 2 sea snail

void _seaSnail(Pen p) {
  const Color skin = Color(0xFFF2C6E2);
  const Color shell = Color(0xFF8FD8E8);
  const Color band = Color(0xFFD6F5FA);
  p.ink = const Color(0xFF1E4A5A);

  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.76 + k * .045, .46),
        pt(.77 + k * .06, .36),
        pt(.78 + k * .085, .30),
      ]),
      .018,
      skin,
    );
    p.part(circle(.78 + k * .085, .30, .024), skin, depth: 0);
  }
  final Path foot = blob(<Offset>[
    pt(.07, .885),
    pt(.12, .83),
    pt(.40, .81),
    pt(.62, .75),
    pt(.64, .58),
    pt(.70, .46),
    pt(.80, .43),
    pt(.90, .48),
    pt(.92, .60),
    pt(.88, .75),
    pt(.93, .86),
    pt(.85, .895),
    pt(.40, .895),
  ]);
  p.part(foot, skin, shine: .8);
  // A tall top shell, tier on tier — not the round garden snail's.
  final Path cone = sym(
    <Offset>[
      pt(.38, .11),
      pt(.43, .20),
      pt(.46, .29),
      pt(.52, .36),
      pt(.56, .47),
      pt(.62, .55),
      pt(.66, .67),
      pt(.62, .80),
      pt(.38, .845),
    ],
    cx: .38,
    sharp: <int>{0},
  );
  p.part(
    cone,
    shell,
    shine: 1,
    marks: () {
      for (final List<double> seam in <List<double>>[
        <double>[.29, .085],
        <double>[.47, .18],
        <double>[.67, .28],
      ]) {
        final double y = seam[0], w = seam[1];
        p.line(
          curve(<Offset>[
            pt(.38 - w, y - .01),
            pt(.38, y + .03),
            pt(.38 + w, y - .01),
          ]),
          width: .03,
          color: band,
        );
        p.line(
          curve(<Offset>[
            pt(.38 - w, y - .03),
            pt(.38, y + .01),
            pt(.38 + w, y - .03),
          ]),
          width: .01,
          color: darker(shell, .16),
        );
      }
    },
  );
  p.eyes(.775, .56, .05, .04, iris: const Color(0xFFB0508A));
  p.cheeks(.775, .615, .08, .028);
  p.smile(pt(.775, .615), .018);

  p.head(const Rect.fromLTRB(.66, .43, .92, .68), hatLift: .03);
  p.torso(const Rect.fromLTRB(.16, .30, .92, .89));
  p.collar(pt(.75, .70), .1);
}

// --------------------------------------------------------------------- 3 clam

void _clam(Pen p) {
  const Color shell = Color(0xFFF7B7D0);
  const Color inner = Color(0xFFFFE6EF);
  const Color body = Color(0xFFFFF4F6);
  p.ink = const Color(0xFF6A2A48);

  // Upper valve, opened back.
  final Path top = _fan(
    pt(.5, .62),
    .36,
    math.pi * 1.04,
    math.pi * 1.96,
    9,
    depth: .05,
  );
  p.part(
    top,
    shell,
    shine: .8,
    marks: () {
      p.flat(
        _fan(pt(.5, .62), .3, math.pi * 1.06, math.pi * 1.94, 9, depth: .05),
        inner,
      );
    },
  );
  final Path flesh = oval(.5, .62, .25, .13);
  p.part(flesh, body, shine: .6);
  p.eye(pt(.43, .60), .036, look: Eye.happy);
  p.eye(pt(.57, .60), .036, look: Eye.happy);
  p.face(pt(.43, .60), pt(.57, .60), .036);
  p.cheeks(.5, .64, .11, .03);
  p.smile(pt(.5, .635), .022);
  // Lower valve with its ribs.
  final Path bottom = _fan(
    pt(.5, .62),
    .36,
    math.pi * .04,
    math.pi * .96,
    9,
    depth: .05,
  );
  p.part(
    bottom,
    shell,
    shine: .4,
    marks: () {
      for (int i = 1; i < 9; i++) {
        final double a = math.pi * (.04 + .92 * i / 9);
        p.line(
          Path()
            ..moveTo(.5, .62)
            ..lineTo(.5 + math.cos(a) * .36, .62 + math.sin(a) * .36),
          width: .01,
          color: darker(shell, .12),
        );
      }
      p.flat(circle(.5, .62, .05), darker(shell, .06));
    },
  );
  // A pearl.
  p.part(circle(.5, .70, .045), const Color(0xFFF5F2FF), shine: 1.4);

  p.head(const Rect.fromLTRB(.25, .49, .75, .75), hatLift: .26);
  p.torso(const Rect.fromLTRB(.14, .30, .86, .90));
  p.collar(pt(.5, .80), .16);
}

// ------------------------------------------------------------------- 4 shrimp

void _shrimp(Pen p) {
  const Color body = Color(0xFFFF8A68);
  const Color band = Color(0xFFFFC2A8);
  p.ink = const Color(0xFF6A2412);

  for (final double d in <double>[0, .04]) {
    p.tube(
      curve(<Offset>[
        pt(.78, .42),
        pt(.84 + d, .26),
        pt(.80 + d * 2, .12),
        pt(.70 + d * 2, .07),
      ]),
      .009,
      body,
    );
  }
  for (final double x in <double>[.40, .47, .54]) {
    p.tube(
      curve(<Offset>[pt(x, .60), pt(x - .015, .70), pt(x - .03, .74)]),
      .012,
      body,
      line: p.lw * .6,
    );
  }
  for (final double a in <double>[-.6, 0, .6]) {
    p.part(
      turn(leaf(pt(.32, .84), pt(.20, .88), .07), pt(.32, .84), a),
      body,
      depth: .4,
    );
  }
  // A curled tail, banded segment by segment.
  // The curled tail flows straight into the head — one animal, no seam.
  final Path tail = union(
    taper(
      <Offset>[
        pt(.34, .83),
        pt(.22, .72),
        pt(.24, .56),
        pt(.38, .47),
        pt(.58, .49),
      ],
      <double>[.035, .06, .085, .1, .12],
    ),
    circle(.68, .52, .15),
  );
  p.part(
    tail,
    body,
    shine: 1,
    marks: () {
      p.flat(oval(.70, .62, .1, .05), band);
      for (final List<Offset> b in <List<Offset>>[
        <Offset>[pt(.12, .70), pt(.32, .70)],
        <Offset>[pt(.14, .58), pt(.34, .62)],
        <Offset>[pt(.26, .42), pt(.40, .56)],
        <Offset>[pt(.44, .38), pt(.48, .58)],
      ]) {
        p.line(
          Path()
            ..moveTo(b[0].dx, b[0].dy)
            ..lineTo(b[1].dx, b[1].dy),
          width: .03,
          color: band,
        );
      }
    },
  );
  p.part(leaf(pt(.76, .42), pt(.90, .36), .04), body, depth: .4);
  p.eyes(.69, .51, .062, .046, iris: const Color(0xFF8A3A2A));
  p.cheeks(.69, .57, .1, .03);
  p.smile(pt(.69, .575), .02);

  p.head(const Rect.fromLTRB(.53, .37, .83, .67), hatLift: .02);
  p.torso(const Rect.fromLTRB(.17, .40, .62, .87));
  p.collar(pt(.6, .66), .1);
}

// ----------------------------------------------------------------- 5 seahorse

void _seahorse(Pen p) {
  const Color body = Color(0xFFFFC64A);
  const Color ridge = Color(0xFFFFE49A);
  const Color fin = Color(0xFFFFE8B0);
  p.ink = const Color(0xFF6A3A08);

  p.part(
    _fan(pt(.38, .54), .11, math.pi * .75, math.pi * 1.25, 4, depth: .08),
    fin.withValues(alpha: .95),
    depth: .3,
  );
  final Path tail = taper(
    <Offset>[
      pt(.48, .70),
      pt(.46, .82),
      pt(.38, .88),
      pt(.30, .84),
      pt(.31, .76),
      pt(.37, .75),
    ],
    <double>[.06, .045, .035, .028, .02, .016],
  );
  p.part(tail, body);
  // Coronet.
  p.part(
    spikes(
      .50,
      .20,
      .06,
      .03,
      4,
      .9,
      from: math.pi * 1.1,
      to: math.pi * 1.9,
      round: .006,
    ),
    body,
    depth: .3,
  );
  // Head, snout and body as one curving shape.
  final Path animal = unite(<Path>[
    blob(<Offset>[
      pt(.42, .36),
      pt(.56, .38),
      pt(.63, .50),
      pt(.61, .64),
      pt(.52, .76),
      pt(.43, .72),
      pt(.40, .58),
      pt(.38, .46),
    ]),
    circle(.52, .29, .115),
    taper(
      <Offset>[pt(.58, .31), pt(.68, .32), pt(.77, .34)],
      <double>[.03, .025, .028],
    ),
  ]);
  p.part(
    animal,
    body,
    shine: 1,
    marks: () {
      for (double y = .46; y < .76; y += .055) {
        p.line(
          curve(<Offset>[pt(.48, y), pt(.58, y + .01), pt(.66, y - .01)]),
          width: .014,
          color: ridge,
        );
      }
    },
  );
  _sideEye(p, pt(.55, .285), .048, iris: const Color(0xFF9A5A1A));
  p.blush(pt(.58, .345), .03);

  p.head(const Rect.fromLTRB(.405, .175, .635, .405), hatLift: .03);
  p.torso(const Rect.fromLTRB(.38, .36, .63, .76));
  p.collar(pt(.52, .40), .08);
}

// ----------------------------------------------------------------- 6 starfish

void _starfish(Pen p) {
  const Color body = Color(0xFFFF8E86);
  const Color dot = Color(0xFFFFC7B8);
  p.ink = const Color(0xFF6A1E2A);

  final Path s = star(.5, .58, .37, inner: .52, rot: .08, round: .07);
  p.part(
    s,
    body,
    shine: 1,
    marks: () {
      for (int i = 0; i < 5; i++) {
        final double a = -math.pi / 2 + .08 + i * math.pi * 2 / 5;
        for (final double d in <double>[.17, .25]) {
          p.flat(
            circle(
              .5 + math.cos(a) * d,
              .58 + math.sin(a) * d,
              d == .17 ? .016 : .012,
            ),
            dot,
          );
        }
      }
    },
  );
  p.sweetFace(.5, .57, .07, .045, iris: const Color(0xFF9A3A3A));

  p.head(const Rect.fromLTRB(.34, .44, .66, .72), hatLift: .2);
  p.torso(const Rect.fromLTRB(.15, .21, .85, .88));
  p.collar(pt(.5, .70), .12);
}

// ---------------------------------------------------------------- 7 jellyfish

void _jellyfish(Pen p) {
  const Color bell = Color(0xFFE7A8F4);
  const Color inner = Color(0xFFF6D6FA);
  const Color arm = Color(0xFFD38BEA);
  p.ink = const Color(0xFF4A2066);

  for (final double x in <double>[.32, .42, .58, .68]) {
    final double w = x < .5 ? -1 : 1;
    p.tube(
      curve(<Offset>[
        pt(x, .52),
        pt(x + w * .03, .64),
        pt(x - w * .02, .74),
        pt(x + w * .02, .86),
      ]),
      .016,
      arm,
    );
  }
  // Frilly oral arms in the middle.
  for (final double k in sides) {
    final Path ribbon = taper(
      <Offset>[
        pt(.5 + k * .03, .52),
        pt(.5 + k * .07, .64),
        pt(.5 + k * .02, .74),
        pt(.5 + k * .06, .84),
      ],
      <double>[.035, .03, .025, .015],
    );
    p.part(ribbon, inner, depth: .3);
  }
  final Path dome = Path()
    ..moveTo(.20, .54)
    ..cubicTo(.18, .22, .82, .22, .80, .54)
    ..quadraticBezierTo(.75, .60, .70, .55)
    ..quadraticBezierTo(.65, .60, .60, .55)
    ..quadraticBezierTo(.55, .60, .50, .55)
    ..quadraticBezierTo(.45, .60, .40, .55)
    ..quadraticBezierTo(.35, .60, .30, .55)
    ..quadraticBezierTo(.25, .60, .20, .54)
    ..close();
  p.part(
    dome,
    bell,
    shine: 1.2,
    marks: () {
      p.flat(oval(.5, .30, .17, .07), inner.withValues(alpha: .7));
      for (final Offset c in <Offset>[
        pt(.30, .40),
        pt(.70, .40),
        pt(.38, .32),
        pt(.64, .31),
      ]) {
        p.flat(circle(c.dx, c.dy, .014), inner);
      }
    },
  );
  p.sweetFace(.5, .44, .085, .045, iris: const Color(0xFF8A4AB0));

  p.head(const Rect.fromLTRB(.2, .30, .8, .57), hatLift: .0);
  p.torso(const Rect.fromLTRB(.3, .5, .7, .86));
  p.collar(pt(.5, .56), .2);
}

// ---------------------------------------------------------------- 8 clownfish

void _clownfish(Pen p) {
  const Color orange = Color(0xFFFF8A2A);
  const Color white = Color(0xFFFFFDF8);
  const Color black = Color(0xFF2E2430);
  p.ink = const Color(0xFF4A1E08);

  void trim(Path fin) => p.canvas.drawPath(fin, strokeOf(black, .03));

  final Path tail = _fan(
    pt(.26, .56),
    .16,
    math.pi * .72,
    math.pi * 1.28,
    3,
    depth: .1,
  );
  p.part(tail, orange, marks: () => trim(tail));
  final Path dorsal = blob(<Offset>[
    pt(.34, .40),
    pt(.40, .28),
    pt(.52, .27),
    pt(.62, .36),
  ]);
  p.part(dorsal, orange, marks: () => trim(dorsal));
  final Path belly = blob(<Offset>[
    pt(.40, .72),
    pt(.46, .82),
    pt(.56, .80),
    pt(.58, .72),
  ]);
  p.part(belly, orange, marks: () => trim(belly));
  final Path body = blob(<Offset>[
    pt(.80, .56),
    pt(.74, .42),
    pt(.58, .35),
    pt(.40, .38),
    pt(.26, .50),
    pt(.26, .62),
    pt(.40, .74),
    pt(.58, .76),
    pt(.74, .70),
  ]);
  p.part(
    body,
    orange,
    shine: 1,
    marks: () {
      for (final List<double> s in <List<double>>[
        <double>[.62, .07],
        <double>[.43, .065],
        <double>[.29, .04],
      ]) {
        final Path band = blob(<Offset>[
          pt(s[0] - s[1] * .5, .30),
          pt(s[0] + s[1] * .5, .30),
          pt(s[0] + s[1] * .7, .55),
          pt(s[0] + s[1] * .5, .80),
          pt(s[0] - s[1] * .5, .80),
          pt(s[0] - s[1] * .3, .55),
        ]);
        p.canvas.drawPath(band, strokeOf(black, .022));
        p.flat(band, white);
      }
    },
  );
  final Path pec = turn(leaf(pt(.56, .60), pt(.48, .70), .06), pt(.56, .60), 0);
  p.part(pec, orange, marks: () => trim(pec));
  _sideEye(p, pt(.70, .51), .05, iris: const Color(0xFFB0602A));
  p.blush(pt(.72, .60), .03);
  p.smile(pt(.775, .605), .02);

  p.head(const Rect.fromLTRB(.58, .36, .80, .74), hatLift: .0);
  p.torso(const Rect.fromLTRB(.26, .35, .80, .76));
  p.collar(pt(.56, .56), .06);
}

// --------------------------------------------------------------- 9 pufferfish

void _puffer(Pen p) {
  const Color body = Color(0xFFFFD86A);
  const Color belly = Color(0xFFFFF4CC);
  const Color spot = Color(0xFFC98E3A);
  p.ink = const Color(0xFF5A3A08);

  p.part(
    _fan(pt(.5, .84), .09, math.pi * .3, math.pi * .7, 3),
    darker(body, .04),
    depth: .4,
  );
  for (final double k in sides) {
    p.part(
      _fan(
        pt(.5 + k * .27, .60),
        .1,
        k < 0 ? math.pi * .8 : -math.pi * .2,
        k < 0 ? math.pi * 1.2 : math.pi * .2,
        3,
      ),
      darker(body, .04),
      depth: .4,
    );
  }
  final Path ball = spikes(.5, .56, .28, .27, 18, .14, round: .008);
  p.part(
    ball,
    body,
    shine: 1,
    marks: () {
      p.flat(oval(.5, .70, .2, .12), belly);
      for (final Offset c in <Offset>[
        pt(.32, .42),
        pt(.40, .34),
        pt(.62, .34),
        pt(.70, .44),
        pt(.28, .55),
        pt(.73, .56),
      ]) {
        p.flat(circle(c.dx, c.dy, .016), spot);
      }
    },
  );
  p.eyes(.5, .52, .1, .05);
  p.cheeks(.5, .61, .16, .045);
  // Puckered little mouth.
  p.part(oval(.5, .64, .028, .024), Kit.mouth, depth: 0, line: p.lw * .7);

  p.head(const Rect.fromLTRB(.22, .29, .78, .83), hatLift: .03);
  p.torso(const Rect.fromLTRB(.22, .29, .78, .83));
  p.collar(pt(.5, .74), .18);
}

// --------------------------------------------------------------------- 10 crab

void _crab(Pen p) {
  const Color shell = Color(0xFFF2603E);
  const Color belly = Color(0xFFFFB79A);
  p.ink = const Color(0xFF5A1408);

  for (final double k in sides) {
    for (int i = 0; i < 3; i++) {
      final double y = .66 + i * .045;
      p.tube(
        curve(<Offset>[
          pt(.5 + k * .2, y),
          pt(.5 + k * (.30 + i * .01), y - .04),
          pt(.5 + k * (.36 + i * .015), y + .1 + i * .02),
        ]),
        .022,
        shell,
      );
    }
  }
  // Big raised claws.
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .18, .62),
        pt(.5 + k * .29, .54),
        pt(.5 + k * .32, .44),
      ]),
      .05,
      shell,
    );
    final Offset c = pt(.5 + k * .32, .35);
    final Path claw = minus(
      oval(c.dx, c.dy, .1, .11),
      turn(
        poly(<Offset>[
          c,
          c.translate(k * -.02, -.14),
          c.translate(k * .12, -.12),
        ]),
        c,
        0,
      ),
    );
    p.part(claw, shell, shine: .8);
  }
  for (final double k in sides) {
    p.tube(
      Path()
        ..moveTo(.5 + k * .06, .52)
        ..lineTo(.5 + k * .08, .40),
      .03,
      shell,
    );
  }
  final Path body = oval(.5, .64, .24, .16);
  p.part(
    body,
    shell,
    shine: 1,
    marks: () => p.flat(oval(.5, .74, .16, .07), belly),
  );
  // Eyes on stalks.
  for (final double k in sides) {
    p.part(circle(.5 + k * .08, .37, .055), Kit.white, depth: .4);
    p.eye(pt(.5 + k * .08, .375), .038, iris: const Color(0xFF8A3A2A));
  }
  p.face(pt(.42, .375), pt(.58, .375), .038);
  p.cheeks(.5, .62, .13, .035);
  p.smile(pt(.5, .62), .03);

  p.head(const Rect.fromLTRB(.26, .31, .74, .80), hatLift: .0);
  p.torso(const Rect.fromLTRB(.26, .48, .74, .80));
  p.collar(pt(.5, .56), .2);
}

// ------------------------------------------------------------------ 11 octopus

void _octopus(Pen p) {
  const Color body = Color(0xFFB98AF0);
  const Color sucker = Color(0xFFE6D6FF);
  p.ink = const Color(0xFF3A1A6A);

  final List<List<Offset>> arms = <List<Offset>>[
    <Offset>[
      pt(.36, .62),
      pt(.24, .74),
      pt(.12, .80),
      pt(.10, .72),
      pt(.15, .70),
    ],
    <Offset>[pt(.42, .64), pt(.34, .80), pt(.26, .88), pt(.20, .84)],
    <Offset>[pt(.47, .65), pt(.46, .80), pt(.42, .89), pt(.37, .87)],
    <Offset>[pt(.53, .65), pt(.54, .80), pt(.58, .89), pt(.63, .87)],
    <Offset>[pt(.58, .64), pt(.66, .80), pt(.74, .88), pt(.80, .84)],
    <Offset>[
      pt(.64, .62),
      pt(.76, .74),
      pt(.88, .80),
      pt(.90, .72),
      pt(.85, .70),
    ],
  ];
  for (final List<Offset> a in arms) {
    final Path arm = taper(
      a,
      <double>[.05, .04, .028, .018, .014].sublist(0, a.length),
    );
    p.part(
      arm,
      body,
      depth: .5,
      marks: () {
        final PathMetric m = curve(a).computeMetrics().first;
        for (double t = .3; t < .9; t += .17) {
          final Offset c = m.getTangentForOffset(m.length * t)!.position;
          p.flat(circle(c.dx, c.dy + .012, .01), sucker);
        }
      },
    );
  }
  final Path mantle = blob(<Offset>[
    pt(.5, .17),
    pt(.70, .22),
    pt(.77, .40),
    pt(.72, .58),
    pt(.60, .66),
    pt(.5, .67),
    pt(.40, .66),
    pt(.28, .58),
    pt(.23, .40),
    pt(.30, .22),
  ]);
  p.part(
    mantle,
    body,
    shine: 1,
    marks: () {
      for (final Offset c in <Offset>[
        pt(.40, .27),
        pt(.58, .25),
        pt(.66, .34),
        pt(.33, .37),
      ]) {
        p.flat(circle(c.dx, c.dy, .02), lighter(body, .08));
      }
    },
  );
  p.sweetFace(.5, .50, .09, .05, iris: const Color(0xFF6A3AB0));

  p.head(const Rect.fromLTRB(.23, .17, .77, .67), hatLift: .0);
  p.torso(const Rect.fromLTRB(.23, .30, .77, .80));
  p.collar(pt(.5, .66), .2);
}

// --------------------------------------------------------------- 12 sea turtle

void _seaTurtle(Pen p) {
  const Color shell = Color(0xFF5FA87A);
  const Color plate = Color(0xFF8DCC9C);
  const Color skin = Color(0xFFB4E0B8);
  const Color spot = Color(0xFF88C496);
  p.ink = const Color(0xFF1E4A30);

  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .13, .84), pt(.5 + k * .26, .89), .06),
      skin,
      depth: .5,
    );
  }
  for (final double k in sides) {
    final Path flipper = leaf(
      pt(.5 + k * .2, .56),
      pt(.5 + k * .44, .74),
      .13,
      bend: k * .03,
    );
    p.part(
      flipper,
      skin,
      shine: .4,
      marks: () => p.flat(circle(.5 + k * .32, .66, .018), spot),
    );
  }
  final Path back = oval(.5, .64, .25, .23);
  p.part(
    back,
    shell,
    shine: 1,
    marks: () {
      final List<Offset> hex = ring(.5, .66, .085, .08, 6, start: 0);
      p.flat(poly(hex), plate);
      for (final Offset c in ring(.5, .66, .17, .155, 6, start: math.pi / 6)) {
        p.flat(
          roundPoly(ring(c.dx, c.dy, .065, .06, 6, start: 0), .015),
          plate,
        );
      }
    },
  );
  p.part(
    rrect(.235, .62, .765, .67, .025),
    Color.lerp(shell, plate, .3)!,
    depth: 0,
    line: 0,
  );
  p.outline(back);
  p.part(
    oval(.5, .38, .14, .125),
    skin,
    shine: 1,
    marks: () {
      p.flat(circle(.42, .30, .016), spot);
      p.flat(circle(.58, .29, .012), spot);
    },
  );
  p.sweetFace(.5, .385, .065, .042, iris: const Color(0xFF3A7A4A));

  p.head(const Rect.fromLTRB(.36, .255, .64, .505), hatLift: .0);
  p.torso(const Rect.fromLTRB(.25, .41, .75, .87));
  p.collar(pt(.5, .5), .1);
}

// ---------------------------------------------------------------- 13 angelfish

void _angelfish(Pen p) {
  const Color body = Color(0xFFFFE594);
  const Color fin = Color(0xFFFFF1C4);
  const Color stripe = Color(0xFF4A3E5E);
  const Color face = Color(0xFFFFB458);
  p.ink = const Color(0xFF3A2A10);

  void stripes() {
    for (final double x in <double>[.40, .52, .64]) {
      p.line(
        curve(<Offset>[pt(x - .03, .06), pt(x, .50), pt(x - .03, .95)]),
        width: .035,
        color: stripe,
      );
    }
  }

  final Path dorsal = blob(
    <Offset>[
      pt(.40, .42),
      pt(.44, .30),
      pt(.36, .16),
      pt(.26, .08),
      pt(.32, .22),
      pt(.33, .42),
    ],
    sharp: <int>{3},
  );
  p.part(dorsal, fin, depth: .4, marks: stripes);
  final Path anal = blob(
    <Offset>[
      pt(.40, .62),
      pt(.44, .72),
      pt(.36, .82),
      pt(.27, .89),
      pt(.32, .78),
      pt(.33, .62),
    ],
    sharp: <int>{3},
  );
  p.part(anal, fin, depth: .4, marks: stripes);
  p.part(
    _fan(pt(.32, .52), .12, math.pi * .78, math.pi * 1.22, 3),
    fin,
    depth: .4,
  );
  final Path b = blob(<Offset>[
    pt(.80, .52),
    pt(.68, .38),
    pt(.52, .32),
    pt(.38, .40),
    pt(.34, .52),
    pt(.38, .64),
    pt(.52, .72),
    pt(.68, .66),
  ]);
  p.part(
    b,
    body,
    shine: 1,
    marks: () {
      p.flat(oval(.70, .42, .12, .08), face);
      stripes();
    },
  );
  p.tube(curve(<Offset>[pt(.56, .70), pt(.54, .80), pt(.50, .88)]), .01, fin);
  _sideEye(p, pt(.68, .49), .045, iris: const Color(0xFF9A6A1A), rim: body);
  p.blush(pt(.70, .57), .028);
  p.smile(pt(.775, .565), .018);

  p.head(const Rect.fromLTRB(.58, .34, .80, .70), hatLift: .0);
  p.torso(const Rect.fromLTRB(.34, .32, .80, .72));
  p.collar(pt(.6, .56), .07);
}

// ---------------------------------------------------------------------- 14 eel

void _eel(Pen p) {
  const Color body = Color(0xFF8ACB62);
  const Color spot = Color(0xFFE8F27A);
  const Color rock = Color(0xFF9A8EB8);
  p.ink = const Color(0xFF1E3A14);

  // Peeking out of a reef rock.
  final Path stone = blob(<Offset>[
    pt(.08, .89),
    pt(.10, .70),
    pt(.22, .58),
    pt(.40, .56),
    pt(.52, .64),
    pt(.56, .80),
    pt(.54, .89),
  ]);
  p.part(
    stone,
    rock,
    shine: .6,
    marks: () {
      p.flat(oval(.34, .76, .1, .08), darker(rock, .3));
      p.flat(circle(.18, .70, .03), lighter(rock, .08));
    },
  );
  // One long body rising out of the rock straight into the head.
  final Path eel = union(
    taper(
      <Offset>[
        pt(.34, .78),
        pt(.40, .66),
        pt(.56, .62),
        pt(.64, .50),
        pt(.62, .40),
      ],
      <double>[.07, .075, .08, .085, .09],
    ),
    blob(<Offset>[
      pt(.54, .40),
      pt(.58, .30),
      pt(.68, .26),
      pt(.80, .30),
      pt(.88, .36),
      pt(.86, .44),
      pt(.74, .48),
      pt(.60, .48),
    ]),
  );
  p.part(
    eel,
    body,
    shine: 1,
    marks: () {
      for (final Offset c in <Offset>[
        pt(.40, .70),
        pt(.50, .63),
        pt(.60, .57),
        pt(.66, .48),
        pt(.45, .66),
        pt(.62, .62),
        pt(.62, .32),
        pt(.58, .40),
      ]) {
        p.flat(circle(c.dx, c.dy, .013), spot);
      }
    },
  );
  p.line(
    curve(<Offset>[pt(.74, .42), pt(.80, .425), pt(.87, .40)]),
    width: p.lw * .7,
  );
  p.fang(pt(.80, .426), .008);
  _sideEye(p, pt(.72, .345), .045, iris: const Color(0xFF6A9A2A));
  p.blush(pt(.70, .41), .028);

  p.head(const Rect.fromLTRB(.54, .26, .88, .48), hatLift: .0, hatX: .70);
  p.torso(const Rect.fromLTRB(.30, .40, .70, .80));
  p.collar(pt(.64, .50), .07);
}

// ------------------------------------------------------------------ 15 lobster

void _lobster(Pen p) {
  const Color shell = Color(0xFFE6493C);
  const Color light = Color(0xFFFF9C88);
  p.ink = const Color(0xFF4A0E08);

  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .04, .36),
        pt(.5 + k * .16, .14),
        pt(.5 + k * .34, .06),
      ]),
      .01,
      shell,
    );
  }
  for (final double k in sides) {
    for (int i = 0; i < 3; i++) {
      final double y = .58 + i * .05;
      p.tube(
        curve(<Offset>[
          pt(.5 + k * .12, y),
          pt(.5 + k * .22, y + .02),
          pt(.5 + k * .25, y + .09),
        ]),
        .018,
        shell,
      );
    }
  }
  // Tail fan, then the segmented tail curled beneath.
  p.part(
    _fan(pt(.5, .80), .12, math.pi * .15, math.pi * .85, 5, depth: .06),
    shell,
    depth: .5,
  );
  for (int i = 0; i < 3; i++) {
    p.part(
      oval(.5, .80 - i * .05, .11 - i * .005, .04),
      i.isEven ? shell : darker(shell, .04),
      depth: .5,
    );
  }
  // Raised claws.
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .1, .52),
        pt(.5 + k * .22, .46),
        pt(.5 + k * .27, .36),
      ]),
      .045,
      shell,
    );
    final Offset c = pt(.5 + k * .29, .25);
    final Path claw = minus(
      oval(c.dx, c.dy, .085, .12),
      poly(<Offset>[
        c.translate(0, .02),
        c.translate(k * -.03, -.16),
        c.translate(k * .07, -.15),
      ]),
    );
    p.part(claw, shell, shine: .8);
  }
  final Path body = oval(.5, .53, .14, .2);
  p.part(
    body,
    shell,
    shine: 1,
    marks: () {
      for (final double y in <double>[.58, .64, .70]) {
        p.line(
          curve(<Offset>[pt(.38, y), pt(.5, y + .02), pt(.62, y)]),
          width: .012,
          color: darker(shell, .14),
        );
      }
      p.flat(oval(.5, .43, .08, .04), light.withValues(alpha: .6));
    },
  );
  p.sweetFace(.5, .48, .06, .042, iris: const Color(0xFF8A2A1A));

  p.head(const Rect.fromLTRB(.36, .33, .64, .62), hatLift: .0);
  p.torso(const Rect.fromLTRB(.36, .33, .64, .84));
  p.collar(pt(.5, .58), .12);
}

// ----------------------------------------------------------------- 16 stingray

void _stingray(Pen p) {
  const Color body = Color(0xFFE2BC8E);
  const Color spot = Color(0xFF4FC3F7);
  p.ink = const Color(0xFF4A3018);

  final Path tail = taper(
    <Offset>[pt(.5, .70), pt(.54, .80), pt(.66, .86), pt(.80, .85)],
    <double>[.025, .018, .012, .006],
  );
  p.part(tail, body, depth: .4);
  final Path disc = sym(
    <Offset>[
      pt(.5, .34),
      pt(.66, .38),
      pt(.80, .48),
      pt(.92, .58),
      pt(.78, .64),
      pt(.64, .70),
      pt(.5, .74),
    ],
    sharp: <int>{3},
  );
  p.part(
    disc,
    body,
    shine: 1,
    marks: () {
      for (final Offset c in <Offset>[
        pt(.30, .54),
        pt(.70, .54),
        pt(.38, .64),
        pt(.62, .64),
        pt(.22, .58),
        pt(.78, .58),
        pt(.42, .43),
        pt(.58, .43),
        pt(.5, .66),
      ]) {
        p.canvas.drawCircle(c, .016, fillOf(spot));
        p.canvas.drawCircle(
          c,
          .016,
          strokeOf(Kit.white.withValues(alpha: .6), .005),
        );
      }
    },
  );
  p.sweetFace(.5, .52, .075, .045, iris: const Color(0xFF8A6A3A));

  p.head(const Rect.fromLTRB(.34, .34, .66, .70), hatLift: .0);
  p.torso(const Rect.fromLTRB(.08, .34, .92, .74));
  p.collar(pt(.5, .65), .12);
}

// ------------------------------------------------------------------ 17 penguin

void _penguin(Pen p) {
  const Color black = Color(0xFF3A3F5C);
  const Color white = Color(0xFFFFFFFF);
  const Color orange = Color(0xFFFFA23A);
  p.ink = const Color(0xFF181B2C);

  for (final double k in sides) {
    p.part(oval(.5 + k * .08, .885, .065, .03), orange, depth: .5);
  }
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.5 + k * .2, .50), pt(.5 + k * .3, .74), .1),
        pt(.5 + k * .2, .5),
        k * -.15,
      ),
      black,
    );
  }
  final Path body = blob(<Offset>[
    pt(.5, .22),
    pt(.66, .26),
    pt(.73, .42),
    pt(.74, .62),
    pt(.68, .80),
    pt(.5, .875),
    pt(.32, .80),
    pt(.26, .62),
    pt(.27, .42),
    pt(.34, .26),
  ]);
  p.part(
    body,
    black,
    shine: .7,
    marks: () {
      p.flat(oval(.5, .66, .17, .2), white);
      final Path mask = Path()
        ..moveTo(.5, .38)
        ..cubicTo(.55, .30, .68, .32, .67, .44)
        ..cubicTo(.66, .54, .56, .58, .5, .60)
        ..cubicTo(.44, .58, .34, .54, .33, .44)
        ..cubicTo(.32, .32, .45, .30, .5, .38)
        ..close();
      p.flat(mask, white);
    },
  );
  p.eyes(.5, .44, .075, .045);
  p.cheeks(.5, .51, .12, .032);
  p.part(
    roundPoly(<Offset>[pt(.465, .495), pt(.535, .495), pt(.5, .545)], .012),
    orange,
    depth: .4,
    line: p.lw * .6,
  );

  p.head(const Rect.fromLTRB(.27, .22, .73, .58), hatLift: .0);
  p.torso(const Rect.fromLTRB(.26, .40, .74, .875));
  p.collar(pt(.5, .58), .16);
}

// ----------------------------------------------------------------- 18 seal pup

void _sealPup(Pen p) {
  const Color fur = Color(0xFFF8F9FF);
  const Color shade = Color(0xFFDCE2F2);
  p.ink = const Color(0xFF2E3650);

  p.part(
    _fan(pt(.16, .80), .1, math.pi * .85, math.pi * 1.25, 2),
    shade,
    depth: .4,
  );
  final Path body = blob(<Offset>[
    pt(.14, .80),
    pt(.24, .68),
    pt(.42, .62),
    pt(.62, .62),
    pt(.78, .72),
    pt(.76, .87),
    pt(.48, .895),
    pt(.22, .87),
  ]);
  p.part(
    body,
    fur,
    shine: .7,
    marks: () => p.flat(oval(.42, .86, .24, .05), shade),
  );
  p.part(leaf(pt(.56, .80), pt(.46, .87), .06), shade, depth: .4);
  p.part(circle(.62, .50, .195), fur, shine: 1);
  // Huge dark eyes.
  p.eyes(.62, .46, .085, .058, iris: const Color(0xFF4A5A8A));
  p.cheeks(.62, .545, .14, .034);
  p.part(
    union(oval(.596, .56, .04, .032), oval(.644, .56, .04, .032)),
    shade,
    depth: 0,
    line: 0,
  );
  p.nose(pt(.62, .54), .02);
  p.catMouth(pt(.62, .565), .018);
  whiskers(p, pt(.62, .56), .05, .1, color: const Color(0xFF8A94B0));

  p.head(const Rect.fromLTRB(.425, .305, .815, .695), hatLift: .0);
  p.torso(const Rect.fromLTRB(.14, .62, .78, .89));
  p.collar(pt(.62, .69), .13);
}

// ------------------------------------------------------------------- 19 walrus

void _walrus(Pen p) {
  const Color skin = Color(0xFFC08A70);
  const Color muzzle = Color(0xFFEDD0BC);
  const Color tusk = Color(0xFFFFFBF0);
  p.ink = const Color(0xFF4A2414);

  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .1, .84), pt(.5 + k * .26, .89), .07),
      darker(skin, .06),
      depth: .5,
    );
  }
  final Path body = blob(<Offset>[
    pt(.5, .26),
    pt(.68, .30),
    pt(.78, .48),
    pt(.80, .70),
    pt(.72, .86),
    pt(.5, .89),
    pt(.28, .86),
    pt(.20, .70),
    pt(.22, .48),
    pt(.32, .30),
  ]);
  p.part(
    body,
    skin,
    shine: 1,
    marks: () {
      p.flat(oval(.5, .78, .2, .1), lighter(skin, .06));
      for (final Offset c in <Offset>[
        pt(.36, .66),
        pt(.66, .70),
        pt(.40, .80),
      ]) {
        p.line(
          Path()
            ..moveTo(c.dx - .02, c.dy)
            ..quadraticBezierTo(c.dx, c.dy + .012, c.dx + .02, c.dy),
          width: .008,
          color: darker(skin, .1),
        );
      }
    },
  );
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.5 + k * .24, .62), pt(.5 + k * .36, .78), .1),
        pt(.5 + k * .24, .62),
        0,
      ),
      darker(skin, .04),
    );
  }
  // Long tusks.
  for (final double k in sides) {
    p.part(
      blob(
        <Offset>[
          pt(.5 + k * .03, .52),
          pt(.5 + k * .075, .52),
          pt(.5 + k * .065, .66),
          pt(.5 + k * .05, .74),
          pt(.5 + k * .035, .66),
        ],
        sharp: <int>{3},
      ),
      tusk,
      shine: .5,
    );
  }
  p.part(
    union(oval(.455, .50, .06, .05), oval(.545, .50, .06, .05)),
    muzzle,
    shine: .5,
  );
  for (final double k in sides) {
    for (final Offset d in <Offset>[
      const Offset(.03, .50),
      const Offset(.055, .495),
      const Offset(.045, .52),
      const Offset(.075, .515),
    ]) {
      p.flat(circle(.5 + k * d.dx, d.dy, .005), darker(muzzle, .3));
    }
  }
  p.nose(pt(.5, .46), .022);
  p.eyes(.5, .39, .09, .038);
  p.cheeks(.5, .44, .15, .03);

  p.head(const Rect.fromLTRB(.3, .26, .7, .60), hatLift: .0);
  p.torso(const Rect.fromLTRB(.2, .40, .8, .89));
  p.collar(pt(.5, .58), .2);
}

// ------------------------------------------------------------------ 20 dolphin

void _dolphin(Pen p) {
  const Color skin = Color(0xFF8FC3EF);
  const Color belly = Color(0xFFEAF5FF);
  p.ink = const Color(0xFF173A5E);

  p.part(_flukes(pt(.17, .50), .13, tilt: -.55), skin);
  p.part(
    blob(
      <Offset>[
        pt(.48, .40),
        pt(.42, .25),
        pt(.34, .22),
        pt(.37, .32),
        pt(.36, .43),
      ],
      sharp: <int>{2},
    ),
    skin,
  );
  // A chubby arched body with a round melon and a short beak.
  final Path body = blob(
    <Offset>[
      pt(.92, .60),
      pt(.86, .55),
      pt(.80, .52),
      pt(.76, .42),
      pt(.64, .37),
      pt(.48, .38),
      pt(.32, .44),
      pt(.18, .52),
      pt(.30, .60),
      pt(.46, .67),
      pt(.64, .69),
      pt(.80, .66),
      pt(.88, .64),
    ],
    sharp: <int>{0, 7},
  );
  p.part(
    body,
    skin,
    shine: 1,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.90, .62),
          pt(.80, .60),
          pt(.64, .61),
          pt(.44, .62),
          pt(.52, .70),
          pt(.70, .72),
          pt(.84, .66),
        ]),
        belly,
      );
    },
  );
  p.part(leaf(pt(.60, .66), pt(.52, .78), .07, bend: .01), skin);
  _sideEye(p, pt(.70, .50), .047, iris: const Color(0xFF3A6AA0));
  p.blush(pt(.72, .57), .03);
  p.line(
    curve(<Offset>[pt(.80, .585), pt(.86, .605), pt(.915, .60)]),
    width: p.lw * .7,
  );
  p.sparkle(pt(.14, .76), .015);
  p.sparkle(pt(.22, .82), .01);
  p.sparkle(pt(.86, .30), .012);

  p.head(const Rect.fromLTRB(.60, .37, .92, .66), hatLift: .0, hatX: .68);
  p.torso(const Rect.fromLTRB(.18, .37, .92, .72));
  p.collar(pt(.58, .55), .06);
}

// ---------------------------------------------------------------- 21 swordfish

void _swordfish(Pen p) {
  const Color top = Color(0xFF4F72B8);
  const Color belly = Color(0xFFE2EAF6);
  const Color sword = Color(0xFF8AA0C8);
  p.ink = const Color(0xFF14244A);

  p.part(
    blob(
      <Offset>[pt(.20, .53), pt(.08, .30), pt(.13, .52), pt(.08, .76)],
      sharp: <int>{1, 3},
    ),
    top,
  );
  // The tall sail.
  p.part(
    blob(
      <Offset>[
        pt(.58, .40),
        pt(.52, .18),
        pt(.42, .14),
        pt(.36, .24),
        pt(.36, .42),
      ],
      sharp: <int>{0},
    ),
    lighter(top, .06),
    marks: () {
      for (final double x in <double>[.40, .46, .52]) {
        p.line(
          Path()
            ..moveTo(x, .42)
            ..lineTo(x - .01, .2),
          width: .008,
          color: darker(top, .12),
        );
      }
    },
  );
  final Path sw = blob(
    <Offset>[pt(.74, .465), pt(.97, .48), pt(.74, .505)],
    sharp: <int>{1},
  );
  p.part(sw, sword, depth: .5);
  final Path body = blob(
    <Offset>[
      pt(.80, .50),
      pt(.70, .41),
      pt(.50, .38),
      pt(.32, .43),
      pt(.20, .53),
      pt(.32, .60),
      pt(.50, .64),
      pt(.70, .60),
    ],
    sharp: <int>{0, 4},
  );
  p.part(
    body,
    top,
    shine: 1,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.80, .51),
          pt(.66, .52),
          pt(.46, .54),
          pt(.26, .55),
          pt(.40, .64),
          pt(.62, .64),
        ]),
        belly,
      );
    },
  );
  p.part(leaf(pt(.58, .58), pt(.50, .70), .06), lighter(top, .06));
  _sideEye(p, pt(.69, .47), .045, iris: const Color(0xFF3A5A9A));
  p.blush(pt(.70, .54), .028);
  p.smile(pt(.765, .535), .015);

  p.head(const Rect.fromLTRB(.60, .40, .80, .62), hatLift: .0, hatX: .66);
  p.torso(const Rect.fromLTRB(.20, .38, .80, .64));
  p.collar(pt(.58, .52), .06);
}

// --------------------------------------------------------------- 22 hammerhead

void _hammerhead(Pen p) {
  const Color skin = Color(0xFF9CAAC0);
  const Color belly = Color(0xFFF2F5FA);
  p.ink = const Color(0xFF1E2A40);

  // Coming toward you: tail curling off behind, fins to each side.
  final Path tail = taper(
    <Offset>[pt(.5, .62), pt(.56, .76), pt(.70, .84)],
    <double>[.1, .06, .03],
  );
  p.part(tail, skin);
  p.part(_flukes(pt(.72, .84), .1, tilt: math.pi), skin);
  p.part(
    blob(<Offset>[pt(.44, .30), pt(.48, .12), pt(.56, .30)], sharp: <int>{1}),
    skin,
  );
  for (final double k in sides) {
    p.part(
      blob(
        <Offset>[
          pt(.5 + k * .12, .56),
          pt(.5 + k * .34, .70),
          pt(.5 + k * .16, .66),
        ],
        sharp: <int>{1},
      ),
      skin,
    );
  }
  final Path torso = oval(.5, .52, .17, .16);
  p.part(
    torso,
    skin,
    shine: .6,
    marks: () => p.flat(oval(.5, .60, .12, .09), belly),
  );
  // The hammer.
  final Path hammer = blob(<Offset>[
    pt(.5, .28),
    pt(.70, .30),
    pt(.86, .30),
    pt(.90, .36),
    pt(.86, .42),
    pt(.66, .44),
    pt(.5, .47),
    pt(.34, .44),
    pt(.14, .42),
    pt(.10, .36),
    pt(.14, .30),
    pt(.30, .30),
  ]);
  p.part(
    hammer,
    skin,
    shine: 1,
    marks: () => p.flat(oval(.5, .46, .12, .035), belly),
  );
  for (final double k in sides) {
    p.eye(
      pt(.5 + k * .33, .36),
      .036,
      iris: const Color(0xFF4A6A9A),
      rim: belly,
    );
  }
  p.face(pt(.17, .36), pt(.83, .36), .036);
  p.cheeks(.5, .43, .1, .03);
  p.smile(pt(.5, .43), .035, depth: .4);
  for (final double k in sides) {
    for (final double d in <double>[0, .02, .04]) {
      p.line(
        Path()
          ..moveTo(.5 + k * (.12 + d), .50)
          ..lineTo(.5 + k * (.115 + d), .54),
        width: .006,
        color: darker(skin, .15),
      );
    }
  }

  p.head(const Rect.fromLTRB(.3, .28, .7, .47), hatLift: .03);
  p.torso(const Rect.fromLTRB(.33, .36, .67, .68));
  p.collar(pt(.5, .5), .14);
}

// --------------------------------------------------------------- 23 anglerfish

void _angler(Pen p) {
  const Color body = Color(0xFF6A4E92);
  const Color belly = Color(0xFF9A82C0);
  const Color lamp = Color(0xFFFFF27A);
  p.ink = const Color(0xFF1E1236);

  for (final double k in sides) {
    p.part(
      _fan(
        pt(.5 + k * .26, .62),
        .1,
        k < 0 ? math.pi * .8 : -math.pi * .2,
        k < 0 ? math.pi * 1.2 : math.pi * .2,
        3,
      ),
      lighter(body, .05),
      depth: .4,
    );
  }
  p.part(
    _fan(pt(.5, .84), .08, math.pi * .3, math.pi * .7, 3),
    lighter(body, .05),
    depth: .4,
  );
  // The lure, arcing forward from the forehead.
  p.tube(
    curve(<Offset>[pt(.5, .36), pt(.52, .22), pt(.62, .13), pt(.72, .16)]),
    .016,
    body,
  );
  p.glow(pt(.73, .19), .11, lamp, alpha: .8);
  p.part(circle(.73, .19, .038), lamp, shine: 1.2);
  final Path ball = oval(.5, .60, .28, .26);
  p.part(
    ball,
    body,
    shine: .8,
    marks: () {
      p.flat(oval(.5, .78, .18, .1), belly);
      for (final Offset c in <Offset>[
        pt(.32, .48),
        pt(.66, .44),
        pt(.30, .66),
        pt(.72, .62),
      ]) {
        p.glow(c, .02, lamp, alpha: .7);
      }
    },
  );
  p.eyes(
    .5,
    .51,
    .1,
    .05,
    iris: const Color(0xFF6AE0F0),
    rim: const Color(0xFFE8E0FF),
  );
  p.cheeks(.5, .58, .17, .03, alpha: .8);
  // A big grin full of tiny teeth.
  final Path mouth = Path()
    ..moveTo(.34, .62)
    ..quadraticBezierTo(.5, .66, .66, .62)
    ..quadraticBezierTo(.62, .76, .5, .77)
    ..quadraticBezierTo(.38, .76, .34, .62)
    ..close();
  p.flat(mouth, Kit.mouth);
  p.inside(mouth, () {
    for (double x = .37; x < .64; x += .045) {
      p.flat(
        poly(<Offset>[pt(x, .62), pt(x + .03, .625), pt(x + .015, .655)]),
        Kit.tooth,
      );
    }
    p.flat(oval(.5, .78, .07, .04), Kit.tongue);
  });
  p.outline(mouth, p.lw * .8);

  p.head(const Rect.fromLTRB(.22, .34, .78, .86), hatLift: .0);
  p.torso(const Rect.fromLTRB(.22, .34, .78, .86));
  p.collar(pt(.5, .80), .16);
}

// ---------------------------------------------------------------- 24 manta ray

void _manta(Pen p) {
  const Color top = Color(0xFF3E5A92);
  const Color white = Color(0xFFF4F7FF);
  p.ink = const Color(0xFF101C3A);

  final Path tail = taper(
    <Offset>[pt(.5, .66), pt(.48, .78), pt(.40, .88)],
    <double>[.018, .012, .006],
  );
  p.part(tail, top, depth: .4);
  final Path wings = sym(
    <Offset>[
      pt(.5, .36),
      pt(.64, .38),
      pt(.78, .44),
      pt(.97, .60),
      pt(.80, .60),
      pt(.64, .66),
      pt(.5, .70),
    ],
    sharp: <int>{3},
  );
  p.part(
    wings,
    top,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(
          blob(<Offset>[
            pt(.5 + k * .14, .42),
            pt(.5 + k * .26, .46),
            pt(.5 + k * .22, .54),
            pt(.5 + k * .12, .52),
          ]),
          white.withValues(alpha: .85),
        );
      }
      p.flat(oval(.5, .70, .14, .04), white);
    },
  );
  // Cephalic fins, curled like little horns.
  for (final double k in sides) {
    final Path horn = taper(
      <Offset>[
        pt(.5 + k * .09, .40),
        pt(.5 + k * .12, .30),
        pt(.5 + k * .08, .25),
      ],
      <double>[.03, .022, .014],
    );
    p.part(horn, top, depth: .4);
  }
  p.sweetFace(.5, .49, .08, .045, iris: const Color(0xFF6A8AD0));

  p.head(const Rect.fromLTRB(.34, .36, .66, .64), hatLift: .06);
  p.torso(const Rect.fromLTRB(.03, .36, .97, .70));
  p.collar(pt(.5, .62), .12);
}

// ----------------------------------------------------------------- 25 narwhal

void _narwhal(Pen p) {
  const Color skin = Color(0xFFA8B8DE);
  const Color belly = Color(0xFFEFF3FC);
  const Color spot = Color(0xFF7E90BE);
  const Color tusk = Color(0xFFFFF6DE);
  p.ink = const Color(0xFF1E2A50);

  p.part(_flukes(pt(.16, .62), .13, tilt: -.2), skin);
  final Path t = blob(
    <Offset>[pt(.76, .44), pt(.98, .17), pt(.80, .48)],
    sharp: <int>{1},
  );
  p.part(
    t,
    tusk,
    shine: .5,
    marks: () {
      for (double f = .2; f < 1; f += .14) {
        final Offset c = Offset.lerp(pt(.78, .46), pt(.98, .17), f)!;
        p.line(
          Path()
            ..moveTo(c.dx - .015, c.dy - .006)
            ..lineTo(c.dx + .008, c.dy + .016),
          width: .006,
          color: darker(tusk, .2),
        );
      }
    },
  );
  final Path body = blob(
    <Offset>[
      pt(.84, .56),
      pt(.80, .45),
      pt(.66, .40),
      pt(.46, .42),
      pt(.28, .52),
      pt(.16, .62),
      pt(.30, .66),
      pt(.50, .70),
      pt(.70, .70),
      pt(.82, .65),
    ],
    sharp: <int>{5},
  );
  p.part(
    body,
    skin,
    shine: 1,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.82, .62),
          pt(.66, .62),
          pt(.46, .64),
          pt(.32, .66),
          pt(.50, .73),
          pt(.72, .73),
        ]),
        belly,
      );
      for (final Offset c in <Offset>[
        pt(.40, .48),
        pt(.48, .45),
        pt(.34, .55),
        pt(.56, .44),
        pt(.44, .54),
        pt(.28, .58),
      ]) {
        p.flat(oval(c.dx, c.dy, .016, .011), spot);
      }
    },
  );
  p.part(leaf(pt(.62, .67), pt(.54, .78), .06), skin);
  _sideEye(p, pt(.70, .52), .045, iris: const Color(0xFF4A5A9A));
  p.blush(pt(.73, .59), .03);
  p.smile(pt(.785, .595), .02);

  p.head(const Rect.fromLTRB(.60, .40, .84, .66), hatLift: .0, hatX: .68);
  p.torso(const Rect.fromLTRB(.16, .40, .84, .72));
  p.collar(pt(.58, .58), .06);
}

// -------------------------------------------------------------------- 26 orca

void _orca(Pen p) {
  const Color black = Color(0xFF2F3448);
  const Color white = Color(0xFFFFFFFF);
  const Color saddle = Color(0xFFC9CEDC);
  p.ink = const Color(0xFF0E1018);

  p.part(_flukes(pt(.16, .62), .13, tilt: -.2), black);
  p.part(
    blob(
      <Offset>[
        pt(.50, .44),
        pt(.44, .22),
        pt(.40, .14),
        pt(.36, .26),
        pt(.38, .45),
      ],
      sharp: <int>{2},
    ),
    black,
  );
  final Path body = blob(
    <Offset>[
      pt(.86, .58),
      pt(.80, .46),
      pt(.64, .41),
      pt(.46, .42),
      pt(.28, .52),
      pt(.16, .62),
      pt(.30, .66),
      pt(.50, .71),
      pt(.70, .71),
      pt(.82, .66),
    ],
    sharp: <int>{5},
  );
  p.part(
    body,
    black,
    shine: .8,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.84, .63),
          pt(.70, .64),
          pt(.56, .66),
          pt(.44, .62),
          pt(.36, .66),
          pt(.50, .74),
          pt(.72, .74),
        ]),
        white,
      );
      p.flat(turn(oval(.64, .48, .065, .03), pt(.64, .48), -.15), white);
      p.flat(oval(.36, .46, .07, .03), saddle);
    },
  );
  p.part(leaf(pt(.62, .68), pt(.54, .80), .07), black);
  _sideEye(p, pt(.74, .52), .04, iris: const Color(0xFF5A6A9A), rim: white);
  p.blush(pt(.76, .585), .028);
  p.smile(pt(.80, .60), .022, color: white);

  p.head(const Rect.fromLTRB(.60, .41, .86, .68), hatLift: .0, hatX: .70);
  p.torso(const Rect.fromLTRB(.16, .41, .86, .72));
  p.collar(pt(.58, .58), .06);
}

// -------------------------------------------------------------- 27 great white

void _greatWhite(Pen p) {
  const Color top = Color(0xFF8E9CB6);
  const Color belly = Color(0xFFF6F8FC);
  p.ink = const Color(0xFF1A2236);

  p.part(
    blob(
      <Offset>[pt(.20, .56), pt(.08, .30), pt(.14, .54), pt(.10, .78)],
      sharp: <int>{1, 3},
    ),
    top,
  );
  p.part(
    blob(<Offset>[pt(.52, .42), pt(.44, .22), pt(.38, .43)], sharp: <int>{1}),
    top,
  );
  final Path body = blob(
    <Offset>[
      pt(.90, .56),
      pt(.82, .45),
      pt(.64, .40),
      pt(.44, .42),
      pt(.28, .50),
      pt(.18, .56),
      pt(.30, .62),
      pt(.50, .68),
      pt(.70, .68),
      pt(.84, .64),
    ],
    sharp: <int>{5},
  );
  p.part(
    body,
    top,
    shine: 1,
    marks: () {
      final Path b = Path()..moveTo(.92, .58);
      final List<double> xs = <double>[.82, .74, .66, .58, .50, .42, .34];
      for (int i = 0; i < xs.length; i++) {
        b.lineTo(xs[i], i.isEven ? .575 : .595);
      }
      b
        ..lineTo(.26, .60)
        ..lineTo(.40, .72)
        ..lineTo(.80, .72)
        ..close();
      p.flat(b, belly);
      for (final double x in <double>[.60, .63, .66]) {
        p.line(
          Path()
            ..moveTo(x, .48)
            ..lineTo(x - .01, .56),
          width: .007,
          color: darker(top, .15),
        );
      }
    },
  );
  p.part(
    blob(<Offset>[pt(.56, .62), pt(.46, .76), pt(.50, .64)], sharp: <int>{1}),
    top,
  );
  _sideEye(p, pt(.73, .49), .042, iris: const Color(0xFF3A4A7A));
  p.blush(pt(.71, .56), .028);
  // A toothy — but friendly — grin.
  final Path mouth = Path()
    ..moveTo(.70, .60)
    ..quadraticBezierTo(.80, .62, .89, .585)
    ..quadraticBezierTo(.86, .65, .78, .655)
    ..quadraticBezierTo(.72, .65, .70, .60)
    ..close();
  p.flat(mouth, Kit.mouth);
  p.inside(mouth, () {
    for (double x = .72; x < .88; x += .033) {
      p.flat(
        poly(<Offset>[pt(x, .60), pt(x + .026, .60), pt(x + .013, .63)]),
        Kit.tooth,
      );
    }
  });
  p.outline(mouth, p.lw * .7);

  p.head(const Rect.fromLTRB(.62, .40, .90, .66), hatLift: .0, hatX: .70);
  p.torso(const Rect.fromLTRB(.18, .40, .90, .70));
  p.collar(pt(.58, .56), .06);
}

// ------------------------------------------------------------- 28 giant squid

void _squid(Pen p) {
  const Color body = Color(0xFFEE6E82);
  const Color light = Color(0xFFFFB2BE);
  p.ink = const Color(0xFF5A0E20);

  // Two long feeding tentacles with clubbed ends.
  for (final double k in sides) {
    final Path t = taper(
      <Offset>[
        pt(.5 + k * .06, .66),
        pt(.5 + k * .22, .74),
        pt(.5 + k * .34, .68),
        pt(.5 + k * .38, .58),
      ],
      <double>[.02, .016, .014, .012],
    );
    p.part(t, body, depth: .4);
    p.part(
      leaf(pt(.5 + k * .37, .62), pt(.5 + k * .40, .48), .06),
      body,
      marks: () {
        p.flat(circle(.5 + k * .39, .55, .01), light);
      },
    );
  }
  final List<List<Offset>> arms = <List<Offset>>[
    for (final double x in <double>[-.12, -.07, -.025, .025, .07, .12])
      <Offset>[
        pt(.5 + x * .6, .66),
        pt(.5 + x * 1.1, .76),
        pt(.5 + x * 1.3, .84),
        pt(.5 + x * 1.6, .89),
      ],
  ];
  for (final List<Offset> a in arms) {
    p.part(
      taper(a, <double>[.03, .024, .018, .012]),
      body,
      depth: .4,
      marks: () {
        p.flat(circle(a[1].dx, a[1].dy, .008), light);
        p.flat(circle(a[2].dx, a[2].dy, .007), light);
      },
    );
  }
  // Mantle with its arrowhead fins.
  p.part(
    blob(
      <Offset>[
        pt(.5, .10),
        pt(.68, .18),
        pt(.60, .28),
        pt(.5, .24),
        pt(.40, .28),
        pt(.32, .18),
      ],
      sharp: <int>{0, 1, 5},
    ),
    darker(body, .03),
  );
  final Path mantle = blob(<Offset>[
    pt(.5, .14),
    pt(.62, .26),
    pt(.66, .44),
    pt(.64, .62),
    pt(.5, .70),
    pt(.36, .62),
    pt(.34, .44),
    pt(.38, .26),
  ]);
  p.part(
    mantle,
    body,
    shine: 1,
    marks: () {
      for (final Offset c in <Offset>[
        pt(.46, .28),
        pt(.55, .34),
        pt(.44, .42),
        pt(.57, .46),
      ]) {
        p.flat(circle(c.dx, c.dy, .014), light);
      }
    },
  );
  p.eyes(
    .5,
    .56,
    .075,
    .05,
    iris: const Color(0xFF8A2A3A),
    rim: const Color(0xFFFFF0F2),
  );
  p.cheeks(.5, .63, .13, .028);
  p.smile(pt(.5, .635), .018);

  p.head(const Rect.fromLTRB(.34, .14, .66, .70), hatLift: .04);
  p.torso(const Rect.fromLTRB(.34, .40, .66, .80));
  p.collar(pt(.5, .68), .12);
}

// --------------------------------------------------------------- 29 blue whale

void _blueWhale(Pen p) {
  const Color skin = Color(0xFF6E98DA);
  const Color belly = Color(0xFFDCE8FA);
  const Color spray = Color(0xFFD8F2FF);
  p.ink = const Color(0xFF142A58);

  // The spout.
  for (final List<double> d in <List<double>>[
    <double>[.62, .26, -.5],
    <double>[.70, .22, 0],
    <double>[.78, .26, .5],
  ]) {
    p.part(
      tear(d[0], d[1], .035, angle: d[2], length: 2.2),
      spray,
      depth: .4,
      line: p.lw * .7,
    );
  }
  p.tube(
    curve(<Offset>[pt(.70, .40), pt(.70, .30)]),
    .02,
    spray,
    line: p.lw * .7,
  );
  p.part(_flukes(pt(.12, .60), .12, tilt: -.3), skin);
  final Path body = blob(
    <Offset>[
      pt(.93, .58),
      pt(.88, .46),
      pt(.70, .40),
      pt(.46, .43),
      pt(.26, .52),
      pt(.12, .60),
      pt(.26, .64),
      pt(.48, .71),
      pt(.74, .72),
      pt(.88, .67),
    ],
    sharp: <int>{5},
  );
  p.part(
    body,
    skin,
    shine: 1,
    marks: () {
      final Path b = blob(<Offset>[
        pt(.92, .62),
        pt(.76, .62),
        pt(.56, .64),
        pt(.38, .66),
        pt(.54, .74),
        pt(.80, .74),
      ]);
      p.flat(b, belly);
      for (double y = .65; y < .76; y += .022) {
        p.line(
          Path()
            ..moveTo(.52, y)
            ..lineTo(.92, y - .02),
          width: .006,
          color: darker(belly, .12),
        );
      }
      for (final Offset c in <Offset>[
        pt(.40, .50),
        pt(.52, .46),
        pt(.62, .45),
        pt(.34, .56),
      ]) {
        p.flat(oval(c.dx, c.dy, .018, .01), lighter(skin, .06));
      }
    },
  );
  p.part(
    blob(<Offset>[pt(.34, .48), pt(.30, .42), pt(.26, .50)], sharp: <int>{1}),
    skin,
    depth: .4,
  );
  p.part(leaf(pt(.62, .69), pt(.54, .80), .06), skin);
  _sideEye(p, pt(.78, .55), .04, iris: const Color(0xFF3A5AA0));
  p.blush(pt(.80, .61), .028);
  p.smile(pt(.86, .615), .03, depth: .3);

  p.head(const Rect.fromLTRB(.66, .40, .93, .70), hatLift: .0, hatX: .76);
  p.torso(const Rect.fromLTRB(.12, .40, .93, .74));
  p.collar(pt(.62, .58), .06);
}

// ---------------------------------------------------------- 30 tidecaller whale

void _tidecaller(Pen p) {
  const Color skin = Color(0xFF39B8C6);
  const Color belly = Color(0xFFD8FBFF);
  const Color glow = Color(0xFF9CF6FF);
  const Color gold = Color(0xFFFFD25A);
  p.ink = const Color(0xFF0C3A48);

  // A ribbon of seawater circling the whale, the tide it answers to.
  final Rect loop = Rect.fromCenter(
    center: pt(.52, .58),
    width: .86,
    height: .26,
  );
  Path arc(double from, double sweep) =>
      turn(Path()..addArc(loop, from, sweep), pt(.52, .58), -.12);
  p.glow(pt(.5, .5), .42, glow, alpha: .3);
  p.tube(arc(math.pi, math.pi), .035, const Color(0xFF8AEAF4));
  p.line(
    arc(math.pi * 1.15, math.pi * .5),
    width: .01,
    color: Kit.white.withValues(alpha: .8),
  );
  p.part(_flukes(pt(.16, .50), .14, tilt: -.5), skin);
  final Path body = blob(
    <Offset>[
      pt(.90, .56),
      pt(.84, .42),
      pt(.66, .34),
      pt(.44, .36),
      pt(.26, .46),
      pt(.16, .52),
      pt(.28, .60),
      pt(.48, .70),
      pt(.72, .70),
      pt(.86, .65),
    ],
    sharp: <int>{5},
  );
  p.part(
    body,
    skin,
    shine: 1,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.88, .60),
          pt(.70, .60),
          pt(.50, .62),
          pt(.36, .62),
          pt(.52, .72),
          pt(.78, .72),
        ]),
        belly,
      );
      for (final List<Offset> sw in <List<Offset>>[
        <Offset>[pt(.34, .46), pt(.40, .42), pt(.46, .45), pt(.42, .49)],
        <Offset>[pt(.52, .40), pt(.58, .37), pt(.64, .40), pt(.60, .44)],
      ]) {
        p.line(curve(sw), width: .012, color: glow);
      }
      for (final Offset c in <Offset>[
        pt(.30, .54),
        pt(.50, .52),
        pt(.66, .48),
        pt(.40, .58),
      ]) {
        p.flat(circle(c.dx, c.dy, .01), glow);
      }
    },
  );
  p.tube(arc(0, math.pi), .035, const Color(0xFF8AEAF4));
  p.line(
    arc(math.pi * .2, math.pi * .45),
    width: .01,
    color: Kit.white.withValues(alpha: .8),
  );
  for (final Offset c in <Offset>[pt(.12, .66), pt(.90, .50), pt(.30, .74)]) {
    p.part(
      tear(c.dx, c.dy, .016, length: 2.0),
      const Color(0xFFBFF6FF),
      depth: 0,
      line: p.lw * .5,
    );
  }
  // A coral crown.
  p.part(
    roundPoly(<Offset>[
      pt(.62, .37),
      pt(.62, .26),
      pt(.665, .31),
      pt(.70, .22),
      pt(.735, .31),
      pt(.78, .26),
      pt(.78, .38),
    ], .008),
    gold,
    shine: .8,
  );
  p.part(
    circle(.70, .30, .014),
    const Color(0xFFFF7A9A),
    depth: 0,
    line: p.lw * .5,
  );
  _sideEye(p, pt(.75, .50), .045, iris: const Color(0xFF1A8A9A), rim: belly);
  p.blush(pt(.77, .575), .03);
  p.smile(pt(.83, .58), .028, depth: .35);
  p.twinkle(pt(.30, .24), .03, gold);
  p.twinkle(pt(.90, .30), .022, glow);
  p.twinkle(pt(.12, .34), .018, glow);

  p.head(const Rect.fromLTRB(.62, .34, .90, .68), hatLift: .05, hatX: .70);
  p.torso(const Rect.fromLTRB(.16, .34, .90, .72));
  p.collar(pt(.58, .56), .06);
}
