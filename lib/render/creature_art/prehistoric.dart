import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'creature_art.dart';
import 'kit.dart';
import 'parts.dart';

/// Fossil Meadow — deep time, from a trilobite in the Cambrian mud up to the
/// largest animal ever to walk the earth.
const Map<String, CreatureArt> prehistoricArt = <String, CreatureArt>{
  'prehistoric_01': CreatureArt(_trilobite, shadow: .3),
  'prehistoric_02': CreatureArt(_ammonite, shadow: .3),
  'prehistoric_03': CreatureArt(_anomalocaris, shadow: .32),
  'prehistoric_04': CreatureArt(_meganeura, shadow: .16),
  'prehistoric_05': CreatureArt(_arthropleura, shadow: .36),
  'prehistoric_06': CreatureArt(_ichthyostega, shadow: .36),
  'prehistoric_07': CreatureArt(_dimetrodon, shadow: .36),
  'prehistoric_08': CreatureArt(_compsognathus, shadow: .26),
  'prehistoric_09': CreatureArt(_microraptor, shadow: .26),
  'prehistoric_10': CreatureArt(_archaeopteryx, shadow: .22),
  'prehistoric_11': CreatureArt(_protoceratops, shadow: .34),
  'prehistoric_12': CreatureArt(_velociraptor, shadow: .3),
  'prehistoric_13': CreatureArt(_oviraptor, shadow: .32),
  'prehistoric_14': CreatureArt(_pachy, shadow: .3),
  'prehistoric_15': CreatureArt(_gallimimus, shadow: .26),
  'prehistoric_16': CreatureArt(_dilophosaurus, shadow: .3),
  'prehistoric_17': CreatureArt(_parasaurolophus, shadow: .34),
  'prehistoric_18': CreatureArt(_stegosaurus, shadow: .38),
  'prehistoric_19': CreatureArt(_ankylosaurus, shadow: .38),
  'prehistoric_20': CreatureArt(_triceratops, shadow: .36),
  'prehistoric_21': CreatureArt(_pteranodon, shadow: .2),
  'prehistoric_22': CreatureArt(_plesiosaur, shadow: .34),
  'prehistoric_23': CreatureArt(_mosasaurus, shadow: .38),
  'prehistoric_24': CreatureArt(_allosaurus, shadow: .32),
  'prehistoric_25': CreatureArt(_spinosaurus, shadow: .34),
  'prehistoric_26': CreatureArt(_tyrannosaurus, shadow: .32),
  'prehistoric_27': CreatureArt(_brachiosaurus, shadow: .34),
  'prehistoric_28': CreatureArt(_sabertooth, shadow: .28),
  'prehistoric_29': CreatureArt(_mammoth, shadow: .36),
  'prehistoric_30': CreatureArt(_titanosaur, shadow: .4),
};

/// One side-on eye that still records where sunglasses would sit.
void _sideEye(
  Pen p,
  Offset c,
  double r, {
  Color iris = const Color(0xFF6A4A2A),
  Color? rim,
}) {
  p.eye(c, r, iris: iris, rim: rim);
  p.face(c.translate(-r * .4, 0), c.translate(r * .4, 0), r);
}

/// A dinosaur's hind leg: a heavy thigh at [hip] and a shin down to a
/// three-toed foot on the ground.
void _hindLeg(Pen p, Offset hip, Color color, {double s = 1, Color? claw}) {
  final Offset knee = pt(hip.dx + .03 * s, (hip.dy + .86) / 2 + .01);
  final Offset ankle = pt(hip.dx - .015 * s, .858);
  // Thigh, shin and foot as one piece, so the leg reads as a single limb.
  final Path limb = unite(<Path>[
    oval(hip.dx, hip.dy, .065 * s, .085 * s),
    taper(
      <Offset>[hip.translate(.01 * s, .05 * s), knee, ankle],
      <double>[.045 * s, .03 * s, .026 * s],
    ),
    oval(ankle.dx + .03 * s, .874, .062 * s, .024),
  ]);
  p.part(limb, color, shine: .3);
  for (final double d in <double>[.0, .035, .07]) {
    p.flat(
      oval(ankle.dx + .0 + d * s, .893, .011 * s, .007),
      claw ?? Kit.tooth,
    );
  }
}

/// A short pillar leg with toenails, for the four-footed giants.
void _stump(
  Pen p,
  double x,
  double top,
  double w,
  Color color, {
  Color nail = const Color(0xFFFFF6E6),
}) {
  p.part(rrect(x - w / 2, top, x + w / 2, .895, w * .42), color, depth: .5);
  for (final double d in <double>[-.3, 0, .3]) {
    p.flat(oval(x + d * w, .888, w * .11, w * .07), nail);
  }
}

/// A short sprawling leg angled out from under a low body, with a round foot.
void _sprawl(
  Pen p,
  double x,
  double top,
  Color color, {
  double lean = .03,
  double w = .034,
}) {
  p.part(
    union(
      taper(
        <Offset>[pt(x, top), pt(x + lean * .6, .80), pt(x + lean, .865)],
        <double>[w, w * .85, w * .75],
      ),
      oval(x + lean + .015, .876, w * 1.5, .02),
    ),
    color,
    depth: .5,
  );
  for (final double d in <double>[-.02, 0, .02]) {
    p.flat(oval(x + lean + .015 + d, .89, .007, .006), lighter(color, .22));
  }
}

/// A row of sharp little teeth along a jaw line from [a] to [b].
void _teeth(Pen p, Offset a, Offset b, int n, double h) {
  for (int i = 0; i < n; i++) {
    final Offset s = Offset.lerp(a, b, i / n)!;
    final Offset e = Offset.lerp(a, b, (i + .8) / n)!;
    p.part(
      poly(<Offset>[s, e, Offset.lerp(s, e, .5)!.translate(0, h)]),
      Kit.tooth,
      depth: 0,
      line: p.lw * .35,
    );
  }
}

// ----------------------------------------------------------------- 1 trilobite

void _trilobite(Pen p) {
  const Color shell = Color(0xFF8FA8D2);
  const Color rib = Color(0xFF6E86B4);
  const Color axis = Color(0xFFB4C8EA);
  p.ink = const Color(0xFF1E2A4A);

  for (final double k in sides) {
    for (int i = 0; i < 4; i++) {
      final double y = .60 + i * .065;
      p.tube(
        Path()
          ..moveTo(.5 + k * .26, y)
          ..lineTo(.5 + k * .33, y + .03),
        .016,
        rib,
      );
    }
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .1, .38),
        pt(.5 + k * .2, .30),
        pt(.5 + k * .28, .30),
      ]),
      .012,
      rib,
    );
  }
  final Path body = blob(<Offset>[
    pt(.5, .50),
    pt(.70, .52),
    pt(.79, .62),
    pt(.76, .76),
    pt(.64, .85),
    pt(.5, .875),
    pt(.36, .85),
    pt(.24, .76),
    pt(.21, .62),
    pt(.30, .52),
  ]);
  p.part(
    body,
    shell,
    shine: .6,
    marks: () {
      for (double y = .58; y < .86; y += .045) {
        p.line(
          curve(<Offset>[pt(.2, y - .02), pt(.5, y + .02), pt(.8, y - .02)]),
          width: .009,
          color: rib,
        );
      }
      p.flat(oval(.5, .69, .075, .19), axis);
      for (double y = .56; y < .86; y += .045) {
        p.line(
          curve(<Offset>[pt(.43, y), pt(.5, y + .012), pt(.57, y)]),
          width: .007,
          color: rib,
        );
      }
    },
  );
  // The head shield, with its swept-back spines.
  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .27, .52), pt(.5 + k * .33, .74), .05, bend: k * -.02),
      shell,
      depth: .4,
    );
  }
  final Path head = Path()
    ..moveTo(.20, .56)
    ..cubicTo(.20, .30, .80, .30, .80, .56)
    ..quadraticBezierTo(.5, .62, .20, .56)
    ..close();
  p.part(
    head,
    shell,
    shine: 1,
    marks: () => p.flat(oval(.5, .44, .09, .1), axis),
  );
  p.eyes(.5, .47, .13, .048, iris: const Color(0xFF4A6AB0));
  p.cheeks(.5, .53, .18, .03);
  p.smile(pt(.5, .53), .02);

  p.head(const Rect.fromLTRB(.2, .36, .8, .59), hatLift: .0);
  p.torso(const Rect.fromLTRB(.21, .5, .79, .875));
  p.collar(pt(.5, .58), .2);
}

// ----------------------------------------------------------------- 2 ammonite

void _ammonite(Pen p) {
  const Color shell = Color(0xFFD9C4F2);
  const Color rib = Color(0xFFB49AD8);
  const Color body = Color(0xFFFF9EAE);
  p.ink = const Color(0xFF3A2258);

  for (final double x in <double>[.62, .68, .74, .80, .86]) {
    p.tube(
      curve(<Offset>[pt(x, .74), pt(x + .02, .82), pt(x - .01, .885)]),
      .026,
      body,
    );
  }
  final Path coil = circle(.42, .50, .30);
  p.part(
    coil,
    shell,
    shine: 1,
    marks: () {
      for (int i = 0; i < 16; i++) {
        final double a = i * math.pi * 2 / 16;
        p.line(
          curve(<Offset>[
            pt(.42 + math.cos(a) * .1, .50 + math.sin(a) * .1),
            pt(.42 + math.cos(a + .25) * .2, .50 + math.sin(a + .25) * .2),
            pt(.42 + math.cos(a + .35) * .3, .50 + math.sin(a + .35) * .3),
          ]),
          width: .012,
          color: rib,
        );
      }
    },
  );
  final List<Offset> spiral = <Offset>[
    for (int i = 0; i <= 40; i++)
      pt(
        .42 + math.cos(i * .3) * .012 * math.exp(i * .07),
        .50 + math.sin(i * .3) * .012 * math.exp(i * .07),
      ),
  ];
  p.line(curve(spiral), width: p.lw * .9);
  // A soft little face peeking out of the opening.
  p.part(oval(.74, .66, .14, .12), body, shine: 1);
  p.eyes(.74, .65, .055, .04, iris: const Color(0xFFB04A6A));
  p.cheeks(.74, .70, .09, .026);
  p.smile(pt(.74, .705), .018);

  p.head(const Rect.fromLTRB(.6, .54, .88, .78), hatLift: .0);
  p.torso(const Rect.fromLTRB(.12, .2, .72, .8));
  p.collar(pt(.74, .77), .1);
}

