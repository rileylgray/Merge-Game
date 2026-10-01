import 'dart:math' as math;
import 'dart:ui';

import 'creature_art.dart';
import 'kit.dart';
import 'parts.dart';

/// Day Meadow — sun-warmed grassland and woodland critters, from a ladybug in
/// the grass up to a storybook stag.
const Map<String, CreatureArt> dayArt = <String, CreatureArt>{
  'day_01': CreatureArt(_ladybug, shadow: .27),
  'day_02': CreatureArt(_bee, shadow: .24),
  'day_03': CreatureArt(_butterfly, shadow: .18),
  'day_04': CreatureArt(_snail, shadow: .36),
  'day_05': CreatureArt(_mouse, shadow: .22),
  'day_06': CreatureArt(_chick, shadow: .25),
  'day_07': CreatureArt(_bunny, shadow: .22),
  'day_08': CreatureArt(_squirrel, shadow: .26),
  'day_09': CreatureArt(_hedgehog, shadow: .28),
  'day_10': CreatureArt(_duckling, shadow: .28),
  'day_11': CreatureArt(_frog, shadow: .32),
  'day_12': CreatureArt(_tortoise, shadow: .36),
  'day_13': CreatureArt(_fox, shadow: .27),
  'day_14': CreatureArt(_piglet, shadow: .24),
  'day_15': CreatureArt(_lamb, shadow: .25),
  'day_16': CreatureArt(_goat, shadow: .23),
  'day_17': CreatureArt(_raccoon, shadow: .28),
  'day_18': CreatureArt(_otter, shadow: .26),
  'day_19': CreatureArt(_fawn, shadow: .30),
  'day_20': CreatureArt(_koala, shadow: .24),
  'day_21': CreatureArt(_redPanda, shadow: .28),
  'day_22': CreatureArt(_sloth, shadow: .16),
  'day_23': CreatureArt(_zebra, shadow: .30),
  'day_24': CreatureArt(_giraffe, shadow: .30),
  'day_25': CreatureArt(_panda, shadow: .26),
  'day_26': CreatureArt(_lion, shadow: .26),
  'day_27': CreatureArt(_elephant, shadow: .28),
  'day_28': CreatureArt(_rhino, shadow: .36),
  'day_29': CreatureArt(_grizzly, shadow: .28),
  'day_30': CreatureArt(_stag, shadow: .30),
};

// ------------------------------------------------------------------ 1 ladybug

void _ladybug(Pen p) {
  const Color red = Color(0xFFF0504A);
  const Color black = Color(0xFF3B3140);
  p.ink = const Color(0xFF3A1820);

  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .07, .30),
        pt(.5 + k * .11, .20),
        pt(.5 + k * .17, .15),
      ]),
      .016,
      black,
    );
    p.part(circle(.5 + k * .17, .15, .032), black, depth: 0);
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .24, .74),
        pt(.5 + k * .33, .80),
        pt(.5 + k * .34, .87),
      ]),
      .022,
      black,
    );
    p.part(oval(.5 + k * .11, .885, .06, .032), black, depth: 0);
  }
  final Path shell = oval(.5, .635, .31, .255);
  p.part(
    shell,
    red,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(circle(.5 + k * .17, .60, .052), black);
        p.flat(circle(.5 + k * .225, .75, .04), black);
        p.flat(circle(.5 + k * .09, .80, .046), black);
      }
    },
  );
  p.line(
    Path()
      ..moveTo(.5, .50)
      ..lineTo(.5, .89),
    width: p.lw,
  );
  final Path head = oval(.5, .43, .2, .165);
  p.part(head, black, shine: .7);
  p.eyes(
    .5,
    .425,
    .08,
    .046,
    rim: const Color(0xFFFFFBF5),
    iris: const Color(0xFF8A5CFF),
  );
  p.cheeks(.5, .495, .14, .035, alpha: .85);
  p.line(
    Path()
      ..moveTo(.478, .5)
      ..quadraticBezierTo(.5, .525, .522, .5),
    color: const Color(0xFFFFB3C0),
    width: p.lw * .7,
  );

  p.head(const Rect.fromLTRB(.30, .265, .70, .595));
  p.torso(const Rect.fromLTRB(.19, .38, .81, .89));
  p.collar(pt(.5, .585), .17);
}

// ------------------------------------------------------------------- 2 bee

void _bee(Pen p) {
  const Color yellow = Color(0xFFFFCF40);
  const Color brown = Color(0xFF5A3D2E);
  const Color wing = Color(0xEBEAF7FF);
  p.ink = const Color(0xFF4A2E1C);

  for (final double k in sides) {
    p.part(
      turn(oval(.5 + k * .21, .36, .14, .095), pt(.5 + k * .21, .36), k * .55),
      wing,
      depth: .5,
      shine: .8,
    );
    p.part(
      turn(oval(.5 + k * .27, .48, .09, .06), pt(.5 + k * .27, .48), k * .25),
      wing,
      depth: .5,
    );
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .06, .40),
        pt(.5 + k * .09, .27),
        pt(.5 + k * .15, .20),
      ]),
      .016,
      brown,
    );
    p.part(circle(.5 + k * .15, .20, .03), brown, depth: 0);
  }
  p.part(
    roundPoly(<Offset>[pt(.46, .86), pt(.54, .86), pt(.5, .93)], .01),
    brown,
    depth: 0,
  );
  final Path body = oval(.5, .62, .285, .265);
  p.part(
    body,
    yellow,
    shine: 1,
    marks: () {
      p.line(
        curve(<Offset>[pt(.18, .70), pt(.5, .75), pt(.82, .70)]),
        width: .065,
        color: brown,
      );
      p.line(
        curve(<Offset>[pt(.22, .84), pt(.5, .89), pt(.78, .84)]),
        width: .06,
        color: brown,
      );
    },
  );
  p.sweetFace(.5, .55, .1, .052, iris: const Color(0xFF9A6A3A));

  p.head(const Rect.fromLTRB(.24, .36, .76, .70));
  p.torso(const Rect.fromLTRB(.215, .355, .785, .885));
  p.collar(pt(.5, .70), .22);
}

// -------------------------------------------------------------- 3 butterfly

void _butterfly(Pen p) {
  const Color pink = Color(0xFFFF95C5);
  const Color pinkLight = Color(0xFFFFD6E8);
  const Color lilac = Color(0xFFB99AF2);
  const Color body = Color(0xFF7B63C2);
  const Color headColor = Color(0xFFA48CE6);
  p.ink = const Color(0xFF3E2766);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * (.5 - x), y);
    final Path upper = blob(<Offset>[
      q(.47, .52),
      q(.40, .30),
      q(.27, .16),
      q(.13, .17),
      q(.08, .30),
      q(.14, .46),
      q(.30, .56),
    ]);
    final Path lower = blob(<Offset>[
      q(.47, .58),
      q(.31, .57),
      q(.17, .65),
      q(.18, .80),
      q(.30, .85),
      q(.43, .76),
    ]);
    p.part(
      lower,
      lilac,
      shine: .5,
      marks: () {
        p.flat(oval(.5 + k * .19, .72, .07, .06), const Color(0xFFE2D4FF));
        p.flat(circle(.5 + k * .24, .78, .022), Kit.white);
      },
    );
    p.part(
      upper,
      pink,
      shine: .8,
      marks: () {
        p.flat(oval(.5 + k * .24, .36, .10, .12), pinkLight);
        p.flat(circle(.5 + k * .33, .24, .03), Kit.white);
        p.flat(circle(.5 + k * .37, .33, .02), Kit.white);
      },
    );
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .04, .32),
        pt(.5 + k * .07, .2),
        pt(.5 + k * .13, .14),
      ]),
      .014,
      body,
    );
    p.part(circle(.5 + k * .13, .14, .026), pink, depth: 0);
  }
  p.part(oval(.5, .66, .058, .17), body, shine: .6);
  p.part(circle(.5, .41, .125), headColor, shine: 1);
  p.sweetFace(.5, .42, .055, .038, iris: const Color(0xFF5A3A9A));

  p.head(const Rect.fromLTRB(.375, .285, .625, .535), hatLift: .02);
  p.torso(const Rect.fromLTRB(.42, .5, .58, .83));
  p.collar(pt(.5, .53), .07);
}

// ------------------------------------------------------------------ 4 snail

