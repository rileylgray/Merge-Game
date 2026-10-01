import 'dart:math' as math;
import 'package:flutter/painting.dart';

import 'creature_art.dart';
import 'kit.dart';
import 'parts.dart';

/// Night Meadow — moonlit hedgerows and the creatures that wake after dark,
/// climbing from a firefly to a stag woven out of constellations.
const Map<String, CreatureArt> nightArt = <String, CreatureArt>{
  'night_01': CreatureArt(_firefly, shadow: .2),
  'night_02': CreatureArt(_moth, shadow: .2),
  'night_03': CreatureArt(_glowworm, shadow: .34),
  'night_04': CreatureArt(_cricket, shadow: .32),
  'night_05': CreatureArt(_bat, shadow: .2),
  'night_06': CreatureArt(_dormouse, shadow: .32),
  'night_07': CreatureArt(_possum, shadow: .26),
  'night_08': CreatureArt(_owlet, shadow: .24),
  'night_09': CreatureArt(_skunk, shadow: .28),
  'night_10': CreatureArt(_fennec, shadow: .26),
  'night_11': CreatureArt(_tarsier, shadow: .3),
  'night_12': CreatureArt(_glider, shadow: .26),
  'night_13': CreatureArt(_loris, shadow: .26),
  'night_14': CreatureArt(_ayeAye, shadow: .26),
  'night_15': CreatureArt(_badger, shadow: .3),
  'night_16': CreatureArt(_armadillo, shadow: .36),
  'night_17': CreatureArt(_porcupine, shadow: .3),
  'night_18': CreatureArt(_barnOwl, shadow: .24),
  'night_19': CreatureArt(_lynx, shadow: .28),
  'night_20': CreatureArt(_wolfPup, shadow: .28),
  'night_21': CreatureArt(_panther, shadow: .3),
  'night_22': CreatureArt(_moonHare, shadow: .24),
  'night_23': CreatureArt(_snowLeopard, shadow: .3),
  'night_24': CreatureArt(_auroraWolf, shadow: .3),
  'night_25': CreatureArt(_cometCat, shadow: .28),
  'night_26': CreatureArt(_dreamTapir, shadow: .32),
  'night_27': CreatureArt(_nebulaOwl, shadow: .26),
  'night_28': CreatureArt(_eclipseBear, shadow: .3),
  'night_29': CreatureArt(_lunarLynx, shadow: .28),
  'night_30': CreatureArt(_starStag, shadow: .3),
};

const Color _starGold = Color(0xFFFFE27A);

// ----------------------------------------------------------------- 1 firefly

void _firefly(Pen p) {
  const Color body = Color(0xFF5A5288);
  const Color cap = Color(0xFFFF8A5B);
  const Color lamp = Color(0xFFFFF27A);
  const Color wing = Color(0xD9E6F0FF);
  p.ink = const Color(0xFF221C3A);

  p.glow(pt(.5, .71), .34, lamp, alpha: .5);
  // Wings fold out from the back, where the head meets the lantern.
  for (final double k in sides) {
    p.part(
      turn(oval(.5 + k * .23, .62, .14, .075), pt(.5 + k * .23, .62), k * .3),
      wing,
      depth: .4,
      shine: .6,
    );
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .06, .36),
        pt(.5 + k * .1, .25),
        pt(.5 + k * .17, .21),
      ]),
      .014,
      body,
    );
    p.part(circle(.5 + k * .17, .21, .026), lamp, depth: 0);
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .14, .79),
        pt(.5 + k * .19, .85),
        pt(.5 + k * .17, .895),
      ]),
      .018,
      body,
    );
  }
  final Path tail = oval(.5, .705, .2, .175);
  p.part(
    tail,
    lamp,
    shine: 1,
    marks: () {
      p.line(
        curve(<Offset>[pt(.32, .73), pt(.5, .77), pt(.68, .73)]),
        width: .012,
        color: const Color(0xFFF2D24E),
      );
      p.line(
        curve(<Offset>[pt(.36, .81), pt(.5, .85), pt(.64, .81)]),
        width: .012,
        color: const Color(0xFFF2D24E),
      );
    },
  );
  // The head sits down into the lantern rather than perched on top of it.
  final Path head = oval(.5, .50, .2, .165);
  p.part(
    head,
    body,
    shine: .8,
    marks: () => p.flat(oval(.5, .35, .2, .09), cap),
  );
  p.eyes(
    .5,
    .50,
    .08,
    .045,
    rim: const Color(0xFFFFFBF0),
    iris: const Color(0xFF7A9AFF),
  );
  p.cheeks(.5, .565, .14, .032, alpha: .8);
  p.smile(pt(.5, .565), .022, color: const Color(0xFFFFC2CF));

  p.head(const Rect.fromLTRB(.30, .335, .70, .665));
  p.torso(const Rect.fromLTRB(.30, .53, .70, .88));
  p.collar(pt(.5, .66), .15);
}

// -------------------------------------------------------------------- 2 moth

void _moth(Pen p) {
  const Color wing = Color(0xFFCDB9E8);
  const Color wingDark = Color(0xFF9C84C4);
  const Color fluffColor = Color(0xFFFFF6E8);
  const Color body = Color(0xFFF2E4CF);
  p.ink = const Color(0xFF3A2A50);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path upper = blob(<Offset>[
      q(.06, .44),
      q(.20, .24),
      q(.38, .18),
      q(.45, .26),
      q(.40, .44),
      q(.22, .56),
    ]);
    final Path lower = blob(<Offset>[
      q(.06, .56),
      q(.22, .55),
      q(.34, .62),
      q(.30, .76),
      q(.16, .78),
      q(.08, .70),
    ]);
    p.part(
      lower,
      wing,
      shine: .4,
      marks: () => p.flat(circle(.5 + k * .22, .67, .035), wingDark),
    );
    p.part(
      upper,
      wing,
      shine: .7,
      marks: () {
        p.canvas.drawPath(upper, strokeOf(wingDark, .035));
        p.flat(
          circle(.5 + k * .27, .36, .055),
          Kit.white.withValues(alpha: .9),
        );
        p.flat(circle(.5 + k * .27, .36, .033), wingDark);
        p.flat(circle(.5 + k * .262, .35, .01), Kit.white);
      },
    );
  }
  // Feathery antennae.
  for (final double k in sides) {
    final Path feather = leaf(
      pt(.5 + k * .05, .30),
      pt(.5 + k * .19, .10),
      .07,
      bend: k * -.01,
    );
    p.part(
      feather,
      body,
      depth: .4,
      marks: () {
        for (double t = .2; t < .95; t += .14) {
          final Offset c = pt(.5 + k * (.05 + .14 * t), .30 - .2 * t);
          p.line(
            Path()
              ..moveTo(c.dx - .03, c.dy - .02)
              ..lineTo(c.dx + .03, c.dy + .02),
            width: .007,
            color: darker(body, .2),
          );
        }
      },
    );
  }
  p.part(
    oval(.5, .67, .1, .17),
    body,
    shine: .5,
    marks: () {
      for (final double y in <double>[.68, .74, .80]) {
        p.line(
          curve(<Offset>[pt(.41, y), pt(.5, y + .015), pt(.59, y)]),
          width: .008,
          color: darker(body, .12),
        );
      }
    },
  );
  p.part(fluff(.5, .53, .14, .075, 9, depth: .2), fluffColor, shine: .5);
  p.part(oval(.5, .41, .14, .12), fluffColor, shine: 1);
  p.eyes(.5, .41, .065, .045, iris: const Color(0xFF8A6AC0));
  p.cheeks(.5, .46, .1, .028);
  p.smile(pt(.5, .465), .016);

  p.head(const Rect.fromLTRB(.36, .29, .64, .53), hatLift: .02);
  p.torso(const Rect.fromLTRB(.40, .50, .60, .84));
  p.collar(pt(.5, .535), .11);
}

// --------------------------------------------------------------- 3 glowworm

void _glowworm(Pen p) {
  const Color body = Color(0xFF8FE3C2);
  const Color ring = Color(0xFFB9F2DA);
  const Color lamp = Color(0xFFFFF27A);
  p.ink = const Color(0xFF1E4A40);

  p.glow(pt(.13, .80), .17, lamp, alpha: .7);
  final List<Offset> segs = <Offset>[
    pt(.15, .80),
    pt(.25, .815),
    pt(.36, .81),
    pt(.47, .79),
    pt(.57, .74),
  ];
  for (int i = 0; i < segs.length; i++) {
    final Offset c = segs[i];
    final double r = .075 + i * .006;
    p.part(
      circle(c.dx, c.dy, r),
      i == 0 ? lamp : body,
      shine: .5,
      marks: () {
        if (i > 0) p.flat(circle(c.dx, c.dy - r * .55, r * .35), ring);
        if (i > 0) {
          p.flat(
            circle(c.dx, c.dy + r * .45, r * .18),
            lamp.withValues(alpha: .9),
          );
        }
      },
    );
    p.tube(
      Path()
        ..moveTo(c.dx - .015, c.dy + r * .85)
        ..lineTo(c.dx - .02, .893),
      .016,
      darker(body, .1),
    );
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.70 + k * .05, .42),
        pt(.72 + k * .07, .32),
        pt(.74 + k * .1, .28),
      ]),
      .014,
      body,
    );
    p.part(circle(.74 + k * .1, .28, .022), lamp, depth: 0);
  }
  p.tube(
    Path()
      ..moveTo(.62, .75)
      ..lineTo(.615, .893),
    .016,
    darker(body, .1),
  );
  // The head grows out of a front segment, so it is joined on, not perched.
  p.part(
    union(circle(.70, .55, .16), circle(.635, .67, .105)),
    body,
    shine: 1,
    marks: () => p.flat(circle(.63, .73, .02), lamp.withValues(alpha: .9)),
  );
  p.eyes(.70, .54, .065, .045, iris: const Color(0xFF3A9A80));
  p.cheeks(.70, .6, .1, .032);
  p.smile(pt(.70, .605), .022);
  p.twinkle(pt(.08, .64), .022, lamp, outline: false);

  p.head(const Rect.fromLTRB(.54, .39, .86, .71), hatLift: .02);
  p.torso(const Rect.fromLTRB(.07, .70, .65, .89));
  p.collar(pt(.66, .70), .11);
}