// -------------------------------------------------------------- 3 anomalocaris

void _anomalocaris(Pen p) {
  const Color body = Color(0xFFD96A8C);
  const Color flap = Color(0xFFF4A6BE);
  const Color claw = Color(0xFFB04A6E);
  p.ink = const Color(0xFF4A0E26);

  // Swimming flaps down both flanks.
  for (int i = 0; i < 6; i++) {
    final double x = .24 + i * .085;
    for (final double k in sides) {
      p.part(
        turn(oval(x, .60 + k * .1, .05, .03), pt(x, .60 + k * .1), k * .5),
        flap,
        depth: .4,
      );
    }
  }
  for (final double k in sides) {
    p.part(
      turn(leaf(pt(.18, .60), pt(.06, .60 + k * .12), .05), pt(.18, .6), 0),
      flap,
      depth: .4,
    );
  }
  final Path b = union(
    blob(
      <Offset>[
        pt(.14, .60),
        pt(.30, .52),
        pt(.56, .50),
        pt(.70, .54),
        pt(.72, .66),
        pt(.56, .70),
        pt(.30, .68),
      ],
      sharp: <int>{0},
    ),
    circle(.78, .58, .11),
  );
  p.part(
    b,
    body,
    shine: .6,
    marks: () {
      for (double x = .28; x < .64; x += .07) {
        p.line(
          Path()
            ..moveTo(x, .50)
            ..lineTo(x, .70),
          width: .008,
          color: darker(body, .12),
        );
      }
    },
  );
  p.cheeks(.78, .60, .07, .026);
  p.smile(pt(.80, .61), .022);
  // Grasping arms curled under the head.
  for (final double d in <double>[0, .03]) {
    final List<Offset> arm = <Offset>[
      pt(.82, .62 + d),
      pt(.92, .68 + d),
      pt(.92, .78 + d),
      pt(.84, .80 + d),
    ];
    p.part(taper(arm, <double>[.022, .02, .015, .01]), claw);
  }
  // Eyes on stalks.
  for (final double k in sides) {
    p.tube(
      Path()
        ..moveTo(.76 + k * .04, .50)
        ..lineTo(.76 + k * .07, .38),
      .02,
      body,
    );
    p.part(circle(.76 + k * .07, .36, .05), Kit.white, depth: .4);
    p.eye(pt(.76 + k * .07, .365), .034, iris: const Color(0xFF8A2A4A));
  }
  p.face(pt(.69, .365), pt(.83, .365), .034);

  p.head(const Rect.fromLTRB(.67, .31, .89, .69), hatLift: .0);
  p.torso(const Rect.fromLTRB(.14, .5, .72, .7));
  p.collar(pt(.70, .62), .07);
}

// ----------------------------------------------------------------- 4 meganeura

void _meganeura(Pen p) {
  const Color thorax = Color(0xFF3FB88A);
  const Color tail = Color(0xFF4A8AD8);
  const Color wing = Color(0xB3E6F6FF);
  const Color vein = Color(0xFF8AB4D0);
  p.ink = const Color(0xFF10343A);

  for (final double k in sides) {
    for (final List<double> w in <List<double>>[
      <double>[.36, .05],
      <double>[.48, .045],
    ]) {
      final Path path = leaf(
        pt(.5 + k * .04, w[0] + .02),
        pt(.5 + k * .45, w[0] - .04),
        w[1] * 2,
      );
      p.part(
        path,
        wing,
        depth: .3,
        shine: .5,
        marks: () {
          p.line(
            Path()
              ..moveTo(.5 + k * .06, w[0] + .015)
              ..lineTo(.5 + k * .43, w[0] - .035),
            width: .006,
            color: vein,
          );
          for (double t = .25; t < .95; t += .15) {
            final Offset c = Offset.lerp(
              pt(.5 + k * .06, w[0] + .015),
              pt(.5 + k * .43, w[0] - .035),
              t,
            )!;
            p.line(
              Path()
                ..moveTo(c.dx, c.dy - .03)
                ..lineTo(c.dx, c.dy + .03),
              width: .004,
              color: vein,
            );
          }
        },
      );
    }
  }
  final Path abdomen = taper(
    <Offset>[pt(.5, .48), pt(.5, .66), pt(.52, .80), pt(.50, .88)],
    <double>[.04, .034, .028, .02],
  );
  p.part(
    abdomen,
    tail,
    shine: .6,
    marks: () {
      for (double y = .54; y < .88; y += .05) {
        p.line(
          Path()
            ..moveTo(.44, y)
            ..lineTo(.56, y),
          width: .012,
          color: darker(tail, .16),
        );
      }
    },
  );
  p.part(oval(.5, .44, .075, .075), thorax, shine: .6);
  p.part(circle(.5, .30, .11), thorax, shine: 1);
  p.eyes(.5, .29, .05, .05, iris: const Color(0xFF2AA07A));
  p.cheeks(.5, .345, .08, .022);
  p.smile(pt(.5, .345), .016);

  p.head(const Rect.fromLTRB(.39, .19, .61, .41), hatLift: .0);
  p.torso(const Rect.fromLTRB(.43, .37, .57, .88));
  p.collar(pt(.5, .40), .07);
}

// -------------------------------------------------------------- 5 arthropleura

void _arthropleura(Pen p) {
  const Color plate = Color(0xFF6E7EB0);
  const Color band = Color(0xFFA4B2DA);
  const Color leg = Color(0xFFFF9A4A);
  p.ink = const Color(0xFF1A2244);

  final List<Offset> segs = <Offset>[
    pt(.12, .80),
    pt(.20, .83),
    pt(.29, .84),
    pt(.38, .82),
    pt(.46, .77),
    pt(.53, .70),
    pt(.60, .63),
    pt(.67, .57),
  ];
  for (int i = 0; i < segs.length; i++) {
    final Offset c = segs[i];
    for (final double d in <double>[-.025, .02]) {
      p.tube(
        curve(<Offset>[
          pt(c.dx + d, c.dy + .04),
          pt(c.dx + d * 1.6, c.dy + .085),
          pt(c.dx + d * 2.2, c.dy + .1),
        ]),
        .012,
        leg,
        line: p.lw * .55,
      );
    }
  }
  for (int i = 0; i < segs.length; i++) {
    final Offset c = segs[i];
    final double r = .05 + i * .004;
    p.part(
      oval(c.dx, c.dy, r, r * 1.1),
      plate,
      marks: () {
        p.flat(oval(c.dx, c.dy - r * .5, r * .8, r * .35), band);
      },
    );
  }
  for (final double d in <double>[-.04, .04]) {
    p.tube(
      curve(<Offset>[
        pt(.78 + d, .42),
        pt(.80 + d * 2, .32),
        pt(.86 + d * 2, .28),
      ]),
      .012,
      plate,
    );
  }
  p.part(circle(.77, .50, .13), plate, shine: 1);
  p.eyes(.78, .49, .055, .042, iris: const Color(0xFF4A6AB0));
  p.cheeks(.78, .545, .09, .028);
  p.smile(pt(.78, .55), .02);

  p.head(const Rect.fromLTRB(.64, .37, .90, .63), hatLift: .02);
  p.torso(const Rect.fromLTRB(.07, .55, .72, .89));
  p.collar(pt(.68, .60), .09);
}

// -------------------------------------------------------------- 6 ichthyostega

void _ichthyostega(Pen p) {
  const Color skin = Color(0xFF5DB89A);
  const Color belly = Color(0xFFE8F4C8);
  const Color fin = Color(0xFFA8E2C8);
  p.ink = const Color(0xFF103A2C);

  _sprawl(p, .36, .66, darker(skin, .07), lean: .04);
  _sprawl(p, .64, .64, darker(skin, .07), lean: .04);
  _sprawl(p, .28, .67, skin, lean: -.03);
  _sprawl(p, .56, .66, skin, lean: -.03);
  // A fish's finned tail on a four-legged body.
  final Path tailFin = blob(
    <Offset>[
      pt(.08, .62),
      pt(.22, .54),
      pt(.36, .58),
      pt(.36, .70),
      pt(.22, .74),
    ],
    sharp: <int>{0},
  );
  p.part(
    tailFin,
    fin,
    depth: .4,
    marks: () {
      for (double x = .14; x < .34; x += .05) {
        p.line(
          Path()
            ..moveTo(x, .56)
            ..lineTo(x, .72),
          width: .006,
          color: darker(fin, .14),
        );
      }
    },
  );
  final Path body = blob(
    <Offset>[
      pt(.08, .64),
      pt(.30, .60),
      pt(.50, .56),
      pt(.66, .50),
      pt(.82, .50),
      pt(.92, .58),
      pt(.88, .66),
      pt(.70, .72),
      pt(.46, .74),
      pt(.26, .70),
    ],
    sharp: <int>{0},
  );
  p.part(
    body,
    skin,
    shine: 1,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.30, .70),
          pt(.50, .68),
          pt(.72, .66),
          pt(.90, .63),
          pt(.80, .72),
          pt(.50, .76),
        ]),
        belly,
      );
      for (final Offset c in <Offset>[
        pt(.34, .62),
        pt(.44, .60),
        pt(.54, .58),
        pt(.40, .66),
        pt(.60, .62),
      ]) {
        p.flat(circle(c.dx, c.dy, .013), darker(skin, .1));
      }
    },
  );
  _sideEye(p, pt(.76, .52), .045, iris: const Color(0xFF3A8A5A));
  p.blush(pt(.80, .60), .026);
  p.line(
    curve(<Offset>[pt(.80, .63), pt(.86, .635), pt(.91, .615)]),
    width: p.lw * .7,
  );

  p.head(const Rect.fromLTRB(.64, .46, .92, .68), hatLift: .0, hatX: .76);
  p.torso(const Rect.fromLTRB(.08, .5, .92, .76));
  p.collar(pt(.62, .62), .06);
}

// ----------------------------------------------------------------- 7 dimetrodon