void _snail(Pen p) {
  const Color skin = Color(0xFFC9E59B);
  const Color shellColor = Color(0xFFF2A45A);
  const Color shellLight = Color(0xFFFFD08A);
  p.ink = const Color(0xFF4A3420);

  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.76 + k * .05, .44),
        pt(.77 + k * .07, .32),
        pt(.78 + k * .1, .25),
      ]),
      .02,
      skin,
    );
    p.part(circle(.78 + k * .1, .25, .028), skin, depth: 0);
  }
  final Path foot = blob(<Offset>[
    pt(.07, .885),
    pt(.12, .82),
    pt(.40, .80),
    pt(.62, .74),
    pt(.64, .56),
    pt(.70, .43),
    pt(.80, .40),
    pt(.90, .45),
    pt(.92, .58),
    pt(.88, .74),
    pt(.93, .86),
    pt(.85, .895),
    pt(.40, .895),
  ]);
  p.part(foot, skin, shine: .8);
  final Path shell = circle(.40, .565, .245);
  final List<Offset> spiral = <Offset>[
    for (int i = 0; i <= 36; i++)
      pt(
        .415 + math.cos(i * .29 + 2.4) * .012 * math.exp(i * .078),
        .585 + math.sin(i * .29 + 2.4) * .012 * math.exp(i * .078),
      ),
  ];
  p.part(
    shell,
    shellColor,
    shine: 1,
    marks: () => p.line(curve(spiral), width: .05, color: shellLight),
  );
  p.line(curve(spiral), width: p.lw * .9);
  p.eyes(.775, .54, .052, .042, iris: const Color(0xFF6A8A3A));
  p.cheeks(.775, .595, .085, .03);
  p.smile(pt(.775, .595), .02);

  p.head(const Rect.fromLTRB(.66, .40, .92, .66), hatLift: .03);
  p.torso(const Rect.fromLTRB(.16, .32, .92, .89));
  p.collar(pt(.75, .69), .1);
}

// ------------------------------------------------------------------- 5 mouse

void _mouse(Pen p) {
  const Color fur = Color(0xFFC6A587);
  const Color belly = Color(0xFFFFF1DF);
  const Color pink = Color(0xFFFFB3B8);
  const Color cheese = Color(0xFFFFD45C);
  p.ink = inkOf(fur);

  p.tube(
    curve(<Offset>[
      pt(.6, .85),
      pt(.78, .87),
      pt(.88, .76),
      pt(.84, .64),
      pt(.77, .62),
    ]),
    .024,
    pink,
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .215, .26), .13, fur, pink, innerScale: .63);
  }
  sitBody(
    p,
    fur: fur,
    belly: belly,
    feet: pink,
    showPaws: false,
    rx: .17,
    ry: .165,
  );
  // A wedge of cheese held up in both paws.
  final Path wedge = roundPoly(<Offset>[
    pt(.42, .74),
    pt(.58, .66),
    pt(.60, .75),
    pt(.44, .80),
  ], .012);
  p.part(
    wedge,
    cheese,
    marks: () {
      p.flat(circle(.50, .745, .016), darker(cheese, .12));
      p.flat(circle(.555, .72, .011), darker(cheese, .12));
      p.flat(
        roundPoly(<Offset>[
          pt(.42, .74),
          pt(.58, .66),
          pt(.60, .70),
          pt(.43, .77),
        ], .01),
        lighter(cheese, .08),
      );
    },
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .085, .73, .036, .032), pink, depth: .4);
  }
  final Path head = oval(.5, .43, .225, .19);
  p.part(
    head,
    fur,
    shine: 1,
    marks: () => p.flat(oval(.5, .53, .12, .085), belly),
  );
  whiskers(p, pt(.5, .512), .07, .13, spread: .016);
  p.eyes(.5, .43, .085, .048);
  p.cheeks(.5, .495, .135, .035);
  p.nose(pt(.5, .495), .022, color: const Color(0xFFF07F96));
  p.catMouth(pt(.5, .53), .02);

  p.head(const Rect.fromLTRB(.275, .24, .725, .62));
  p.collar(pt(.5, .615), .13);
}

// ------------------------------------------------------------------- 6 chick

void _chick(Pen p) {
  const Color yellow = Color(0xFFFFD447);
  const Color orange = Color(0xFFFF9A3C);
  const Color shell = Color(0xFFFFF9EE);
  p.ink = const Color(0xFF5A3A12);

  for (final double a in <double>[-.45, 0, .45]) {
    p.part(
      turn(leaf(pt(.5, .33), pt(.5, .19), .06), pt(.5, .33), a),
      yellow,
      depth: .5,
    );
  }
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(.5 + k * .2, .55), pt(.5 + k * .31, .67), .1),
        pt(.5 + k * .2, .55),
        k * -.2,
      ),
      yellow,
    );
  }
  p.part(circle(.5, .54, .245), yellow, shine: 1);
  p.sweetFace(.5, .5, .085, .046, iris: const Color(0xFF8A5A2A), mouth: false);
  p.part(
    roundPoly(<Offset>[pt(.465, .555), pt(.535, .555), pt(.5, .6)], .012),
    orange,
    depth: .5,
    line: p.lw * .7,
  );
  final Path cup = Path()..moveTo(.235, .66);
  for (int i = 1; i <= 8; i++) {
    cup.lineTo(.235 + i * .53 / 8, i.isEven ? .66 : .71);
  }
  cup
    ..cubicTo(.78, .82, .66, .895, .5, .895)
    ..cubicTo(.34, .895, .22, .82, .235, .66)
    ..close();
  p.part(
    cup,
    shell,
    shine: .6,
    marks: () {
      p.flat(circle(.36, .8, .022), const Color(0xFFFFE3C2));
      p.flat(circle(.62, .84, .016), const Color(0xFFFFE3C2));
    },
  );

  p.head(const Rect.fromLTRB(.255, .295, .745, .66), hatLift: .04);
  p.torso(const Rect.fromLTRB(.23, .40, .77, .89));
  p.collar(pt(.5, .64), .17);
}

// ------------------------------------------------------------------- 7 bunny

void _bunny(Pen p) {
  const Color fur = Color(0xFFFCF3EC);
  const Color inner = Color(0xFFFFB5C5);
  p.ink = const Color(0xFF5B4049);

  p.part(fluff(.685, .80, .05, .045, 7, depth: .18), Kit.white);
  // One ear up, one with a little flop.
  p.part(leaf(pt(.42, .32), pt(.37, .05), .115, bend: .01), fur, shine: .4);
  p.part(leaf(pt(.42, .29), pt(.38, .10), .055), inner, depth: .4, line: 0);
  final Path flop = blob(<Offset>[
    pt(.53, .31),
    pt(.57, .15),
    pt(.64, .07),
    pt(.75, .10),
    pt(.71, .15),
    pt(.64, .20),
    pt(.63, .32),
  ]);
  p.part(flop, fur, shine: .4);
  p.part(
    blob(<Offset>[
      pt(.565, .28),
      pt(.595, .16),
      pt(.65, .11),
      pt(.70, .12),
      pt(.62, .2),
      pt(.60, .29),
    ]),
    inner,
    depth: .4,
    line: 0,
  );

  sitBody(
    p,
    fur: fur,
    belly: Kit.white,
    rx: .165,
    ry: .15,
    cy: .74,
    footW: .074,
  );
  p.part(oval(.5, .45, .225, .19), fur, shine: 1);
  p.eyes(.5, .455, .088, .048);
  p.cheeks(.5, .52, .14, .036);
  p.part(
    rrect(.486, .535, .514, .572, .007),
    Kit.tooth,
    depth: 0,
    line: p.lw * .5,
  );
  p.line(
    Path()
      ..moveTo(.5, .537)
      ..lineTo(.5, .57),
    width: p.lw * .4,
  );
  p.nose(pt(.5, .512), .019, color: Kit.nosePink);
  p.catMouth(pt(.5, .535), .02);

  p.head(const Rect.fromLTRB(.275, .26, .725, .64), hatLift: .02);
  p.collar(pt(.5, .635), .13);
}

// ---------------------------------------------------------------- 8 squirrel