// ---------------------------------------------------------------- 4 cricket

void _cricket(Pen p) {
  const Color green = Color(0xFF8ACB5C);
  const Color dark = Color(0xFF5E9A3E);
  const Color belly = Color(0xFFD9F0A8);
  p.ink = const Color(0xFF223A14);

  // Long antennae sweeping back.
  for (final double d in <double>[0, .04]) {
    p.tube(
      curve(<Offset>[
        pt(.66 + d, .34),
        pt(.56 + d, .16),
        pt(.36 + d, .08),
        pt(.18 + d, .10),
      ]),
      .01,
      dark,
    );
  }
  for (final double x in <double>[.55, .66]) {
    p.tube(
      curve(<Offset>[pt(x, .68), pt(x + .02, .80), pt(x + .04, .885)]),
      .018,
      dark,
    );
  }
  final Path body = union(
    turn(oval(.44, .65, .25, .13), pt(.44, .65), -.12),
    circle(.70, .47, .155),
  );
  p.part(
    body,
    green,
    shine: .8,
    marks: () =>
        p.flat(turn(oval(.46, .74, .2, .06), pt(.44, .65), -.12), belly),
  );
  final Path wings = blob(
    <Offset>[
      pt(.20, .66),
      pt(.30, .56),
      pt(.50, .53),
      pt(.60, .58),
      pt(.44, .64),
      pt(.28, .70),
    ],
    sharp: <int>{0},
  );
  p.part(
    wings,
    dark,
    marks: () {
      for (final double x in <double>[.32, .40, .48]) {
        p.line(
          Path()
            ..moveTo(x, .565)
            ..lineTo(x - .06, .655),
          width: .008,
          color: darker(dark, .15),
        );
      }
    },
  );
  // The big jumping leg: thigh up to the knee, shin back down.
  p.tube(
    curve(<Offset>[pt(.19, .46), pt(.22, .68), pt(.30, .885)]),
    .022,
    green,
  );
  p.part(
    leaf(pt(.40, .70), pt(.19, .45), .1, bend: -.01),
    green,
    shine: .5,
    marks: () {
      for (double t = .3; t < .9; t += .16) {
        final Offset c = Offset.lerp(pt(.40, .70), pt(.19, .45), t)!;
        p.line(
          Path()
            ..moveTo(c.dx - .025, c.dy + .02)
            ..lineTo(c.dx + .02, c.dy - .025),
          width: .007,
          color: dark,
        );
      }
    },
  );
  p.tube(
    Path()
      ..moveTo(.30, .885)
      ..lineTo(.36, .89),
    .018,
    green,
  );
  p.eyes(.71, .46, .068, .046, iris: const Color(0xFF5A8A2A));
  p.cheeks(.71, .52, .11, .032);
  p.smile(pt(.71, .525), .022);

  p.head(const Rect.fromLTRB(.545, .315, .855, .625), hatLift: .02);
  p.torso(const Rect.fromLTRB(.19, .52, .69, .78));
  p.collar(pt(.62, .60), .1);
}

// -------------------------------------------------------------------- 5 bat

void _bat(Pen p) {
  const Color fur = Color(0xFFA394C6);
  const Color wing = Color(0xFF7E6BAA);
  const Color belly = Color(0xFFE2DAF2);
  const Color inner = Color(0xFFFFBFD2);
  p.ink = const Color(0xFF2A2045);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.10, .50).dx, q(.10, .50).dy)
      ..quadraticBezierTo(
        q(.28, .34).dx,
        q(.28, .34).dy,
        q(.44, .36).dx,
        q(.44, .36).dy,
      )
      ..quadraticBezierTo(
        q(.46, .52).dx,
        q(.46, .52).dy,
        q(.43, .64).dx,
        q(.43, .64).dy,
      )
      ..quadraticBezierTo(
        q(.37, .58).dx,
        q(.37, .58).dy,
        q(.32, .64).dx,
        q(.32, .64).dy,
      )
      ..quadraticBezierTo(
        q(.26, .58).dx,
        q(.26, .58).dy,
        q(.20, .66).dx,
        q(.20, .66).dy,
      )
      ..quadraticBezierTo(
        q(.16, .58).dx,
        q(.16, .58).dy,
        q(.10, .64).dx,
        q(.10, .64).dy,
      )
      ..close();
    p.part(
      w,
      wing,
      shine: .4,
      marks: () {
        for (final Offset f in <Offset>[q(.32, .64), q(.20, .66)]) {
          p.line(
            Path()
              ..moveTo(q(.44, .37).dx, q(.44, .37).dy)
              ..lineTo(f.dx, f.dy),
            width: .008,
            color: darker(wing, .15),
          );
        }
      },
    );
  }
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .12, .32),
      pt(.5 + k * .2, .12),
      .13,
      fur,
      inner,
      round: .03,
    );
  }
  for (final double k in sides) {
    p.part(oval(.5 + k * .06, .87, .035, .028), darker(fur, .08), depth: .4);
  }
  p.part(
    oval(.5, .68, .14, .18),
    fur,
    marks: () => p.flat(oval(.5, .72, .09, .12), belly),
  );
  p.part(oval(.5, .44, .19, .16), fur, shine: 1);
  p.eyes(.5, .44, .08, .046);
  p.cheeks(.5, .5, .13, .032);
  p.part(oval(.5, .49, .022, .015), inner, depth: 0, line: p.lw * .5);
  p.catMouth(pt(.5, .515), .018);
  p.fang(pt(.48, .522), .009);
  p.fang(pt(.52, .522), .009);

  p.head(const Rect.fromLTRB(.31, .28, .69, .60), hatLift: .03);
  p.torso(const Rect.fromLTRB(.36, .50, .64, .86));
  p.collar(pt(.5, .595), .12);
}

// --------------------------------------------------------------- 6 dormouse

void _dormouse(Pen p) {
  const Color fur = Color(0xFFE6A85E);
  const Color belly = Color(0xFFFFEBCC);
  const Color inner = Color(0xFFFFB9A8);
  p.ink = const Color(0xFF4A2A10);

  // Curled up asleep, tail wrapped round the front.
  p.part(oval(.55, .67, .3, .22), fur, shine: .7);
  for (final double k in sides) {
    roundEar(p, pt(.36 + k * .085, .47 - (k + 1) * .01), .055, fur, inner);
  }
  p.part(
    oval(.40, .62, .17, .145),
    fur,
    shine: 1,
    marks: () => p.flat(oval(.40, .69, .1, .06), belly),
  );
  p.eye(pt(.34, .62), .04, look: Eye.shut);
  p.eye(pt(.46, .62), .04, look: Eye.shut);
  p.cheeks(.40, .665, .105, .03);
  p.nose(pt(.40, .665), .016, color: Kit.nosePink);
  final Path tail = puffs(
    <Offset>[
      pt(.84, .66),
      pt(.80, .82),
      pt(.60, .87),
      pt(.40, .84),
      pt(.22, .80),
    ],
    <double>[.06, .075, .075, .07, .06],
  );
  p.part(
    tail,
    lighter(fur, .04),
    shine: .5,
    marks: () => p.flat(circle(.20, .80, .06), belly),
  );
  for (final double k in sides) {
    p.part(oval(.40 + k * .045, .745, .028, .022), inner, depth: .3);
  }
  // Two floating z's.
  for (final List<double> z in <List<double>>[
    <double>[.72, .40, .045],
    <double>[.83, .30, .032],
  ]) {
    final double x = z[0], y = z[1], s = z[2];
    p.tube(
      Path()
        ..moveTo(x - s, y - s)
        ..lineTo(x + s, y - s)
        ..lineTo(x - s, y + s)
        ..lineTo(x + s, y + s),
      .012,
      const Color(0xFFDCD6FF),
      cap: StrokeCap.round,
    );
  }

  p.head(const Rect.fromLTRB(.23, .475, .57, .765), hatLift: .03);
  p.torso(const Rect.fromLTRB(.25, .45, .85, .89));
  p.collar(pt(.43, .76), .1);
}

// ------------------------------------------------------------------ 7 possum