void _dimetrodon(Pen p) {
  const Color skin = Color(0xFF8C7CCA);
  const Color belly = Color(0xFFE2DAFA);
  const Color sail = Color(0xFFFF9C6A);
  p.ink = const Color(0xFF241848);

  _sprawl(p, .36, .68, darker(skin, .07), lean: .04);
  _sprawl(p, .62, .68, darker(skin, .07), lean: .04);
  _sprawl(p, .27, .69, skin, lean: -.03);
  _sprawl(p, .54, .69, skin, lean: -.03);
  final Path fan = Path()
    ..moveTo(.22, .64)
    ..cubicTo(.22, .20, .62, .16, .62, .62)
    ..close();
  p.part(
    fan,
    sail,
    shine: .7,
    marks: () {
      for (final double a in <double>[-.9, -.55, -.2, .15, .5, .85]) {
        p.line(
          Path()
            ..moveTo(.42, .64)
            ..lineTo(.42 + math.sin(a) * .26, .64 - math.cos(a) * .46),
          width: .012,
          color: darker(sail, .16),
        );
      }
      p.line(
        curve(<Offset>[pt(.22, .48), pt(.42, .36), pt(.62, .48)]),
        width: .025,
        color: lighter(sail, .08),
      );
    },
  );
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.28, .68), pt(.14, .71), pt(.05, .66)],
      <double>[.05, .03, .01],
    ),
    oval(.45, .67, .25, .095),
    blob(<Offset>[
      pt(.62, .62),
      pt(.74, .52),
      pt(.86, .52),
      pt(.93, .60),
      pt(.90, .67),
      pt(.74, .71),
      pt(.62, .72),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () => p.flat(oval(.50, .745, .26, .04), belly),
  );
  _sideEye(p, pt(.80, .565), .04, iris: const Color(0xFF6A4AB0));
  p.blush(pt(.82, .63), .025);
  p.line(
    curve(<Offset>[pt(.80, .655), pt(.86, .66), pt(.92, .64)]),
    width: p.lw * .7,
  );
  p.fang(pt(.855, .66), .008);

  p.head(const Rect.fromLTRB(.66, .5, .93, .70), hatLift: .0, hatX: .80);
  p.torso(const Rect.fromLTRB(.2, .2, .7, .77));
  p.collar(pt(.66, .64), .06);
}

// -------------------------------------------------------------- 8 compsognathus

void _compsognathus(Pen p) {
  const Color skin = Color(0xFF9CCB5A);
  const Color belly = Color(0xFFF2F6C8);
  const Color stripe = Color(0xFF6A9A3A);
  p.ink = const Color(0xFF223A10);

  _hindLeg(p, pt(.48, .62), darker(skin, .07), s: .75);
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.44, .58), pt(.26, .54), pt(.12, .44), pt(.06, .38)],
      <double>[.06, .04, .02, .008],
    ),
    turn(oval(.50, .58, .13, .09), pt(.50, .58), -.25),
    taper(
      <Offset>[pt(.56, .55), pt(.62, .44), pt(.66, .38)],
      <double>[.05, .04, .04],
    ),
    blob(<Offset>[
      pt(.60, .34),
      pt(.68, .27),
      pt(.78, .29),
      pt(.88, .34),
      pt(.87, .40),
      pt(.74, .43),
      pt(.62, .41),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.55, .64, .1, .045), belly);
      for (final double x in <double>[.16, .24, .32]) {
        p.line(
          Path()
            ..moveTo(x, .42)
            ..lineTo(x + .03, .56),
          width: .012,
          color: stripe,
        );
      }
    },
  );
  p.tube(curve(<Offset>[pt(.60, .60), pt(.65, .64), pt(.67, .62)]), .018, skin);
  _hindLeg(p, pt(.44, .62), skin, s: .8);
  _sideEye(p, pt(.72, .335), .04, iris: const Color(0xFF6A8A2A));
  p.blush(pt(.75, .395), .022);
  p.smile(pt(.81, .385), .03, depth: .3);

  p.head(const Rect.fromLTRB(.6, .27, .88, .43), hatLift: .0, hatX: .72);
  p.torso(const Rect.fromLTRB(.37, .49, .63, .67));
  p.collar(pt(.62, .47), .05);
}

// ---------------------------------------------------------------- 9 microraptor

void _microraptor(Pen p) {
  const Color feather = Color(0xFF3E4E9E);
  const Color sheen = Color(0xFF5AD2E2);
  const Color belly = Color(0xFF8E9CDA);
  p.ink = const Color(0xFF10163A);

  // Four wings: one pair on the arms, one trailing from the legs.
  for (final double d in <double>[.07, 0]) {
    final Path w = blob(
      <Offset>[
        pt(.56 - d, .52),
        pt(.46 - d, .34),
        pt(.36 - d, .18),
        pt(.30 - d, .26),
        pt(.32 - d, .36),
        pt(.28 - d, .40),
        pt(.34 - d, .48),
        pt(.32 - d, .52),
        pt(.44 - d, .58),
      ],
      sharp: <int>{2},
    );
    p.part(
      w,
      d == 0 ? feather : darker(feather, .06),
      shine: .5,
      marks: () {
        p.line(
          curve(<Offset>[pt(.52 - d, .50), pt(.42 - d, .36), pt(.36 - d, .24)]),
          width: .02,
          color: sheen.withValues(alpha: .7),
        );
      },
    );
  }
  for (final double x in <double>[.46, .54]) {
    p.part(
      leaf(pt(x, .70), pt(x - .14, .80), .07),
      darker(feather, .04),
      depth: .4,
    );
    p.tube(
      curve(<Offset>[pt(x, .64), pt(x + .01, .80), pt(x, .87)]),
      .022,
      feather,
    );
    p.part(oval(x + .02, .88, .035, .015), const Color(0xFFFFC23A), depth: .4);
  }
  p.part(
    roundPoly(<Offset>[
      pt(.13, .64),
      pt(.04, .58),
      pt(.02, .64),
      pt(.04, .70),
    ], .012),
    feather,
    marks: () => p.flat(circle(.06, .64, .02), sheen),
  );
  for (final double a in <double>[-.5, -.2]) {
    p.part(
      turn(leaf(pt(.62, .33), pt(.54, .21), .04), pt(.62, .33), a),
      sheen,
      depth: .4,
    );
  }
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.44, .64), pt(.26, .66), pt(.12, .64)],
      <double>[.04, .022, .012],
    ),
    oval(.52, .60, .13, .12),
    taper(<Offset>[pt(.56, .54), pt(.62, .45)], <double>[.06, .06]),
    oval(.66, .40, .12, .1),
  ]);
  p.part(
    animal,
    feather,
    shine: .8,
    marks: () {
      p.flat(oval(.56, .66, .08, .07), belly);
      p.flat(oval(.70, .44, .07, .04), belly);
    },
  );
  p.part(
    blob(<Offset>[pt(.76, .38), pt(.87, .41), pt(.76, .45)], sharp: <int>{1}),
    const Color(0xFF2A3470),
    depth: 0,
  );
  _sideEye(p, pt(.67, .385), .042, iris: sheen, rim: const Color(0xFFE6EAFF));
  p.blush(pt(.70, .44), .022);

  p.head(const Rect.fromLTRB(.54, .30, .78, .50), hatLift: .04, hatX: .66);
  p.torso(const Rect.fromLTRB(.39, .48, .65, .72));
  p.collar(pt(.6, .50), .07);
}

// ------------------------------------------------------------ 10 archaeopteryx

void _archaeopteryx(Pen p) {
  const Color feather = Color(0xFF4E4256);
  const Color tip = Color(0xFFF4EEE6);
  const Color belly = Color(0xFFD8C8B8);
  const Color beak = Color(0xFFF2D8B0);
  p.ink = const Color(0xFF1A121E);

  // A long feathered tail, fringed down both sides of the bone.
  final Path tail = blob(<Offset>[
    pt(.46, .70),
    pt(.34, .76),
    pt(.24, .86),
    pt(.30, .88),
    pt(.40, .84),
    pt(.54, .76),
  ]);
  p.part(
    tail,
    feather,
    marks: () {
      p.line(
        curve(<Offset>[pt(.48, .74), pt(.38, .80), pt(.27, .87)]),
        width: .01,
        color: tip,
      );
    },
  );
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = blob(
      <Offset>[
        q(.12, .50),
        q(.24, .36),
        q(.40, .32),
        q(.44, .40),
        q(.40, .46),
        q(.42, .52),
        q(.34, .56),
        q(.34, .62),
        q(.20, .62),
      ],
      sharp: <int>{2},
    );
    p.part(
      w,
      feather,
      shine: .4,
      marks: () {
        p.flat(
          blob(<Offset>[q(.30, .56), q(.44, .40), q(.46, .54), q(.36, .64)]),
          tip,
        );
      },
    );
    // Clawed fingers at the wrist.
    for (final double d in <double>[0, .03]) {
      p.tube(
        curve(<Offset>[q(.38, .34 + d), q(.42, .30 + d), q(.44, .32 + d)]),
        .01,
        beak,
      );
    }
  }
  birdFoot(p, .44, beak);
  birdFoot(p, .56, beak);
  final Path b = blob(<Offset>[
    pt(.5, .30),
    pt(.62, .34),
    pt(.66, .50),
    pt(.62, .70),
    pt(.5, .78),
    pt(.38, .70),
    pt(.34, .50),
    pt(.38, .34),
  ]);
  p.part(
    b,
    feather,
    shine: .8,
    marks: () => p.flat(oval(.5, .62, .1, .13), belly),
  );
  p.part(oval(.5, .36, .13, .11), feather, shine: 1);
  p.eyes(
    .5,
    .35,
    .06,
    .04,
    iris: const Color(0xFFE0A83A),
    rim: const Color(0xFFF0E8E0),
  );
  // A beak with tiny teeth.
  final Path bill = blob(
    <Offset>[
      pt(.46, .40),
      pt(.54, .40),
      pt(.53, .45),
      pt(.5, .50),
      pt(.47, .45),
    ],
    sharp: <int>{3},
  );
  p.part(bill, beak, shine: .5, line: p.lw * .7);
  p.line(
    Path()
      ..moveTo(.47, .44)
      ..lineTo(.53, .44),
    width: .006,
  );
  p.cheeks(.5, .41, .1, .026);

  p.head(const Rect.fromLTRB(.37, .25, .63, .47), hatLift: .0);
  p.torso(const Rect.fromLTRB(.34, .38, .66, .78));
  p.collar(pt(.5, .49), .1);
}

// ------------------------------------------------------------ 11 protoceratops