void _squirrel(Pen p) {
  const Color fur = Color(0xFFDA824A);
  const Color belly = Color(0xFFFFE8D0);
  const Color dark = Color(0xFF9C5228);
  const double cx = .57;
  p.ink = inkOf(fur);

  // A big bushy plume: slim at the root, swelling as it climbs, with a
  // tufted edge and a flick at the tip.
  final List<Offset> spine = <Offset>[
    pt(.44, .82),
    pt(.28, .78),
    pt(.18, .62),
    pt(.17, .42),
    pt(.24, .26),
    pt(.36, .17),
    pt(.46, .18),
  ];
  final Path tail = puffs(spine, <double>[
    .05,
    .075,
    .1,
    .12,
    .115,
    .09,
    .06,
  ], spacing: .7);
  p.part(
    tail,
    fur,
    shine: .6,
    marks: () {
      p.flat(
        taper(
          spine.sublist(1, 6).map((Offset o) => o.translate(.02, .01)).toList(),
          <double>[.02, .04, .05, .045, .02],
        ),
        lighter(fur, .08),
      );
    },
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(cx + k * .125, .29),
      pt(cx + k * .165, .14),
      .1,
      fur,
      belly,
      round: .025,
      tipColor: dark,
    );
  }
  sitBody(
    p,
    cx: cx,
    fur: fur,
    belly: belly,
    feet: dark,
    showPaws: false,
    rx: .16,
    ry: .155,
  );
  // An acorn held to the chest.
  p.part(oval(cx, .71, .048, .056), const Color(0xFFC98C4E), shine: .8);
  final Path cap = oval(cx, .662, .062, .03);
  p.part(
    cap,
    const Color(0xFF7D4D2B),
    marks: () {
      for (double x = cx - .06; x < cx + .07; x += .025) {
        p.line(
          Path()
            ..moveTo(x, .63)
            ..lineTo(x + .02, .695),
          width: p.lw * .35,
          color: const Color(0xFF5E381E),
        );
      }
    },
  );
  p.tube(
    curve(<Offset>[pt(cx, .635), pt(cx + .008, .615), pt(cx + .022, .605)]),
    .012,
    const Color(0xFF7D4D2B),
  );
  for (final double k in sides) {
    p.part(oval(cx + k * .06, .705, .034, .03), fur, depth: .4);
  }
  p.part(
    oval(cx, .43, .215, .185),
    fur,
    shine: 1,
    marks: () => p.flat(oval(cx, .53, .105, .075), belly),
  );
  p.eyes(cx, .43, .085, .047);
  p.cheeks(cx, .49, .135, .034);
  p.nose(pt(cx, .5), .018);
  p.catMouth(pt(cx, .53), .018);

  p.head(const Rect.fromLTRB(cx - .215, .245, cx + .215, .615), hatLift: .03);
  p.collar(pt(cx, .61), .13);
}

// --------------------------------------------------------------- 9 hedgehog

void _hedgehog(Pen p) {
  const Color quill = Color(0xFF8E6A4C);
  const Color quillTip = Color(0xFFBF9C7A);
  const Color face = Color(0xFFFCE4C8);
  const Color pink = Color(0xFFF4BBA6);
  p.ink = const Color(0xFF3E2A1C);

  final Path back = spikes(
    .5,
    .62,
    .31,
    .27,
    14,
    .2,
    from: math.pi * .78,
    to: math.pi * 2.22,
    round: .012,
  );
  p.part(
    back,
    quill,
    shine: .5,
    marks: () {
      for (int i = 0; i < 11; i++) {
        final double a = math.pi * (.92 + i * .118);
        final Offset c = pt(.5 + math.cos(a) * .2, .62 + math.sin(a) * .17);
        p.line(
          Path()
            ..moveTo(c.dx, c.dy)
            ..lineTo(c.dx + math.cos(a) * .06, c.dy + math.sin(a) * .055),
          width: .014,
          color: quillTip,
        );
      }
    },
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .085, .885, .058, .032), pink, depth: .5);
  }
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .135, .465), .045, face, pink);
  }
  final Path muzzle = union(oval(.5, .64, .2, .18), oval(.5, .73, .085, .065));
  p.part(muzzle, face, shine: .8);
  for (final double k in sides) {
    p.part(oval(.5 + k * .1, .80, .035, .03), pink, depth: .4);
  }
  p.eyes(.5, .615, .085, .045);
  p.cheeks(.5, .69, .14, .035);
  p.nose(pt(.5, .73), .03);
  p.smile(pt(.5, .772), .022);

  p.head(const Rect.fromLTRB(.30, .40, .70, .80), hatLift: .06);
  p.torso(const Rect.fromLTRB(.19, .40, .81, .89));
  p.collar(pt(.5, .80), .14);
}

// --------------------------------------------------------------- 10 duckling

void _duckling(Pen p) {
  const Color yellow = Color(0xFFFFE066);
  const Color bill = Color(0xFFFF9B3D);
  p.ink = const Color(0xFF5E4214);

  for (final double x in <double>[.40, .56]) {
    p.part(
      roundPoly(<Offset>[
        pt(x - .015, .85),
        pt(x + .07, .895),
        pt(x - .065, .895),
      ], .012),
      bill,
      depth: .5,
    );
  }
  final Path body = blob(
    <Offset>[
      pt(.14, .54),
      pt(.26, .60),
      pt(.45, .58),
      pt(.68, .62),
      pt(.77, .74),
      pt(.69, .86),
      pt(.46, .89),
      pt(.26, .85),
      pt(.17, .74),
      pt(.15, .63),
    ],
    sharp: <int>{0},
  );
  p.part(body, yellow, shine: .6);
  // A little wing with scalloped feather tips.
  final Path wing = Path()
    ..moveTo(.56, .68)
    ..cubicTo(.54, .62, .40, .61, .30, .66)
    ..quadraticBezierTo(.34, .70, .33, .73)
    ..quadraticBezierTo(.38, .74, .38, .77)
    ..quadraticBezierTo(.44, .77, .45, .80)
    ..cubicTo(.52, .80, .58, .75, .56, .68)
    ..close();
  p.part(wing, darker(yellow, .04), shine: .4);
  for (final double a in <double>[-.4, 0, .4]) {
    p.part(
      turn(leaf(pt(.60, .265), pt(.60, .19), .035), pt(.60, .265), a),
      yellow,
      depth: .4,
    );
  }
  p.part(circle(.60, .42, .175), yellow, shine: 1);
  p.eyes(.62, .405, .068, .042);
  p.blush(pt(.53, .47), .03);
  p.part(
    blob(<Offset>[
      pt(.64, .465),
      pt(.75, .445),
      pt(.86, .46),
      pt(.875, .495),
      pt(.77, .53),
      pt(.65, .52),
    ]),
    bill,
    shine: .5,
  );
  p.line(
    curve(<Offset>[pt(.67, .49), pt(.77, .495), pt(.86, .48)]),
    width: p.lw * .5,
  );

  p.head(const Rect.fromLTRB(.425, .245, .775, .595), hatLift: .02);
  p.torso(const Rect.fromLTRB(.15, .56, .77, .89));
  p.collar(pt(.58, .60), .13);
}

// ------------------------------------------------------------------ 11 frog

void _frog(Pen p) {
  const Color green = Color(0xFF7ACB5D);
  const Color belly = Color(0xFFEAF7C6);
  p.ink = inkOf(green);

  for (final double k in sides) {
    p.part(oval(.5 + k * .27, .80, .1, .08), green, shine: .4);
    p.part(
      blob(<Offset>[
        pt(.5 + k * .24, .86),
        pt(.5 + k * .37, .855),
        pt(.5 + k * .41, .895),
        pt(.5 + k * .22, .895),
      ]),
      green,
      depth: .5,
    );
  }
  final Path body = union(
    oval(.5, .66, .31, .22),
    union(circle(.36, .45, .105), circle(.64, .45, .105)),
  );
  p.part(
    body,
    green,
    shine: 1,
    marks: () {
      p.flat(oval(.5, .81, .21, .12), belly);
      p.flat(circle(.30, .62, .022), darker(green, .08));
      p.flat(circle(.72, .60, .016), darker(green, .08));
      p.flat(circle(.69, .67, .012), darker(green, .08));
    },
  );
  for (final double k in sides) {
    p.part(
      blob(<Offset>[
        pt(.5 + k * .07, .83),
        pt(.5 + k * .15, .83),
        pt(.5 + k * .19, .895),
        pt(.5 + k * .04, .895),
      ]),
      green,
      depth: .5,
    );
  }
  p.eyes(.5, .455, .14, .056);
  p.cheeks(.5, .58, .2, .045);
  p.line(
    curve(<Offset>[pt(.40, .575), pt(.5, .615), pt(.60, .575)]),
    width: p.lw * .85,
  );

  p.head(const Rect.fromLTRB(.25, .345, .75, .64), hatLift: .0);
  p.torso(const Rect.fromLTRB(.19, .44, .81, .89));
  p.collar(pt(.5, .66), .22);
}

// -------------------------------------------------------------- 12 tortoise