void _possum(Pen p) {
  const Color fur = Color(0xFFBDBACB);
  const Color face = Color(0xFFFBF8F3);
  const Color dark = Color(0xFF3E3A4C);
  const Color pink = Color(0xFFFFB3C2);
  p.ink = const Color(0xFF2A2735);

  p.tube(
    curve(<Offset>[
      pt(.62, .84),
      pt(.80, .84),
      pt(.86, .72),
      pt(.80, .64),
      pt(.74, .68),
      pt(.77, .74),
    ]),
    .026,
    pink,
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .19, .27), .075, dark, pink, innerScale: .55);
  }
  sitBody(
    p,
    fur: fur,
    belly: lighter(fur, .1),
    feet: dark,
    paws: dark,
    rx: .17,
    ry: .16,
  );
  final Path head = sym(<Offset>[
    pt(.5, .25),
    pt(.64, .27),
    pt(.72, .36),
    pt(.71, .47),
    pt(.61, .56),
    pt(.53, .625),
    pt(.5, .635),
  ]);
  p.part(
    head,
    face,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(oval(.5 + k * .085, .42, .055, .05), const Color(0xFFD9D4E2));
      }
      p.flat(oval(.5, .26, .06, .05), const Color(0xFFD9D4E2));
    },
  );
  p.eyes(.5, .42, .085, .042);
  p.cheeks(.5, .49, .13, .03);
  p.part(oval(.5, .61, .03, .022), pink, depth: .4, line: p.lw * .6);
  whiskers(p, pt(.5, .58), .05, .11);
  p.smile(pt(.5, .555), .016);

  p.head(const Rect.fromLTRB(.28, .25, .72, .635), hatLift: .03);
  p.collar(pt(.5, .62), .13);
}

// ------------------------------------------------------------------ 8 owlet

void _owlet(Pen p) {
  const Color fur = Color(0xFFA88B70);
  const Color disc = Color(0xFFF6E7CF);
  const Color belly = Color(0xFFE9D7BB);
  const Color beak = Color(0xFFF2A646);
  p.ink = const Color(0xFF3A2818);

  birdFoot(p, .43, beak);
  birdFoot(p, .57, beak);
  final Path body = blob(<Offset>[
    pt(.5, .25),
    pt(.66, .27),
    pt(.75, .40),
    pt(.77, .58),
    pt(.72, .76),
    pt(.60, .86),
    pt(.5, .875),
    pt(.40, .86),
    pt(.28, .76),
    pt(.23, .58),
    pt(.25, .40),
    pt(.34, .27),
  ]);
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.5 + k * .19, .30), pt(.5 + k * .25, .17), .08),
        pt(.5 + k * .19, .30),
        0,
      ),
      fur,
    );
  }
  p.part(
    body,
    fur,
    shine: .8,
    marks: () {
      p.flat(oval(.5, .72, .17, .16), belly);
      for (final Offset c in <Offset>[
        pt(.44, .68),
        pt(.56, .68),
        pt(.5, .74),
        pt(.42, .79),
        pt(.58, .79),
      ]) {
        p.line(
          Path()
            ..moveTo(c.dx - .02, c.dy)
            ..quadraticBezierTo(c.dx, c.dy + .02, c.dx + .02, c.dy),
          width: .01,
          color: darker(belly, .2),
        );
      }
    },
  );
  for (final double k in sides) {
    p.part(
      blob(<Offset>[
        pt(.5 + k * .22, .50),
        pt(.5 + k * .29, .60),
        pt(.5 + k * .27, .76),
        pt(.5 + k * .20, .72),
      ]),
      darker(fur, .06),
    );
  }
  p.part(
    union(circle(.43, .44, .1), circle(.57, .44, .1)),
    disc,
    depth: .4,
    line: 0,
  );
  p.eyes(.5, .44, .07, .055, iris: const Color(0xFFF2B13C));
  p.part(
    roundPoly(<Offset>[pt(.475, .51), pt(.525, .51), pt(.5, .555)], .01),
    beak,
    depth: .4,
    line: p.lw * .6,
  );
  p.cheeks(.5, .52, .14, .03);

  p.head(const Rect.fromLTRB(.25, .25, .75, .60), hatLift: .03);
  p.torso(const Rect.fromLTRB(.23, .40, .77, .87));
  p.collar(pt(.5, .59), .16);
}

// ------------------------------------------------------------------ 9 skunk

void _skunk(Pen p) {
  const Color fur = Color(0xFF55516B);
  const Color white = Color(0xFFFAF8FF);
  const Color pink = Color(0xFFFFB3C2);
  p.ink = const Color(0xFF1C1A26);

  final List<Offset> spine = <Offset>[
    pt(.60, .84),
    pt(.80, .80),
    pt(.88, .62),
    pt(.84, .40),
    pt(.72, .28),
    pt(.62, .30),
  ];
  final Path tail = puffs(spine, <double>[.07, .1, .11, .1, .085, .06]);
  p.part(
    tail,
    fur,
    shine: .4,
    marks: () {
      p.line(
        curve(
          spine.sublist(0, 5).map((Offset o) => o.translate(-.004, 0)).toList(),
        ),
        width: .06,
        color: white,
      );
    },
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .18, .29), .06, fur, pink);
  }
  sitBody(
    p,
    fur: fur,
    belly: lighter(fur, .06),
    feet: darker(fur, .06),
    paws: darker(fur, .06),
    rx: .17,
    ry: .16,
  );
  p.part(
    oval(.5, .43, .22, .185),
    fur,
    shine: .9,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.5, .24),
          pt(.535, .30),
          pt(.52, .45),
          pt(.5, .48),
          pt(.48, .45),
          pt(.465, .30),
        ]),
        white,
      );
      p.flat(oval(.5, .53, .09, .065), lighter(fur, .1));
    },
  );
  p.eyes(.5, .44, .09, .045, rim: white);
  p.cheeks(.5, .51, .14, .03, alpha: .8);
  p.nose(pt(.5, .5), .022, color: pink);
  p.catMouth(pt(.5, .535), .018, color: white);

  p.head(const Rect.fromLTRB(.28, .245, .72, .615), hatLift: .0);
  p.collar(pt(.5, .61), .13);
}

// ------------------------------------------------------------ 10 fennec fox

void _fennec(Pen p) {
  const Color fur = Color(0xFFF1CF9B);
  const Color cream = Color(0xFFFFF7EA);
  const Color inner = Color(0xFFFFC7B8);
  p.ink = const Color(0xFF55381A);

  final Path tail = puffs(
    <Offset>[pt(.60, .86), pt(.78, .84), pt(.86, .72), pt(.85, .60)],
    <double>[.05, .065, .07, .06],
  );
  p.part(
    tail,
    fur,
    marks: () => p.flat(circle(.85, .59, .055), const Color(0xFF6A4A2A)),
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .13, .33),
      pt(.5 + k * .36, .04),
      .2,
      fur,
      inner,
      round: .05,
    );
  }
  sitBody(p, fur: fur, belly: cream, rx: .155, ry: .15);
  final Path head = sym(<Offset>[
    pt(.5, .29),
    pt(.62, .30),
    pt(.69, .38),
    pt(.70, .47),
    pt(.62, .55),
    pt(.5, .60),
  ]);
  p.part(
    head,
    fur,
    shine: 1,
    marks: () => p.flat(
      sym(<Offset>[
        pt(.5, .47),
        pt(.58, .46),
        pt(.70, .47),
        pt(.62, .555),
        pt(.5, .605),
      ]),
      cream,
    ),
  );
  p.eyes(.5, .44, .08, .047);
  p.cheeks(.5, .5, .13, .03);
  p.nose(pt(.5, .505), .02);
  p.catMouth(pt(.5, .535), .017);

  p.head(const Rect.fromLTRB(.30, .29, .70, .60), hatLift: .03);
  p.collar(pt(.5, .60), .12);
}

// ---------------------------------------------------------------- 11 tarsier

void _tarsier(Pen p) {
  const Color fur = Color(0xFFC2A68A);
  const Color pale = Color(0xFFEBDCC8);
  const Color branch = Color(0xFF8A6244);
  p.ink = const Color(0xFF3A2818);

  p.tube(
    curve(<Offset>[pt(.62, .80), pt(.74, .86), pt(.82, .80), pt(.88, .74)]),
    .014,
    fur,
  );
  p.part(tear(.89, .72, .022, angle: .9, length: 2.2), fur);
  p.tube(curve(<Offset>[pt(.06, .82), pt(.5, .80), pt(.94, .83)]), .05, branch);
  p.part(leaf(pt(.14, .815), pt(.07, .72), .05), Kit.leafGreen, depth: .5);
  p.part(
    oval(.5, .68, .14, .13),
    fur,
    marks: () => p.flat(oval(.5, .71, .09, .09), pale),
  );
  // Long thin fingers gripping the branch.
  for (final double k in sides) {
    for (final double d in <double>[-.025, 0, .025]) {
      p.tube(
        curve(<Offset>[
          pt(.5 + k * .12 + d, .76),
          pt(.5 + k * .12 + d * 1.4, .81),
          pt(.5 + k * .12 + d * 1.6, .835),
        ]),
        .013,
        fur,
      );
    }
    p.part(oval(.5 + k * .12, .77, .028, .03), fur, depth: .4);
  }
  for (final double k in sides) {
    roundEar(
      p,
      pt(.5 + k * .2, .27),
      .065,
      fur,
      const Color(0xFFF2C2B0),
      innerScale: .55,
    );
  }
  p.part(oval(.5, .42, .23, .19), fur, shine: 1);
  // Those famous eyes, each nearly as big as the brain behind it.
  p.eyes(.5, .41, .105, .085, iris: const Color(0xFFD08A30), width: .9);
  p.cheeks(.5, .51, .17, .03);
  p.nose(pt(.5, .5), .014);
  p.smile(pt(.5, .53), .018);

  p.head(const Rect.fromLTRB(.27, .23, .73, .61), hatLift: .02);
  p.torso(const Rect.fromLTRB(.36, .55, .64, .81));
  p.collar(pt(.5, .60), .12);
}

