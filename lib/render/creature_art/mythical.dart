import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'creature_art.dart';
import 'kit.dart';
import 'parts.dart';

/// Myth Meadow — folklore and legend, from hedgerow spirits to elder dragons.
const Map<String, CreatureArt> mythicalArt = <String, CreatureArt>{
  'mythical_01': CreatureArt(_wisp, shadow: .18),
  'mythical_02': CreatureArt(_pixie, shadow: .18),
  'mythical_03': CreatureArt(_sporeling, shadow: .26),
  'mythical_04': CreatureArt(_fairy, shadow: .2),
  'mythical_05': CreatureArt(_gnome, shadow: .24),
  'mythical_06': CreatureArt(_imp, shadow: .24),
  'mythical_07': CreatureArt(_jackalope, shadow: .22),
  'mythical_08': CreatureArt(_kitsuneKit, shadow: .28),
  'mythical_09': CreatureArt(_cockatrice, shadow: .26),
  'mythical_10': CreatureArt(_gargoyle, shadow: .3),
  'mythical_11': CreatureArt(_satyr, shadow: .22),
  'mythical_12': CreatureArt(_faun, shadow: .22),
  'mythical_13': CreatureArt(_kelpie, shadow: .3),
  'mythical_14': CreatureArt(_griffinCub, shadow: .26),
  'mythical_15': CreatureArt(_unicornFoal, shadow: .24),
  'mythical_16': CreatureArt(_pegasus, shadow: .3),
  'mythical_17': CreatureArt(_basilisk, shadow: .32),
  'mythical_18': CreatureArt(_chimera, shadow: .28),
  'mythical_19': CreatureArt(_minotaur, shadow: .26),
  'mythical_20': CreatureArt(_sphinx, shadow: .34),
  'mythical_21': CreatureArt(_nineTail, shadow: .28),
  'mythical_22': CreatureArt(_hydra, shadow: .32),
  'mythical_23': CreatureArt(_griffin, shadow: .3),
  'mythical_24': CreatureArt(_unicorn, shadow: .3),
  'mythical_25': CreatureArt(_wyvern, shadow: .28),
  'mythical_26': CreatureArt(_thunderbird, shadow: .28),
  'mythical_27': CreatureArt(_phoenix, shadow: .26),
  'mythical_28': CreatureArt(_leviathan, shadow: .38),
  'mythical_29': CreatureArt(_dragon, shadow: .3),
  'mythical_30': CreatureArt(_elderDragon, shadow: .38),
};

const Color _skin = Color(0xFFFFE2CF);

/// A chibi person's round head with hair, for the hedgerow folk.
void _kidHead(
  Pen p, {
  required Color hair,
  Color skin = _skin,
  double cx = .5,
  double cy = .40,
  double r = .17,
  bool elfEars = false,
  Color iris = const Color(0xFF7A4E3A),
  VoidCallback? fringe,
}) {
  if (elfEars) {
    for (final double k in sides) {
      p.part(
        roundPoly(<Offset>[
          pt(cx + k * r * .8, cy - .01),
          pt(cx + k * (r + .1), cy - .07),
          pt(cx + k * r * .85, cy + .06),
        ], .015),
        skin,
      );
    }
  }
  p.part(circle(cx, cy, r), skin, shine: .6);
  if (fringe != null) {
    fringe();
  } else {
    final Path bangs = Path()
      ..moveTo(cx - r * 1.02, cy + r * .05)
      ..cubicTo(
        cx - r * 1.1,
        cy - r * 1.25,
        cx + r * 1.1,
        cy - r * 1.25,
        cx + r * 1.02,
        cy + r * .05,
      )
      ..quadraticBezierTo(cx + r * .7, cy - r * .5, cx + r * .2, cy - r * .35)
      ..quadraticBezierTo(cx, cy - r * .2, cx - r * .25, cy - r * .4)
      ..quadraticBezierTo(
        cx - r * .7,
        cy - r * .45,
        cx - r * 1.02,
        cy + r * .05,
      )
      ..close();
    p.part(bangs, hair, shine: .8);
  }
  p.eyes(cx, cy + r * .2, r * .45, r * .27, iris: iris);
  p.cheeks(cx, cy + r * .52, r * .7, r * .2);
  p.smile(Offset(cx, cy + r * .5), r * .12);
}

// ---------------------------------------------------------------------- 1 wisp

void _wisp(Pen p) {
  const Color flame = Color(0xFFB8EEFF);
  const Color core = Color(0xFFF2FDFF);
  p.ink = const Color(0xFF235A78);

  p.glow(pt(.5, .58), .36, const Color(0xFF8ADCFF), alpha: .5);
  final Path body = blob(
    <Offset>[
      pt(.57, .12),
      pt(.60, .24),
      pt(.69, .38),
      pt(.73, .55),
      pt(.69, .71),
      pt(.58, .81),
      pt(.5, .83),
      pt(.42, .81),
      pt(.31, .71),
      pt(.27, .55),
      pt(.32, .40),
      pt(.42, .30),
      pt(.50, .24),
    ],
    sharp: <int>{0},
  );
  p.part(
    body,
    flame,
    shine: 1,
    marks: () {
      p.flat(
        blob(
          <Offset>[
            pt(.53, .34),
            pt(.62, .50),
            pt(.62, .66),
            pt(.5, .74),
            pt(.38, .66),
            pt(.38, .52),
            pt(.46, .42),
          ],
          sharp: <int>{0},
        ),
        core,
      );
    },
  );
  p.eye(pt(.43, .59), .04, look: Eye.happy);
  p.eye(pt(.57, .59), .04, look: Eye.happy);
  p.face(pt(.43, .59), pt(.57, .59), .04);
  p.cheeks(.5, .64, .11, .03);
  p.smile(pt(.5, .645), .02);
  p.twinkle(pt(.22, .32), .03, const Color(0xFFDFF8FF));
  p.twinkle(pt(.80, .40), .022, const Color(0xFFDFF8FF));
  p.twinkle(pt(.76, .80), .016, const Color(0xFFDFF8FF));

  p.head(const Rect.fromLTRB(.27, .30, .73, .83), hatLift: .0);
  p.torso(const Rect.fromLTRB(.27, .30, .73, .83));
  p.collar(pt(.5, .74), .16);
}

// --------------------------------------------------------------------- 2 pixie

void _pixie(Pen p) {
  const Color hair = Color(0xFF6FD6A8);
  const Color dress = Color(0xFF8ED36A);
  const Color wing = Color(0xCCE4FFF2);
  p.ink = const Color(0xFF2A4A30);

  for (final double k in sides) {
    p.part(
      turn(oval(.5 + k * .17, .50, .15, .05), pt(.5 + k * .06, .55), k * -.5),
      wing,
      depth: .3,
      shine: .5,
    );
    p.part(
      turn(oval(.5 + k * .15, .62, .12, .04), pt(.5 + k * .06, .6), k * .25),
      wing,
      depth: .3,
    );
  }
  for (final double k in sides) {
    p.tube(
      Path()
        ..moveTo(.5 + k * .04, .74)
        ..lineTo(.5 + k * .05, .85),
      .03,
      _skin,
    );
    p.part(
      roundPoly(<Offset>[
        pt(.5 + k * .035, .84),
        pt(.5 + k * .085, .84),
        pt(.5 + k * .12, .87),
        pt(.5 + k * .09, .895),
        pt(.5 + k * .035, .895),
      ], .01),
      dress,
    );
  }
  // A dress of pointed leaves.
  final Path skirt = Path()..moveTo(.42, .56);
  skirt.lineTo(.58, .56);
  skirt.quadraticBezierTo(.64, .66, .66, .76);
  for (int i = 0; i < 4; i++) {
    final double x0 = .66 - i * .08;
    skirt.quadraticBezierTo(x0 - .02, .70, x0 - .04, .78);
    skirt.quadraticBezierTo(x0 - .06, .72, x0 - .08, .76);
  }
  skirt.quadraticBezierTo(.36, .66, .42, .56);
  skirt.close();
  p.part(
    skirt,
    dress,
    shine: .5,
    marks: () {
      p.line(
        Path()
          ..moveTo(.5, .58)
          ..lineTo(.5, .74),
        width: .008,
        color: darker(dress, .15),
      );
    },
  );
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .07, .59),
        pt(.5 + k * .11, .65),
        pt(.5 + k * .1, .7),
      ]),
      .028,
      _skin,
    );
  }
  _kidHead(
    p,
    hair: hair,
    elfEars: true,
    cy: .40,
    iris: const Color(0xFF3A9A6A),
  );
  // A leaf cap.
  final Path cap = turn(
    leaf(pt(.40, .26), pt(.64, .14), .12, bend: .02),
    pt(.5, .22),
    0,
  );
  p.part(cap, dress, shine: .6);
  p.tube(
    curve(<Offset>[pt(.64, .14), pt(.68, .11), pt(.70, .13)]),
    .01,
    darker(dress, .2),
  );
  p.twinkle(pt(.20, .30), .025, const Color(0xFFE8FFD8));
  p.twinkle(pt(.82, .70), .02, const Color(0xFFE8FFD8));

  p.head(const Rect.fromLTRB(.33, .23, .67, .57), hatLift: .04);
  p.torso(const Rect.fromLTRB(.34, .56, .66, .80));
  p.collar(pt(.5, .57), .07);
}

// ----------------------------------------------------------------- 3 sporeling

void _sporeling(Pen p) {
  const Color cap = Color(0xFFF0584A);
  const Color stem = Color(0xFFFFF1DC);
  const Color gill = Color(0xFFF2D6C0);
  p.ink = const Color(0xFF5A1A14);

  for (final double k in sides) {
    p.part(oval(.5 + k * .08, .88, .055, .03), darker(stem, .08), depth: .5);
  }
  final Path body = blob(<Offset>[
    pt(.5, .46),
    pt(.64, .48),
    pt(.68, .64),
    pt(.66, .80),
    pt(.58, .87),
    pt(.5, .875),
    pt(.42, .87),
    pt(.34, .80),
    pt(.32, .64),
    pt(.36, .48),
  ]);
  p.part(body, stem, shine: .7);
  for (final double k in sides) {
    p.part(oval(.5 + k * .19, .70, .04, .035), stem, depth: .4);
  }
  p.eyes(.5, .64, .07, .042);
  p.cheeks(.5, .70, .12, .03);
  p.smile(pt(.5, .705), .018);
  // The cap, with the gills showing underneath.
  p.part(
    oval(.5, .47, .29, .06),
    gill,
    depth: 0,
    marks: () {
      for (double x = .26; x < .76; x += .04) {
        p.line(
          Path()
            ..moveTo(.5, .47)
            ..lineTo(x, .53),
          width: .006,
          color: darker(gill, .12),
        );
      }
    },
  );
  final Path dome = Path()
    ..moveTo(.17, .48)
    ..cubicTo(.14, .10, .86, .10, .83, .48)
    ..quadraticBezierTo(.5, .40, .17, .48)
    ..close();
  p.part(
    dome,
    cap,
    shine: 1.2,
    marks: () {
      for (final List<double> d in <List<double>>[
        <double>[.34, .30, .045],
        <double>[.54, .22, .055],
        <double>[.68, .34, .04],
        <double>[.44, .40, .03],
        <double>[.24, .42, .025],
      ]) {
        p.flat(oval(d[0], d[1], d[2], d[2] * .85), Kit.white);
      }
    },
  );

  p.head(const Rect.fromLTRB(.17, .19, .83, .48), hatLift: .0);
  p.torso(const Rect.fromLTRB(.32, .46, .68, .875));
  p.collar(pt(.5, .76), .14);
}

// --------------------------------------------------------------------- 4 fairy