void _protoceratops(Pen p) {
  const Color skin = Color(0xFF8FD0A2);
  const Color belly = Color(0xFFE8F6DA);
  const Color frill = Color(0xFFFFD86A);
  const Color beak = Color(0xFF5E8A6A);
  p.ink = const Color(0xFF173A22);

  _stump(p, .32, .66, .075, darker(skin, .07));
  _stump(p, .56, .66, .075, darker(skin, .07));
  _stump(p, .26, .68, .08, skin);
  _stump(p, .50, .68, .08, skin);
  // A short frill and a parrot beak.
  final Path f = blob(<Offset>[
    pt(.56, .56),
    pt(.56, .40),
    pt(.64, .30),
    pt(.74, .32),
    pt(.72, .46),
    pt(.66, .58),
  ]);
  p.part(
    f,
    frill,
    shine: .5,
    marks: () => p.canvas.drawPath(f, strokeOf(darker(frill, .14), .03)),
  );
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.28, .64), pt(.14, .66), pt(.06, .62)],
      <double>[.06, .035, .012],
    ),
    oval(.42, .64, .23, .14),
    blob(<Offset>[
      pt(.64, .46),
      pt(.72, .40),
      pt(.82, .42),
      pt(.90, .50),
      pt(.88, .60),
      pt(.78, .64),
      pt(.62, .66),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.44, .74, .18, .05), belly);
      for (final Offset c in <Offset>[
        pt(.30, .56),
        pt(.40, .53),
        pt(.50, .56),
      ]) {
        p.flat(circle(c.dx, c.dy, .015), darker(skin, .08));
      }
    },
  );
  p.part(
    blob(
      <Offset>[pt(.86, .50), pt(.93, .54), pt(.91, .60), pt(.86, .58)],
      sharp: <int>{1},
    ),
    beak,
    depth: .4,
  );
  _sideEye(p, pt(.76, .49), .042, iris: const Color(0xFF3A8A4A));
  p.blush(pt(.78, .56), .025);
  p.smile(pt(.84, .595), .02);

  p.head(const Rect.fromLTRB(.64, .4, .92, .64), hatLift: .0, hatX: .76);
  p.torso(const Rect.fromLTRB(.19, .5, .65, .78));
  p.collar(pt(.65, .58), .06);
}

// ------------------------------------------------------------ 12 velociraptor

void _velociraptor(Pen p) {
  const Color skin = Color(0xFF5AAAB8);
  const Color belly = Color(0xFFE0F2F2);
  const Color feather = Color(0xFFFF9C4A);
  const Color stripe = Color(0xFF3E8090);
  p.ink = const Color(0xFF0E2E36);

  _hindLeg(p, pt(.46, .62), darker(skin, .07), s: .85);
  p.part(
    roundPoly(<Offset>[
      pt(.10, .48),
      pt(.03, .44),
      pt(.02, .50),
      pt(.06, .53),
    ], .01),
    feather,
  );
  for (final double a in <double>[-.6, -.3]) {
    p.part(
      turn(leaf(pt(.65, .29), pt(.57, .18), .04), pt(.65, .29), a),
      feather,
      depth: .4,
    );
  }
  // A stiff tail held straight out, a slim body and a long snout, all one.
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.42, .58), pt(.24, .52), pt(.08, .48)],
      <double>[.055, .035, .015],
    ),
    turn(oval(.50, .57, .15, .1), pt(.50, .57), -.2),
    taper(
      <Offset>[pt(.58, .52), pt(.63, .42), pt(.66, .36)],
      <double>[.05, .045, .045],
    ),
    blob(<Offset>[
      pt(.60, .32),
      pt(.68, .25),
      pt(.80, .27),
      pt(.92, .34),
      pt(.91, .40),
      pt(.76, .44),
      pt(.62, .42),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.55, .63, .1, .05), belly);
      for (final double x in <double>[.18, .26, .34, .42, .50]) {
        p.line(
          Path()
            ..moveTo(x, .46)
            ..lineTo(x + .02, .58),
          width: .012,
          color: stripe,
        );
      }
    },
  );
  // Feathered arms.
  p.part(leaf(pt(.60, .56), pt(.66, .68), .06), feather, depth: .4);
  p.tube(curve(<Offset>[pt(.62, .56), pt(.67, .64), pt(.70, .63)]), .02, skin);
  _hindLeg(p, pt(.42, .62), skin, s: .9, claw: const Color(0xFFFFF0D8));
  p.part(
    leaf(pt(.40, .86), pt(.42, .78), .03, bend: .01),
    Kit.tooth,
    depth: 0,
    line: p.lw * .5,
  );
  _sideEye(p, pt(.72, .325), .042, iris: const Color(0xFFE0A83A));
  p.blush(pt(.75, .39), .022);
  p.line(
    curve(<Offset>[pt(.77, .40), pt(.84, .405), pt(.91, .385)]),
    width: p.lw * .7,
  );
  _teeth(p, pt(.80, .402), pt(.90, .39), 3, .016);

  p.head(const Rect.fromLTRB(.6, .25, .92, .44), hatLift: .03, hatX: .72);
  p.torso(const Rect.fromLTRB(.35, .47, .65, .67));
  p.collar(pt(.62, .47), .06);
}

// --------------------------------------------------------------- 13 oviraptor

void _oviraptor(Pen p) {
  const Color feather = Color(0xFF9C7CD2);
  const Color belly = Color(0xFFE6DAFA);
  const Color crest = Color(0xFFF25A5A);
  const Color beak = Color(0xFFFFB23A);
  const Color nest = Color(0xFFB98454);
  const Color egg = Color(0xFFBCE6F2);
  p.ink = const Color(0xFF241446);

  // Tail feathers fanning up behind.
  for (final double a in <double>[-.5, -.2, .1]) {
    p.part(
      turn(leaf(pt(.34, .64), pt(.18, .44), .09), pt(.34, .64), a),
      darker(feather, .06),
      depth: .4,
    );
  }
  final Path b = oval(.5, .62, .22, .17);
  p.part(
    b,
    feather,
    shine: .7,
    marks: () => p.flat(oval(.52, .68, .14, .1), belly),
  );
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.5 + k * .14, .58), pt(.5 + k * .30, .72), .1),
        pt(.5 + k * .14, .58),
        0,
      ),
      darker(feather, .03),
    );
  }
  // The nest of eggs it broods.
  for (final Offset e in <Offset>[pt(.36, .76), pt(.5, .78), pt(.64, .76)]) {
    p.part(
      oval(e.dx, e.dy, .055, .065),
      egg,
      shine: 1,
      marks: () {
        p.flat(circle(e.dx + .015, e.dy + .02, .008), darker(egg, .12));
      },
    );
  }
  final Path bowl = Path()
    ..moveTo(.16, .78)
    ..quadraticBezierTo(.5, .84, .84, .78)
    ..quadraticBezierTo(.82, .90, .5, .895)
    ..quadraticBezierTo(.18, .90, .16, .78)
    ..close();
  p.part(
    bowl,
    nest,
    shine: .4,
    marks: () {
      for (double x = .2; x < .82; x += .07) {
        p.line(
          Path()
            ..moveTo(x, .79)
            ..lineTo(x + .06, .87),
          width: .009,
          color: darker(nest, .15),
        );
        p.line(
          Path()
            ..moveTo(x + .06, .79)
            ..lineTo(x, .87),
          width: .009,
          color: lighter(nest, .08),
        );
      }
    },
  );
  // A tall crest and a stubby parrot beak.
  p.part(
    blob(<Offset>[
      pt(.46, .34),
      pt(.47, .20),
      pt(.54, .17),
      pt(.57, .24),
      pt(.56, .34),
    ]),
    crest,
    shine: .6,
  );
  p.part(
    taper(<Offset>[pt(.5, .56), pt(.5, .46)], <double>[.05, .05]),
    feather,
  );
  p.part(oval(.5, .40, .13, .11), feather, shine: 1);
  p.eyes(.5, .39, .06, .04, iris: const Color(0xFFE0A83A));
  p.part(
    blob(
      <Offset>[
        pt(.46, .43),
        pt(.54, .43),
        pt(.535, .47),
        pt(.5, .51),
        pt(.47, .47),
      ],
      sharp: <int>{3},
    ),
    beak,
    shine: .5,
    line: p.lw * .7,
  );
  p.cheeks(.5, .44, .1, .026);

  p.head(const Rect.fromLTRB(.37, .29, .63, .51), hatLift: .1);
  p.torso(const Rect.fromLTRB(.28, .45, .72, .79));
  p.collar(pt(.5, .52), .08);
}

// --------------------------------------------------------- 14 pachycephalosaur

void _pachy(Pen p) {
  const Color skin = Color(0xFF8CBA6A);
  const Color belly = Color(0xFFEAF2CC);
  const Color dome = Color(0xFFF4E4C2);
  p.ink = const Color(0xFF223A14);

  _hindLeg(p, pt(.46, .64), darker(skin, .07));
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.42, .62), pt(.24, .62), pt(.10, .56)],
      <double>[.07, .045, .015],
    ),
    oval(.50, .60, .17, .14),
    taper(<Offset>[pt(.58, .54), pt(.64, .46)], <double>[.07, .07]),
    blob(<Offset>[
      pt(.58, .42),
      pt(.64, .34),
      pt(.78, .34),
      pt(.86, .42),
      pt(.86, .50),
      pt(.76, .54),
      pt(.62, .54),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .6,
    marks: () => p.flat(oval(.55, .66, .11, .08), belly),
  );
  p.tube(curve(<Offset>[pt(.62, .58), pt(.68, .64), pt(.70, .62)]), .022, skin);
  _hindLeg(p, pt(.42, .65), skin);
  // The thick bony dome, ringed with knobs.
  for (final double a in <double>[1.0, 1.25, 1.5, 1.75]) {
    p.part(
      circle(
        .71 + math.cos(math.pi * a) * .14,
        .38 + math.sin(math.pi * a) * .11,
        .02,
      ),
      dome,
      depth: .4,
      line: p.lw * .6,
    );
  }
  p.part(oval(.71, .31, .11, .085), dome, shine: 1.2);
  _sideEye(p, pt(.74, .425), .04, iris: const Color(0xFF6A8A2A));
  p.blush(pt(.77, .48), .024);
  p.smile(pt(.82, .495), .02);

  p.head(const Rect.fromLTRB(.58, .22, .86, .54), hatLift: .0, hatX: .71);
  p.torso(const Rect.fromLTRB(.33, .46, .67, .74));
  p.collar(pt(.62, .53), .07);
}

// --------------------------------------------------------------- 15 gallimimus