// ----------------------------------------------------------- 12 sugar glider

void _glider(Pen p) {
  const Color fur = Color(0xFFAEB0C6);
  const Color belly = Color(0xFFF5F3F9);
  const Color stripe = Color(0xFF4E4A64);
  const Color pink = Color(0xFFFFB9C9);
  p.ink = const Color(0xFF2C2A3C);

  final Path tail = puffs(
    <Offset>[pt(.5, .76), pt(.56, .84), pt(.66, .88)],
    <double>[.035, .045, .045],
  );
  p.part(tail, stripe);
  // The gliding membrane, stretched wrist to ankle.
  final Path sail = blob(
    <Offset>[
      pt(.5, .46),
      pt(.70, .44),
      pt(.90, .44),
      pt(.86, .56),
      pt(.84, .70),
      pt(.76, .80),
      pt(.62, .76),
      pt(.5, .80),
      pt(.38, .76),
      pt(.24, .80),
      pt(.16, .70),
      pt(.14, .56),
      pt(.10, .44),
      pt(.30, .44),
    ],
    sharp: <int>{2, 5, 9, 12},
  );
  p.part(
    sail,
    fur,
    shine: .4,
    marks: () {
      p.flat(oval(.5, .64, .17, .16), belly);
      p.canvas.drawPath(
        blob(<Offset>[pt(.22, .52), pt(.20, .70), pt(.30, .76)]),
        strokeOf(darker(fur, .08), .01),
      );
      p.canvas.drawPath(
        blob(<Offset>[pt(.78, .52), pt(.80, .70), pt(.70, .76)]),
        strokeOf(darker(fur, .08), .01),
      );
    },
  );
  for (final Offset c in <Offset>[
    pt(.10, .44),
    pt(.90, .44),
    pt(.24, .80),
    pt(.76, .80),
  ]) {
    p.part(circle(c.dx, c.dy, .03), pink, depth: .4);
  }
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .15, .24), .07, fur, pink, innerScale: .58);
  }
  p.part(
    oval(.5, .37, .17, .15),
    fur,
    shine: 1,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.5, .21),
          pt(.525, .3),
          pt(.512, .42),
          pt(.5, .44),
          pt(.488, .42),
          pt(.475, .3),
        ]),
        stripe,
      );
      for (final double k in sides) {
        p.flat(oval(.5 + k * .075, .37, .052, .055), stripe);
      }
      p.flat(oval(.5, .46, .08, .05), belly);
    },
  );
  p.eyes(.5, .37, .075, .045, rim: belly);
  p.cheeks(.5, .43, .12, .028);
  p.nose(pt(.5, .445), .016, color: pink);
  p.smile(pt(.5, .47), .015);

  p.head(const Rect.fromLTRB(.33, .22, .67, .52), hatLift: .03);
  p.torso(const Rect.fromLTRB(.30, .46, .70, .80));
  p.collar(pt(.5, .515), .11);
}

// ------------------------------------------------------------- 13 slow loris

void _loris(Pen p) {
  const Color fur = Color(0xFFCBA57F);
  const Color pale = Color(0xFFF4E6D2);
  const Color dark = Color(0xFF6E4A30);
  const Color flower = Color(0xFFFF8FB8);
  p.ink = const Color(0xFF3A2414);

  sitBody(
    p,
    fur: fur,
    belly: pale,
    feet: darker(fur, .06),
    showPaws: false,
    rx: .175,
    ry: .165,
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .19, .335), .05, fur, darker(fur, .12));
  }
  // The head settles down onto the shoulders.
  const double hy = .455;
  p.part(
    fluff(.5, hy, .22, .17, 12, depth: .05),
    fur,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(oval(.5 + k * .085, hy, .07, .075), dark);
      }
      p.flat(
        blob(<Offset>[
          pt(.5, hy - .15),
          pt(.53, hy - .05),
          pt(.525, hy + .07),
          pt(.5, hy + .1),
          pt(.475, hy + .07),
          pt(.47, hy - .05),
        ]),
        pale,
      );
      p.flat(oval(.5, hy + .09, .06, .04), pale);
    },
  );
  p.eyes(.5, hy, .085, .052, rim: pale, iris: const Color(0xFFC07A30));
  p.cheeks(.5, hy + .08, .16, .028);
  p.nose(pt(.5, hy + .07), .015);
  p.smile(pt(.5, hy + .1), .016);
  // A hibiscus held to the chest in both hands.
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .16, .63),
        pt(.5 + k * .17, .70),
        pt(.5 + k * .1, .735),
      ]),
      .055,
      fur,
    );
  }
  for (int i = 0; i < 5; i++) {
    final double a = -math.pi / 2 + i * math.pi * 2 / 5;
    p.part(
      circle(.5 + math.cos(a) * .04, .715 + math.sin(a) * .04, .035),
      flower,
      depth: .4,
      line: p.lw * .6,
    );
  }
  p.part(circle(.5, .715, .02), Kit.gold, depth: 0, line: p.lw * .5);
  for (final double k in sides) {
    p.part(oval(.5 + k * .075, .735, .032, .03), fur, depth: .4);
  }

  p.head(const Rect.fromLTRB(.28, .285, .72, .625), hatLift: .0);
  p.collar(pt(.5, .62), .13);
}

// ---------------------------------------------------------------- 14 aye-aye

void _ayeAye(Pen p) {
  const Color fur = Color(0xFF6E6276);
  const Color face = Color(0xFFD8CCBE);
  const Color ear = Color(0xFF5A4E60);
  const Color inner = Color(0xFFE8B8C4);
  p.ink = const Color(0xFF1E1824);

  final Path tail = puffs(
    <Offset>[pt(.6, .84), pt(.8, .80), pt(.88, .62), pt(.82, .46)],
    <double>[.06, .08, .085, .07],
  );
  p.part(tail, fur, shine: .3);
  for (final double k in sides) {
    final Path e = turn(
      oval(.5 + k * .25, .22, .13, .15),
      pt(.5 + k * .25, .22),
      k * .4,
    );
    p.part(
      e,
      ear,
      shine: .4,
      marks: () => p.flat(
        turn(
          oval(.5 + k * .25, .23, .085, .105),
          pt(.5 + k * .25, .22),
          k * .4,
        ),
        inner,
      ),
    );
  }
  sitBody(
    p,
    fur: fur,
    belly: lighter(fur, .1),
    feet: darker(fur, .05),
    paws: darker(fur, .05),
    rx: .17,
    ry: .16,
  );
  p.part(
    fluff(.5, .42, .2, .18, 11, depth: .07),
    fur,
    shine: .8,
    marks: () {
      p.flat(oval(.5, .47, .15, .13), face);
    },
  );
  // The long, thin tapping finger, raised beside the face.
  p.tube(
    curve(<Offset>[pt(.66, .66), pt(.70, .55), pt(.71, .45), pt(.70, .40)]),
    .012,
    face,
  );
  p.part(oval(.665, .66, .032, .03), fur, depth: .4);
  p.eyes(
    .5,
    .44,
    .085,
    .052,
    iris: const Color(0xFFFFB52E),
    rim: const Color(0xFFFFF4DA),
  );
  p.cheeks(.5, .51, .13, .028);
  p.nose(pt(.5, .5), .018, color: Kit.nosePink);
  p.smile(pt(.5, .53), .016);

  p.head(const Rect.fromLTRB(.30, .24, .70, .60), hatLift: .03);
  p.collar(pt(.5, .60), .12);
}

// ----------------------------------------------------------------- 15 badger