void _fairy(Pen p) {
  const Color hair = Color(0xFFFFCF6E);
  const Color dress = Color(0xFFFF9CC8);
  const Color wing = Color(0xCCF2E2FF);
  const Color wingEdge = Color(0xFFC9A8F2);
  p.ink = const Color(0xFF5A2A4A);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    p.part(
      blob(<Offset>[
        q(.06, .52),
        q(.20, .30),
        q(.38, .26),
        q(.42, .38),
        q(.30, .52),
      ]),
      wing,
      depth: .3,
      shine: .6,
      marks: () {
        p.canvas.drawPath(
          blob(<Offset>[
            q(.06, .52),
            q(.20, .30),
            q(.38, .26),
            q(.42, .38),
            q(.30, .52),
          ]),
          strokeOf(wingEdge, .025),
        );
      },
    );
    p.part(
      blob(<Offset>[q(.06, .56), q(.28, .58), q(.32, .70), q(.20, .74)]),
      wing,
      depth: .3,
      marks: () {
        p.canvas.drawPath(
          blob(<Offset>[q(.06, .56), q(.28, .58), q(.32, .70), q(.20, .74)]),
          strokeOf(wingEdge, .02),
        );
      },
    );
  }
  // Long hair falling behind.
  p.part(
    blob(<Offset>[
      pt(.32, .38),
      pt(.5, .22),
      pt(.68, .38),
      pt(.70, .58),
      pt(.62, .64),
      pt(.38, .64),
      pt(.30, .58),
    ]),
    hair,
  );
  for (final double k in sides) {
    p.tube(
      Path()
        ..moveTo(.5 + k * .035, .76)
        ..lineTo(.5 + k * .04, .86),
      .028,
      _skin,
    );
    p.part(oval(.5 + k * .05, .88, .035, .02), dress, depth: .4);
  }
  final Path gown = Path()
    ..moveTo(.44, .55)
    ..lineTo(.56, .55)
    ..quadraticBezierTo(.62, .64, .68, .78)
    ..quadraticBezierTo(.64, .74, .60, .79)
    ..quadraticBezierTo(.55, .75, .5, .80)
    ..quadraticBezierTo(.45, .75, .40, .79)
    ..quadraticBezierTo(.36, .74, .32, .78)
    ..quadraticBezierTo(.38, .64, .44, .55)
    ..close();
  p.part(
    gown,
    dress,
    shine: .6,
    marks: () => p.flat(rrect(.4, .55, .6, .6, .01), lighter(dress, .08)),
  );
  p.tube(
    curve(<Offset>[pt(.44, .59), pt(.39, .65), pt(.40, .70)]),
    .028,
    _skin,
  );
  // A star wand.
  p.tube(
    Path()
      ..moveTo(.61, .68)
      ..lineTo(.74, .48),
    .014,
    const Color(0xFFF2D7A0),
  );
  p.glow(pt(.75, .46), .07, Kit.gold, alpha: .6);
  p.part(star(.75, .46, .05, round: .008), Kit.gold, shine: .8);
  p.tube(
    curve(<Offset>[pt(.56, .59), pt(.61, .64), pt(.62, .68)]),
    .028,
    _skin,
  );
  _kidHead(p, hair: hair, cy: .40, iris: const Color(0xFF8A5AC0));
  // Flower crown.
  for (final List<double> f in <List<double>>[
    <double>[.38, .29],
    <double>[.5, .245],
    <double>[.62, .29],
  ]) {
    for (int i = 0; i < 5; i++) {
      final double a = i * math.pi * 2 / 5;
      p.flat(
        circle(f[0] + math.cos(a) * .017, f[1] + math.sin(a) * .017, .014),
        Kit.white,
      );
    }
    p.flat(circle(f[0], f[1], .01), const Color(0xFFFF8FB8));
  }

  p.head(const Rect.fromLTRB(.33, .23, .67, .57), hatLift: .02);
  p.torso(const Rect.fromLTRB(.34, .55, .66, .80));
  p.collar(pt(.5, .56), .07);
}

// --------------------------------------------------------------------- 5 gnome

void _gnome(Pen p) {
  const Color hat = Color(0xFFE5483E);
  const Color tunic = Color(0xFF5A8FD8);
  const Color beard = Color(0xFFFFFDF8);
  const Color boot = Color(0xFF7A4E2E);
  p.ink = const Color(0xFF3A1E14);

  for (final double k in sides) {
    p.part(oval(.5 + k * .08, .875, .065, .035), boot, depth: .5);
  }
  final Path body = blob(<Offset>[
    pt(.5, .56),
    pt(.64, .60),
    pt(.70, .76),
    pt(.66, .86),
    pt(.5, .875),
    pt(.34, .86),
    pt(.30, .76),
    pt(.36, .60),
  ]);
  p.part(
    body,
    tunic,
    shine: .5,
    marks: () {
      p.flat(rrect(.30, .76, .70, .80, .01), const Color(0xFF5A3A24));
      p.flat(rrect(.47, .755, .53, .805, .006), Kit.gold);
    },
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .19, .72, .045, .04), _skin, depth: .4);
  }
  p.part(circle(.5, .44, .15), _skin, shine: .5);
  // The beard, big and fluffy.
  p.part(fluff(.5, .58, .15, .12, 9, depth: .1), beard, shine: .5);
  p.part(oval(.5, .49, .1, .035), beard, depth: .3, line: p.lw * .7);
  p.eyes(.5, .42, .065, .036);
  p.cheeks(.5, .47, .1, .03);
  p.part(circle(.5, .47, .04), const Color(0xFFFFA8A0), shine: 1, depth: .5);
  // The tall pointed hat.
  final Path cone = blob(
    <Offset>[
      pt(.32, .39),
      pt(.40, .22),
      pt(.52, .08),
      pt(.66, .10),
      pt(.60, .20),
      pt(.66, .38),
      pt(.5, .40),
    ],
    sharp: <int>{0, 3, 5},
  );
  p.part(cone, hat, shine: .8);

  p.head(const Rect.fromLTRB(.35, .30, .65, .59), hatLift: .2);
  p.torso(const Rect.fromLTRB(.3, .56, .7, .875));
  p.collar(pt(.5, .62), .12);
}

// ----------------------------------------------------------------------- 6 imp

void _imp(Pen p) {
  const Color skin = Color(0xFFE85E6A);
  const Color belly = Color(0xFFFFB0A8);
  const Color horn = Color(0xFF4A3048);
  const Color wing = Color(0xFF9A3A58);
  p.ink = const Color(0xFF3A0E1A);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.12, .56).dx, q(.12, .56).dy)
      ..quadraticBezierTo(
        q(.26, .40).dx,
        q(.26, .40).dy,
        q(.38, .40).dx,
        q(.38, .40).dy,
      )
      ..quadraticBezierTo(
        q(.36, .48).dx,
        q(.36, .48).dy,
        q(.38, .56).dx,
        q(.38, .56).dy,
      )
      ..quadraticBezierTo(
        q(.32, .53).dx,
        q(.32, .53).dy,
        q(.28, .60).dx,
        q(.28, .60).dy,
      )
      ..quadraticBezierTo(
        q(.22, .56).dx,
        q(.22, .56).dy,
        q(.16, .64).dx,
        q(.16, .64).dy,
      )
      ..close();
    p.part(w, wing, shine: .4);
  }
  p.tube(
    curve(<Offset>[pt(.62, .82), pt(.78, .84), pt(.84, .72), pt(.80, .62)]),
    .02,
    skin,
  );
  p.part(
    roundPoly(<Offset>[
      pt(.80, .64),
      pt(.74, .58),
      pt(.80, .52),
      pt(.86, .58),
    ], .012),
    skin,
  );
  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .1, .29), pt(.5 + k * .17, .14), .055, bend: k * .02),
      horn,
      depth: .5,
    );
  }
  for (final double k in sides) {
    p.part(
      roundPoly(<Offset>[
        pt(.5 + k * .17, .40),
        pt(.5 + k * .3, .34),
        pt(.5 + k * .19, .48),
      ], .02),
      skin,
    );
  }
  sitBody(p, fur: skin, belly: belly, rx: .15, ry: .15, cy: .74);
  p.part(oval(.5, .43, .2, .17), skin, shine: 1);
  p.eyes(.5, .43, .08, .046, iris: const Color(0xFFFFC94A));
  p.cheeks(.5, .49, .13, .03);
  p.grin(pt(.5, .50), .045, .055, fangs: true);

  p.head(const Rect.fromLTRB(.3, .26, .7, .60), hatLift: .05);
  p.collar(pt(.5, .60), .12);
}

// ----------------------------------------------------------------- 7 jackalope

void _jackalope(Pen p) {
  const Color fur = Color(0xFFCDA57E);
  const Color belly = Color(0xFFFFF4E4);
  const Color inner = Color(0xFFFFC2C0);
  const Color antler = Color(0xFFF2E2C4);
  p.ink = const Color(0xFF4A2E18);

  // Little antlers between the ears.
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    p.tube(
      curve(<Offset>[q(.06, .28), q(.12, .18), q(.20, .14)]),
      .022,
      antler,
    );
    p.tube(curve(<Offset>[q(.11, .20), q(.10, .12)]), .018, antler);
    p.tube(curve(<Offset>[q(.165, .155), q(.19, .09)]), .016, antler);
  }
  p.part(fluff(.685, .80, .045, .04, 7, depth: .18), belly);
  for (final double k in sides) {
    final Path ear = turn(
      leaf(pt(.5 + k * .1, .32), pt(.5 + k * .2, .08), .1),
      pt(.5 + k * .1, .32),
      k * .2,
    );
    p.part(
      ear,
      fur,
      shine: .4,
      marks: () => p.flat(
        turn(
          leaf(pt(.5 + k * .1, .30), pt(.5 + k * .19, .12), .05),
          pt(.5 + k * .1, .32),
          k * .2,
        ),
        inner,
      ),
    );
  }
  sitBody(p, fur: fur, belly: belly, rx: .16, ry: .15, cy: .74, footW: .072);
  p.part(
    oval(.5, .45, .215, .185),
    fur,
    shine: 1,
    marks: () => p.flat(oval(.5, .54, .1, .07), belly),
  );
  p.eyes(.5, .45, .088, .047);
  p.cheeks(.5, .51, .14, .034);
  p.nose(pt(.5, .515), .018, color: Kit.nosePink);
  p.catMouth(pt(.5, .54), .018);

  p.head(const Rect.fromLTRB(.285, .265, .715, .635), hatLift: .04);
  p.collar(pt(.5, .63), .12);
}

// --------------------------------------------------------------- 8 kitsune kit