void _gallimimus(Pen p) {
  const Color skin = Color(0xFF64C2B4);
  const Color belly = Color(0xFFE6F8F2);
  const Color beak = Color(0xFFF2D8A8);
  p.ink = const Color(0xFF0E3A34);

  // Long ostrich legs, each thigh, shin and foot in one piece.
  for (final List<double> l in <List<double>>[
    <double>[.46, 1],
    <double>[.40, 0],
  ]) {
    final double x = l[0];
    final Color c = l[1] > 0 ? darker(skin, .07) : skin;
    p.part(
      unite(<Path>[
        oval(x, .60, .055, .07),
        taper(
          <Offset>[pt(x + .01, .63), pt(x + .045, .74), pt(x, .865)],
          <double>[.03, .02, .016],
        ),
        oval(x + .025, .878, .045, .018),
      ]),
      c,
      shine: .3,
    );
  }
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.38, .54), pt(.22, .52), pt(.08, .46)],
      <double>[.06, .035, .01],
    ),
    turn(oval(.44, .55, .13, .095), pt(.44, .55), -.15),
    taper(
      <Offset>[pt(.52, .52), pt(.60, .42), pt(.60, .30), pt(.66, .22)],
      <double>[.05, .035, .032, .035],
    ),
    blob(<Offset>[
      pt(.62, .20),
      pt(.68, .15),
      pt(.76, .16),
      pt(.80, .21),
      pt(.76, .25),
      pt(.66, .27),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.47, .60, .09, .045), belly);
      p.flat(
        taper(
          <Offset>[pt(.55, .52), pt(.63, .42), pt(.63, .30)],
          <double>[.02, .016, .014],
        ),
        belly,
      );
    },
  );
  p.tube(curve(<Offset>[pt(.53, .56), pt(.58, .60), pt(.60, .59)]), .016, skin);
  p.part(
    blob(<Offset>[pt(.78, .18), pt(.90, .22), pt(.78, .245)], sharp: <int>{1}),
    beak,
    depth: .4,
  );
  _sideEye(p, pt(.71, .195), .034, iris: const Color(0xFF2A8A7A));
  p.blush(pt(.735, .235), .018);

  p.head(const Rect.fromLTRB(.62, .14, .9, .27), hatLift: .0, hatX: .71);
  p.torso(const Rect.fromLTRB(.31, .46, .57, .64));
  p.collar(pt(.6, .36), .04);
}

// ------------------------------------------------------------ 16 dilophosaurus

void _dilophosaurus(Pen p) {
  const Color skin = Color(0xFF7CBF5A);
  const Color belly = Color(0xFFEFF6CC);
  const Color frill = Color(0xFFFFD24A);
  const Color crest = Color(0xFFF25A4A);
  p.ink = const Color(0xFF1E3A10);

  _hindLeg(p, pt(.44, .64), darker(skin, .07));
  // The famous neck frill, spread wide.
  final Path fr = circle(.66, .42, .19);
  p.part(
    fr,
    frill,
    shine: .5,
    marks: () {
      for (int i = 0; i < 10; i++) {
        final double a = i * math.pi / 5;
        p.line(
          Path()
            ..moveTo(.66, .42)
            ..lineTo(.66 + math.cos(a) * .2, .42 + math.sin(a) * .2),
          width: .016,
          color: crest.withValues(alpha: .8),
        );
      }
      p.canvas.drawCircle(pt(.66, .42), .17, strokeOf(crest, .02));
    },
  );
  // Twin crests.
  for (final double d in <double>[0, .05]) {
    p.part(
      blob(<Offset>[
        pt(.62 + d, .37),
        pt(.64 + d, .26),
        pt(.70 + d, .24),
        pt(.72 + d, .35),
      ]),
      crest,
      depth: .4,
    );
  }
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.40, .60), pt(.22, .60), pt(.08, .54)],
      <double>[.065, .04, .012],
    ),
    oval(.48, .60, .16, .13),
    taper(<Offset>[pt(.56, .55), pt(.63, .45)], <double>[.065, .06]),
    blob(<Offset>[
      pt(.58, .40),
      pt(.64, .33),
      pt(.78, .33),
      pt(.90, .40),
      pt(.88, .47),
      pt(.74, .50),
      pt(.60, .50),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.52, .66, .1, .07), belly);
      for (final double x in <double>[.16, .24, .32]) {
        p.line(
          Path()
            ..moveTo(x, .52)
            ..lineTo(x + .02, .64),
          width: .012,
          color: darker(skin, .12),
        );
      }
    },
  );
  p.tube(curve(<Offset>[pt(.58, .58), pt(.64, .64), pt(.66, .62)]), .02, skin);
  _hindLeg(p, pt(.40, .65), skin);
  _sideEye(p, pt(.72, .39), .04, iris: const Color(0xFFE0A83A));
  p.blush(pt(.75, .45), .022);
  p.smile(pt(.83, .455), .025, depth: .35);

  p.head(const Rect.fromLTRB(.58, .24, .9, .5), hatLift: .04, hatX: .70);
  p.torso(const Rect.fromLTRB(.32, .47, .64, .73));
  p.collar(pt(.6, .52), .06);
}

// ----------------------------------------------------------- 17 parasaurolophus

void _parasaurolophus(Pen p) {
  const Color skin = Color(0xFF5CB2C2);
  const Color belly = Color(0xFFE2F4F6);
  const Color crest = Color(0xFFFF9C4A);
  const Color bill = Color(0xFFF2D8A8);
  p.ink = const Color(0xFF0E3440);

  _stump(p, .34, .64, .075, darker(skin, .07));
  _stump(p, .58, .66, .06, darker(skin, .07));
  _stump(p, .28, .66, .08, skin);
  _stump(p, .52, .68, .065, skin);
  // The long, swept-back tube crest.
  p.part(
    taper(
      <Offset>[pt(.70, .32), pt(.60, .22), pt(.46, .16)],
      <double>[.03, .028, .024],
    ),
    crest,
    shine: .5,
  );
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.30, .60), pt(.14, .60), pt(.04, .54)],
      <double>[.07, .045, .014],
    ),
    turn(oval(.44, .60, .22, .14), pt(.44, .6), -.1),
    taper(
      <Offset>[pt(.58, .54), pt(.64, .44), pt(.68, .38)],
      <double>[.06, .05, .05],
    ),
    blob(<Offset>[
      pt(.62, .34),
      pt(.68, .28),
      pt(.78, .28),
      pt(.88, .34),
      pt(.88, .40),
      pt(.76, .42),
      pt(.64, .42),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.48, .70, .16, .05), belly);
      for (final double x in <double>[.30, .38, .46, .54]) {
        p.line(
          Path()
            ..moveTo(x, .47)
            ..lineTo(x - .01, .58),
          width: .014,
          color: darker(skin, .1),
        );
      }
    },
  );
  p.part(
    blob(<Offset>[pt(.84, .34), pt(.94, .36), pt(.94, .40), pt(.85, .41)]),
    bill,
    depth: .4,
  );
  _sideEye(p, pt(.74, .335), .04, iris: const Color(0xFF2A7A8A));
  p.blush(pt(.77, .39), .022);

  p.head(const Rect.fromLTRB(.62, .27, .94, .42), hatLift: .03, hatX: .74);
  p.torso(const Rect.fromLTRB(.22, .46, .66, .74));
  p.collar(pt(.64, .45), .05);
}

// ---------------------------------------------------------------- 18 stegosaurus

void _stegosaurus(Pen p) {
  const Color skin = Color(0xFF7DC06A);
  const Color belly = Color(0xFFEAF6D2);
  const Color plate = Color(0xFFFF8C5A);
  const Color spike = Color(0xFFFFF0D8);
  p.ink = const Color(0xFF1E3A14);

  _stump(p, .30, .66, .08, darker(skin, .07));
  _stump(p, .60, .68, .07, darker(skin, .07));
  _stump(p, .24, .68, .085, skin);
  _stump(p, .54, .70, .075, skin);
  // Tail spikes — the thagomizer.
  for (final List<double> sp in <List<double>>[
    <double>[.13, -.5],
    <double>[.08, -.9],
    <double>[.13, .5],
    <double>[.08, .9],
  ]) {
    final Offset base = pt(sp[0], .62);
    p.part(
      leaf(
        base,
        base.translate(math.sin(sp[1]) * .08, sp[1] < 0 ? -.1 : .09),
        .03,
      ),
      spike,
      depth: .4,
    );
  }
  // Two staggered rows of back plates rising out from behind the spine.
  final List<List<double>> plates = <List<double>>[
    <double>[.22, .54, .06],
    <double>[.32, .46, .08],
    <double>[.44, .42, .09],
    <double>[.56, .46, .08],
    <double>[.66, .54, .06],
  ];
  for (final List<double> pl in plates) {
    p.part(
      roundPoly(<Offset>[
        pt(pl[0] + .03, pl[1] + .1),
        pt(pl[0] - .04, pl[1] + .04),
        pt(pl[0] + .01, pl[1] - pl[2]),
        pt(pl[0] + .07, pl[1] + .04),
      ], .015),
      darker(plate, .08),
      depth: .4,
    );
  }
  for (final List<double> pl in plates) {
    p.part(
      roundPoly(<Offset>[
        pt(pl[0] - .01, pl[1] + .1),
        pt(pl[0] - .055, pl[1] + .03),
        pt(pl[0] - .02, pl[1] - pl[2] + .02),
        pt(pl[0] + .035, pl[1] + .04),
      ], .015),
      plate,
      depth: .4,
    );
  }
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.26, .66), pt(.14, .63), pt(.05, .60)],
      <double>[.07, .045, .02],
    ),
    blob(<Offset>[
      pt(.16, .66),
      pt(.26, .54),
      pt(.44, .48),
      pt(.62, .54),
      pt(.72, .64),
      pt(.66, .74),
      pt(.44, .78),
      pt(.24, .74),
    ]),
    taper(
      <Offset>[pt(.66, .64), pt(.74, .66), pt(.78, .66)],
      <double>[.06, .05, .05],
    ),
    blob(<Offset>[
      pt(.74, .62),
      pt(.80, .58),
      pt(.90, .60),
      pt(.94, .66),
      pt(.90, .71),
      pt(.76, .71),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .7,
    marks: () => p.flat(oval(.44, .76, .2, .05), belly),
  );
  _sideEye(p, pt(.84, .63), .036, iris: const Color(0xFF6A8A2A));
  p.blush(pt(.87, .68), .02);
  p.smile(pt(.90, .685), .016);

  p.head(const Rect.fromLTRB(.74, .58, .94, .72), hatLift: .0, hatX: .84);
  p.torso(const Rect.fromLTRB(.16, .48, .72, .78));
  p.collar(pt(.74, .66), .05);
}