void _badger(Pen p) {
  const Color fur = Color(0xFF9F9CAD);
  const Color white = Color(0xFFFBFAFD);
  const Color black = Color(0xFF34313E);
  p.ink = const Color(0xFF1E1C26);

  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .2, .30), .055, white, black, innerScale: .55);
  }
  sitBody(
    p,
    fur: fur,
    belly: black,
    feet: black,
    paws: black,
    rx: .21,
    ry: .16,
    footW: .07,
    footGap: .1,
  );
  final Path head = sym(<Offset>[
    pt(.5, .25),
    pt(.66, .28),
    pt(.74, .38),
    pt(.72, .50),
    pt(.60, .59),
    pt(.5, .62),
  ]);
  p.part(
    head,
    white,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(
          blob(<Offset>[
            pt(.5 + k * .045, .26),
            pt(.5 + k * .1, .27),
            pt(.5 + k * .13, .40),
            pt(.5 + k * .1, .52),
            pt(.5 + k * .06, .50),
            pt(.5 + k * .055, .38),
          ]),
          black,
        );
      }
    },
  );
  p.eyes(.5, .43, .085, .04, rim: white);
  p.cheeks(.5, .51, .15, .03);
  p.nose(pt(.5, .54), .024);
  p.catMouth(pt(.5, .575), .018);

  p.head(const Rect.fromLTRB(.26, .25, .74, .62), hatLift: .0);
  p.collar(pt(.5, .61), .15);
}

// ------------------------------------------------------------- 16 armadillo

void _armadillo(Pen p) {
  const Color shell = Color(0xFFD8B49C);
  const Color band = Color(0xFFC09478);
  const Color skin = Color(0xFFF0D2C2);
  const Color inner = Color(0xFFFFB5BE);
  p.ink = const Color(0xFF4A2E22);

  p.part(
    blob(
      <Offset>[pt(.18, .74), pt(.06, .84), pt(.08, .86), pt(.22, .80)],
      sharp: <int>{1},
    ),
    shell,
  );
  for (final double x in <double>[.30, .62]) {
    stubLeg(p, x, .72, .085, darker(skin, .06));
  }
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.71 + k * .045, .45),
      pt(.71 + k * .08, .30),
      .07,
      skin,
      inner,
      round: .025,
    );
  }
  final Path head = blob(<Offset>[
    pt(.64, .48),
    pt(.74, .44),
    pt(.82, .50),
    pt(.92, .62),
    pt(.90, .67),
    pt(.78, .68),
    pt(.64, .64),
  ]);
  p.part(
    head,
    skin,
    shine: .8,
    marks: () => p.flat(
      blob(<Offset>[
        pt(.66, .47),
        pt(.74, .44),
        pt(.80, .48),
        pt(.74, .53),
        pt(.66, .54),
      ]),
      shell,
    ),
  );
  p.part(circle(.92, .645, .018), Kit.nosePink, depth: 0, line: p.lw * .5);
  p.eye(pt(.75, .555), .036);
  p.blush(pt(.79, .61), .025);
  p.smile(pt(.84, .655), .016);
  for (final double x in <double>[.24, .58]) {
    stubLeg(p, x, .74, .09, skin);
  }
  final Path dome = blob(
    <Offset>[
      pt(.14, .80),
      pt(.18, .58),
      pt(.32, .44),
      pt(.48, .42),
      pt(.62, .48),
      pt(.70, .62),
      pt(.72, .80),
    ],
    sharp: <int>{0, 6},
  );
  p.part(
    dome,
    shell,
    shine: 1,
    marks: () {
      for (final double x in <double>[.28, .36, .44, .52, .60]) {
        p.line(
          curve(<Offset>[pt(x - .02, .44), pt(x + .01, .62), pt(x, .80)]),
          width: .02,
          color: band,
        );
      }
      for (final double y in <double>[.56, .68]) {
        p.line(
          curve(<Offset>[pt(.16, y + .02), pt(.44, y - .01), pt(.72, y + .02)]),
          width: .008,
          color: band,
        );
      }
    },
  );

  p.head(const Rect.fromLTRB(.64, .42, .92, .68), hatLift: .05, hatX: .74);
  p.torso(const Rect.fromLTRB(.14, .42, .72, .80));
  p.collar(pt(.66, .65), .07);
}

// -------------------------------------------------------------- 17 porcupine

void _porcupine(Pen p) {
  const Color fur = Color(0xFF8A6C56);
  const Color face = Color(0xFFDCC2A6);
  const Color quill = Color(0xFFF6EBDA);
  const Color quillBase = Color(0xFF5E4636);
  p.ink = const Color(0xFF2E2016);

  // Long banded quills fanned up behind.
  for (int i = 0; i < 13; i++) {
    final double a = math.pi * (1.05 + i * .075);
    final Offset root = pt(.5 + math.cos(a) * .12, .58 + math.sin(a) * .1);
    final Offset tip = pt(.5 + math.cos(a) * .40, .58 + math.sin(a) * .38);
    p.part(
      leaf(root, tip, .055),
      quill,
      depth: .3,
      line: p.lw * .7,
      marks: () {
        p.flat(leaf(root, Offset.lerp(root, tip, .55)!, .06), quillBase);
      },
    );
  }
  sitBody(
    p,
    fur: fur,
    belly: face,
    feet: darker(fur, .08),
    paws: darker(fur, .08),
    rx: .18,
    ry: .16,
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .16, .38), .04, face, darker(face, .15));
  }
  p.part(oval(.5, .50, .18, .15), face, shine: 1);
  p.eyes(.5, .48, .08, .042);
  p.cheeks(.5, .54, .13, .03);
  p.part(
    oval(.5, .545, .04, .03),
    const Color(0xFF3A2A22),
    shine: 1,
    depth: .4,
  );
  p.catMouth(pt(.5, .585), .016);

  p.head(const Rect.fromLTRB(.32, .35, .68, .65), hatLift: .1);
  p.collar(pt(.5, .645), .13);
}

// --------------------------------------------------------------- 18 barn owl

void _barnOwl(Pen p) {
  const Color back = Color(0xFFE6BD84);
  const Color wing = Color(0xFFC9A378);
  const Color face = Color(0xFFFFFCF6);
  const Color rim = Color(0xFFE9C595);
  const Color beak = Color(0xFFF3D2C4);
  p.ink = const Color(0xFF3E2814);

  birdFoot(p, .44, const Color(0xFFD9B8A8));
  birdFoot(p, .56, const Color(0xFFD9B8A8));
  final Path body = blob(<Offset>[
    pt(.5, .22),
    pt(.66, .25),
    pt(.73, .40),
    pt(.74, .60),
    pt(.68, .78),
    pt(.58, .87),
    pt(.5, .88),
    pt(.42, .87),
    pt(.32, .78),
    pt(.26, .60),
    pt(.27, .40),
    pt(.34, .25),
  ]);
  p.part(
    body,
    back,
    shine: .8,
    marks: () {
      p.flat(oval(.5, .70, .16, .17), face);
      for (final Offset c in <Offset>[
        pt(.45, .64),
        pt(.55, .66),
        pt(.5, .72),
        pt(.43, .76),
        pt(.57, .77),
        pt(.5, .82),
      ]) {
        p.flat(circle(c.dx, c.dy, .007), const Color(0xFFB08860));
      }
    },
  );
  for (final double k in sides) {
    final Path w = blob(
      <Offset>[
        pt(.5 + k * .2, .46),
        pt(.5 + k * .27, .56),
        pt(.5 + k * .27, .76),
        pt(.5 + k * .19, .84),
        pt(.5 + k * .17, .66),
      ],
      sharp: <int>{3},
    );
    p.part(
      w,
      wing,
      marks: () {
        for (final double y in <double>[.56, .63, .70]) {
          p.flat(
            circle(.5 + k * .23, y, .008),
            Kit.white.withValues(alpha: .85),
          );
        }
      },
    );
  }
  // The heart-shaped face.
  final Path heart = Path()
    ..moveTo(.5, .32)
    ..cubicTo(.56, .25, .70, .26, .70, .38)
    ..cubicTo(.70, .50, .58, .58, .5, .62)
    ..cubicTo(.42, .58, .30, .50, .30, .38)
    ..cubicTo(.30, .26, .44, .25, .5, .32)
    ..close();
  p.part(heart, face, shine: .6, line: 0, depth: .3);
  p.outline(heart, .016);
  p.canvas.drawPath(heart, strokeOf(rim, .012));
  p.eyes(.5, .42, .085, .045);
  p.part(
    blob(<Offset>[
      pt(.485, .46),
      pt(.515, .46),
      pt(.505, .53),
      pt(.5, .54),
      pt(.495, .53),
    ]),
    beak,
    depth: .4,
    line: p.lw * .6,
  );
  p.cheeks(.5, .49, .13, .03);

  p.head(const Rect.fromLTRB(.30, .25, .70, .62), hatLift: .0);
  p.torso(const Rect.fromLTRB(.26, .40, .74, .88));
  p.collar(pt(.5, .60), .15);
}

// ------------------------------------------------------------------ 19 lynx