void _kitsuneKit(Pen p) {
  const Color fur = Color(0xFFFFFCF8);
  const Color red = Color(0xFFE8503A);
  const Color fire = Color(0xFF7AC8FF);
  p.ink = const Color(0xFF4A2030);

  for (final double a in <double>[-.35, .25]) {
    final Path tail = turn(
      puffs(
        <Offset>[pt(.58, .84), pt(.74, .78), pt(.84, .62), pt(.82, .46)],
        <double>[.045, .06, .065, .05],
      ),
      pt(.58, .84),
      a,
    );
    final Offset tip = turn(
      Path()..addOval(Rect.fromCircle(center: pt(.82, .46), radius: .001)),
      pt(.58, .84),
      a,
    ).getBounds().center;
    p.part(
      tail,
      fur,
      shine: .4,
      marks: () => p.flat(circle(tip.dx, tip.dy, .055), red),
    );
  }
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .155, .30),
      pt(.5 + k * .225, .12),
      .15,
      fur,
      const Color(0xFFFFD6D0),
      round: .03,
      tipColor: red,
    );
  }
  sitBody(p, fur: fur, belly: Kit.white, rx: .16, ry: .155);
  // A red rope collar with a little bell.
  p.tube(curve(<Offset>[pt(.38, .61), pt(.5, .64), pt(.62, .61)]), .022, red);
  p.part(circle(.5, .66, .03), Kit.gold, shine: 1);
  final Path head = sym(
    <Offset>[
      pt(.5, .25),
      pt(.64, .265),
      pt(.72, .34),
      pt(.75, .45),
      pt(.77, .53),
      pt(.66, .585),
      pt(.5, .62),
    ],
    sharp: <int>{4},
  );
  p.part(
    head,
    fur,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(leaf(pt(.5 + k * .04, .34), pt(.5 + k * .13, .32), .025), red);
        p.line(
          curve(<Offset>[
            pt(.5 + k * .16, .48),
            pt(.5 + k * .2, .50),
            pt(.5 + k * .24, .49),
          ]),
          width: .012,
          color: red,
        );
      }
      p.flat(tear(.5, .29, .012, angle: math.pi, length: 2.2), red);
    },
  );
  p.eyes(.5, .43, .09, .046, iris: const Color(0xFFE88A3A));
  p.cheeks(.5, .5, .15, .03);
  p.nose(pt(.5, .5), .02);
  p.catMouth(pt(.5, .53), .018);
  // A drifting foxfire.
  p.glow(pt(.18, .40), .08, fire, alpha: .7);
  p.part(
    tear(.18, .42, .03, length: 2.3, angle: .3),
    const Color(0xFFBFE6FF),
    depth: .3,
    line: p.lw * .6,
  );

  p.head(const Rect.fromLTRB(.25, .25, .75, .62), hatLift: .02);
  p.collar(pt(.5, .62), .13);
}

// ---------------------------------------------------------------- 9 cockatrice

void _cockatrice(Pen p) {
  const Color feather = Color(0xFFFFF6E6);
  const Color scale = Color(0xFF72C46A);
  const Color comb = Color(0xFFF04A4A);
  const Color beak = Color(0xFFFFB23A);
  p.ink = const Color(0xFF3A2A14);

  // A lizard's tail where a rooster's plume should be.
  final Path tail = taper(
    <Offset>[
      pt(.40, .78),
      pt(.22, .76),
      pt(.14, .62),
      pt(.18, .48),
      pt(.26, .44),
    ],
    <double>[.06, .05, .035, .022, .014],
  );
  p.part(
    tail,
    scale,
    shine: .4,
    marks: () {
      for (final Offset c in <Offset>[
        pt(.26, .76),
        pt(.17, .66),
        pt(.17, .55),
      ]) {
        p.flat(circle(c.dx, c.dy, .012), lighter(scale, .1));
      }
    },
  );
  p.part(
    roundPoly(<Offset>[pt(.26, .46), pt(.20, .38), pt(.32, .40)], .01),
    scale,
  );
  birdFoot(p, .44, beak);
  birdFoot(p, .58, beak);
  final Path body = oval(.52, .66, .21, .2);
  p.part(
    body,
    feather,
    shine: .6,
    marks: () => p.flat(oval(.54, .74, .14, .1), lighter(feather, .03)),
  );
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.52 + k * .17, .60), pt(.52 + k * .28, .72), .09),
        pt(.52 + k * .17, .6),
        0,
      ),
      lighter(scale, .05),
    );
  }
  // Comb.
  p.part(
    blob(
      <Offset>[
        pt(.44, .30),
        pt(.44, .22),
        pt(.49, .24),
        pt(.52, .17),
        pt(.56, .23),
        pt(.61, .21),
        pt(.61, .30),
      ],
      sharp: <int>{1, 3, 5},
    ),
    comb,
    depth: .5,
  );
  p.part(circle(.53, .42, .14), feather, shine: 1);
  p.eyes(.53, .41, .065, .042);
  p.cheeks(.53, .47, .1, .03);
  p.part(
    roundPoly(<Offset>[pt(.505, .45), pt(.555, .45), pt(.53, .50)], .01),
    beak,
    depth: .4,
    line: p.lw * .6,
  );
  p.part(oval(.53, .525, .02, .026), comb, depth: .4, line: p.lw * .6);

  p.head(const Rect.fromLTRB(.39, .28, .67, .56), hatLift: .06);
  p.torso(const Rect.fromLTRB(.31, .46, .73, .86));
  p.collar(pt(.53, .56), .11);
}

// ---------------------------------------------------------------- 10 gargoyle

void _gargoyle(Pen p) {
  const Color stone = Color(0xFF9C9CB2);
  const Color dark = Color(0xFF6E6E86);
  const Color block = Color(0xFFB8B4C6);
  p.ink = const Color(0xFF26263A);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.14, .56).dx, q(.14, .56).dy)
      ..quadraticBezierTo(
        q(.26, .26).dx,
        q(.26, .26).dy,
        q(.40, .22).dx,
        q(.40, .22).dy,
      )
      ..quadraticBezierTo(
        q(.40, .34).dx,
        q(.40, .34).dy,
        q(.44, .44).dx,
        q(.44, .44).dy,
      )
      ..quadraticBezierTo(
        q(.38, .42).dx,
        q(.38, .42).dy,
        q(.36, .50).dx,
        q(.36, .50).dy,
      )
      ..quadraticBezierTo(
        q(.30, .46).dx,
        q(.30, .46).dy,
        q(.26, .56).dx,
        q(.26, .56).dy,
      )
      ..close();
    p.part(w, dark, shine: .3);
  }
  // The pedestal it squats on.
  p.part(
    rrect(.24, .76, .76, .895, .02),
    block,
    marks: () {
      p.line(
        Path()
          ..moveTo(.24, .80)
          ..lineTo(.76, .80),
        width: .01,
        color: darker(block, .1),
      );
      p.line(
        Path()
          ..moveTo(.40, .84)
          ..lineTo(.43, .87)
          ..lineTo(.41, .89),
        width: .008,
        color: darker(block, .2),
      );
    },
  );
  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .09, .28), pt(.5 + k * .15, .14), .05, bend: k * .02),
      dark,
      depth: .5,
    );
    p.part(
      roundPoly(<Offset>[
        pt(.5 + k * .17, .38),
        pt(.5 + k * .28, .28),
        pt(.5 + k * .2, .45),
      ], .02),
      stone,
    );
  }
  final Path body = oval(.5, .64, .17, .14);
  p.part(
    body,
    stone,
    shine: .5,
    marks: () => p.flat(oval(.5, .68, .1, .08), lighter(stone, .06)),
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .12, .76, .06, .045), stone, depth: .5);
    p.part(oval(.5 + k * .06, .72, .035, .05), stone, depth: .5);
  }
  p.part(
    oval(.5, .42, .2, .16),
    stone,
    shine: .8,
    marks: () {
      p.line(
        Path()
          ..moveTo(.60, .30)
          ..lineTo(.62, .34)
          ..lineTo(.60, .37),
        width: .007,
        color: darker(stone, .15),
      );
    },
  );
  p.eyes(
    .5,
    .42,
    .08,
    .044,
    iris: const Color(0xFFFFB23A),
    rim: lighter(stone, .15),
  );
  p.cheeks(.5, .48, .13, .03);
  p.grin(pt(.5, .485), .04, .045, fangs: true);

  p.head(const Rect.fromLTRB(.3, .26, .7, .58), hatLift: .05);
  p.torso(const Rect.fromLTRB(.33, .5, .67, .78));
  p.collar(pt(.5, .57), .12);
}

// ------------------------------------------------------------------- 11 satyr

void _satyr(Pen p) {
  const Color hair = Color(0xFF6A4026);
  const Color fur = Color(0xFF9A6A48);
  const Color horn = Color(0xFFE8DCC6);
  const Color sash = Color(0xFF7FBF5A);
  p.ink = const Color(0xFF3A2010);

  // Goat legs with hooves.
  for (final double k in sides) {
    p.part(
      blob(<Offset>[
        pt(.5 + k * .02, .66),
        pt(.5 + k * .13, .67),
        pt(.5 + k * .12, .76),
        pt(.5 + k * .1, .86),
        pt(.5 + k * .04, .86),
        pt(.5 + k * .05, .76),
      ]),
      fur,
    );
    p.part(
      rrect(.5 + k * .07 - .035, .845, .5 + k * .07 + .035, .895, .012),
      const Color(0xFF3A2A22),
      depth: .4,
    );
  }
  final Path hips = fluff(.5, .66, .13, .05, 8, depth: .2);
  p.part(hips, fur);
  final Path chest = rrect(.39, .52, .61, .67, .06);
  p.part(
    chest,
    _skin,
    shine: .4,
    marks: () {
      p.line(
        Path()
          ..moveTo(.40, .53)
          ..lineTo(.60, .64),
        width: .03,
        color: sash,
      );
    },
  );
  // Pan pipes held up in both hands.
  final List<double> lens = <double>[.15, .13, .11, .09];
  for (int i = 0; i < 4; i++) {
    final double x = .57 + i * .034;
    p.part(
      rrect(x, .48, x + .032, .48 + lens[i], .01),
      const Color(0xFFE8C27A),
      depth: .4,
      line: p.lw * .6,
    );
  }
  p.part(
    rrect(.565, .53, .71, .555, .008),
    const Color(0xFFB8864A),
    depth: 0,
    line: p.lw * .6,
  );
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .1, .55),
        pt(.5 + k * .14, .60),
        pt(.5 + k * .12, .58),
      ]),
      .03,
      _skin,
    );
  }
  p.part(circle(.62, .58, .03), _skin, depth: .4);
  _kidHead(
    p,
    hair: hair,
    elfEars: true,
    cy: .38,
    fringe: () {
      p.part(fluff(.5, .27, .17, .08, 9, depth: .2), hair, shine: .5);
    },
  );
  // Ram's horns curling back over the curls.
  for (final double k in sides) {
    p.part(
      taper(
        <Offset>[
          pt(.5 + k * .07, .25),
          pt(.5 + k * .14, .14),
          pt(.5 + k * .23, .15),
          pt(.5 + k * .25, .24),
          pt(.5 + k * .2, .28),
        ],
        <double>[.032, .03, .025, .018, .01],
      ),
      horn,
      depth: .5,
      marks: () {
        for (final double t in <double>[.17, .2]) {
          p.line(
            Path()
              ..moveTo(.5 + k * .12, t)
              ..lineTo(.5 + k * .16, t - .03),
            width: .006,
            color: darker(horn, .2),
          );
        }
      },
    );
  }

  p.head(const Rect.fromLTRB(.33, .21, .67, .55), hatLift: .05);
  p.torso(const Rect.fromLTRB(.37, .52, .63, .86));
  p.collar(pt(.5, .55), .09);
}

// -------------------------------------------------------------------- 12 faun