void _tortoise(Pen p) {
  const Color shell = Color(0xFF8DBE5B);
  const Color plate = Color(0xFFB5D978);
  const Color rim = Color(0xFFD9B967);
  const Color skin = Color(0xFFD7C890);
  p.ink = const Color(0xFF3D3A1C);

  stubLeg(p, .33, .72, .085, darker(skin, .07));
  stubLeg(p, .61, .72, .085, darker(skin, .07));
  p.part(
    roundPoly(<Offset>[pt(.17, .74), pt(.07, .79), pt(.18, .80)], .012),
    skin,
  );
  p.part(
    union(
      blob(<Offset>[
        pt(.66, .76),
        pt(.70, .64),
        pt(.78, .58),
        pt(.84, .66),
        pt(.78, .78),
      ]),
      oval(.835, .53, .115, .105),
    ),
    skin,
    shine: 1,
  );
  p.eyes(.845, .52, .047, .037);
  p.blush(pt(.89, .57), .025);
  p.smile(pt(.865, .575), .02);

  final Path dome = blob(
    <Offset>[
      pt(.11, .76),
      pt(.16, .56),
      pt(.29, .40),
      pt(.45, .355),
      pt(.61, .40),
      pt(.72, .54),
      pt(.77, .76),
    ],
    sharp: <int>{0, 6},
  );
  p.part(
    dome,
    shell,
    shine: 1,
    marks: () {
      final List<Offset> hex = ring(.44, .57, .1, .09, 6, start: 0);
      p.flat(poly(hex), plate);
      p.flat(
        roundPoly(<Offset>[pt(.12, .66), pt(.22, .58), pt(.26, .74)], .02),
        plate,
      );
      p.flat(
        roundPoly(<Offset>[pt(.66, .60), pt(.76, .66), pt(.62, .74)], .02),
        plate,
      );
      p.flat(
        roundPoly(<Offset>[
          pt(.33, .38),
          pt(.55, .38),
          pt(.50, .47),
          pt(.38, .47),
        ], .02),
        plate,
      );
      p.canvas.drawPath(poly(hex), strokeOf(darker(shell, .16), .014));
      for (int i = 0; i < 6; i++) {
        final Offset a = hex[i];
        final Offset b = pt(.44 + (a.dx - .44) * 3, .57 + (a.dy - .57) * 3);
        p.line(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy),
          width: .014,
          color: darker(shell, .16),
        );
      }
    },
  );
  for (final double x in <double>[.24, .64]) {
    stubLeg(p, x, .74, .095, skin);
  }
  final Path band = rrect(.09, .725, .79, .79, .032);
  p.part(
    band,
    rim,
    marks: () {
      for (double x = .18; x < .79; x += .1) {
        p.line(
          Path()
            ..moveTo(x, .725)
            ..lineTo(x, .79),
          width: .012,
          color: darker(rim, .14),
        );
      }
    },
  );

  p.head(const Rect.fromLTRB(.72, .425, .95, .635), hatLift: .0);
  p.torso(const Rect.fromLTRB(.11, .36, .77, .80));
  p.collar(pt(.79, .64), .07);
}

// ---------------------------------------------------------------- 13 fox cub

void _fox(Pen p) {
  const Color fur = Color(0xFFF2853F);
  const Color cream = Color(0xFFFFF4E6);
  const Color dark = Color(0xFF5A2E1E);
  p.ink = inkOf(fur);

  final Path tail = blob(<Offset>[
    pt(.60, .87),
    pt(.78, .86),
    pt(.90, .74),
    pt(.92, .56),
    pt(.86, .44),
    pt(.78, .47),
    pt(.76, .60),
    pt(.70, .74),
  ]);
  p.part(
    tail,
    fur,
    shine: .5,
    marks: () => p.flat(circle(.865, .45, .075), cream),
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .155, .31),
      pt(.5 + k * .23, .12),
      .15,
      fur,
      cream,
      round: .03,
      tipColor: dark,
    );
  }
  sitBody(
    p,
    fur: fur,
    belly: cream,
    feet: dark,
    paws: dark,
    rx: .165,
    ry: .155,
  );
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
      p.flat(
        sym(
          <Offset>[
            pt(.5, .475),
            pt(.57, .46),
            pt(.66, .47),
            pt(.77, .53),
            pt(.66, .585),
            pt(.5, .625),
          ],
          sharp: <int>{3},
        ),
        cream,
      );
    },
  );
  p.eyes(.5, .43, .09, .048);
  p.cheeks(.5, .50, .15, .034);
  p.nose(pt(.5, .5), .024);
  p.catMouth(pt(.5, .535), .02);

  p.head(const Rect.fromLTRB(.25, .25, .75, .62), hatLift: .02);
  p.collar(pt(.5, .61), .14);
}

// ---------------------------------------------------------------- 14 piglet

void _piglet(Pen p) {
  const Color pink = Color(0xFFFFB3C2);
  const Color snout = Color(0xFFFF8FA7);
  p.ink = const Color(0xFF6E2F43);

  p.tube(
    curve(<Offset>[
      pt(.64, .79),
      pt(.74, .78),
      pt(.77, .71),
      pt(.72, .675),
      pt(.69, .72),
      pt(.75, .765),
      pt(.83, .74),
    ]),
    .02,
    pink,
  );
  for (final double k in sides) {
    final Path ear = roundPoly(<Offset>[
      pt(.5 + k * .09, .30),
      pt(.5 + k * .26, .17),
      pt(.5 + k * .24, .36),
    ], .035);
    p.part(
      ear,
      pink,
      marks: () => p.flat(
        roundPoly(<Offset>[
          pt(.5 + k * .14, .29),
          pt(.5 + k * .245, .20),
          pt(.5 + k * .23, .32),
        ], .02),
        snout,
      ),
    );
  }
  sitBody(
    p,
    fur: pink,
    belly: lighter(pink, .05),
    feet: snout,
    rx: .18,
    ry: .155,
  );
  for (final double k in sides) {
    p.line(
      Path()
        ..moveTo(.5 + k * .085, .865)
        ..lineTo(.5 + k * .085, .905),
      width: p.lw * .5,
    );
  }
  p.part(oval(.5, .45, .235, .195), pink, shine: 1);
  p.eyes(.5, .425, .1, .046);
  p.cheeks(.5, .495, .16, .04);
  p.part(
    oval(.5, .52, .075, .052),
    snout,
    shine: .7,
    marks: () {
      p.flat(oval(.476, .52, .012, .019), darker(snout, .22));
      p.flat(oval(.524, .52, .012, .019), darker(snout, .22));
    },
  );
  p.smile(pt(.5, .59), .02);

  p.head(const Rect.fromLTRB(.265, .255, .735, .645), hatLift: .02);
  p.collar(pt(.5, .64), .14);
}

// ------------------------------------------------------------------ 15 lamb

void _lamb(Pen p) {
  const Color wool = Color(0xFFFFFCF6);
  const Color face = Color(0xFFF6DCCB);
  const Color hoof = Color(0xFF5E5260);
  p.ink = const Color(0xFF5A4650);

  for (final double k in sides) {
    leg(p, .5 + k * .085, .76, .062, face, hoof: hoof);
  }
  p.part(fluff(.5, .69, .23, .165, 11, depth: .12), wool, shine: .6);
  for (final double k in sides) {
    final Path ear = leaf(
      pt(.5 + k * .1, .43),
      pt(.5 + k * .30, .48),
      .085,
      bend: k * -.012,
    );
    p.part(
      ear,
      face,
      marks: () => p.flat(
        leaf(pt(.5 + k * .15, .445), pt(.5 + k * .28, .475), .04),
        Kit.blush.withValues(alpha: .7),
      ),
    );
  }
  p.part(oval(.5, .46, .155, .15), face, shine: 1);
  p.part(fluff(.5, .325, .115, .062, 7, depth: .22), wool, shine: .6);
  p.eyes(.5, .465, .065, .042);
  p.cheeks(.5, .53, .1, .03);
  p.nose(pt(.5, .525), .017, color: const Color(0xFFC98A86));
  p.catMouth(pt(.5, .553), .017);

  p.head(const Rect.fromLTRB(.345, .27, .655, .61), hatLift: .0);
  p.torso(const Rect.fromLTRB(.27, .53, .73, .86));
  p.collar(pt(.5, .61), .12);
}

// --------------------------------------------------------------- 16 kid goat

void _goat(Pen p) {
  const Color fur = Color(0xFFF3ECE2);
  const Color patch = Color(0xFFC9A27E);
  const Color horn = Color(0xFFBDAA8E);
  const Color muzzle = Color(0xFFF9DCD2);
  p.ink = const Color(0xFF5A4636);

  for (final double k in sides) {
    p.part(
      leaf(pt(.5 + k * .085, .30), pt(.5 + k * .165, .12), .06, bend: k * .025),
      horn,
      marks: () {
        for (final double y in <double>[.17, .21, .25]) {
          p.line(
            Path()
              ..moveTo(.5 + k * .07, y)
              ..lineTo(.5 + k * .19, y - .02),
            width: .008,
            color: darker(horn, .15),
          );
        }
      },
    );
  }
  for (final double k in sides) {
    final Path ear = turn(
      leaf(pt(.5 + k * .12, .37), pt(.5 + k * .33, .43), .085),
      pt(.5 + k * .12, .37),
      k * .15,
    );
    p.part(
      ear,
      fur,
      marks: () => p.flat(
        turn(
          leaf(pt(.5 + k * .16, .385), pt(.5 + k * .3, .43), .04),
          pt(.5 + k * .12, .37),
          k * .15,
        ),
        Kit.blush.withValues(alpha: .6),
      ),
    );
  }
  sitBody(p, fur: fur, feet: const Color(0xFF7A6656), rx: .165, ry: .155);
  final Path head = oval(.5, .43, .17, .2);
  p.part(
    head,
    fur,
    shine: 1,
    marks: () {
      p.flat(oval(.59, .33, .1, .09), patch);
      p.flat(oval(.5, .545, .1, .075), muzzle);
    },
  );
  p.eyes(.5, .44, .075, .045);
  p.cheeks(.5, .5, .12, .032);
  p.flat(oval(.48, .525, .009, .012), darker(muzzle, .35));
  p.flat(oval(.52, .525, .009, .012), darker(muzzle, .35));
  p.catMouth(pt(.5, .56), .018);
  // A wispy goatee hanging from the chin.
  p.part(
    blob(
      <Offset>[
        pt(.475, .605),
        pt(.525, .605),
        pt(.52, .65),
        pt(.5, .70),
        pt(.48, .65),
      ],
      sharp: <int>{3},
    ),
    const Color(0xFFE4D8C6),
    depth: .4,
    line: p.lw * .75,
  );

  p.head(const Rect.fromLTRB(.325, .235, .675, .625), hatLift: .05);
  p.collar(pt(.5, .625), .12);
}