/// A sitting cat, shared by the lynxes, leopards and panthers of the night.
void _sitCat(
  Pen p, {
  required Color fur,
  required Color belly,
  required Color inner,
  required Color tailTip,
  Color iris = const Color(0xFF8AA03A),
  Color? eyeRim,
  Color muzzle = const Color(0xFFFFFBF5),
  Color nose = Kit.nosePink,
  bool tufts = false,
  bool ruffs = false,
  bool longTail = true,
  Color? tuftColor,
  VoidCallback? bodyMarks,
  VoidCallback? headMarks,
  VoidCallback? beforeHead,
  Path? tailPath,
}) {
  if (longTail) {
    final Path tail =
        tailPath ??
        puffs(
          <Offset>[
            pt(.62, .86),
            pt(.80, .84),
            pt(.87, .72),
            pt(.84, .58),
            pt(.80, .52),
          ],
          <double>[.04, .045, .048, .048, .046],
        );
    p.part(
      tail,
      fur,
      marks: () {
        if (bodyMarks != null) bodyMarks();
        p.flat(circle(.80, .52, .05), tailTip);
      },
    );
  } else {
    p.part(
      circle(.66, .82, .05),
      fur,
      marks: () => p.flat(circle(.69, .79, .03), tailTip),
    );
  }
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .155, .30),
      pt(.5 + k * .21, .13),
      .15,
      fur,
      inner,
      round: .035,
    );
    if (tufts) {
      p.part(
        leaf(pt(.5 + k * .21, .15), pt(.5 + k * .235, .05), .03),
        tuftColor ?? const Color(0xFF2E2A36),
        depth: 0,
        line: p.lw * .6,
      );
    }
  }
  sitBody(p, fur: fur, belly: belly, rx: .17, ry: .16, marks: bodyMarks);
  if (beforeHead != null) beforeHead();
  if (ruffs) {
    for (final double k in sides) {
      p.part(
        blob(
          <Offset>[
            pt(.5 + k * .15, .42),
            pt(.5 + k * .27, .50),
            pt(.5 + k * .25, .55),
            pt(.5 + k * .28, .59),
            pt(.5 + k * .16, .60),
          ],
          sharp: <int>{1, 3},
        ),
        belly,
        marks: () {
          p.line(
            Path()
              ..moveTo(.5 + k * .19, .52)
              ..lineTo(.5 + k * .25, .555),
            width: .01,
            color: darker(fur, .3),
          );
        },
      );
    }
  }
  p.part(oval(.5, .43, .225, .185), fur, shine: 1, marks: headMarks);
  p.eyes(.5, .43, .088, .047, iris: iris, rim: eyeRim);
  p.cheeks(.5, .5, .14, .03);
  catMuzzle(p, .5, .43, muzzle: muzzle, nose: nose);

  p.head(
    const Rect.fromLTRB(.275, .245, .725, .615),
    hatLift: tufts ? .03 : .02,
  );
  p.collar(pt(.5, .61), .13);
}

void _lynx(Pen p) {
  const Color fur = Color(0xFFCDB89C);
  const Color spot = Color(0xFF8E7558);
  p.ink = const Color(0xFF3A2C1C);
  _sitCat(
    p,
    fur: fur,
    belly: const Color(0xFFFBF4EA),
    inner: const Color(0xFFFFE6D6),
    tailTip: const Color(0xFF2E2A36),
    tufts: true,
    ruffs: true,
    longTail: false,
    iris: const Color(0xFFB09A3A),
    bodyMarks: () {
      for (final Offset c in <Offset>[
        pt(.38, .66),
        pt(.62, .67),
        pt(.36, .76),
        pt(.64, .77),
        pt(.41, .84),
        pt(.59, .84),
      ]) {
        p.flat(circle(c.dx, c.dy, .013), spot);
      }
    },
    headMarks: () {
      for (final Offset c in <Offset>[
        pt(.46, .30),
        pt(.54, .30),
        pt(.5, .34),
        pt(.36, .36),
        pt(.64, .36),
      ]) {
        p.flat(circle(c.dx, c.dy, .01), spot);
      }
    },
  );
}

// --------------------------------------------------------------- 20 wolf pup

void _wolfPup(Pen p) {
  const Color fur = Color(0xFF9EA7BC);
  const Color pale = Color(0xFFF1F3F8);
  const Color dark = Color(0xFF5E667C);
  p.ink = const Color(0xFF252A38);

  final Path tail = puffs(
    <Offset>[pt(.62, .86), pt(.80, .84), pt(.89, .70), pt(.88, .55)],
    <double>[.05, .07, .075, .06],
  );
  p.part(tail, fur, marks: () => p.flat(circle(.88, .54, .055), pale));
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .15, .30),
      pt(.5 + k * .22, .12),
      .15,
      fur,
      pale,
      round: .03,
      tipColor: dark,
    );
  }
  sitBody(p, fur: fur, belly: pale, feet: pale, paws: pale);
  final Path head = sym(
    <Offset>[
      pt(.5, .25),
      pt(.64, .265),
      pt(.72, .34),
      pt(.75, .45),
      pt(.76, .52),
      pt(.66, .58),
      pt(.5, .62),
    ],
    sharp: <int>{4},
  );
  p.part(
    head,
    fur,
    shine: 1,
    marks: () {
      p.flat(
        sym(
          <Offset>[
            pt(.5, .44),
            pt(.56, .42),
            pt(.65, .46),
            pt(.76, .52),
            pt(.66, .585),
            pt(.5, .625),
          ],
          sharp: <int>{3},
        ),
        pale,
      );
      p.flat(
        blob(<Offset>[
          pt(.5, .25),
          pt(.535, .32),
          pt(.515, .40),
          pt(.485, .40),
          pt(.465, .32),
        ]),
        dark,
      );
    },
  );
  p.eyes(.5, .43, .09, .047, iris: const Color(0xFF6A8AC8));
  p.cheeks(.5, .5, .15, .03);
  p.nose(pt(.5, .495), .025);
  p.grin(pt(.5, .525), .04, .07);

  p.head(const Rect.fromLTRB(.24, .25, .76, .62), hatLift: .03);
  p.collar(pt(.5, .61), .14);
}

// ----------------------------------------------------------------- 21 panther

void _panther(Pen p) {
  const Color fur = Color(0xFF424466);
  const Color rosette = Color(0xFF363856);
  p.ink = const Color(0xFF14141F);
  final Path tail = taper(
    <Offset>[
      pt(.62, .86),
      pt(.82, .86),
      pt(.90, .74),
      pt(.88, .58),
      pt(.80, .48),
    ],
    <double>[.034, .036, .036, .034, .03],
  );
  _sitCat(
    p,
    fur: fur,
    belly: const Color(0xFF55587C),
    inner: const Color(0xFF7A6E9A),
    tailTip: fur,
    tailPath: tail,
    iris: const Color(0xFFD4F04A),
    eyeRim: const Color(0xFF2A2B40),
    muzzle: const Color(0xFF5C5F84),
    nose: const Color(0xFF7A6E9A),
    bodyMarks: () {
      for (final Offset c in <Offset>[
        pt(.38, .68),
        pt(.62, .66),
        pt(.40, .80),
        pt(.60, .79),
      ]) {
        p.canvas.drawCircle(c, .016, strokeOf(rosette, .008));
      }
    },
    headMarks: () {
      for (final Offset c in <Offset>[
        pt(.42, .31),
        pt(.58, .31),
        pt(.5, .29),
      ]) {
        p.canvas.drawCircle(c, .012, strokeOf(rosette, .007));
      }
    },
  );
}

// --------------------------------------------------------------- 22 moon hare

void _moonHare(Pen p) {
  const Color fur = Color(0xFFEDEFFB);
  const Color inner = Color(0xFFC9B8F2);
  const Color moon = Color(0xFFFFE07A);
  p.ink = const Color(0xFF3A3560);

  // A crescent moon rising behind.
  final Path crescent = minus(circle(.30, .50, .2), circle(.38, .45, .17));
  p.glow(pt(.28, .52), .26, moon, alpha: .35);
  p.part(crescent, moon, shine: .6, depth: .6);
  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .07, .31), pt(.5 + k * .14, .04), .1, bend: k * -.01),
      fur,
      shine: .4,
    );
    p.part(
      leaf(pt(.5 + k * .075, .28), pt(.5 + k * .13, .09), .05),
      inner,
      depth: .4,
      line: 0,
    );
  }
  p.part(fluff(.69, .80, .045, .04, 7, depth: .18), Kit.white);
  sitBody(p, fur: fur, belly: Kit.white, rx: .16, ry: .15, cy: .74, footW: .07);
  p.part(
    oval(.5, .45, .21, .18),
    fur,
    shine: 1,
    marks: () {
      p.flat(minus(circle(.5, .32, .035), circle(.515, .31, .03)), moon);
    },
  );
  p.eyes(.5, .455, .085, .047, iris: const Color(0xFF8A70E0));
  p.cheeks(.5, .52, .135, .034);
  p.nose(pt(.5, .51), .017, color: Kit.nosePink);
  p.catMouth(pt(.5, .535), .018);
  p.twinkle(pt(.82, .30), .03, moon);
  p.twinkle(pt(.86, .52), .02, moon);

  p.head(const Rect.fromLTRB(.29, .27, .71, .63), hatLift: .02);
  p.collar(pt(.5, .625), .12);
}

// ------------------------------------------------------------ 23 snow leopard