void _faun(Pen p) {
  const Color hair = Color(0xFFC98A52);
  const Color fur = Color(0xFFD9A06A);
  const Color spot = Color(0xFFFFF2DE);
  const Color scarf = Color(0xFFE5524A);
  const Color inner = Color(0xFFFFC7B8);
  p.ink = const Color(0xFF4A2814);

  for (final double k in sides) {
    p.part(
      blob(<Offset>[
        pt(.5 + k * .02, .64),
        pt(.5 + k * .13, .65),
        pt(.5 + k * .12, .76),
        pt(.5 + k * .1, .86),
        pt(.5 + k * .04, .86),
        pt(.5 + k * .05, .76),
      ]),
      fur,
      marks: () {
        p.flat(circle(.5 + k * .09, .70, .012), spot);
        p.flat(circle(.5 + k * .07, .76, .01), spot);
      },
    );
    p.part(
      rrect(.5 + k * .07 - .035, .845, .5 + k * .07 + .035, .895, .012),
      const Color(0xFF5A3A26),
      depth: .4,
    );
  }
  final Path tunic = rrect(.38, .52, .62, .68, .06);
  p.part(tunic, const Color(0xFF9ACB7A), shine: .4);
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .1, .55),
        pt(.5 + k * .15, .62),
        pt(.5 + k * .13, .68),
      ]),
      .03,
      _skin,
    );
  }
  // A flower held out.
  p.tube(
    Path()
      ..moveTo(.63, .68)
      ..lineTo(.68, .56),
    .01,
    Kit.leafGreen,
  );
  for (int i = 0; i < 5; i++) {
    final double a = i * math.pi * 2 / 5;
    p.flat(
      circle(.685 + math.cos(a) * .02, .55 + math.sin(a) * .02, .016),
      const Color(0xFFFFE07A),
    );
  }
  p.flat(circle(.685, .55, .012), const Color(0xFFFF9A3A));
  for (final double k in sides) {
    final Path ear = leaf(pt(.5 + k * .15, .38), pt(.5 + k * .29, .32), .07);
    p.part(
      ear,
      fur,
      marks: () => p.flat(
        leaf(pt(.5 + k * .17, .375), pt(.5 + k * .27, .33), .035),
        inner,
      ),
    );
    p.part(
      leaf(pt(.5 + k * .07, .26), pt(.5 + k * .1, .17), .035),
      const Color(0xFFF2E2C4),
      depth: .5,
    );
  }
  _kidHead(p, hair: hair, cy: .39, iris: const Color(0xFF8A5A2A));
  // The scarf.
  p.part(rrect(.38, .51, .62, .56, .025), scarf, shine: .5);
  p.part(rrect(.53, .53, .58, .64, .015), scarf);

  p.head(const Rect.fromLTRB(.33, .22, .67, .56), hatLift: .04);
  p.torso(const Rect.fromLTRB(.37, .52, .63, .86));
  p.collar(pt(.5, .535), .09);
}

// ------------------------------------------------------------------ 13 kelpie

void _kelpie(Pen p) {
  const Color body = Color(0xFF5FC6C2);
  const Color belly = Color(0xFFD8F7F2);
  const Color weed = Color(0xFF2E8A6A);
  const Color hoof = Color(0xFF2A5A66);
  const double hx = .62;
  p.ink = const Color(0xFF103A40);

  // A fish's tail where a horse's should be.
  p.part(
    blob(
      <Offset>[
        pt(.22, .58),
        pt(.10, .46),
        pt(.08, .58),
        pt(.12, .64),
        pt(.08, .74),
        pt(.20, .66),
      ],
      sharp: <int>{1, 4},
    ),
    body,
    marks: () {
      for (final double a in <double>[-.4, 0, .4]) {
        p.line(
          Path()
            ..moveTo(.20, .62)
            ..lineTo(.20 - math.cos(a) * .1, .62 + math.sin(a) * .1),
          width: .008,
          color: darker(body, .14),
        );
      }
    },
  );
  standBody(
    p,
    fur: body,
    hoof: hoof,
    belly: belly,
    neck: standNeck(top: .44),
    marks: () {
      for (final Offset c in <Offset>[
        pt(.30, .56),
        pt(.38, .53),
        pt(.34, .60),
        pt(.46, .56),
      ]) {
        p.canvas.drawCircle(c, .018, strokeOf(lighter(body, .1), .008));
      }
      p.flat(oval(.62, .58, .045, .06), belly);
    },
  );
  // Seaweed mane in wavy strands.
  for (final double d in <double>[0, .04, .08]) {
    p.tube(
      curve(<Offset>[
        pt(.58 - d * .3, .20 + d),
        pt(.52 - d, .30 + d),
        pt(.54 - d, .42 + d),
        pt(.48 - d, .54 + d * .5),
      ]),
      .03,
      weed,
    );
  }
  for (final double k in sides) {
    p.part(_finEar(pt(hx + k * .1, .23), k), body);
  }
  final Path head = union(oval(hx, .315, .14, .13), oval(hx, .42, .1, .08));
  p.part(
    head,
    body,
    shine: 1,
    marks: () => p.flat(oval(hx, .445, .1, .065), belly),
  );
  p.flat(oval(hx - .035, .44, .012, .016), darker(belly, .4));
  p.flat(oval(hx + .035, .44, .012, .016), darker(belly, .4));
  p.eyes(hx, .32, .068, .044, iris: const Color(0xFF1A8A8A));
  p.cheeks(hx, .38, .11, .028);
  p.smile(pt(hx, .475), .022);
  for (final Offset c in <Offset>[pt(.86, .30), pt(.90, .44), pt(.14, .30)]) {
    p.part(
      tear(c.dx, c.dy, .016, length: 2.0),
      const Color(0xFFBFF6FF),
      depth: 0,
      line: p.lw * .5,
    );
  }

  p.head(const Rect.fromLTRB(hx - .14, .185, hx + .14, .50), hatLift: .03);
  p.collar(pt(.61, .53), .075);
}

Path _finEar(Offset base, double k) => blob(
  <Offset>[
    base.translate(-.03, .02),
    base.translate(k * .06, -.12),
    base.translate(k * .08, -.04),
    base.translate(.03, .03),
  ],
  sharp: <int>{1},
);

// ------------------------------------------------------------- 14 griffin cub

void _griffinCub(Pen p) {
  const Color fur = Color(0xFFE6B66C);
  const Color feather = Color(0xFFFFF8EC);
  const Color wing = Color(0xFFB98A4E);
  const Color beak = Color(0xFFFFC23A);
  p.ink = const Color(0xFF4A2E10);

  p.tube(curve(<Offset>[pt(.62, .84), pt(.80, .82), pt(.84, .70)]), .024, fur);
  p.part(tear(.84, .68, .032, length: 2.0), wing);
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    p.part(
      blob(<Offset>[
        q(.14, .56),
        q(.26, .42),
        q(.38, .40),
        q(.36, .48),
        q(.40, .52),
        q(.34, .58),
        q(.36, .64),
        q(.24, .66),
      ]),
      wing,
      shine: .4,
    );
  }
  sitBody(
    p,
    fur: fur,
    belly: lighter(fur, .1),
    feet: fur,
    paws: fur,
    rx: .16,
    ry: .155,
  );
  p.part(fluff(.5, .44, .2, .18, 11, depth: .07), feather, shine: 1);
  p.part(leaf(pt(.5, .28), pt(.53, .18), .04), feather, depth: .4);
  p.part(leaf(pt(.47, .28), pt(.44, .19), .035), feather, depth: .4);
  p.eyes(.5, .43, .085, .046, iris: const Color(0xFFE09A2A));
  p.cheeks(.5, .49, .14, .03);
  // A hooked little beak.
  p.part(
    blob(
      <Offset>[
        pt(.46, .47),
        pt(.54, .47),
        pt(.535, .52),
        pt(.5, .56),
        pt(.49, .52),
      ],
      sharp: <int>{3},
    ),
    beak,
    shine: .5,
    line: p.lw * .7,
  );

  p.head(const Rect.fromLTRB(.29, .25, .71, .63), hatLift: .03);
  p.collar(pt(.5, .62), .13);
}

// ------------------------------------------------------------ 15 unicorn foal

/// A pastel rainbow, for unicorn manes.
const List<Color> _rainbow = <Color>[
  Color(0xFFFFA8C8),
  Color(0xFFFFD08A),
  Color(0xFFB8E8A0),
  Color(0xFF9ED0FF),
  Color(0xFFC8A8F8),
];

void _unicornFoal(Pen p) {
  const Color fur = Color(0xFFFFFFFF);
  const Color muzzle = Color(0xFFFFE6EE);
  const Color hoof = Color(0xFFC8A8F8);
  p.ink = const Color(0xFF5A3A70);

  final Path tail = puffs(
    <Offset>[pt(.62, .84), pt(.78, .82), pt(.84, .70), pt(.80, .60)],
    <double>[.04, .055, .05, .04],
  );
  p.part(
    tail,
    _rainbow[4],
    marks: () => p.flat(
      puffs(
        <Offset>[pt(.70, .84), pt(.82, .76), pt(.82, .66)],
        <double>[.03, .03, .025],
      ),
      _rainbow[0],
    ),
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .15, .30),
      pt(.5 + k * .2, .15),
      .1,
      fur,
      muzzle,
      round: .03,
    );
  }
  sitBody(p, fur: fur, feet: hoof, paws: fur, rx: .16, ry: .155);
  p.part(
    oval(.5, .44, .2, .18),
    fur,
    shine: 1,
    marks: () => p.flat(oval(.5, .54, .12, .08), muzzle),
  );
  // Curly rainbow forelock.
  for (int i = 0; i < 4; i++) {
    p.part(
      circle(.40 + i * .05, .28 + (i == 1 || i == 2 ? -.02 : 0), .045),
      _rainbow[i],
      depth: .4,
    );
  }
  // A small spiral horn.
  final Path horn = poly(<Offset>[pt(.47, .27), pt(.53, .27), pt(.5, .12)]);
  p.part(
    horn,
    Kit.gold,
    shine: .6,
    marks: () {
      for (final double y in <double>[.17, .21, .25]) {
        p.line(
          Path()
            ..moveTo(.47, y + .01)
            ..lineTo(.53, y - .01),
          width: .007,
          color: darker(Kit.gold, .2),
        );
      }
    },
  );
  p.eyes(.5, .43, .085, .048, iris: const Color(0xFF9A6AE0));
  p.cheeks(.5, .49, .14, .034);
  p.flat(oval(.475, .54, .009, .012), darker(muzzle, .3));
  p.flat(oval(.525, .54, .009, .012), darker(muzzle, .3));
  p.smile(pt(.5, .565), .018);

  p.head(const Rect.fromLTRB(.3, .26, .7, .62), hatLift: .07);
  p.collar(pt(.5, .62), .12);
}

// ----------------------------------------------------------------- 16 pegasus

void _pegasus(Pen p) {
  const Color fur = Color(0xFFFFFFFF);
  const Color mane = Color(0xFF8EC8F8);
  const Color hoof = Color(0xFFFFCF4A);
  const Color wing = Color(0xFFF4F8FF);
  const double hx = .62;
  p.ink = const Color(0xFF2E4064);

  // Big feathered wings raised behind.
  for (final double d in <double>[.06, 0]) {
    final Path w = blob(
      <Offset>[
        pt(.48 - d, .54),
        pt(.36 - d, .40),
        pt(.22 - d, .22),
        pt(.12 - d, .12),
        pt(.20 - d, .30),
        pt(.14 - d, .32),
        pt(.22 - d, .44),
        pt(.18 - d, .48),
        pt(.30 - d, .56),
      ],
      sharp: <int>{3},
    );
    p.part(
      w,
      d == 0 ? wing : darker(wing, .06),
      shine: .5,
      marks: () {
        for (final double t in <double>[.3, .45, .6]) {
          p.line(
            curve(<Offset>[
              pt(.46 - d, .54),
              pt(.46 - d - t * .4, .54 - t * .5),
            ]),
            width: .007,
            color: darker(wing, .12),
          );
        }
      },
    );
  }
  p.part(
    puffs(
      <Offset>[pt(.20, .56), pt(.14, .64), pt(.14, .74)],
      <double>[.04, .045, .035],
    ),
    mane,
  );
  standBody(p, fur: fur, hoof: hoof, neck: standNeck(top: .44));
  p.part(
    puffs(
      <Offset>[pt(.60, .20), pt(.52, .30), pt(.52, .44), pt(.50, .54)],
      <double>[.04, .045, .04, .03],
    ),
    mane,
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(hx + k * .085, .225),
      pt(hx + k * .12, .1),
      .07,
      fur,
      const Color(0xFFFFD6E2),
      round: .025,
    );
  }
  final Path head = union(oval(hx, .315, .14, .13), oval(hx, .42, .1, .08));
  p.part(
    head,
    fur,
    shine: 1,
    marks: () => p.flat(oval(hx, .445, .1, .065), const Color(0xFFFFE6EE)),
  );
  p.part(fluff(hx, .22, .07, .04, 6, depth: .2), mane, depth: .4);
  p.flat(oval(hx - .035, .44, .011, .015), const Color(0xFFD8A8B8));
  p.flat(oval(hx + .035, .44, .011, .015), const Color(0xFFD8A8B8));
  p.eyes(hx, .32, .068, .044, iris: const Color(0xFF4A8AD8));
  p.cheeks(hx, .38, .11, .028);
  p.smile(pt(hx, .475), .02);

  p.head(const Rect.fromLTRB(hx - .14, .185, hx + .14, .50), hatLift: .04);
  p.collar(pt(.61, .53), .075);
}