// --------------------------------------------------------------- 19 ankylosaurus

void _ankylosaurus(Pen p) {
  const Color skin = Color(0xFF8AA2BC);
  const Color armor = Color(0xFF6E86A4);
  const Color knob = Color(0xFFF4E4C2);
  p.ink = const Color(0xFF1A2640);

  _stump(p, .32, .72, .075, darker(skin, .07));
  _stump(p, .62, .72, .07, darker(skin, .07));
  _stump(p, .26, .74, .08, skin);
  _stump(p, .56, .74, .075, skin);
  // The tail club.
  p.part(
    taper(
      <Offset>[pt(.24, .72), pt(.14, .72), pt(.08, .70)],
      <double>[.05, .03, .02],
    ),
    skin,
  );
  p.part(oval(.07, .70, .055, .045), knob, shine: .6);
  // The head tucks in under the front of the armour.
  final Path head = blob(<Offset>[
    pt(.70, .66),
    pt(.80, .60),
    pt(.90, .62),
    pt(.94, .68),
    pt(.90, .74),
    pt(.76, .76),
  ]);
  p.part(head, skin, shine: 1);
  for (final Offset h in <Offset>[pt(.82, .605), pt(.89, .615)]) {
    p.part(
      roundPoly(<Offset>[
        h.translate(-.015, .01),
        h.translate(.0, -.04),
        h.translate(.015, .01),
      ], .006),
      knob,
      depth: .3,
      line: p.lw * .6,
    );
  }
  // A wide armoured back with spikes along the flank.
  for (int i = 0; i < 6; i++) {
    final double x = .22 + i * .09;
    p.part(
      leaf(pt(x, .76), pt(x - .03, .83), .03),
      knob,
      depth: .3,
      line: p.lw * .7,
    );
  }
  final Path shell = Path()
    ..moveTo(.16, .78)
    ..cubicTo(.16, .50, .76, .48, .78, .76)
    ..quadraticBezierTo(.46, .80, .16, .78)
    ..close();
  p.part(
    shell,
    armor,
    shine: .8,
    marks: () {
      for (final List<double> row in <List<double>>[
        <double>[.62, .07],
        <double>[.70, .05],
      ]) {
        for (double x = .24; x < .74; x += .1) {
          p.flat(oval(x + (row[0] == .70 ? .05 : 0), row[0], .03, .022), knob);
        }
      }
      p.flat(oval(.46, .56, .14, .03), lighter(armor, .1));
    },
  );
  _sideEye(p, pt(.85, .655), .036, iris: const Color(0xFF4A6A9A));
  p.blush(pt(.88, .705), .02);
  p.smile(pt(.905, .71), .016);

  p.head(const Rect.fromLTRB(.74, .60, .94, .75), hatLift: .03, hatX: .85);
  p.torso(const Rect.fromLTRB(.16, .52, .78, .79));
  p.collar(pt(.76, .70), .05);
}

// --------------------------------------------------------------- 20 triceratops

void _triceratops(Pen p) {
  const Color skin = Color(0xFF6CBFA2);
  const Color belly = Color(0xFFE6F6EC);
  const Color frill = Color(0xFFFFC25A);
  const Color horn = Color(0xFFFFF4DE);
  const Color beak = Color(0xFF3E7A64);
  p.ink = const Color(0xFF0E3A2C);

  _stump(p, .28, .66, .085, darker(skin, .07));
  _stump(p, .52, .68, .08, darker(skin, .07));
  _stump(p, .22, .68, .09, skin);
  _stump(p, .46, .70, .085, skin);
  final Path animal = union(
    taper(
      <Offset>[pt(.24, .64), pt(.12, .66), pt(.06, .64)],
      <double>[.06, .035, .012],
    ),
    oval(.38, .64, .24, .15),
  );
  p.part(
    animal,
    skin,
    shine: .7,
    marks: () => p.flat(oval(.40, .75, .18, .05), belly),
  );
  // The great frill behind the head.
  final Path f = circle(.62, .46, .22);
  p.part(
    f,
    frill,
    shine: .6,
    marks: () {
      p.canvas.drawCircle(pt(.62, .46), .2, strokeOf(darker(frill, .16), .03));
      for (int i = 0; i < 6; i++) {
        final double a = math.pi * (1.05 + i * .17);
        p.flat(
          circle(.62 + math.cos(a) * .2, .46 + math.sin(a) * .2, .022),
          lighter(frill, .1),
        );
      }
    },
  );
  final Path head = blob(<Offset>[
    pt(.58, .52),
    pt(.66, .42),
    pt(.80, .42),
    pt(.90, .52),
    pt(.92, .62),
    pt(.84, .68),
    pt(.66, .66),
  ]);
  p.part(head, skin, shine: 1);
  p.part(
    blob(
      <Offset>[pt(.88, .54), pt(.96, .60), pt(.92, .66), pt(.88, .63)],
      sharp: <int>{1},
    ),
    beak,
    depth: .4,
  );
  // Two long brow horns and a short nose horn.
  for (final double d in <double>[.05, .0]) {
    p.part(
      blob(
        <Offset>[pt(.70 + d, .46), pt(.80 + d, .30), pt(.76 + d, .47)],
        sharp: <int>{1},
      ),
      d == 0 ? horn : darker(horn, .06),
      shine: .4,
    );
  }
  p.part(
    blob(<Offset>[pt(.86, .52), pt(.90, .44), pt(.89, .53)], sharp: <int>{1}),
    horn,
    depth: .4,
  );
  _sideEye(p, pt(.76, .53), .042, iris: const Color(0xFF2A7A5A));
  p.blush(pt(.80, .60), .025);
  p.smile(pt(.86, .63), .02);

  p.head(const Rect.fromLTRB(.58, .42, .92, .68), hatLift: .08, hatX: .72);
  p.torso(const Rect.fromLTRB(.14, .49, .62, .79));
  p.collar(pt(.62, .64), .06);
}

// ---------------------------------------------------------------- 21 pteranodon

void _pteranodon(Pen p) {
  const Color wing = Color(0xFFA8B6F2);
  const Color body = Color(0xFFFFF2DE);
  const Color crest = Color(0xFFFF7A4A);
  const Color beak = Color(0xFFFFC85A);
  p.ink = const Color(0xFF1E2450);

  // Leathery wings spread wide.
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.06, .44).dx, q(.06, .44).dy)
      ..lineTo(q(.46, .30).dx, q(.46, .30).dy)
      ..quadraticBezierTo(
        q(.36, .46).dx,
        q(.36, .46).dy,
        q(.42, .62).dx,
        q(.42, .62).dy,
      )
      ..quadraticBezierTo(
        q(.24, .56).dx,
        q(.24, .56).dy,
        q(.08, .66).dx,
        q(.08, .66).dy,
      )
      ..close();
    p.part(
      w,
      wing,
      shine: .6,
      marks: () {
        p.line(
          Path()
            ..moveTo(q(.06, .44).dx, q(.06, .44).dy)
            ..lineTo(q(.46, .30).dx, q(.46, .30).dy),
          width: .02,
          color: darker(wing, .14),
        );
      },
    );
  }
  birdFoot(p, .46, beak, size: .8);
  birdFoot(p, .54, beak, size: .8);
  p.part(oval(.5, .62, .085, .17), body, shine: .7);
  // Head in profile: a long beak forward, a long crest back.
  p.part(
    blob(
      <Offset>[
        pt(.48, .30),
        pt(.32, .20),
        pt(.30, .16),
        pt(.40, .18),
        pt(.52, .26),
      ],
      sharp: <int>{2},
    ),
    crest,
    shine: .4,
  );
  p.part(oval(.53, .33, .1, .085), body, shine: 1);
  p.part(
    blob(<Offset>[pt(.58, .30), pt(.86, .36), pt(.60, .38)], sharp: <int>{1}),
    beak,
    shine: .5,
  );
  p.line(
    Path()
      ..moveTo(.60, .345)
      ..lineTo(.80, .36),
    width: .006,
  );
  _sideEye(p, pt(.535, .32), .036, iris: const Color(0xFF4A5AB0));
  p.blush(pt(.53, .37), .02);

  p.head(const Rect.fromLTRB(.43, .245, .63, .415), hatLift: .02, hatX: .52);
  p.torso(const Rect.fromLTRB(.415, .45, .585, .79));
  p.collar(pt(.5, .44), .07);
}

// ----------------------------------------------------------------- 22 plesiosaur

void _plesiosaur(Pen p) {
  const Color skin = Color(0xFF5E92D2);
  const Color belly = Color(0xFFE2EEFA);
  p.ink = const Color(0xFF102850);

  for (final List<Offset> f in <List<Offset>>[
    <Offset>[pt(.30, .66), pt(.18, .80)],
    <Offset>[pt(.52, .68), pt(.44, .84)],
  ]) {
    p.part(leaf(f[0], f[1], .07), darker(skin, .07), depth: .4);
  }
  // Body, swan neck and head in one sweep.
  final List<Offset> neckPts = <Offset>[
    pt(.52, .62),
    pt(.64, .48),
    pt(.68, .36),
    pt(.74, .28),
  ];
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.26, .64), pt(.12, .66), pt(.05, .64)],
      <double>[.05, .03, .01],
    ),
    oval(.40, .64, .2, .11),
    taper(neckPts, <double>[.07, .045, .04, .042]),
    blob(<Offset>[
      pt(.70, .26),
      pt(.76, .21),
      pt(.86, .22),
      pt(.92, .27),
      pt(.88, .31),
      pt(.74, .33),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.42, .71, .16, .045), belly);
      p.flat(
        taper(
          neckPts.map((Offset o) => o.translate(.022, .01)).toList(),
          <double>[.03, .02, .016, .014],
        ),
        belly,
      );
    },
  );
  for (final List<Offset> f in <List<Offset>>[
    <Offset>[pt(.36, .70), pt(.26, .84)],
    <Offset>[pt(.56, .68), pt(.54, .84)],
  ]) {
    p.part(leaf(f[0], f[1], .075), skin, depth: .4);
  }
  _sideEye(p, pt(.79, .25), .034, iris: const Color(0xFF3A6AB0));
  p.blush(pt(.81, .295), .02);
  p.smile(pt(.87, .295), .016);

  p.head(const Rect.fromLTRB(.70, .2, .92, .32), hatLift: .0, hatX: .79);
  p.torso(const Rect.fromLTRB(.2, .53, .6, .75));
  p.collar(pt(.66, .42), .04);
}