// --------------------------------------------------------------- 17 raccoon

void _raccoon(Pen p) {
  const Color fur = Color(0xFF9DA5B4);
  const Color dark = Color(0xFF454B5A);
  const Color white = Color(0xFFF4F6FA);
  p.ink = const Color(0xFF2C303C);

  final Path tail = blob(<Offset>[
    pt(.60, .86),
    pt(.78, .85),
    pt(.90, .72),
    pt(.90, .56),
    pt(.84, .45),
    pt(.77, .49),
    pt(.76, .64),
    pt(.70, .76),
  ]);
  p.part(
    tail,
    fur,
    marks: () {
      p.line(
        Path()
          ..moveTo(.72, .58)
          ..lineTo(.96, .54),
        width: .045,
        color: dark,
      );
      p.line(
        Path()
          ..moveTo(.68, .70)
          ..lineTo(.96, .69),
        width: .045,
        color: dark,
      );
      p.line(
        Path()
          ..moveTo(.62, .81)
          ..lineTo(.90, .84),
        width: .045,
        color: dark,
      );
      p.flat(circle(.86, .45, .05), dark);
    },
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .15, .30),
      pt(.5 + k * .215, .16),
      .15,
      fur,
      white,
      round: .045,
    );
  }
  sitBody(p, fur: fur, belly: white, feet: dark, paws: dark);
  final Path head = sym(
    <Offset>[
      pt(.5, .25),
      pt(.64, .27),
      pt(.72, .35),
      pt(.775, .47),
      pt(.71, .52),
      pt(.63, .59),
      pt(.5, .62),
    ],
    sharp: <int>{3},
  );
  p.part(
    head,
    fur,
    shine: 1,
    marks: () {
      p.flat(
        sym(
          <Offset>[
            pt(.5, .47),
            pt(.6, .47),
            pt(.775, .47),
            pt(.63, .59),
            pt(.5, .625),
          ],
          sharp: <int>{2},
        ),
        white,
      );
      p.flat(
        sym(<Offset>[
          pt(.5, .345),
          pt(.57, .335),
          pt(.66, .35),
          pt(.68, .385),
          pt(.57, .385),
          pt(.5, .39),
        ]),
        white,
      );
      p.flat(
        sym(<Offset>[
          pt(.5, .41),
          pt(.56, .395),
          pt(.67, .385),
          pt(.745, .44),
          pt(.70, .495),
          pt(.6, .49),
          pt(.5, .465),
        ]),
        dark,
      );
    },
  );
  p.eyes(.5, .44, .088, .043, rim: white, iris: const Color(0xFF6A5A4A));
  p.cheeks(.5, .52, .15, .03);
  p.nose(pt(.5, .51), .024);
  p.catMouth(pt(.5, .545), .02);

  p.head(const Rect.fromLTRB(.225, .25, .775, .62), hatLift: .03);
  p.collar(pt(.5, .61), .14);
}

// ----------------------------------------------------------------- 18 otter

void _otter(Pen p) {
  const Color fur = Color(0xFF9A6A48);
  const Color pale = Color(0xFFEBD3B6);
  const Color shellColor = Color(0xFFFFB7A8);
  p.ink = inkOf(fur);

  p.part(
    blob(
      <Offset>[
        pt(.40, .86),
        pt(.22, .87),
        pt(.08, .82),
        pt(.22, .77),
        pt(.40, .75),
      ],
      sharp: <int>{2},
    ),
    fur,
  );
  sitBody(
    p,
    fur: fur,
    belly: pale,
    feet: darker(fur, .1),
    showPaws: false,
    rx: .17,
    ry: .165,
  );
  // A scallop shell held in both paws.
  final Path shell = blob(<Offset>[
    pt(.45, .735),
    pt(.43, .68),
    pt(.46, .635),
    pt(.5, .625),
    pt(.54, .635),
    pt(.57, .68),
    pt(.55, .735),
    pt(.5, .745),
  ]);
  p.part(
    shell,
    shellColor,
    shine: .6,
    marks: () {
      for (final double a in <double>[-.9, -.45, 0, .45, .9]) {
        p.line(
          Path()
            ..moveTo(.5, .75)
            ..lineTo(.5 + math.sin(a) * .1, .75 - math.cos(a) * .12),
          width: .008,
          color: darker(shellColor, .14),
        );
      }
    },
  );
  for (final double k in sides) {
    p.part(oval(.5 + k * .065, .70, .034, .03), fur, depth: .4);
  }
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .19, .32), .048, fur, darker(fur, .12));
  }
  p.part(
    oval(.5, .43, .215, .175),
    fur,
    shine: 1,
    marks: () {
      p.flat(
        union(oval(.462, .505, .065, .055), oval(.538, .505, .065, .055)),
        pale,
      );
      p.flat(oval(.5, .56, .13, .06), pale);
    },
  );
  p.eyes(.5, .415, .095, .042);
  p.cheeks(.5, .47, .15, .032);
  for (final double k in sides) {
    for (final Offset d in <Offset>[
      const Offset(.05, .505),
      const Offset(.075, .495),
      const Offset(.07, .52),
    ]) {
      p.flat(circle(.5 + k * d.dx, d.dy, .006), darker(pale, .3));
    }
  }
  p.nose(pt(.5, .48), .026);
  p.catMouth(pt(.5, .515), .02);

  p.head(const Rect.fromLTRB(.285, .255, .715, .605));
  p.collar(pt(.5, .6), .14);
}

// ------------------------------------------------------------------ 19 fawn

void _fawn(Pen p) {
  const Color fur = Color(0xFFCB8957);
  const Color cream = Color(0xFFFFF2E0);
  const Color hoof = Color(0xFF5A3A28);
  const Color inner = Color(0xFFFFC2C0);
  const double hx = .62;
  p.ink = inkOf(fur);

  p.part(tear(.20, .545, .03, angle: -1.0, length: 2.0), cream);
  standBody(
    p,
    fur: fur,
    hoof: hoof,
    belly: cream,
    neck: standNeck(),
    marks: () {
      for (final Offset s in <Offset>[
        const Offset(.27, .555),
        const Offset(.35, .535),
        const Offset(.43, .545),
        const Offset(.31, .61),
        const Offset(.40, .60),
        const Offset(.49, .585),
        const Offset(.23, .62),
      ]) {
        p.flat(circle(s.dx, s.dy, .016), cream);
      }
      p.flat(oval(.62, .58, .045, .06), cream);
    },
  );
  for (final double k in sides) {
    final Path ear = leaf(
      pt(hx + k * .12, .29),
      pt(hx + k * .27, .19),
      .1,
      bend: k * .01,
    );
    p.part(
      ear,
      fur,
      marks: () => p.flat(
        leaf(pt(hx + k * .15, .28), pt(hx + k * .25, .21), .05),
        inner,
      ),
    );
  }
  p.part(
    oval(hx, .36, .165, .145),
    fur,
    shine: 1,
    marks: () => p.flat(oval(hx, .45, .085, .06), cream),
  );
  p.eyes(hx, .35, .07, .047);
  for (final double k in sides) {
    p.line(
      Path()
        ..moveTo(hx + k * .1, .325)
        ..lineTo(hx + k * .125, .305),
      width: p.lw * .6,
    );
  }
  p.cheeks(hx, .41, .115, .03);
  p.nose(pt(hx, .43), .02);
  p.catMouth(pt(hx, .46), .016);

  p.head(const Rect.fromLTRB(hx - .165, .215, hx + .165, .505), hatLift: .0);
  p.collar(pt(.61, .52), .07);
}

// ----------------------------------------------------------------- 20 koala