// ---------------------------------------------------------------- 17 basilisk

void _basilisk(Pen p) {
  const Color scale = Color(0xFF6CC05A);
  const Color belly = Color(0xFFF2EAB0);
  const Color frill = Color(0xFFB88AE8);
  p.ink = const Color(0xFF1E3A14);

  // Stacked coils.
  for (final List<double> c in <List<double>>[
    <double>[.5, .80, .30, .08],
    <double>[.52, .68, .23, .07],
  ]) {
    final Path coil = oval(c[0], c[1], c[2], c[3]);
    p.part(
      coil,
      scale,
      shine: .6,
      marks: () {
        p.flat(oval(c[0], c[1] + c[3] * .55, c[2] * .85, c[3] * .4), belly);
        for (double x = c[0] - c[2] * .7; x < c[0] + c[2] * .8; x += .07) {
          p.flat(circle(x, c[1] - c[3] * .35, .012), lighter(scale, .1));
        }
      },
    );
  }
  // A royal frill, then the neck and head in one rising curve.
  p.part(_crestFan(pt(.56, .36), .16), frill, depth: .4);
  p.part(
    union(
      taper(
        <Offset>[pt(.62, .66), pt(.66, .54), pt(.60, .44)],
        <double>[.07, .065, .07],
      ),
      oval(.56, .38, .15, .12),
    ),
    scale,
    shine: 1,
    marks: () {
      p.flat(
        taper(
          <Offset>[pt(.66, .66), pt(.69, .54), pt(.65, .47)],
          <double>[.03, .028, .02],
        ),
        belly,
      );
    },
  );
  p.part(
    roundPoly(<Offset>[
      pt(.47, .29),
      pt(.47, .20),
      pt(.51, .24),
      pt(.56, .17),
      pt(.61, .24),
      pt(.65, .20),
      pt(.65, .29),
    ], .008),
    Kit.gold,
    shine: .8,
  );
  p.eyes(.57, .38, .065, .042, iris: const Color(0xFFE0B83A));
  p.cheeks(.57, .43, .1, .03);
  p.smile(pt(.57, .44), .022);
  p.tube(
    curve(<Offset>[pt(.57, .465), pt(.58, .50), pt(.56, .52)]),
    .008,
    const Color(0xFFF04A6A),
  );

  p.head(const Rect.fromLTRB(.41, .26, .71, .50), hatLift: .08);
  p.torso(const Rect.fromLTRB(.2, .58, .8, .88));
  p.collar(pt(.6, .5), .08);
}

Path _crestFan(Offset c, double r) =>
    _fanShape(c, r, math.pi * 1.1, math.pi * 1.9, 5);

Path _fanShape(Offset hinge, double r, double from, double to, int lobes) {
  final Path p = Path()..moveTo(hinge.dx, hinge.dy);
  final Offset start = hinge + Offset(math.cos(from), math.sin(from)) * r;
  p.lineTo(start.dx, start.dy);
  for (int i = 1; i <= lobes; i++) {
    final double a = from + (to - from) * i / lobes;
    final double am = from + (to - from) * (i - .5) / lobes;
    final Offset q = hinge + Offset(math.cos(a), math.sin(a)) * r;
    final Offset c = hinge + Offset(math.cos(am), math.sin(am)) * r * 1.25;
    p.quadraticBezierTo(c.dx, c.dy, q.dx, q.dy);
  }
  return p..close();
}

// ----------------------------------------------------------------- 18 chimera

void _chimera(Pen p) {
  const Color fur = Color(0xFFEDB868);
  const Color mane = Color(0xFFC97A3A);
  const Color snake = Color(0xFF6CC05A);
  const Color horn = Color(0xFFE8DCC6);
  const Color wing = Color(0xFFC0704A);
  p.ink = const Color(0xFF4A2410);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.12, .58).dx, q(.12, .58).dy)
      ..quadraticBezierTo(
        q(.24, .40).dx,
        q(.24, .40).dy,
        q(.36, .40).dx,
        q(.36, .40).dy,
      )
      ..quadraticBezierTo(
        q(.34, .50).dx,
        q(.34, .50).dy,
        q(.36, .58).dx,
        q(.36, .58).dy,
      )
      ..quadraticBezierTo(
        q(.28, .54).dx,
        q(.28, .54).dy,
        q(.24, .62).dx,
        q(.24, .62).dy,
      )
      ..close();
    p.part(w, wing, shine: .3);
  }
  // A snake for a tail, with its own little face.
  final Path tail = taper(
    <Offset>[pt(.62, .84), pt(.80, .84), pt(.88, .72), pt(.84, .62)],
    <double>[.025, .028, .03, .03],
  );
  p.part(tail, snake);
  p.part(oval(.84, .58, .05, .042), snake, shine: .8);
  p.eye(pt(.825, .575), .016);
  p.eye(pt(.86, .575), .016);
  p.tube(
    curve(<Offset>[pt(.84, .62), pt(.845, .645)]),
    .006,
    const Color(0xFFF04A6A),
  );
  sitBody(p, fur: fur, belly: lighter(fur, .1), rx: .16, ry: .155);
  p.part(fluff(.5, .44, .25, .22, 11, depth: .08), mane, shine: .4);
  for (final double k in sides) {
    p.part(
      taper(
        <Offset>[
          pt(.5 + k * .1, .28),
          pt(.5 + k * .2, .18),
          pt(.5 + k * .28, .22),
          pt(.5 + k * .27, .30),
        ],
        <double>[.03, .024, .016, .01],
      ),
      horn,
      depth: .5,
    );
  }
  p.part(
    oval(.5, .45, .17, .15),
    fur,
    shine: 1,
    marks: () {
      p.flat(
        union(oval(.465, .52, .05, .04), oval(.535, .52, .05, .04)),
        const Color(0xFFFFF0D2),
      );
    },
  );
  p.eyes(.5, .43, .08, .044);
  p.cheeks(.5, .49, .13, .03);
  p.nose(pt(.5, .495), .024, color: const Color(0xFF8A4A2A));
  p.catMouth(pt(.5, .53), .018);

  p.head(const Rect.fromLTRB(.27, .22, .73, .66), hatLift: .03);
  p.collar(pt(.5, .64), .14);
}

// ---------------------------------------------------------------- 19 minotaur

void _minotaur(Pen p) {
  const Color fur = Color(0xFFA06A4A);
  const Color muzzle = Color(0xFFE8C2A8);
  const Color horn = Color(0xFFF2E8D2);
  const Color hoof = Color(0xFF3A2A22);
  p.ink = const Color(0xFF3A1A0A);

  for (final double k in sides) {
    p.part(
      rrect(.5 + k * .08 - .05, .72, .5 + k * .08 + .05, .895, .04),
      fur,
      depth: .5,
      marks: () {
        p.flat(
          Rect.fromLTRB(
            .5 + k * .08 - .06,
            .85,
            .5 + k * .08 + .06,
            .91,
          ).toPathRect(),
          hoof,
        );
      },
    );
  }
  final Path torso = rrect(.33, .54, .67, .78, .1);
  p.part(
    torso,
    fur,
    shine: .5,
    marks: () {
      p.flat(oval(.5, .66, .11, .09), lighter(fur, .1));
      p.flat(rrect(.33, .72, .67, .77, .01), const Color(0xFF7A5A3A));
      p.flat(circle(.5, .745, .02), Kit.gold);
    },
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .2, .64, .06, .08), fur, depth: .5);
  }
  // Big curved horns.
  for (final double k in sides) {
    p.part(
      taper(
        <Offset>[
          pt(.5 + k * .14, .32),
          pt(.5 + k * .27, .28),
          pt(.5 + k * .33, .18),
          pt(.5 + k * .3, .12),
        ],
        <double>[.04, .035, .025, .012],
      ),
      horn,
      shine: .4,
    );
  }
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.5 + k * .16, .38), pt(.5 + k * .3, .42), .07),
        pt(.5 + k * .16, .38),
        0,
      ),
      fur,
    );
  }
  p.part(
    oval(.5, .40, .18, .16),
    fur,
    shine: 1,
    marks: () => p.flat(oval(.5, .29, .07, .05), darker(fur, .1)),
  );
  p.part(oval(.5, .50, .12, .075), muzzle, shine: .5);
  p.flat(oval(.465, .50, .014, .018), darker(muzzle, .35));
  p.flat(oval(.535, .50, .014, .018), darker(muzzle, .35));
  p.canvas.drawArc(
    Rect.fromCenter(center: pt(.5, .545), width: .07, height: .06),
    .2,
    math.pi - .4,
    false,
    strokeOf(p.ink, .022),
  );
  p.canvas.drawArc(
    Rect.fromCenter(center: pt(.5, .545), width: .07, height: .06),
    .2,
    math.pi - .4,
    false,
    strokeOf(Kit.gold, .012),
  );
  p.eyes(.5, .38, .085, .042);
  p.cheeks(.5, .43, .14, .03);

  p.head(const Rect.fromLTRB(.32, .24, .68, .58), hatLift: .06);
  p.torso(const Rect.fromLTRB(.33, .54, .67, .78));
  p.collar(pt(.5, .58), .13);
}

// ------------------------------------------------------------------ 20 sphinx

void _sphinx(Pen p) {
  const Color fur = Color(0xFFEDC67A);
  const Color blue = Color(0xFF3E6EC8);
  const Color gold = Color(0xFFFFD25A);
  p.ink = const Color(0xFF4A2E0E);

  // Lying down, paws out front.
  p.tube(curve(<Offset>[pt(.16, .84), pt(.08, .80), pt(.10, .70)]), .022, fur);
  final Path body = oval(.5, .76, .34, .13);
  p.part(body, fur, shine: .6);
  for (final double k in sides) {
    p.part(
      rrect(.5 + k * .11 - .06, .80, .5 + k * .11 + .06, .895, .045),
      fur,
      depth: .5,
    );
  }
  // The nemes headdress, striped gold and blue.
  final Path nemes = blob(
    <Offset>[
      pt(.5, .18),
      pt(.66, .22),
      pt(.72, .36),
      pt(.76, .60),
      pt(.66, .66),
      pt(.62, .50),
      pt(.5, .48),
      pt(.38, .50),
      pt(.34, .66),
      pt(.24, .60),
      pt(.28, .36),
      pt(.34, .22),
    ],
    sharp: <int>{3, 9},
  );
  p.part(
    nemes,
    gold,
    shine: .6,
    marks: () {
      for (double y = .24; y < .7; y += .055) {
        p.line(
          Path()
            ..moveTo(.2, y)
            ..lineTo(.8, y + .02),
          width: .025,
          color: blue,
        );
      }
    },
  );
  p.part(oval(.5, .43, .16, .15), fur, shine: 1);
  p.part(
    rrect(.34, .28, .66, .33, .02),
    gold,
    marks: () => p.flat(circle(.5, .305, .015), blue),
  );
  p.part(
    _fanShape(pt(.5, .60), .14, math.pi * .15, math.pi * .85, 5),
    gold,
    depth: .4,
    marks: () {
      p.canvas.drawArc(
        Rect.fromCircle(center: pt(.5, .60), radius: .09),
        math.pi * .15,
        math.pi * .7,
        false,
        strokeOf(blue, .025),
      );
    },
  );
  p.eyes(.5, .43, .075, .042, iris: const Color(0xFF3A6AB0));
  for (final double k in sides) {
    p.line(
      Path()
        ..moveTo(.5 + k * .1, .425)
        ..lineTo(.5 + k * .14, .44),
      width: .012,
    );
  }
  p.cheeks(.5, .48, .11, .028);
  p.nose(pt(.5, .48), .016, color: const Color(0xFFB07A4A));
  p.catMouth(pt(.5, .505), .016);

  p.head(const Rect.fromLTRB(.34, .28, .66, .58), hatLift: .1);
  p.torso(const Rect.fromLTRB(.16, .63, .84, .89));
  p.collar(pt(.5, .60), .14);
}