void _snowLeopard(Pen p) {
  const Color fur = Color(0xFFE9EBF1);
  const Color rosette = Color(0xFF7F8496);
  p.ink = const Color(0xFF2E3242);

  void rosettes(List<Offset> at, double r) {
    for (final Offset c in at) {
      p.canvas.drawCircle(c, r, strokeOf(rosette, r * .55));
      p.canvas.drawCircle(c, r * .3, fillOf(rosette));
    }
  }

  final Path tail = puffs(
    <Offset>[
      pt(.60, .87),
      pt(.80, .86),
      pt(.91, .74),
      pt(.88, .56),
      pt(.78, .46),
    ],
    <double>[.06, .07, .075, .075, .068],
  );
  _sitCat(
    p,
    fur: fur,
    belly: Kit.white,
    inner: const Color(0xFFFFD6DE),
    tailTip: fur,
    tailPath: tail,
    iris: const Color(0xFF7AA0C8),
    bodyMarks: () => rosettes(<Offset>[
      pt(.38, .66),
      pt(.62, .67),
      pt(.37, .78),
      pt(.63, .79),
      pt(.86, .70),
      pt(.80, .50),
      pt(.72, .84),
    ], .016),
    headMarks: () => rosettes(<Offset>[
      pt(.42, .32),
      pt(.58, .32),
      pt(.5, .29),
      pt(.33, .40),
      pt(.67, .40),
    ], .011),
  );
}

// ------------------------------------------------------------ 24 aurora wolf

Shader _aurora(Rect r) => const LinearGradient(
  colors: <Color>[Color(0xFF6CF2C2), Color(0xFF7AB8FF), Color(0xFFC79BFF)],
).createShader(r);

void _auroraWolf(Pen p) {
  const Color fur = Color(0xFF6A78B0);
  const Color pale = Color(0xFFDDE4FF);
  p.ink = const Color(0xFF1C2244);

  // A flowing aurora tail.
  final Path tail = blob(<Offset>[
    pt(.60, .86),
    pt(.80, .84),
    pt(.94, .66),
    pt(.90, .44),
    pt(.80, .36),
    pt(.82, .52),
    pt(.78, .66),
    pt(.68, .74),
  ]);
  p.glow(pt(.86, .55), .2, const Color(0xFF7AF2D0), alpha: .35);
  p.canvas.drawPath(tail, Paint()..shader = _aurora(tail.getBounds()));
  p.outline(tail);
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .15, .28),
      pt(.5 + k * .22, .09),
      .15,
      fur,
      pale,
      round: .03,
    );
  }
  sitBody(p, fur: fur, belly: pale, feet: pale, paws: pale);
  // An aurora ruff round the neck.
  final Path ruff = fluff(.5, .56, .24, .1, 11, depth: .14);
  p.canvas.drawPath(ruff, Paint()..shader = _aurora(ruff.getBounds()));
  p.outline(ruff);
  final Path head = sym(
    <Offset>[
      pt(.5, .23),
      pt(.64, .245),
      pt(.72, .32),
      pt(.75, .43),
      pt(.76, .50),
      pt(.66, .56),
      pt(.5, .60),
    ],
    sharp: <int>{4},
  );
  p.part(
    head,
    fur,
    shine: 1,
    marks: () {
      p.flat(
        sym(
          <Offset>[
            pt(.5, .42),
            pt(.56, .40),
            pt(.65, .44),
            pt(.76, .50),
            pt(.66, .565),
            pt(.5, .605),
          ],
          sharp: <int>{3},
        ),
        pale,
      );
      p.flat(star(.5, .30, .03, round: .004), const Color(0xFF9EF7DC));
    },
  );
  p.eyes(.5, .41, .09, .047, iris: const Color(0xFF5AE0D0));
  p.cheeks(.5, .48, .15, .03);
  p.nose(pt(.5, .475), .025);
  p.catMouth(pt(.5, .51), .02);
  p.twinkle(pt(.15, .30), .028, const Color(0xFFB8FFE8));
  p.twinkle(pt(.20, .55), .018, const Color(0xFFD8C2FF));

  p.head(const Rect.fromLTRB(.24, .23, .76, .60), hatLift: .03);
  p.collar(pt(.5, .60), .15);
}

// -------------------------------------------------------------- 25 comet cat

void _cometCat(Pen p) {
  const Color fur = Color(0xFF7466C4);
  const Color belly = Color(0xFFD9D2FF);
  p.ink = const Color(0xFF221A4A);

  // The tail streams up into a comet.
  final Path streak = blob(
    <Offset>[
      pt(.62, .86),
      pt(.82, .80),
      pt(.90, .60),
      pt(.86, .34),
      pt(.84, .22),
      pt(.80, .34),
      pt(.80, .56),
      pt(.72, .72),
    ],
    sharp: <int>{4},
  );
  final Rect sb = streak.getBounds();
  p.canvas.drawPath(
    streak,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: <Color>[fur, Color(0xFF9F8CFF), Color(0xFFFFF0A8)],
      ).createShader(sb),
  );
  p.outline(streak);
  p.glow(pt(.84, .2), .12, _starGold, alpha: .7);
  p.part(star(.84, .19, .065, round: .01), _starGold, shine: .8);
  _sitCatBody(
    p,
    fur: fur,
    belly: belly,
    iris: const Color(0xFFFFC94A),
    headMarks: () {
      p.flat(star(.5, .31, .035, round: .005), _starGold);
    },
    bodyMarks: () {
      for (final Offset c in <Offset>[
        pt(.40, .70),
        pt(.61, .76),
        pt(.44, .82),
      ]) {
        p.flat(star(c.dx, c.dy, .014, round: .002), belly);
      }
    },
  );
  p.twinkle(pt(.16, .34), .025, _starGold);
  p.twinkle(pt(.68, .14), .018, _starGold);
}

/// A sitting cat with no tail of its own, for those whose tail is special.
void _sitCatBody(
  Pen p, {
  required Color fur,
  required Color belly,
  required Color iris,
  VoidCallback? headMarks,
  VoidCallback? bodyMarks,
  Color inner = const Color(0xFFFFC2E0),
}) {
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .155, .30),
      pt(.5 + k * .21, .13),
      .15,
      fur,
      inner,
      round: .035,
    );
  }
  sitBody(p, fur: fur, belly: belly, rx: .17, ry: .16, marks: bodyMarks);
  p.part(oval(.5, .43, .225, .185), fur, shine: 1, marks: headMarks);
  p.eyes(.5, .43, .088, .047, iris: iris);
  p.cheeks(.5, .5, .14, .03);
  catMuzzle(p, .5, .43, muzzle: belly);
  p.head(const Rect.fromLTRB(.275, .245, .725, .615), hatLift: .02);
  p.collar(pt(.5, .61), .13);
}

// ------------------------------------------------------------ 26 dream tapir

void _dreamTapir(Pen p) {
  const Color front = Color(0xFF8A7CC4);
  const Color saddle = Color(0xFFF6F3FF);
  const Color cap = Color(0xFF6AA8F0);
  const double hx = .63;
  p.ink = const Color(0xFF261E4A);

  standBody(
    p,
    fur: front,
    hoof: darker(front, .2),
    cx: .42,
    cy: .62,
    rx: .25,
    ry: .15,
    legW: .07,
    legTop: .66,
    neck: standNeck(top: .44),
    marks: () {
      p.flat(fluff(.34, .58, .15, .12, 8, depth: .12), saddle);
    },
  );
  p.tube(curve(<Offset>[pt(.18, .58), pt(.15, .62)]), .02, front);
  for (final double k in sides) {
    roundEar(p, pt(hx + k * .13, .29), .05, front, saddle, innerScale: .55);
  }
  // Head and short drooping nose-trunk in one piece.
  p.part(
    union(
      oval(hx, .40, .16, .14),
      taper(
        <Offset>[pt(hx, .46), pt(hx, .52), pt(hx + .02, .565)],
        <double>[.045, .038, .034],
      ),
    ),
    front,
    shine: 1,
  );
  p.eye(pt(hx - .065, .39), .042, look: Eye.shut);
  p.eye(pt(hx + .065, .39), .042, look: Eye.shut);
  p.face(pt(hx - .065, .39), pt(hx + .065, .39), .042);
  p.cheeks(hx, .44, .11, .03);
  // A nightcap with a pompom.
  final Path hat = blob(
    <Offset>[
      pt(hx - .13, .31),
      pt(hx - .05, .2),
      pt(hx + .06, .13),
      pt(hx + .2, .16),
      pt(hx + .16, .22),
      pt(hx + .1, .24),
      pt(hx + .13, .32),
    ],
    sharp: <int>{3},
  );
  p.part(
    hat,
    cap,
    shine: .6,
    marks: () {
      for (final Offset c in <Offset>[
        pt(hx - .04, .26),
        pt(hx + .05, .2),
        pt(hx + .06, .28),
      ]) {
        p.flat(star(c.dx, c.dy, .016, round: .002), _starGold);
      }
    },
  );
  p.part(rrect(hx - .145, .29, hx + .145, .335, .022), saddle);
  p.part(circle(hx + .2, .16, .035), saddle, shine: .6);
  for (final List<double> z in <List<double>>[
    <double>[.22, .32, .035],
    <double>[.12, .22, .025],
  ]) {
    final double x = z[0], y = z[1], s = z[2];
    p.tube(
      Path()
        ..moveTo(x - s, y - s)
        ..lineTo(x + s, y - s)
        ..lineTo(x - s, y + s)
        ..lineTo(x + s, y + s),
      .011,
      const Color(0xFFDCD6FF),
    );
  }

  p.head(const Rect.fromLTRB(hx - .16, .26, hx + .16, .54), hatLift: .08);
  p.collar(pt(.6, .55), .08);
}