void _koala(Pen p) {
  const Color fur = Color(0xFFA9B1BE);
  const Color pale = Color(0xFFF0F3F7);
  const Color leafColor = Color(0xFF7DBF97);
  p.ink = const Color(0xFF353A45);

  for (final double k in sides) {
    p.part(fluff(.5 + k * .23, .30, .12, .11, 8, depth: .1), fur, shine: .4);
    p.part(
      fluff(.5 + k * .23, .31, .068, .062, 7, depth: .14),
      pale,
      depth: .4,
      line: 0,
    );
  }
  sitBody(
    p,
    fur: fur,
    belly: pale,
    feet: darker(fur, .1),
    showPaws: false,
    rx: .175,
    ry: .16,
  );
  // A eucalyptus sprig hugged to the chest.
  p.tube(
    curve(<Offset>[pt(.52, .82), pt(.54, .70), pt(.58, .56)]),
    .013,
    const Color(0xFF8A6A50),
  );
  for (final List<Offset> l in <List<Offset>>[
    <Offset>[pt(.575, .58), pt(.66, .52)],
    <Offset>[pt(.58, .57), pt(.56, .47)],
    <Offset>[pt(.565, .64), pt(.49, .60)],
    <Offset>[pt(.555, .66), pt(.64, .64)],
  ]) {
    p.part(leaf(l[0], l[1], .045), leafColor, depth: .5);
  }
  for (final double k in sides) {
    p.part(oval(.5 + k * .075, .705, .036, .032), darker(fur, .05), depth: .4);
  }
  p.part(oval(.5, .44, .22, .19), fur, shine: 1);
  p.eyes(.5, .43, .105, .04);
  p.cheeks(.5, .50, .155, .036);
  final Path nose = oval(.5, .495, .048, .064);
  p.part(nose, const Color(0xFF3E3B46), shine: 1.2, depth: .5);
  p.smile(pt(.5, .58), .018);

  p.head(const Rect.fromLTRB(.28, .25, .72, .63), hatLift: .02);
  p.collar(pt(.5, .625), .13);
}

// ------------------------------------------------------------- 21 red panda

void _redPanda(Pen p) {
  const Color fur = Color(0xFFD9653A);
  const Color white = Color(0xFFFFF5EA);
  const Color dark = Color(0xFF4A2A24);
  const Color tearColor = Color(0xFFA0432A);
  p.ink = const Color(0xFF3A1A12);

  final Path tail = blob(<Offset>[
    pt(.60, .88),
    pt(.80, .86),
    pt(.92, .72),
    pt(.91, .54),
    pt(.83, .45),
    pt(.76, .51),
    pt(.78, .66),
    pt(.70, .78),
  ]);
  p.part(
    tail,
    fur,
    shine: .4,
    marks: () {
      for (final List<Offset> b in <List<Offset>>[
        <Offset>[pt(.74, .56), pt(.96, .52)],
        <Offset>[pt(.72, .68), pt(.97, .67)],
        <Offset>[pt(.64, .80), pt(.92, .83)],
      ]) {
        p.line(
          Path()
            ..moveTo(b[0].dx, b[0].dy)
            ..lineTo(b[1].dx, b[1].dy),
          width: .04,
          color: const Color(0xFFA9482A),
        );
      }
    },
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.5 + k * .16, .30),
      pt(.5 + k * .225, .165),
      .16,
      fur,
      white,
      round: .05,
    );
  }
  sitBody(p, fur: fur, belly: const Color(0xFF7A3A28), feet: dark, paws: dark);
  p.part(
    oval(.5, .43, .235, .19),
    fur,
    shine: 1,
    marks: () {
      p.flat(oval(.5, .525, .11, .085), white);
      for (final double k in sides) {
        p.flat(oval(.5 + k * .065, .355, .035, .022), white);
        p.flat(oval(.5 + k * .19, .47, .05, .065), white);
        p.line(
          curve(<Offset>[
            pt(.5 + k * .09, .47),
            pt(.5 + k * .1, .52),
            pt(.5 + k * .075, .57),
          ]),
          width: .028,
          color: tearColor,
        );
      }
    },
  );
  p.eyes(.5, .435, .09, .046);
  p.nose(pt(.5, .505), .024);
  p.catMouth(pt(.5, .54), .02);

  p.head(const Rect.fromLTRB(.265, .24, .735, .62), hatLift: .03);
  p.collar(pt(.5, .61), .14);
}

// ----------------------------------------------------------------- 22 sloth

void _sloth(Pen p) {
  const Color fur = Color(0xFFB8A587);
  const Color face = Color(0xFFF1E6D0);
  const Color patch = Color(0xFF7A6550);
  const Color branch = Color(0xFF9A6B45);
  p.ink = const Color(0xFF3E3022);

  p.tube(
    curve(<Offset>[pt(.08, .23), pt(.5, .19), pt(.92, .22)]),
    .055,
    branch,
  );
  p.part(leaf(pt(.18, .23), pt(.10, .33), .055), Kit.leafGreen, depth: .5);
  p.part(leaf(pt(.82, .21), pt(.92, .12), .055), Kit.leafGreen, depth: .5);
  p.part(leaf(pt(.76, .215), pt(.70, .11), .05), Kit.leafGreen, depth: .5);
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .1, .58),
        pt(.5 + k * .2, .42),
        pt(.5 + k * .19, .23),
      ]),
      .075,
      fur,
    );
    for (final double d in <double>[-.02, .015]) {
      p.line(
        curve(<Offset>[
          pt(.5 + k * .19 + d, .225),
          pt(.5 + k * .19 + d - .01, .175),
          pt(.5 + k * .19 + d - .03, .17),
        ]),
        width: .012,
      );
    }
  }
  for (final double k in sides) {
    p.tube(
      curve(<Offset>[
        pt(.5 + k * .08, .74),
        pt(.5 + k * .12, .82),
        pt(.5 + k * .11, .87),
      ]),
      .07,
      fur,
    );
  }
  p.part(
    oval(.5, .70, .145, .15),
    fur,
    marks: () => p.flat(oval(.5, .73, .09, .1), lighter(fur, .08)),
  );
  p.part(
    oval(.5, .47, .19, .165),
    fur,
    shine: 1,
    marks: () {
      p.flat(oval(.5, .49, .15, .12), face);
      for (final double k in sides) {
        p.flat(
          leaf(
            pt(.5 + k * .035, .45),
            pt(.5 + k * .145, .53),
            .06,
            bend: k * .01,
          ),
          patch,
        );
      }
    },
  );
  p.eyes(.5, .47, .072, .036, rim: face, iris: const Color(0xFF5A4030));
  p.nose(pt(.5, .52), .02);
  p.smile(pt(.5, .55), .03, depth: .5);
  p.cheeks(.5, .56, .12, .03);

  p.head(const Rect.fromLTRB(.31, .305, .69, .635), hatLift: .0);
  p.torso(const Rect.fromLTRB(.355, .55, .645, .85));
  p.collar(pt(.5, .63), .11);
}

// ----------------------------------------------------------------- 23 zebra

void _zebra(Pen p) {
  const Color white = Color(0xFFFAF8F5);
  const Color black = Color(0xFF3A3A48);
  const Color muzzle = Color(0xFF5E5E6E);
  const double hx = .62;
  p.ink = const Color(0xFF26262E);

  p.tube(
    curve(<Offset>[pt(.20, .56), pt(.14, .62), pt(.14, .70)]),
    .016,
    white,
  );
  p.part(tear(.14, .73, .026, angle: math.pi, length: 2.0), black);
  standBody(
    p,
    fur: white,
    hoof: black,
    neck: standNeck(top: .44),
    marks: () {
      for (double x = .24; x < .50; x += .075) {
        p.line(
          curve(<Offset>[
            pt(x, .48),
            pt(x + .02, .58),
            pt(x - .005, .68),
            pt(x + .01, .77),
          ]),
          width: .028,
          color: black,
        );
      }
      for (double y = .48; y < .70; y += .055) {
        p.line(
          Path()
            ..moveTo(.52, y)
            ..lineTo(.72, y - .02),
          width: .022,
          color: black,
        );
      }
    },
    legMarks: () {
      for (final double x in <double>[.26, .52]) {
        for (final double y in <double>[.73, .79]) {
          p.line(
            Path()
              ..moveTo(x - .03, y)
              ..lineTo(x + .03, y + .01),
            width: .016,
            color: black,
          );
        }
      }
    },
  );
  // Mane: an upright brush along the back of the neck.
  final Path mane = blob(<Offset>[
    pt(.62, .18),
    pt(.58, .14),
    pt(.56, .26),
    pt(.50, .34),
    pt(.48, .46),
    pt(.52, .55),
    pt(.56, .44),
    pt(.60, .32),
  ]);
  p.part(
    mane,
    black,
    depth: .4,
    marks: () {
      for (double y = .2; y < .55; y += .06) {
        p.line(
          Path()
            ..moveTo(.45, y)
            ..lineTo(.65, y + .02),
          width: .016,
          color: white,
        );
      }
    },
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(hx + k * .085, .225),
      pt(hx + k * .125, .095),
      .075,
      white,
      const Color(0xFFFFC9D2),
      round: .025,
    );
  }
  final Path head = union(oval(hx, .315, .14, .13), oval(hx, .42, .1, .08));
  p.part(
    head,
    white,
    shine: 1,
    marks: () {
      for (final double y in <double>[.205, .245]) {
        p.line(
          curve(<Offset>[
            pt(hx - .1, y + .02),
            pt(hx, y),
            pt(hx + .1, y + .02),
          ]),
          width: .018,
          color: black,
        );
      }
      for (final double k in sides) {
        p.line(
          curve(<Offset>[
            pt(hx + k * .14, .27),
            pt(hx + k * .12, .3),
            pt(hx + k * .135, .34),
          ]),
          width: .016,
          color: black,
        );
      }
      p.flat(oval(hx, .445, .1, .065), muzzle);
    },
  );
  p.flat(oval(hx - .035, .44, .012, .016), black);
  p.flat(oval(hx + .035, .44, .012, .016), black);
  p.eyes(hx, .32, .068, .044);
  p.cheeks(hx, .38, .11, .028);
  p.smile(pt(hx, .475), .025, color: white);

  p.head(const Rect.fromLTRB(hx - .14, .185, hx + .14, .50), hatLift: .03);
  p.collar(pt(.61, .53), .075);
}