// ----------------------------------------------------------- 21 nine-tail fox

void _nineTail(Pen p) {
  const Color fur = Color(0xFFF6C46A);
  const Color cream = Color(0xFFFFF6E6);
  const Color fire = Color(0xFF8AD0FF);
  p.ink = const Color(0xFF5A3010);

  // Nine plumed tails fanned out behind, outermost first.
  for (final int i in <int>[0, 8, 1, 7, 2, 6, 3, 5, 4]) {
    final double a = math.pi * (1.06 + .88 * i / 8);
    final Offset root = pt(.5, .76);
    Offset at(double d) =>
        pt(.5 + math.cos(a) * d * 1.1, .72 + math.sin(a) * d * 1.08);
    final Path tail = puffs(
      <Offset>[root, at(.18), at(.30), at(.38)],
      <double>[.03, .06, .065, .05],
    );
    final Offset tip = at(.39);
    p.part(tail, fur, marks: () => p.flat(circle(tip.dx, tip.dy, .055), cream));
  }
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .14, .36),
      pt(.5 + k * .2, .19),
      .13,
      fur,
      cream,
      round: .03,
    );
  }
  sitBody(p, fur: fur, belly: cream, rx: .15, ry: .145, cy: .75);
  final Path head = sym(
    <Offset>[
      pt(.5, .31),
      pt(.62, .325),
      pt(.69, .39),
      pt(.71, .48),
      pt(.73, .55),
      pt(.63, .60),
      pt(.5, .635),
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
            pt(.5, .5),
            pt(.56, .49),
            pt(.64, .5),
            pt(.73, .55),
            pt(.63, .60),
            pt(.5, .64),
          ],
          sharp: <int>{3},
        ),
        cream,
      );
      p.flat(
        tear(.5, .37, .014, angle: math.pi, length: 2.2),
        const Color(0xFFE8503A),
      );
    },
  );
  p.eyes(.5, .47, .08, .042, iris: const Color(0xFFE07A2A));
  p.cheeks(.5, .53, .13, .028);
  p.nose(pt(.5, .535), .018);
  p.catMouth(pt(.5, .56), .016);
  for (final Offset c in <Offset>[pt(.10, .84), pt(.90, .84)]) {
    p.glow(c, .07, fire, alpha: .7);
    p.part(
      tear(c.dx, c.dy, .025, length: 2.3),
      const Color(0xFFCFEFFF),
      depth: .3,
      line: p.lw * .6,
    );
  }

  p.head(const Rect.fromLTRB(.27, .31, .73, .635), hatLift: .03);
  p.collar(pt(.5, .635), .12);
}

// -------------------------------------------------------------------- 22 hydra

void _hydra(Pen p) {
  const Color scale = Color(0xFF4FB89A);
  const Color belly = Color(0xFFE6F6C8);
  const Color spine = Color(0xFF2E8A72);
  p.ink = const Color(0xFF103A30);

  p.part(
    taper(
      <Offset>[pt(.62, .82), pt(.80, .84), pt(.90, .76)],
      <double>[.05, .035, .015],
    ),
    scale,
  );
  final List<List<Offset>> necks = <List<Offset>>[
    <Offset>[pt(.42, .64), pt(.32, .52), pt(.22, .42)],
    <Offset>[pt(.5, .62), pt(.5, .44), pt(.5, .30)],
    <Offset>[pt(.58, .64), pt(.68, .52), pt(.78, .42)],
  ];
  final List<Offset> heads = <Offset>[pt(.22, .40), pt(.5, .27), pt(.78, .40)];
  for (int i = 0; i < 3; i++) {
    final Offset h = heads[i];
    p.part(
      spikes(
        h.dx,
        h.dy - .02,
        .07,
        .07,
        3,
        .5,
        from: math.pi * 1.2,
        to: math.pi * 1.8,
        round: .005,
      ),
      spine,
      depth: .3,
    );
  }
  for (int i = 0; i < 3; i++) {
    final List<Offset> n = necks[i];
    final Offset h = heads[i];
    p.part(
      union(taper(n, <double>[.06, .05, .05]), oval(h.dx, h.dy, .11, .095)),
      scale,
      shine: 1,
      marks: () {
        p.flat(
          taper(
            n.sublist(0, 2).map((Offset o) => o.translate(.012, .01)).toList(),
            <double>[.025, .02],
          ),
          belly,
        );
      },
    );
  }
  for (final double k in sides) {
    p.part(oval(.5 + k * .1, .88, .06, .03), scale, depth: .5);
  }
  final Path body = oval(.5, .74, .2, .15);
  p.part(
    body,
    scale,
    shine: .6,
    marks: () => p.flat(oval(.5, .79, .13, .09), belly),
  );
  final List<Eye> looks = <Eye>[Eye.open, Eye.open, Eye.happy];
  for (int i = 0; i < 3; i++) {
    final Offset h = heads[i];
    p.eye(
      pt(h.dx - .04, h.dy - .005),
      .03,
      look: looks[i],
      iris: const Color(0xFFE0B83A),
    );
    p.eye(
      pt(h.dx + .04, h.dy - .005),
      .03,
      look: looks[i],
      iris: const Color(0xFFE0B83A),
    );
    p.blush(pt(h.dx - .065, h.dy + .035), .02);
    p.blush(pt(h.dx + .065, h.dy + .035), .02);
    p.smile(pt(h.dx, h.dy + .04), .018);
  }
  p.face(pt(.46, .265), pt(.54, .265), .03);

  p.head(const Rect.fromLTRB(.39, .175, .61, .365), hatLift: .03);
  p.torso(const Rect.fromLTRB(.3, .59, .7, .89));
  p.collar(pt(.5, .60), .12);
}

// ------------------------------------------------------------------ 23 griffin

void _griffin(Pen p) {
  const Color fur = Color(0xFFE2B062);
  const Color feather = Color(0xFFFFF8EC);
  const Color wing = Color(0xFFB98448);
  const Color beak = Color(0xFFFFC23A);
  const double hx = .62;
  p.ink = const Color(0xFF4A2A0C);

  // Spread wings.
  for (final double d in <double>[.08, 0]) {
    final Path w = blob(
      <Offset>[
        pt(.50 - d * .5, .52),
        pt(.36 - d, .34),
        pt(.20 - d, .18),
        pt(.08 - d * .5, .14),
        pt(.16 - d * .5, .28),
        pt(.10 - d * .5, .32),
        pt(.20 - d * .5, .42),
        pt(.16 - d * .5, .48),
        pt(.30 - d * .5, .56),
      ],
      sharp: <int>{3},
    );
    p.part(
      w,
      d == 0 ? wing : darker(wing, .06),
      shine: .4,
      marks: () {
        p.flat(
          blob(<Offset>[
            pt(.08 - d * .5, .14),
            pt(.20 - d, .18),
            pt(.16 - d * .5, .28),
          ]),
          feather,
        );
      },
    );
  }
  p.tube(curve(<Offset>[pt(.20, .58), pt(.12, .62), pt(.12, .72)]), .02, fur);
  p.part(tear(.12, .74, .03, angle: math.pi, length: 2.0), wing);
  standBody(
    p,
    fur: fur,
    hoof: beak,
    belly: lighter(fur, .08),
    legW: .062,
    neck: standNeck(top: .44),
    marks: () {
      p.flat(
        blob(<Offset>[
          pt(.53, .60),
          pt(.55, .44),
          pt(.69, .44),
          pt(.70, .62),
          pt(.62, .68),
        ]),
        feather,
      );
    },
  );
  p.part(fluff(hx, .35, .16, .15, 10, depth: .07), feather, shine: 1);
  p.part(leaf(pt(hx + .02, .21), pt(hx + .06, .11), .04), feather, depth: .4);
  p.part(leaf(pt(hx - .02, .21), pt(hx - .06, .12), .035), feather, depth: .4);
  p.eyes(hx, .34, .072, .044, iris: const Color(0xFFE09A2A));
  p.cheeks(hx, .40, .12, .028);
  p.part(
    blob(
      <Offset>[
        pt(hx - .045, .38),
        pt(hx + .045, .38),
        pt(hx + .04, .43),
        pt(hx, .48),
        pt(hx - .01, .43),
      ],
      sharp: <int>{3},
    ),
    beak,
    shine: .5,
    line: p.lw * .7,
  );

  p.head(const Rect.fromLTRB(hx - .16, .20, hx + .16, .50), hatLift: .04);
  p.collar(pt(.61, .52), .08);
}

extension on Rect {
  Path toPathRect() => Path()..addRect(this);
}

// ------------------------------------------------------------------ 24 unicorn

void _unicorn(Pen p) {
  const Color fur = Color(0xFFFFFFFF);
  const Color hoof = Color(0xFFFFCF4A);
  const double hx = .62;
  p.ink = const Color(0xFF4A3070);

  // A flowing rainbow tail.
  for (int i = 0; i < 3; i++) {
    p.part(
      taper(
        <Offset>[
          pt(.20, .55 + i * .02),
          pt(.12, .62 + i * .03),
          pt(.12 + i * .02, .76 + i * .03),
        ],
        <double>[.025, .035, .02],
      ),
      _rainbow[i * 2 % 5],
    );
  }
  standBody(p, fur: fur, hoof: hoof, neck: standNeck(top: .44));
  // Rainbow mane flowing down the back of the neck.
  for (int i = 4; i >= 0; i--) {
    p.part(circle(.50 - i * .006, .25 + i * .07, .048), _rainbow[i], depth: .4);
  }
  for (final double k in sides) {
    pointyEar(
      p,
      pt(hx + k * .085, .225),
      pt(hx + k * .12, .1),
      .07,
      fur,
      const Color(0xFFFFD6E2),
      round: .025,
    );
  }
  final Path head = union(oval(hx, .315, .14, .13), oval(hx, .42, .1, .08));
  p.part(
    head,
    fur,
    shine: 1,
    marks: () => p.flat(oval(hx, .445, .1, .065), const Color(0xFFFFE6EE)),
  );
  // The long spiral horn.
  final Path horn = poly(<Offset>[
    pt(hx - .03, .21),
    pt(hx + .03, .21),
    pt(hx + .01, .02),
  ]);
  p.part(
    horn,
    Kit.gold,
    shine: .6,
    marks: () {
      for (final double y in <double>[.07, .11, .15, .19]) {
        p.line(
          Path()
            ..moveTo(hx - .03, y + .012)
            ..lineTo(hx + .03, y - .012),
          width: .007,
          color: darker(Kit.gold, .2),
        );
      }
    },
  );
  p.flat(oval(hx - .035, .44, .011, .015), const Color(0xFFD8A8B8));
  p.flat(oval(hx + .035, .44, .011, .015), const Color(0xFFD8A8B8));
  p.eyes(hx, .32, .068, .044, iris: const Color(0xFF9A6AE0));
  p.cheeks(hx, .38, .11, .028);
  p.smile(pt(hx, .475), .02);
  p.twinkle(pt(.86, .20), .03, Kit.gold);
  p.twinkle(pt(.18, .30), .024, const Color(0xFFFFB8D8));
  p.twinkle(pt(.84, .58), .018, const Color(0xFFB8E0FF));

  p.head(const Rect.fromLTRB(hx - .14, .185, hx + .14, .50), hatLift: .08);
  p.collar(pt(.61, .53), .075);
}