// ---------------------------------------------------------------- 23 mosasaurus

void _mosasaurus(Pen p) {
  const Color skin = Color(0xFF3A8EAC);
  const Color belly = Color(0xFFE2F2EC);
  const Color stripe = Color(0xFF2A6A86);
  p.ink = const Color(0xFF0A2A36);

  p.part(leaf(pt(.44, .70), pt(.36, .84), .07), darker(skin, .07), depth: .4);
  // A shark-like tail fluke.
  p.part(
    blob(
      <Offset>[pt(.18, .60), pt(.04, .50), pt(.08, .62), pt(.04, .80)],
      sharp: <int>{1, 3},
    ),
    skin,
  );
  // Body and long crocodile head as one.
  final Path animal = unite(<Path>[
    blob(
      <Offset>[
        pt(.14, .62),
        pt(.30, .56),
        pt(.50, .52),
        pt(.66, .50),
        pt(.74, .58),
        pt(.66, .68),
        pt(.46, .72),
        pt(.28, .68),
      ],
      sharp: <int>{0},
    ),
    blob(<Offset>[
      pt(.60, .52),
      pt(.70, .44),
      pt(.84, .44),
      pt(.96, .52),
      pt(.94, .58),
      pt(.80, .62),
      pt(.62, .64),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.20, .64),
          pt(.46, .64),
          pt(.70, .60),
          pt(.94, .56),
          pt(.84, .62),
          pt(.62, .68),
          pt(.40, .73),
        ]),
        belly,
      );
      for (final double x in <double>[.30, .40, .50, .60]) {
        p.line(
          Path()
            ..moveTo(x, .52)
            ..lineTo(x - .02, .60),
          width: .016,
          color: stripe,
        );
      }
    },
  );
  p.part(leaf(pt(.58, .66), pt(.52, .80), .07), skin, depth: .4);
  p.line(
    curve(<Offset>[pt(.76, .575), pt(.86, .575), pt(.95, .545)]),
    width: p.lw * .7,
  );
  _teeth(p, pt(.78, .575), pt(.94, .55), 5, .018);
  _sideEye(p, pt(.76, .50), .04, iris: const Color(0xFF2A8A9A));
  p.blush(pt(.74, .555), .022);

  p.head(const Rect.fromLTRB(.62, .44, .96, .62), hatLift: .0, hatX: .76);
  p.torso(const Rect.fromLTRB(.14, .5, .74, .73));
  p.collar(pt(.62, .58), .06);
}

// ---------------------------------------------------------------- 24 allosaurus

/// The shared big-theropod build: huge head, little arms, heavy legs, a tail
/// held out for balance.
void _bigTheropod(
  Pen p, {
  required Color skin,
  required Color belly,
  required Color stripe,
  bool longArms = false,
  VoidCallback? headExtras,
  VoidCallback? backExtras,
  Color iris = const Color(0xFFE0A83A),
}) {
  _hindLeg(p, pt(.42, .64), darker(skin, .07), s: 1.15);
  if (backExtras != null) backExtras();
  // Tail, body, neck and that big head, all one shape.
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.38, .58), pt(.20, .58), pt(.05, .50)],
      <double>[.08, .05, .015],
    ),
    turn(oval(.47, .58, .18, .15), pt(.47, .58), -.2),
    taper(<Offset>[pt(.56, .50), pt(.62, .42)], <double>[.09, .09]),
    blob(<Offset>[
      pt(.52, .40),
      pt(.58, .28),
      pt(.72, .24),
      pt(.88, .28),
      pt(.95, .36),
      pt(.94, .46),
      pt(.80, .52),
      pt(.60, .54),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.54, .67, .12, .08), belly);
      p.flat(
        blob(<Offset>[pt(.62, .48), pt(.92, .44), pt(.84, .52), pt(.62, .54)]),
        belly,
      );
      for (final double x in <double>[.12, .20, .28, .38, .46]) {
        p.line(
          Path()
            ..moveTo(x, x < .35 ? .48 : .44)
            ..lineTo(x + .03, x < .35 ? .62 : .56),
          width: .016,
          color: stripe,
        );
      }
    },
  );
  // Arms: three-fingered and useful, or famously tiny.
  if (longArms) {
    p.tube(
      curve(<Offset>[pt(.58, .60), pt(.66, .66), pt(.70, .64)]),
      .028,
      skin,
    );
    for (final double a in <double>[-.4, 0, .4]) {
      p.tube(
        Path()
          ..moveTo(.70, .64)
          ..lineTo(.70 + math.cos(a) * .03, .64 + math.sin(a) * .03 + .01),
        .01,
        Kit.tooth,
      );
    }
  } else {
    p.tube(
      curve(<Offset>[pt(.60, .58), pt(.64, .61), pt(.66, .60)]),
      .022,
      skin,
    );
  }
  _hindLeg(p, pt(.38, .65), skin, s: 1.2);
  if (headExtras != null) headExtras();
  p.line(
    curve(<Offset>[pt(.72, .46), pt(.84, .455), pt(.94, .42)]),
    width: p.lw * .75,
  );
  _teeth(p, pt(.74, .46), pt(.92, .43), 5, .02);
  _sideEye(p, pt(.70, .35), .046, iris: iris);
  p.blush(pt(.72, .42), .026);

  p.head(const Rect.fromLTRB(.52, .24, .95, .52), hatLift: .02, hatX: .70);
  p.torso(const Rect.fromLTRB(.29, .43, .65, .73));
  p.collar(pt(.6, .52), .07);
}

void _allosaurus(Pen p) {
  const Color skin = Color(0xFF7E80C6);
  const Color crest = Color(0xFFF2604A);
  p.ink = const Color(0xFF1C1C48);
  _bigTheropod(
    p,
    skin: skin,
    belly: const Color(0xFFE2E2FA),
    stripe: const Color(0xFF5A5CA0),
    longArms: true,
    headExtras: () {
      // The ridged horns over each eye.
      p.part(
        roundPoly(<Offset>[pt(.64, .30), pt(.68, .21), pt(.74, .29)], .01),
        crest,
        depth: .4,
      );
      p.part(
        roundPoly(<Offset>[pt(.76, .28), pt(.80, .22), pt(.84, .29)], .01),
        crest,
        depth: .4,
      );
    },
  );
}

// ---------------------------------------------------------------- 25 spinosaurus

void _spinosaurus(Pen p) {
  const Color skin = Color(0xFF4AA8A2);
  const Color belly = Color(0xFFE2F4EC);
  const Color sail = Color(0xFFF2604A);
  const Color fish = Color(0xFFC8D4E2);
  p.ink = const Color(0xFF0C3432);

  _hindLeg(p, pt(.42, .66), darker(skin, .07));
  // The tall sail.
  final Path s = Path()
    ..moveTo(.26, .60)
    ..cubicTo(.24, .18, .62, .14, .64, .54)
    ..close();
  p.part(
    s,
    sail,
    shine: .6,
    marks: () {
      for (final double x in <double>[.32, .38, .44, .50, .56]) {
        p.line(
          Path()
            ..moveTo(x, .60)
            ..lineTo(x + (x - .45) * .3, .22),
          width: .012,
          color: darker(sail, .14),
        );
      }
      p.line(
        curve(<Offset>[pt(.26, .44), pt(.44, .30), pt(.62, .42)]),
        width: .025,
        color: const Color(0xFFFFB04A),
      );
    },
  );
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.36, .62), pt(.20, .62), pt(.05, .56)],
      <double>[.075, .05, .02],
    ),
    turn(oval(.47, .60, .18, .13), pt(.47, .6), -.15),
    taper(<Offset>[pt(.56, .54), pt(.62, .46)], <double>[.075, .07]),
    blob(<Offset>[
      pt(.56, .44),
      pt(.62, .36),
      pt(.72, .34),
      pt(.84, .38),
      pt(.97, .42),
      pt(.96, .47),
      pt(.80, .50),
      pt(.62, .54),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.52, .68, .12, .06), belly);
      p.flat(
        blob(<Offset>[pt(.66, .48), pt(.96, .45), pt(.84, .50), pt(.66, .53)]),
        belly,
      );
    },
  );
  _hindLeg(p, pt(.38, .67), skin);
  // A fish, caught.
  p.part(
    roundPoly(<Offset>[pt(.62, .68), pt(.56, .64), pt(.56, .72)], .008),
    fish,
  );
  p.part(oval(.69, .68, .07, .03), fish, shine: .6);
  p.flat(circle(.735, .675, .007), Kit.eyeDark);
  p.tube(curve(<Offset>[pt(.60, .60), pt(.64, .66), pt(.66, .66)]), .024, skin);
  p.tube(curve(<Offset>[pt(.62, .62), pt(.70, .66), pt(.72, .66)]), .022, skin);
  p.line(
    curve(<Offset>[pt(.72, .47), pt(.86, .465), pt(.96, .445)]),
    width: p.lw * .7,
  );
  _teeth(p, pt(.80, .468), pt(.95, .447), 4, .016);
  _sideEye(p, pt(.70, .40), .042, iris: const Color(0xFFE0A83A));
  p.blush(pt(.72, .465), .022);

  p.head(const Rect.fromLTRB(.56, .34, .97, .52), hatLift: .02, hatX: .70);
  p.torso(const Rect.fromLTRB(.3, .47, .64, .73));
  p.collar(pt(.6, .52), .07);
}

// -------------------------------------------------------------- 26 tyrannosaurus

void _tyrannosaurus(Pen p) {
  p.ink = const Color(0xFF173A10);
  _bigTheropod(
    p,
    skin: const Color(0xFF6CB85A),
    belly: const Color(0xFFEFF6CC),
    stripe: const Color(0xFF4A8A3A),
    headExtras: () {
      p.flat(circle(.66, .29, .014), const Color(0xFF4A8A3A));
      p.flat(circle(.72, .27, .011), const Color(0xFF4A8A3A));
    },
  );
}

// -------------------------------------------------------------- 27 brachiosaurus