// --------------------------------------------------------------- 24 giraffe

void _giraffe(Pen p) {
  const Color fur = Color(0xFFF5C862);
  const Color patch = Color(0xFFC57E3C);
  const Color pale = Color(0xFFFFEDC6);
  const Color hoof = Color(0xFF6A4424);
  const double hx = .62;
  p.ink = const Color(0xFF55320F);

  void spots(List<Offset> at, double r) {
    for (final Offset c in at) {
      p.flat(
        roundPoly(ring(c.dx, c.dy, r, r * .85, 5, start: c.dx * 9), r * .35),
        patch,
      );
    }
  }

  p.tube(curve(<Offset>[pt(.22, .62), pt(.16, .66), pt(.15, .74)]), .014, fur);
  p.part(tear(.15, .765, .022, angle: math.pi, length: 2.0), hoof);
  final Path neck = blob(<Offset>[
    pt(.51, .66),
    pt(.55, .44),
    pt(.575, .30),
    pt(.665, .30),
    pt(.665, .46),
    pt(.64, .68),
  ]);
  standBody(
    p,
    fur: fur,
    hoof: hoof,
    cy: .66,
    rx: .21,
    ry: .115,
    legTop: .70,
    legW: .052,
    neck: neck,
    marks: () {
      spots(<Offset>[
        pt(.27, .62),
        pt(.36, .60),
        pt(.45, .62),
        pt(.31, .69),
        pt(.41, .69),
        pt(.22, .68),
      ], .03);
      spots(<Offset>[
        pt(.60, .38),
        pt(.585, .48),
        pt(.615, .57),
        pt(.55, .64),
      ], .026);
      p.line(
        curve(<Offset>[pt(.565, .31), pt(.54, .45), pt(.515, .62)]),
        width: .028,
        color: patch,
      );
    },
  );
  for (final double k in sides) {
    p.tube(
      Path()
        ..moveTo(hx + k * .045, .17)
        ..lineTo(hx + k * .055, .085),
      .03,
      fur,
    );
    p.part(circle(hx + k * .055, .08, .025), hoof, depth: .5);
  }
  for (final double k in sides) {
    p.part(
      turn(
        leaf(pt(hx + k * .1, .19), pt(hx + k * .21, .15), .055),
        pt(hx + k * .1, .19),
        0,
      ),
      fur,
    );
  }
  p.part(
    oval(hx, .245, .135, .12),
    fur,
    shine: 1,
    marks: () {
      p.flat(oval(hx, .32, .085, .055), pale);
      p.flat(circle(hx, .165, .022), patch);
    },
  );
  p.flat(oval(hx - .03, .31, .009, .013), darker(pale, .4));
  p.flat(oval(hx + .03, .31, .009, .013), darker(pale, .4));
  p.eyes(hx, .24, .06, .04);
  p.cheeks(hx, .29, .1, .026);
  p.smile(pt(hx, .34), .018);

  p.head(const Rect.fromLTRB(hx - .135, .125, hx + .135, .365), hatLift: .06);
  p.collar(pt(.61, .40), .055);
}

// ----------------------------------------------------------------- 25 panda

void _panda(Pen p) {
  const Color white = Color(0xFFFBFAF7);
  const Color black = Color(0xFF3A3742);
  const Color bamboo = Color(0xFF8CC85A);
  p.ink = const Color(0xFF26232C);

  for (final double k in sides) {
    p.part(circle(.5 + k * .195, .27, .085), black, shine: .5);
  }
  sitBody(
    p,
    fur: white,
    feet: black,
    showPaws: false,
    rx: .185,
    ry: .16,
    marks: () {
      p.flat(oval(.5, .60, .2, .05), black);
    },
  );
  // A bamboo stalk held across the body.
  final Path stalk = turn(rrect(.47, .52, .53, .90, .02), pt(.5, .71), .55);
  p.part(
    stalk,
    bamboo,
    marks: () {
      for (final double y in <double>[.62, .74]) {
        p.line(
          turn(
            Path()
              ..moveTo(.46, y)
              ..lineTo(.54, y),
            pt(.5, .71),
            .55,
          ),
          width: .01,
          color: darker(bamboo, .2),
        );
      }
    },
  );
  p.part(leaf(pt(.40, .57), pt(.30, .52), .05), bamboo, depth: .5);
  p.part(leaf(pt(.40, .57), pt(.34, .47), .045), bamboo, depth: .5);
  for (final double k in sides) {
    p.part(oval(.5 + k * .1, .69, .055, .05), black, depth: .5);
  }
  p.part(
    oval(.5, .44, .235, .195),
    white,
    shine: 1,
    marks: () {
      for (final double k in sides) {
        p.flat(
          turn(
            oval(.5 + k * .09, .455, .052, .07),
            pt(.5 + k * .09, .455),
            -k * .55,
          ),
          black,
        );
      }
    },
  );
  p.eyes(.5, .445, .09, .035, rim: const Color(0xFFEDEBF2));
  p.cheeks(.5, .52, .16, .035);
  p.nose(pt(.5, .515), .026);
  p.catMouth(pt(.5, .55), .02);

  p.head(const Rect.fromLTRB(.265, .245, .735, .635), hatLift: .02);
  p.collar(pt(.5, .62), .15);
}

// ------------------------------------------------------------------ 26 lion

void _lion(Pen p) {
  const Color fur = Color(0xFFF3C26C);
  const Color mane = Color(0xFFD97E36);
  const Color cream = Color(0xFFFFF0D2);
  p.ink = const Color(0xFF5A2E10);

  p.tube(
    curve(<Offset>[pt(.62, .85), pt(.80, .83), pt(.86, .72), pt(.84, .63)]),
    .028,
    fur,
  );
  p.part(tear(.84, .62, .035, length: 2.1), mane);
  sitBody(p, fur: fur, belly: cream, rx: .17, ry: .16);
  p.part(
    fluff(.5, .435, .27, .25, 12, depth: .1),
    mane,
    shine: .5,
    marks: () {
      p.canvas.drawPath(
        fluff(.5, .44, .2, .185, 12, depth: .1),
        strokeOf(darker(mane, .1), .02),
      );
    },
  );
  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .15, .30), .055, fur, darker(fur, .1));
  }
  p.part(
    oval(.5, .455, .185, .165),
    fur,
    shine: 1,
    marks: () {
      p.flat(
        union(oval(.462, .53, .058, .048), oval(.538, .53, .058, .048)),
        cream,
      );
    },
  );
  p.eyes(.5, .435, .085, .046);
  p.cheeks(.5, .5, .14, .032);
  for (final double k in sides) {
    for (final Offset d in <Offset>[
      const Offset(.045, .525),
      const Offset(.07, .535),
      const Offset(.055, .55),
    ]) {
      p.flat(circle(.5 + k * d.dx, d.dy, .005), darker(cream, .3));
    }
  }
  p.nose(pt(.5, .5), .028, color: const Color(0xFF8A4A2A));
  p.catMouth(pt(.5, .54), .02);

  p.head(const Rect.fromLTRB(.24, .19, .76, .68), hatLift: .0);
  p.collar(pt(.5, .66), .15);
}

// -------------------------------------------------------------- 27 elephant