// ------------------------------------------------------------------- 25 wyvern

void _wyvern(Pen p) {
  const Color scale = Color(0xFF8A6AD0);
  const Color belly = Color(0xFFE6D8FF);
  const Color wing = Color(0xFF6A4AB0);
  const Color membrane = Color(0xFFB8A0F0);
  p.ink = const Color(0xFF221446);

  // Wings that double as arms.
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.12, .52).dx, q(.12, .52).dy)
      ..lineTo(q(.36, .22).dx, q(.36, .22).dy)
      ..quadraticBezierTo(
        q(.40, .40).dx,
        q(.40, .40).dy,
        q(.44, .58).dx,
        q(.44, .58).dy,
      )
      ..quadraticBezierTo(
        q(.36, .54).dx,
        q(.36, .54).dy,
        q(.30, .62).dx,
        q(.30, .62).dy,
      )
      ..quadraticBezierTo(
        q(.24, .56).dx,
        q(.24, .56).dy,
        q(.16, .62).dx,
        q(.16, .62).dy,
      )
      ..close();
    p.part(
      w,
      membrane,
      shine: .4,
      marks: () {
        for (final Offset f in <Offset>[q(.30, .62), q(.16, .62)]) {
          p.line(
            Path()
              ..moveTo(q(.36, .22).dx, q(.36, .22).dy)
              ..lineTo(f.dx, f.dy),
            width: .012,
            color: wing,
          );
        }
      },
    );
    p.tube(
      Path()
        ..moveTo(q(.12, .52).dx, q(.12, .52).dy)
        ..lineTo(q(.36, .22).dx, q(.36, .22).dy),
      .03,
      wing,
    );
    p.part(
      roundPoly(<Offset>[q(.36, .22), q(.40, .16), q(.38, .24)], .006),
      Kit.tooth,
      depth: 0,
      line: p.lw * .5,
    );
  }
  final Path tail = taper(
    <Offset>[pt(.58, .80), pt(.76, .84), pt(.86, .76), pt(.88, .64)],
    <double>[.06, .045, .03, .018],
  );
  p.part(tail, scale);
  p.part(
    roundPoly(<Offset>[
      pt(.88, .66),
      pt(.83, .60),
      pt(.88, .52),
      pt(.93, .60),
    ], .01),
    wing,
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .09, .875, .065, .032), scale, depth: .5);
    for (final double d in <double>[-.03, 0, .03]) {
      p.flat(
        poly(<Offset>[
          pt(.5 + k * .09 + d - .008, .89),
          pt(.5 + k * .09 + d + .008, .89),
          pt(.5 + k * .09 + d, .91),
        ]),
        Kit.tooth,
      );
    }
  }
  p.part(
    oval(.5, .70, .15, .17),
    scale,
    shine: .6,
    marks: () {
      p.flat(oval(.5, .74, .1, .13), belly);
      for (double y = .64; y < .86; y += .045) {
        p.line(
          Path()
            ..moveTo(.42, y)
            ..lineTo(.58, y),
          width: .007,
          color: darker(belly, .14),
        );
      }
    },
  );
  for (final double k in sides) {
    p.part(
      taper(
        <Offset>[
          pt(.5 + k * .08, .32),
          pt(.5 + k * .14, .22),
          pt(.5 + k * .2, .19),
        ],
        <double>[.025, .018, .008],
      ),
      Kit.tooth,
      depth: .4,
    );
  }
  p.part(
    oval(.5, .42, .17, .15),
    scale,
    shine: 1,
    marks: () => p.flat(oval(.5, .50, .1, .06), belly),
  );
  p.flat(oval(.475, .49, .01, .012), darker(scale, .3));
  p.flat(oval(.525, .49, .01, .012), darker(scale, .3));
  p.eyes(.5, .40, .075, .044, iris: const Color(0xFFFFC94A));
  p.cheeks(.5, .46, .12, .03);
  p.smile(pt(.5, .515), .03, depth: .4);
  p.fang(pt(.47, .53), .009);
  p.fang(pt(.53, .53), .009);

  p.head(const Rect.fromLTRB(.33, .27, .67, .57), hatLift: .03);
  p.torso(const Rect.fromLTRB(.35, .53, .65, .87));
  p.collar(pt(.5, .57), .11);
}

// ------------------------------------------------------------- 26 thunderbird

void _thunderbird(Pen p) {
  const Color body = Color(0xFF4A58B0);
  const Color belly = Color(0xFFA8B8F0);
  const Color bolt = Color(0xFFFFE04A);
  const Color beak = Color(0xFFFFC23A);
  p.ink = const Color(0xFF141C4A);

  Path boltShape(Offset c, double s, double a) => turn(
    poly(<Offset>[
      c.translate(-s * .2, -s),
      c.translate(s * .45, -s),
      c.translate(s * .05, -s * .1),
      c.translate(s * .45, -s * .1),
      c.translate(-s * .35, s),
      c.translate(-s * .05, s * .05),
      c.translate(-s * .45, s * .05),
    ]),
    c,
    a,
  );

  // Wings flung wide.
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = blob(
      <Offset>[
        q(.14, .44),
        q(.30, .28),
        q(.46, .20),
        q(.48, .30),
        q(.42, .34),
        q(.46, .42),
        q(.38, .46),
        q(.40, .54),
        q(.30, .56),
        q(.16, .58),
      ],
      sharp: <int>{2, 4, 6},
    );
    p.part(
      w,
      body,
      shine: .5,
      marks: () => p.flat(boltShape(q(.32, .40), .07, k * .4), bolt),
    );
  }
  birdFoot(p, .44, beak);
  birdFoot(p, .56, beak);
  p.part(
    _fanShape(pt(.5, .76), .14, math.pi * .3, math.pi * .7, 4),
    darker(body, .05),
    depth: .4,
  );
  final Path b = blob(<Offset>[
    pt(.5, .28),
    pt(.64, .32),
    pt(.70, .48),
    pt(.68, .68),
    pt(.58, .82),
    pt(.5, .85),
    pt(.42, .82),
    pt(.32, .68),
    pt(.30, .48),
    pt(.36, .32),
  ]);
  p.part(
    b,
    body,
    shine: .8,
    marks: () {
      p.flat(oval(.5, .68, .13, .14), belly);
      p.flat(boltShape(pt(.5, .68), .07, 0), bolt);
    },
  );
  // Crest feathers.
  for (final double a in <double>[-.4, 0, .4]) {
    p.part(
      turn(leaf(pt(.5, .28), pt(.5, .12), .05), pt(.5, .28), a),
      bolt,
      depth: .4,
    );
  }
  p.part(oval(.5, .38, .15, .13), body, shine: 1);
  p.eyes(.5, .37, .07, .044, iris: bolt, rim: const Color(0xFFE8ECFF));
  p.part(
    blob(
      <Offset>[
        pt(.46, .42),
        pt(.54, .42),
        pt(.535, .46),
        pt(.5, .50),
        pt(.49, .46),
      ],
      sharp: <int>{3},
    ),
    beak,
    shine: .5,
    line: p.lw * .7,
  );
  p.cheeks(.5, .43, .11, .028);

  p.head(const Rect.fromLTRB(.35, .25, .65, .51), hatLift: .1);
  p.torso(const Rect.fromLTRB(.3, .40, .7, .85));
  p.collar(pt(.5, .52), .13);
}

// ------------------------------------------------------------------ 27 phoenix

void _phoenix(Pen p) {
  const Color red = Color(0xFFFF6A3A);
  const Color orange = Color(0xFFFFA23A);
  const Color gold = Color(0xFFFFD84A);
  p.ink = const Color(0xFF5A1406);

  p.glow(pt(.5, .5), .44, orange, alpha: .4);
  // Long flame tail plumes sweeping down.
  for (final double k in <double>[-1, 0, 1]) {
    final Path plume = taper(
      <Offset>[
        pt(.5 + k * .04, .74),
        pt(.5 + k * .14, .82),
        pt(.5 + k * .24, .86),
        pt(.5 + k * .30, .80),
      ],
      <double>[.04, .04, .03, .012],
    );
    p.part(
      plume,
      k == 0 ? gold : orange,
      marks: () => p.flat(circle(.5 + k * .30, .80, .03), red),
    );
  }
  // Wings raised like flames.
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = blob(
      <Offset>[
        q(.14, .56),
        q(.22, .40),
        q(.30, .22),
        q(.34, .32),
        q(.40, .16),
        q(.42, .30),
        q(.46, .24),
        q(.44, .44),
        q(.34, .58),
      ],
      sharp: <int>{2, 4, 6},
    );
    p.part(
      w,
      red,
      shine: .5,
      marks: () => p.flat(
        blob(<Offset>[q(.20, .52), q(.28, .38), q(.36, .40), q(.32, .54)]),
        orange,
      ),
    );
  }
  birdFoot(p, .45, gold);
  birdFoot(p, .55, gold);
  final Path b = blob(<Offset>[
    pt(.5, .30),
    pt(.62, .34),
    pt(.66, .50),
    pt(.64, .66),
    pt(.56, .76),
    pt(.5, .78),
    pt(.44, .76),
    pt(.36, .66),
    pt(.34, .50),
    pt(.38, .34),
  ]);
  p.part(b, red, shine: .8, marks: () => p.flat(oval(.5, .64, .1, .12), gold));
  // A flame crest.
  for (final List<double> f in <List<double>>[
    <double>[-.35, .026],
    <double>[0, .032],
    <double>[.35, .026],
  ]) {
    p.part(
      tear(.5 + f[0] * .08, .26, f[1], angle: f[0], length: 2.4),
      gold,
      depth: .4,
    );
  }
  p.part(oval(.5, .38, .13, .115), red, shine: 1);
  p.eyes(.5, .37, .062, .042, iris: gold);
  p.part(
    blob(
      <Offset>[
        pt(.465, .415),
        pt(.535, .415),
        pt(.53, .45),
        pt(.5, .485),
        pt(.49, .45),
      ],
      sharp: <int>{3},
    ),
    gold,
    shine: .5,
    line: p.lw * .7,
  );
  p.cheeks(.5, .42, .1, .028);

  p.head(const Rect.fromLTRB(.37, .265, .63, .495), hatLift: .08);
  p.torso(const Rect.fromLTRB(.34, .40, .66, .78));
  p.collar(pt(.5, .50), .11);
}

// --------------------------------------------------------------- 28 leviathan