void _brachiosaurus(Pen p) {
  const Color skin = Color(0xFF7AB8D6);
  const Color belly = Color(0xFFE6F2FA);
  const Color spot = Color(0xFF5E9ABC);
  p.ink = const Color(0xFF12304A);

  _stump(p, .30, .66, .08, darker(skin, .07));
  _stump(p, .56, .62, .085, darker(skin, .07));
  _stump(p, .24, .68, .085, skin);
  _stump(p, .50, .64, .09, skin);
  // Body, a neck reaching up to the treetops, and the head, as one shape.
  final List<Offset> neckPts = <Offset>[
    pt(.58, .58),
    pt(.66, .40),
    pt(.70, .24),
    pt(.74, .16),
  ];
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.26, .66), pt(.12, .70), pt(.04, .66)],
      <double>[.06, .035, .012],
    ),
    blob(<Offset>[
      pt(.18, .68),
      pt(.28, .58),
      pt(.46, .52),
      pt(.62, .52),
      pt(.70, .62),
      pt(.64, .74),
      pt(.40, .78),
      pt(.22, .76),
    ]),
    taper(neckPts, <double>[.09, .06, .05, .05]),
    blob(<Offset>[
      pt(.68, .14),
      pt(.72, .08),
      pt(.80, .08),
      pt(.88, .13),
      pt(.88, .19),
      pt(.76, .21),
      pt(.68, .20),
    ]),
    oval(.75, .085, .04, .025),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.44, .76, .18, .04), belly);
      p.flat(
        taper(
          neckPts.map((Offset o) => o.translate(.03, .01)).toList(),
          <double>[.035, .025, .02, .018],
        ),
        belly,
      );
      for (final Offset c in <Offset>[
        pt(.34, .60),
        pt(.44, .57),
        pt(.54, .58),
        pt(.40, .66),
        pt(.52, .65),
      ]) {
        p.flat(circle(c.dx, c.dy, .018), spot);
      }
    },
  );
  _sideEye(p, pt(.78, .135), .034, iris: const Color(0xFF3A6A9A));
  p.blush(pt(.80, .18), .02);
  p.smile(pt(.85, .18), .015);
  p.part(
    leaf(pt(.88, .18), pt(.96, .24), .03),
    Kit.leafGreen,
    depth: .4,
    line: p.lw * .6,
  );

  p.head(const Rect.fromLTRB(.68, .06, .88, .21), hatLift: .03, hatX: .77);
  p.torso(const Rect.fromLTRB(.18, .52, .70, .78));
  p.collar(pt(.68, .30), .04);
}

// ---------------------------------------------------------------- 28 sabertooth

void _sabertooth(Pen p) {
  const Color fur = Color(0xFFB8A08A);
  const Color pale = Color(0xFFF8EEE2);
  const Color stripe = Color(0xFF8A7058);
  p.ink = const Color(0xFF3A2818);

  p.part(
    circle(.67, .83, .045),
    fur,
    marks: () => p.flat(circle(.70, .81, .025), stripe),
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .17, .30), .055, fur, const Color(0xFFF2C8B8));
  }
  sitBody(
    p,
    fur: fur,
    belly: pale,
    rx: .19,
    ry: .16,
    marks: () {
      for (final double k in sides) {
        p.line(
          Path()
            ..moveTo(.5 + k * .17, .64)
            ..lineTo(.5 + k * .13, .70),
          width: .014,
          color: stripe,
        );
      }
    },
  );
  p.part(
    oval(.5, .43, .23, .19),
    fur,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.line(
          Path()
            ..moveTo(.5 + k * .2, .38)
            ..lineTo(.5 + k * .15, .41),
          width: .014,
          color: stripe,
        );
        p.line(
          Path()
            ..moveTo(.5 + k * .03, .27)
            ..lineTo(.5 + k * .04, .32),
          width: .012,
          color: stripe,
        );
      }
    },
  );
  // The sabres.
  for (final double k in sides) {
    p.part(
      blob(
        <Offset>[
          pt(.5 + k * .03, .53),
          pt(.5 + k * .065, .53),
          pt(.5 + k * .06, .62),
          pt(.5 + k * .045, .67),
          pt(.5 + k * .04, .60),
        ],
        sharp: <int>{3},
      ),
      Kit.tooth,
      shine: .5,
      line: p.lw * .7,
    );
  }
  p.part(
    union(oval(.465, .515, .045, .036), oval(.535, .515, .045, .036)),
    pale,
    depth: 0,
    line: 0,
  );
  p.eyes(.5, .42, .09, .045, iris: const Color(0xFFC8A03A));
  p.cheeks(.5, .48, .15, .03);
  p.nose(pt(.5, .49), .022, color: const Color(0xFF8A5A4A));
  p.catMouth(pt(.5, .525), .02);
  whiskers(p, pt(.5, .52), .07, .1);

  p.head(const Rect.fromLTRB(.27, .24, .73, .62), hatLift: .02);
  p.collar(pt(.5, .62), .14);
}

// ------------------------------------------------------------- 29 woolly mammoth

void _mammoth(Pen p) {
  const Color fur = Color(0xFF9C5E3A);
  const Color tip = Color(0xFFC8844E);
  const Color tusk = Color(0xFFFFF6E2);
  p.ink = const Color(0xFF3A1C0A);

  for (final double x in <double>[.32, .58]) {
    p.part(fluff(x, .78, .06, .1, 7, depth: .1), darker(fur, .07), depth: .4);
    p.flat(oval(x, .885, .05, .015), darker(fur, .2));
  }
  p.part(
    taper(
      <Offset>[pt(.20, .58), pt(.12, .64), pt(.10, .72)],
      <double>[.025, .02, .015],
    ),
    fur,
  );
  // A shaggy domed body with a hump at the shoulders.
  final Path body = fluff(.44, .58, .27, .2, 16, depth: .05);
  p.part(
    body,
    fur,
    shine: .6,
    marks: () {
      for (int i = 0; i < 12; i++) {
        final double x = .22 + (i % 6) * .08, y = .50 + (i ~/ 6) * .14;
        p.line(
          curve(<Offset>[
            pt(x, y),
            pt(x + .01, y + .04),
            pt(x - .005, y + .08),
          ]),
          width: .01,
          color: tip,
        );
      }
    },
  );
  for (final double x in <double>[.26, .52]) {
    p.part(fluff(x, .80, .065, .1, 7, depth: .1), fur, depth: .4);
    p.flat(oval(x, .885, .055, .016), darker(fur, .2));
  }
  p.part(fluff(.66, .42, .17, .17, 11, depth: .06), fur, shine: 1);
  p.part(oval(.58, .42, .06, .08), darker(fur, .05), depth: .4);
  // Long curved tusks sweeping up.
  for (final double d in <double>[.03, 0]) {
    p.part(
      taper(
        <Offset>[
          pt(.72 - d, .54),
          pt(.80 - d, .66),
          pt(.92 - d, .62),
          pt(.94 - d, .52),
        ],
        <double>[.025, .022, .016, .006],
      ),
      d == 0 ? tusk : darker(tusk, .08),
      shine: .5,
    );
  }
  // The trunk.
  p.part(
    taper(
      <Offset>[pt(.74, .48), pt(.78, .62), pt(.76, .76), pt(.80, .82)],
      <double>[.05, .04, .03, .025],
    ),
    fur,
  );
  _sideEye(p, pt(.68, .40), .04, iris: const Color(0xFF8A5A2A));
  p.blush(pt(.70, .46), .024);

  p.head(const Rect.fromLTRB(.49, .25, .83, .59), hatLift: .0, hatX: .64);
  p.torso(const Rect.fromLTRB(.17, .38, .71, .78));
  p.collar(pt(.6, .58), .08);
}

// ---------------------------------------------------------------- 30 titanosaur

void _titanosaur(Pen p) {
  const Color skin = Color(0xFF8C72C2);
  const Color belly = Color(0xFFE6DCF8);
  const Color plate = Color(0xFFFFCF5A);
  p.ink = const Color(0xFF221446);

  _stump(p, .30, .66, .085, darker(skin, .07));
  _stump(p, .56, .66, .085, darker(skin, .07));
  _stump(p, .24, .68, .09, skin);
  _stump(p, .50, .68, .09, skin);
  // Whip tail, body, a long neck stretched forward and the head, as one.
  final List<Offset> neckPts = <Offset>[
    pt(.60, .58),
    pt(.72, .44),
    pt(.80, .34),
    pt(.86, .28),
  ];
  final Path animal = unite(<Path>[
    taper(
      <Offset>[pt(.22, .64), pt(.10, .58), pt(.04, .46), pt(.06, .38)],
      <double>[.06, .04, .02, .008],
    ),
    blob(<Offset>[
      pt(.14, .66),
      pt(.24, .54),
      pt(.44, .48),
      pt(.62, .50),
      pt(.72, .60),
      pt(.66, .74),
      pt(.42, .78),
      pt(.20, .76),
    ]),
    taper(neckPts, <double>[.09, .06, .05, .048]),
    blob(<Offset>[
      pt(.80, .26),
      pt(.84, .20),
      pt(.92, .20),
      pt(.97, .25),
      pt(.95, .31),
      pt(.84, .33),
    ]),
  ]);
  p.part(
    animal,
    skin,
    shine: .8,
    marks: () {
      p.flat(oval(.44, .76, .2, .04), belly);
      p.flat(
        taper(
          neckPts.map((Offset o) => o.translate(.025, .02)).toList(),
          <double>[.035, .025, .02, .018],
        ),
        belly,
      );
      // Armoured bumps down the back and neck.
      for (final Offset c in <Offset>[
        pt(.26, .56),
        pt(.34, .52),
        pt(.43, .50),
        pt(.52, .50),
        pt(.60, .53),
        pt(.38, .60),
        pt(.48, .58),
        pt(.70, .43),
        pt(.78, .33),
      ]) {
        p.part(
          circle(c.dx, c.dy, c.dx > .65 ? .015 : .022),
          plate,
          depth: .4,
          line: p.lw * .5,
        );
      }
    },
  );
  _sideEye(p, pt(.87, .245), .034, iris: const Color(0xFFE0A83A));
  p.blush(pt(.89, .29), .02);
  p.smile(pt(.93, .29), .014);
  p.twinkle(pt(.66, .18), .03, plate);
  p.twinkle(pt(.30, .32), .024, plate);

  p.head(const Rect.fromLTRB(.80, .19, .97, .32), hatLift: .02, hatX: .88);
  p.torso(const Rect.fromLTRB(.14, .48, .72, .78));
  p.collar(pt(.78, .38), .04);
}