void _elephant(Pen p) {
  const Color skin = Color(0xFFA9B3CC);
  const Color inner = Color(0xFFF5B8C4);
  const Color nail = Color(0xFFF4EEE4);
  p.ink = const Color(0xFF353B52);

  for (final double k in sides) {
    Offset q(double x, double y) => pt(.5 + k * x, y);
    p.part(
      blob(<Offset>[
        q(.12, .30),
        q(.27, .21),
        q(.42, .27),
        q(.45, .44),
        q(.37, .58),
        q(.20, .57),
      ]),
      skin,
      shine: .4,
    );
    p.part(
      blob(<Offset>[
        q(.18, .32),
        q(.28, .27),
        q(.38, .31),
        q(.40, .43),
        q(.34, .52),
        q(.22, .51),
      ]),
      inner,
      depth: .4,
      line: 0,
    );
  }
  sitBody(p, fur: skin, feet: skin, paws: skin, rx: .19, ry: .16, footW: .072);
  for (final double k in sides) {
    for (final double d in <double>[-.025, 0, .025]) {
      p.flat(oval(.5 + k * .085 + d, .9, .01, .007), nail);
    }
  }
  p.part(oval(.5, .42, .2, .18), skin, shine: 1);
  p.eyes(.5, .40, .1, .042);
  p.cheeks(.5, .46, .14, .034);
  final Path trunk = curve(<Offset>[
    pt(.5, .45),
    pt(.5, .57),
    pt(.525, .645),
    pt(.595, .645),
    pt(.625, .585),
  ]);
  p.tube(trunk, .072, skin);
  for (final double y in <double>[.53, .575]) {
    p.line(
      Path()
        ..moveTo(.475, y)
        ..quadraticBezierTo(.5, y + .012, .525, y),
      width: .01,
    );
  }
  p.part(
    oval(.627, .58, .034, .02),
    darker(skin, .08),
    depth: 0,
    line: p.lw * .7,
  );
  p.smile(pt(.43, .515), .018);

  p.head(const Rect.fromLTRB(.30, .24, .70, .60), hatLift: .0);
  p.collar(pt(.5, .62), .15);
}

// ----------------------------------------------------------------- 28 rhino

void _rhino(Pen p) {
  const Color skin = Color(0xFF9EA4B6);
  const Color horn = Color(0xFFF1E9D8);
  p.ink = const Color(0xFF353A48);

  for (final double x in <double>[.30, .56]) {
    leg(p, x, .66, .1, darker(skin, .07), bottom: .885);
  }
  for (final double x in <double>[.22, .48]) {
    leg(p, x, .68, .105, skin);
  }
  p.tube(curve(<Offset>[pt(.17, .58), pt(.12, .64), pt(.13, .70)]), .016, skin);
  final Path body = oval(.41, .64, .27, .17);
  p.part(
    body,
    skin,
    shine: .6,
    marks: () {
      p.flat(oval(.43, .76, .2, .06), lighter(skin, .06));
      p.line(
        curve(<Offset>[pt(.30, .50), pt(.34, .62), pt(.31, .76)]),
        width: .01,
        color: darker(skin, .1),
      );
    },
  );
  for (final double k in sides) {
    pointyEar(
      p,
      pt(.665 + k * .06, .35),
      pt(.665 + k * .085, .235),
      .07,
      skin,
      const Color(0xFFF2B9C2),
      round: .022,
    );
  }
  final Path head = blob(<Offset>[
    pt(.55, .44),
    pt(.62, .35),
    pt(.74, .34),
    pt(.84, .40),
    pt(.92, .50),
    pt(.92, .60),
    pt(.84, .67),
    pt(.68, .68),
    pt(.57, .60),
  ]);
  p.part(head, skin, shine: 1);
  p.part(leaf(pt(.82, .43), pt(.80, .345), .05, bend: .006), horn, depth: .6);
  p.part(
    blob(
      <Offset>[
        pt(.84, .47),
        pt(.86, .36),
        pt(.89, .27),
        pt(.915, .37),
        pt(.92, .47),
      ],
      sharp: <int>{2},
    ),
    horn,
    shine: .5,
  );
  p.eyes(.715, .49, .055, .038);
  p.cheeks(.715, .55, .085, .03);
  p.flat(oval(.895, .57, .01, .015), darker(skin, .35));
  p.smile(pt(.84, .625), .022);

  p.head(const Rect.fromLTRB(.56, .34, .92, .68), hatLift: .0, hatX: .70);
  p.collar(pt(.6, .66), .08);
}

// ---------------------------------------------------------------- 29 grizzly

void _grizzly(Pen p) {
  const Color fur = Color(0xFF8D6345);
  const Color muzzle = Color(0xFFE2C29C);
  const Color fish = Color(0xFFF59C8A);
  p.ink = const Color(0xFF3A2416);

  for (final double k in sides) {
    roundEar(p, pt(.5 + k * .19, .27), .075, fur, darker(fur, .1));
  }
  sitBody(
    p,
    fur: fur,
    belly: lighter(fur, .09),
    feet: darker(fur, .08),
    showPaws: false,
    rx: .2,
    ry: .165,
  );
  // A salmon, fresh from the river.
  p.part(
    roundPoly(<Offset>[pt(.36, .70), pt(.27, .645), pt(.27, .755)], .012),
    darker(fish, .05),
  );
  final Path salmon = blob(<Offset>[
    pt(.34, .70),
    pt(.45, .65),
    pt(.60, .65),
    pt(.68, .695),
    pt(.60, .735),
    pt(.45, .74),
  ]);
  p.part(
    salmon,
    fish,
    shine: .6,
    marks: () => p.flat(oval(.52, .725, .14, .02), lighter(fish, .1)),
  );
  p.flat(circle(.625, .69, .01), Kit.eyeDark);
  for (final double k in sides) {
    p.part(oval(.5 + k * .09, .70, .045, .04), fur, depth: .4);
  }
  p.part(
    oval(.5, .43, .23, .19),
    fur,
    shine: 1,
    marks: () => p.flat(oval(.5, .51, .1, .075), muzzle),
  );
  p.eyes(.5, .415, .1, .044);
  p.cheeks(.5, .48, .16, .034);
  p.nose(pt(.5, .49), .03);
  p.catMouth(pt(.5, .528), .02);

  p.head(const Rect.fromLTRB(.27, .24, .73, .62));
  p.collar(pt(.5, .615), .15);
}

// ------------------------------------------------------------ 30 golden stag

void _stag(Pen p) {
  const Color fur = Color(0xFFE6B55A);
  const Color cream = Color(0xFFFFF3D6);
  const Color antler = Color(0xFFFFE6A6);
  const Color hoof = Color(0xFF6A4A22);
  const double hx = .62;
  p.ink = const Color(0xFF5A3810);

  // Antlers first, so the head sits in front of their roots.
  for (final double k in sides) {
    Offset q(double x, double y) => pt(hx + k * x, y);
    p.tube(
      curve(<Offset>[q(.05, .22), q(.09, .15), q(.17, .10), q(.25, .095)]),
      .03,
      antler,
    );
    p.tube(
      curve(<Offset>[q(.09, .155), q(.085, .085), q(.10, .045)]),
      .026,
      antler,
    );
    p.tube(
      curve(<Offset>[q(.165, .105), q(.18, .05), q(.21, .025)]),
      .024,
      antler,
    );
    p.tube(
      curve(<Offset>[q(.06, .19), q(.13, .19), q(.17, .175)]),
      .022,
      antler,
    );
  }
  p.part(tear(.20, .54, .03, angle: -1.0, length: 2.0), cream);
  standBody(
    p,
    fur: fur,
    hoof: hoof,
    belly: cream,
    cy: .63,
    neck: standNeck(),
    marks: () {
      for (final Offset s in <Offset>[
        const Offset(.28, .56),
        const Offset(.38, .545),
        const Offset(.47, .56),
        const Offset(.33, .62),
        const Offset(.43, .615),
      ]) {
        p.flat(star(s.dx, s.dy, .02, round: .003), cream);
      }
      p.flat(oval(.62, .55, .05, .07), cream);
    },
  );
  for (final double k in sides) {
    final Path ear = leaf(pt(hx + k * .11, .29), pt(hx + k * .24, .25), .085);
    p.part(
      ear,
      fur,
      marks: () => p.flat(
        leaf(pt(hx + k * .14, .285), pt(hx + k * .225, .255), .04),
        const Color(0xFFFFC9B0),
      ),
    );
  }
  p.part(
    oval(hx, .36, .155, .14),
    fur,
    shine: 1,
    marks: () => p.flat(oval(hx, .445, .08, .058), cream),
  );
  p.eyes(hx, .35, .068, .045, iris: const Color(0xFFB0782A));
  p.cheeks(hx, .41, .11, .03);
  p.nose(pt(hx, .425), .02);
  p.catMouth(pt(hx, .458), .016);
  p.twinkle(pt(.16, .40), .035, Kit.gold);
  p.twinkle(pt(.88, .44), .028, Kit.gold);
  p.twinkle(pt(.30, .30), .022, Kit.gold);

  p.head(const Rect.fromLTRB(hx - .155, .22, hx + .155, .50), hatLift: .05);
  p.collar(pt(.61, .52), .07);
}