void _leviathan(Pen p) {
  const Color scale = Color(0xFF3E84B8);
  const Color belly = Color(0xFFE0F2D8);
  const Color fin = Color(0xFF6ACCD8);
  const Color sea = Color(0xFF7FD6EE);
  p.ink = const Color(0xFF0C2A44);

  // Coils arching out of the sea.
  for (final List<Offset> hump in <List<Offset>>[
    <Offset>[
      pt(.08, .84),
      pt(.13, .70),
      pt(.22, .66),
      pt(.31, .70),
      pt(.36, .84),
    ],
    <Offset>[
      pt(.38, .84),
      pt(.42, .68),
      pt(.50, .64),
      pt(.58, .68),
      pt(.60, .84),
    ],
  ]) {
    p.part(
      spikes(
        hump[2].dx,
        hump[2].dy - .045,
        .06,
        .04,
        3,
        .7,
        from: math.pi * 1.15,
        to: math.pi * 1.85,
        round: .005,
      ),
      fin,
      depth: .3,
    );
    p.part(
      taper(hump, <double>[.05, .055, .055, .055, .05]),
      scale,
      shine: .6,
      marks: () {
        for (final Offset c in hump.sublist(1, 4)) {
          p.flat(circle(c.dx, c.dy - .015, .012), lighter(scale, .12));
        }
      },
    );
  }
  // Frilled head on a neck rising from the sea, one shape.
  for (final double k in sides) {
    p.part(
      _fanShape(
        pt(.72 + k * .1, .34),
        .1,
        k < 0 ? math.pi * .8 : -math.pi * .2,
        k < 0 ? math.pi * 1.3 : math.pi * .2,
        3,
      ),
      fin,
      depth: .4,
    );
  }
  p.part(
    union(
      taper(
        <Offset>[pt(.62, .80), pt(.66, .58), pt(.70, .44)],
        <double>[.07, .065, .06],
      ),
      oval(.72, .36, .14, .12),
    ),
    scale,
    shine: 1,
    marks: () {
      p.flat(
        taper(
          <Offset>[pt(.67, .80), pt(.70, .60), pt(.74, .48)],
          <double>[.03, .028, .022],
        ),
        belly,
      );
      p.flat(oval(.74, .43, .09, .045), belly);
    },
  );
  for (final double k in sides) {
    p.part(
      taper(
        <Offset>[
          pt(.72 + k * .06, .26),
          pt(.72 + k * .1, .18),
          pt(.72 + k * .15, .16),
        ],
        <double>[.018, .012, .006],
      ),
      Kit.tooth,
      depth: .4,
    );
  }
  p.eyes(.72, .35, .06, .042, iris: const Color(0xFF6AE0D0));
  p.cheeks(.72, .40, .1, .028);
  p.smile(pt(.72, .425), .028, depth: .4);
  // The sea it rises from.
  final Path water = Path()..moveTo(.02, .82);
  for (int i = 0; i < 6; i++) {
    final double x = .02 + i * .16;
    water.quadraticBezierTo(x + .04, .77, x + .08, .80);
    water.quadraticBezierTo(x + .12, .83, x + .16, .80);
  }
  water
    ..lineTo(.98, .895)
    ..lineTo(.02, .895)
    ..close();
  p.part(
    water,
    sea,
    shine: .4,
    marks: () {
      for (int i = 0; i < 5; i++) {
        p.flat(
          oval(.12 + i * .18, .845, .03, .008),
          Kit.white.withValues(alpha: .7),
        );
      }
    },
  );

  p.head(const Rect.fromLTRB(.58, .24, .86, .48), hatLift: .06);
  p.torso(const Rect.fromLTRB(.06, .56, .80, .89));
  p.collar(pt(.69, .52), .07);
}

// ------------------------------------------------------------------- 29 dragon

void _dragon(Pen p) {
  const Color scale = Color(0xFFE8503A);
  const Color belly = Color(0xFFFFE0A8);
  const Color wing = Color(0xFFB8302A);
  const Color membrane = Color(0xFFFF9A6A);
  const Color horn = Color(0xFFFFF0D2);
  p.ink = const Color(0xFF4A0E06);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    final Path w = Path()
      ..moveTo(q(.14, .52).dx, q(.14, .52).dy)
      ..lineTo(q(.34, .20).dx, q(.34, .20).dy)
      ..quadraticBezierTo(
        q(.38, .36).dx,
        q(.38, .36).dy,
        q(.44, .48).dx,
        q(.44, .48).dy,
      )
      ..quadraticBezierTo(
        q(.36, .46).dx,
        q(.36, .46).dy,
        q(.32, .54).dx,
        q(.32, .54).dy,
      )
      ..quadraticBezierTo(
        q(.26, .48).dx,
        q(.26, .48).dy,
        q(.20, .56).dx,
        q(.20, .56).dy,
      )
      ..close();
    p.part(
      w,
      membrane,
      shine: .4,
      marks: () {
        for (final Offset f in <Offset>[q(.32, .54), q(.20, .56)]) {
          p.line(
            Path()
              ..moveTo(q(.34, .20).dx, q(.34, .20).dy)
              ..lineTo(f.dx, f.dy),
            width: .012,
            color: wing,
          );
        }
      },
    );
    p.tube(
      Path()
        ..moveTo(q(.14, .52).dx, q(.14, .52).dy)
        ..lineTo(q(.34, .20).dx, q(.34, .20).dy),
      .026,
      wing,
    );
  }
  final Path tail = taper(
    <Offset>[pt(.58, .84), pt(.78, .86), pt(.88, .76), pt(.86, .64)],
    <double>[.06, .045, .03, .02],
  );
  p.part(tail, scale);
  p.part(
    roundPoly(<Offset>[
      pt(.86, .66),
      pt(.80, .60),
      pt(.86, .52),
      pt(.92, .60),
    ], .01),
    wing,
  );
  // Back spikes peeking over the shoulders.
  p.part(
    spikes(
      .5,
      .58,
      .2,
      .16,
      5,
      .22,
      from: math.pi * 1.15,
      to: math.pi * 1.85,
      round: .008,
    ),
    belly,
    depth: .4,
  );
  final Path body = sitBody(
    p,
    fur: scale,
    feet: scale,
    paws: scale,
    rx: .18,
    ry: .16,
    marks: () {
      p.flat(oval(.5, .76, .11, .12), belly);
    },
  );
  p.inside(body, () {
    for (double y = .68; y < .88; y += .045) {
      p.line(
        Path()
          ..moveTo(.40, y)
          ..lineTo(.60, y),
        width: .007,
        color: darker(belly, .14),
      );
    }
  });
  for (final double k in sides) {
    p.part(
      taper(
        <Offset>[
          pt(.5 + k * .09, .30),
          pt(.5 + k * .15, .20),
          pt(.5 + k * .22, .16),
        ],
        <double>[.03, .02, .008],
      ),
      horn,
      depth: .4,
    );
    p.part(
      roundPoly(<Offset>[
        pt(.5 + k * .17, .38),
        pt(.5 + k * .28, .34),
        pt(.5 + k * .19, .45),
      ], .02),
      scale,
    );
  }
  p.part(
    oval(.5, .43, .2, .17),
    scale,
    shine: 1,
    marks: () => p.flat(oval(.5, .51, .11, .065), belly),
  );
  p.flat(oval(.475, .50, .01, .012), darker(scale, .3));
  p.flat(oval(.525, .50, .01, .012), darker(scale, .3));
  p.eyes(.5, .41, .085, .046, iris: const Color(0xFFFFC94A));
  p.cheeks(.5, .47, .14, .03);
  p.smile(pt(.5, .525), .035, depth: .4);
  p.fang(pt(.465, .54), .009);
  p.fang(pt(.535, .54), .009);

  p.head(const Rect.fromLTRB(.3, .26, .7, .60), hatLift: .04);
  p.collar(pt(.5, .60), .14);
}

// -------------------------------------------------------------- 30 elder dragon

void _elderDragon(Pen p) {
  const Color scale = Color(0xFF3FB88A);
  const Color belly = Color(0xFFFFE08A);
  const Color mane = Color(0xFFFF7A4A);
  const Color antler = Color(0xFFFFD25A);
  const Color pearl = Color(0xFFF2F0FF);
  p.ink = const Color(0xFF0E3A28);

  // Mane and antlers, behind the head.
  p.part(fluff(.56, .28, .14, .12, 9, depth: .12), mane, shine: .4);
  for (final double k in sides) {
    Offset q(double x, double y) => pt(.6 + k * x, y);
    p.tube(curve(<Offset>[q(.05, .20), q(.08, .12), q(.14, .07)]), .02, antler);
    p.tube(curve(<Offset>[q(.075, .135), q(.05, .07)]), .016, antler);
  }
  // A long serpentine body coiled in an S, eastern style.
  final List<Offset> spine = <Offset>[
    pt(.10, .74),
    pt(.18, .86),
    pt(.36, .87),
    pt(.52, .80),
    pt(.54, .66),
    pt(.42, .56),
    pt(.42, .44),
    pt(.52, .36),
  ];
  for (int i = 2; i < spine.length - 1; i++) {
    final Offset c = spine[i];
    p.part(
      tear(c.dx - .045, c.dy - .05, .025, angle: -.8, length: 2.0),
      mane,
      depth: .3,
    );
  }
  final Path body = unite(<Path>[
    taper(spine, <double>[.012, .04, .055, .065, .07, .07, .07, .07]),
    oval(.62, .30, .14, .115),
    oval(.76, .345, .085, .062),
  ]);
  p.part(
    body,
    scale,
    shine: .8,
    marks: () {
      p.flat(oval(.77, .38, .07, .028), belly);
      p.flat(
        taper(
          spine.map((Offset o) => o.translate(.022, .018)).toList(),
          <double>[.004, .016, .024, .028, .03, .03, .03, .03],
        ),
        belly,
      );
      for (int i = 1; i < spine.length - 1; i++) {
        p.flat(
          circle(spine[i].dx - .02, spine[i].dy - .02, .01),
          lighter(scale, .12),
        );
      }
    },
  );
  p.part(
    roundPoly(<Offset>[pt(.10, .74), pt(.04, .66), pt(.14, .70)], .008),
    mane,
    depth: .3,
  );
  for (final Offset l in <Offset>[pt(.30, .86)]) {
    p.tube(curve(<Offset>[l, l.translate(.04, .02)]), .028, scale);
    p.part(oval(l.dx + .05, l.dy + .025, .025, .016), antler, depth: .4);
  }
  // A claw clutching its pearl.
  p.glow(pt(.78, .64), .12, const Color(0xFFD8D0FF), alpha: .8);
  p.tube(
    curve(<Offset>[pt(.56, .64), pt(.66, .67), pt(.72, .66)]),
    .032,
    scale,
  );
  p.part(circle(.78, .63, .058), pearl, shine: 1.6);
  for (final double a in <double>[-.9, 0, .9]) {
    p.tube(
      curve(<Offset>[
        pt(.73, .66),
        pt(.75 + math.cos(a) * .02, .68 + math.sin(a) * .02),
      ]),
      .014,
      antler,
    );
  }
  p.flat(oval(.83, .325, .009, .012), darker(scale, .35));
  // Long flowing whiskers.
  for (final double d in <double>[0, .035]) {
    p.tube(
      curve(<Offset>[
        pt(.80, .36 + d),
        pt(.88, .34 + d * 2),
        pt(.94, .42 + d * 2),
        pt(.92, .50 + d),
      ]),
      .009,
      antler,
    );
  }
  p.eyes(.62, .29, .055, .04, iris: const Color(0xFFE0A83A));
  p.cheeks(.62, .34, .09, .026);
  p.smile(pt(.75, .385), .022, depth: .4);
  p.twinkle(pt(.88, .76), .025, antler);
  p.twinkle(pt(.18, .40), .022, antler);

  p.head(const Rect.fromLTRB(.48, .185, .85, .41), hatLift: .07, hatX: .62);
  p.torso(const Rect.fromLTRB(.1, .36, .58, .88));
  p.collar(pt(.58, .43), .07);
}