// ------------------------------------------------------------- 27 nebula owl

void _nebulaOwl(Pen p) {
  const Color body = Color(0xFF5A4AAE);
  const Color disc = Color(0xFFB9A8F2);
  const Color pink = Color(0xFFFF8AD0);
  const Color teal = Color(0xFF6CE0E8);
  p.ink = const Color(0xFF1A1440);

  for (final double k in sides) {
    final Path w = blob(<Offset>[
      pt(.5 + k * .18, .44),
      pt(.5 + k * .34, .40),
      pt(.5 + k * .42, .52),
      pt(.5 + k * .38, .66),
      pt(.5 + k * .30, .72),
      pt(.5 + k * .20, .70),
    ]);
    p.part(
      w,
      darker(body, .04),
      shine: .4,
      marks: () {
        p.flat(circle(.5 + k * .34, .52, .05), pink.withValues(alpha: .45));
        for (final Offset c in <Offset>[
          pt(.5 + k * .3, .48),
          pt(.5 + k * .36, .6),
          pt(.5 + k * .26, .62),
        ]) {
          p.flat(circle(c.dx, c.dy, .007), Kit.white);
        }
      },
    );
  }
  birdFoot(p, .44, Kit.gold);
  birdFoot(p, .56, Kit.gold);
  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .15, .28), pt(.5 + k * .25, .10), .085, bend: k * .01),
      body,
    );
  }
  final Path b = blob(<Offset>[
    pt(.5, .24),
    pt(.65, .26),
    pt(.73, .40),
    pt(.74, .60),
    pt(.68, .78),
    pt(.5, .875),
    pt(.32, .78),
    pt(.26, .60),
    pt(.27, .40),
    pt(.35, .26),
  ]);
  p.part(
    b,
    body,
    shine: .8,
    marks: () {
      p.flat(oval(.42, .74, .12, .08), pink.withValues(alpha: .4));
      p.flat(oval(.58, .68, .1, .07), teal.withValues(alpha: .35));
      for (final Offset c in <Offset>[
        pt(.40, .66),
        pt(.6, .78),
        pt(.5, .72),
        pt(.36, .78),
        pt(.62, .62),
      ]) {
        p.flat(circle(c.dx, c.dy, .008), Kit.white);
      }
    },
  );
  p.part(
    union(circle(.43, .43, .1), circle(.57, .43, .1)),
    disc,
    depth: .4,
    line: 0,
  );
  p.eyes(.5, .43, .07, .055, iris: pink);
  p.part(
    roundPoly(<Offset>[pt(.475, .50), pt(.525, .50), pt(.5, .545)], .01),
    Kit.gold,
    depth: .4,
    line: p.lw * .6,
  );
  p.cheeks(.5, .51, .14, .03);
  p.twinkle(pt(.14, .26), .028, teal);
  p.twinkle(pt(.86, .28), .022, pink);

  p.head(const Rect.fromLTRB(.27, .24, .73, .58), hatLift: .04);
  p.torso(const Rect.fromLTRB(.26, .40, .74, .875));
  p.collar(pt(.5, .58), .16);
}

// ------------------------------------------------------------ 28 eclipse bear

void _eclipseBear(Pen p) {
  const Color fur = Color(0xFF4E4A6A);
  const Color muzzle = Color(0xFF8A84A8);
  const Color gold = Color(0xFFFFCB57);
  p.ink = const Color(0xFF16141F);

  // The eclipse: a dark disc ringed in fire, rising behind the head.
  p.glow(pt(.5, .38), .36, gold, alpha: .55);
  p.part(spikes(.5, .38, .27, .27, 16, .14, round: .01), gold, depth: .4);
  p.part(circle(.5, .38, .25), const Color(0xFF2A2640), depth: 0);
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .19, .27), .07, fur, muzzle, innerScale: .55);
  }
  sitBody(
    p,
    fur: fur,
    feet: darker(fur, .06),
    paws: darker(fur, .06),
    rx: .2,
    ry: .165,
    marks: () {
      p.flat(minus(circle(.5, .64, .085), circle(.5, .60, .08)), gold);
    },
  );
  p.part(
    oval(.5, .43, .23, .19),
    fur,
    shine: .8,
    marks: () => p.flat(oval(.5, .51, .1, .075), muzzle),
  );
  p.eyes(.5, .415, .1, .044, iris: gold, rim: const Color(0xFF34304A));
  p.cheeks(.5, .48, .16, .03);
  p.nose(pt(.5, .49), .03, color: const Color(0xFF221E30));
  p.catMouth(pt(.5, .528), .02);

  p.head(const Rect.fromLTRB(.27, .24, .73, .62));
  p.collar(pt(.5, .615), .15);
}

// ------------------------------------------------------------- 29 lunar lynx

void _lunarLynx(Pen p) {
  const Color fur = Color(0xFFC8CCF0);
  const Color glow = Color(0xFF9EE6FF);
  p.ink = const Color(0xFF2A2C58);

  p.glow(pt(.5, .5), .42, const Color(0xFFB8C8FF), alpha: .3);
  _sitCat(
    p,
    fur: fur,
    belly: const Color(0xFFF4F5FF),
    inner: const Color(0xFFE8D8FF),
    tailTip: const Color(0xFF6A6EB0),
    tufts: true,
    ruffs: true,
    longTail: false,
    tuftColor: const Color(0xFF6A6EB0),
    iris: const Color(0xFF5AC8F0),
    muzzle: const Color(0xFFF4F5FF),
    headMarks: () =>
        p.flat(minus(circle(.5, .31, .035), circle(.517, .30, .03)), _starGold),
    bodyMarks: () {
      for (final Offset c in <Offset>[
        pt(.38, .68),
        pt(.62, .70),
        pt(.42, .82),
      ]) {
        p.flat(star(c.dx, c.dy, .014, round: .002), glow);
      }
    },
  );
  for (final double k in sides) {
    p.twinkle(pt(.5 + k * .235, .05), .028, _starGold);
  }
  p.twinkle(pt(.14, .48), .02, glow);
}

// ----------------------------------------------------------- 30 starweaver

void _starStag(Pen p) {
  const Color fur = Color(0xFF4A5698);
  const Color belly = Color(0xFF8E9CDA);
  const Color hoof = Color(0xFF2A3060);
  const double hx = .62;
  p.ink = const Color(0xFF141838);

  // Antlers drawn as constellations: glowing lines joining stars.
  final List<List<Offset>> beams = <List<Offset>>[];
  for (final double k in sides) {
    Offset q(double x, double y) => pt(hx + k * x, y);
    beams.add(<Offset>[q(.05, .23), q(.10, .15), q(.18, .10), q(.26, .09)]);
    beams.add(<Offset>[q(.10, .15), q(.09, .06)]);
    beams.add(<Offset>[q(.18, .10), q(.21, .03)]);
  }
  for (final List<Offset> b in beams) {
    p.glow(b.last, .05, _starGold, alpha: .6);
  }
  for (final List<Offset> b in beams) {
    final Path path = Path()..moveTo(b.first.dx, b.first.dy);
    for (final Offset o in b.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    p.line(path, width: .022, color: const Color(0xFF8C7A3A));
    p.line(path, width: .01, color: const Color(0xFFFFF2B8));
  }
  for (final List<Offset> b in beams) {
    for (final Offset o in b.skip(1)) {
      p.twinkle(o, .022, _starGold);
    }
  }
  p.part(tear(.20, .54, .03, angle: -1.0, length: 2.0), belly);
  standBody(
    p,
    fur: fur,
    hoof: hoof,
    belly: belly,
    cy: .63,
    neck: standNeck(),
    marks: () {
      for (final Offset s in <Offset>[
        pt(.28, .56),
        pt(.38, .545),
        pt(.47, .56),
        pt(.33, .62),
        pt(.43, .615),
        pt(.24, .62),
      ]) {
        p.flat(star(s.dx, s.dy, .016, round: .002), _starGold);
      }
      p.flat(oval(.62, .55, .05, .07), belly);
    },
  );
  for (final double k in sides) {
    p.part(
      leaf(pt(hx + k * .11, .29), pt(hx + k * .24, .25), .085),
      fur,
      marks: () => p.flat(
        leaf(pt(hx + k * .14, .285), pt(hx + k * .225, .255), .04),
        belly,
      ),
    );
  }
  p.part(
    oval(hx, .36, .155, .14),
    fur,
    shine: 1,
    marks: () {
      p.flat(oval(hx, .445, .08, .058), belly);
      p.flat(star(hx, .29, .024, round: .003), _starGold);
    },
  );
  p.eyes(
    hx,
    .35,
    .068,
    .045,
    iris: const Color(0xFFFFD86A),
    rim: const Color(0xFF3A4480),
  );
  p.cheeks(hx, .41, .11, .03);
  p.nose(pt(hx, .425), .02, color: const Color(0xFF1E2450));
  p.catMouth(pt(hx, .458), .016);

  p.head(const Rect.fromLTRB(hx - .155, .22, hx + .155, .50), hatLift: .05);
  p.collar(pt(.61, .52), .07);
}
