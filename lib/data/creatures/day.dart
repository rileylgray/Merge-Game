import 'dart:ui' show Color;

import '../creature_spec.dart';

const CreaturePalette _p1 = CreaturePalette(
  body: Color(0xFFE8564F),
  belly: Color(0xFFFFD9C4),
  accent: Color(0xFF3D3450),
  detail: Color(0xFF3D3450),
);

/// Day Meadow — sun-warmed grassland and woodland critters.
///
/// Tier 1 starts with the smallest things in the grass and climbs to a
/// storybook stag; silhouettes get steadily larger and grander with tier.
const List<CreatureSpec> dayCreatures = <CreatureSpec>[
  // 1 — Ladybug
  CreatureSpec(
    worldId: 'day',
    tier: 1,
    palette: _p1,
    body: BodyShape.bug,
    ears: EarType.antenna,
    pattern: PatternType.spots,
    eyes: EyeStyle.round,
    limbs: LimbType.tinyFeet,
    widthScale: .90,
    heightScale: .82,
  ),

  // 2 — Honeybee
  CreatureSpec(
    worldId: 'day',
    tier: 2,
    palette: CreaturePalette(
      body: Color(0xFFF9C744),
      belly: Color(0xFFFFF0C2),
      accent: Color(0xFF4A3B2A),
      detail: Color(0xFF4A3B2A),
    ),
    body: BodyShape.bug,
    ears: EarType.antenna,
    wings: WingType.insect,
    pattern: PatternType.stripes,
    eyes: EyeStyle.sparkle,
    tail: TailType.stinger,
    widthScale: .95,
    heightScale: .88,
  ),

  // 3 — Butterfly
  CreatureSpec(
    worldId: 'day',
    tier: 3,
    palette: CreaturePalette(
      body: Color(0xFFB79CE8),
      belly: Color(0xFFFFD8F0),
      accent: Color(0xFFFF9EC4),
      detail: Color(0xFF5B4A7A),
    ),
    body: BodyShape.bug,
    ears: EarType.antenna,
    wings: WingType.butterfly,
    eyes: EyeStyle.closedHappy,
    accent: Accent.sparkles,
    widthScale: .82,
    heightScale: .92,
  ),

  // 4 — Snail
  CreatureSpec(
    worldId: 'day',
    tier: 4,
    palette: CreaturePalette(
      body: Color(0xFFCFE0A6),
      belly: Color(0xFFE9A85C),
      accent: Color(0xFFFFC9A0),
      detail: Color(0xFF7A6A4E),
    ),
    body: BodyShape.serpent,
    ears: EarType.antenna,
    crest: CrestType.shellSpiral,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.none,
    widthScale: .92,
  ),

  // 5 — Field Mouse
  CreatureSpec(
    worldId: 'day',
    tier: 5,
    palette: CreaturePalette(
      body: Color(0xFFC3A98F),
      belly: Color(0xFFFBEEDC),
      accent: Color(0xFFFFAFA0),
      detail: Color(0xFF6E5A48),
    ),
    body: BodyShape.egg,
    ears: EarType.roundBig,
    tail: TailType.whip,
    snout: SnoutType.dot,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    widthScale: .95,
    heightScale: .88,
  ),

  // 6 — Chick
  CreatureSpec(
    worldId: 'day',
    tier: 6,
    palette: CreaturePalette(
      body: Color(0xFFFFD65C),
      belly: Color(0xFFFFF0B8),
      accent: Color(0xFFFFAB91),
      detail: Color(0xFFF08A3C),
    ),
    body: BodyShape.bird,
    crest: CrestType.crest,
    snout: SnoutType.beakSmall,
    limbs: LimbType.talons,
    eyes: EyeStyle.round,
    accent: Accent.crackedEgg,
    widthScale: .94,
    heightScale: .86,
  ),

  // 7 — Bunny
  CreatureSpec(
    worldId: 'day',
    tier: 7,
    palette: CreaturePalette(
      body: Color(0xFFF6E7DA),
      belly: Color(0xFFFFFDF8),
      accent: Color(0xFFFFB0BE),
      detail: Color(0xFFBFA593),
    ),
    body: BodyShape.egg,
    ears: EarType.bunny,
    tail: TailType.puff,
    snout: SnoutType.buckTeeth,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
  ),

  // 8 — Squirrel
  CreatureSpec(
    worldId: 'day',
    tier: 8,
    palette: CreaturePalette(
      body: Color(0xFFD08248),
      belly: Color(0xFFFCE6CE),
      accent: Color(0xFFFFA98F),
      detail: Color(0xFF7C4E2A),
    ),
    body: BodyShape.pear,
    ears: EarType.tufted,
    tail: TailType.bushy,
    snout: SnoutType.dot,
    pattern: PatternType.belly,
    eyes: EyeStyle.sparkle,
    accent: Accent.leaf,
  ),

  // 9 — Hedgehog
  CreatureSpec(
    worldId: 'day',
    tier: 9,
    palette: CreaturePalette(
      body: Color(0xFFAE8F76),
      belly: Color(0xFFF4DCC2),
      accent: Color(0xFFFFAF9E),
      detail: Color(0xFF6B5340),
    ),
    body: BodyShape.wide,
    ears: EarType.roundSmall,
    crest: CrestType.spikes,
    snout: SnoutType.dot,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    widthScale: .96,
  ),

  // 10 — Duckling
  CreatureSpec(
    worldId: 'day',
    tier: 10,
    palette: CreaturePalette(
      body: Color(0xFFFBE08A),
      belly: Color(0xFFFFF6D6),
      accent: Color(0xFFFFB27A),
      detail: Color(0xFFF29B3C),
    ),
    body: BodyShape.bird,
    wings: WingType.tiny,
    snout: SnoutType.duckBill,
    limbs: LimbType.flippers,
    eyes: EyeStyle.round,
    accent: Accent.droplet,
  ),

  // 11 — Frog
  CreatureSpec(
    worldId: 'day',
    tier: 11,
    palette: CreaturePalette(
      body: Color(0xFF7ECB6B),
      belly: Color(0xFFE7F7C9),
      accent: Color(0xFFFFA9A0),
      detail: Color(0xFF43813C),
    ),
    body: BodyShape.wide,
    eyes: EyeStyle.wide,
    pattern: PatternType.belly,
    limbs: LimbType.stubby,
    accent: Accent.leaf,
    widthScale: 1.02,
    eyeSpacing: 1.28,
  ),

  // 12 — Tortoise
  CreatureSpec(
    worldId: 'day',
    tier: 12,
    palette: CreaturePalette(
      body: Color(0xFF9AC48A),
      belly: Color(0xFFE8F0CE),
      accent: Color(0xFFFFB2A2),
      detail: Color(0xFFB08A4E),
    ),
    body: BodyShape.shell,
    eyes: EyeStyle.sleepy,
    snout: SnoutType.dot,
    limbs: LimbType.stubby,
    accent: Accent.shellPlate,
  ),

  // 13 — Fox Cub
  CreatureSpec(
    worldId: 'day',
    tier: 13,
    palette: CreaturePalette(
      body: Color(0xFFF08B4B),
      belly: Color(0xFFFFF1E0),
      accent: Color(0xFFFFB09B),
      detail: Color(0xFF7A4020),
    ),
    body: BodyShape.egg,
    ears: EarType.cat,
    tail: TailType.bushy,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
  ),

  // 14 — Piglet
  CreatureSpec(
    worldId: 'day',
    tier: 14,
    palette: CreaturePalette(
      body: Color(0xFFFFB6C4),
      belly: Color(0xFFFFE3E8),
      accent: Color(0xFFFF8FA8),
      detail: Color(0xFFE07E93),
    ),
    body: BodyShape.blob,
    ears: EarType.pointed,
    tail: TailType.curl,
    snout: SnoutType.wideMuzzle,
    eyes: EyeStyle.closedHappy,
    limbs: LimbType.hooves,
  ),

  // 15 — Lamb
  CreatureSpec(
    worldId: 'day',
    tier: 15,
    palette: CreaturePalette(
      body: Color(0xFFFCF6EE),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFFFB9B0),
      detail: Color(0xFF4F4A56),
    ),
    body: BodyShape.blob,
    ears: EarType.floppy,
    crest: CrestType.woolTuft,
    snout: SnoutType.muzzle,
    pattern: PatternType.dapple,
    eyes: EyeStyle.round,
    limbs: LimbType.hooves,
    accent: Accent.cloud,
  ),

  // 16 — Kid Goat
  CreatureSpec(
    worldId: 'day',
    tier: 16,
    palette: CreaturePalette(
      body: Color(0xFFD9CFC2),
      belly: Color(0xFFF7F1E8),
      accent: Color(0xFFFFB6A6),
      detail: Color(0xFF8A7A66),
    ),
    body: BodyShape.egg,
    ears: EarType.floppy,
    crest: CrestType.hornsSmall,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    // Dapple, not patches: patches paint in the accent colour, and this goat's
    // accent is its blush pink — which put a salmon blanket on its back.
    pattern: PatternType.dapple,
    eyes: EyeStyle.side,
    limbs: LimbType.hooves,
    accent: Accent.beardTuft,
  ),

  // 17 — Raccoon
  CreatureSpec(
    worldId: 'day',
    tier: 17,
    palette: CreaturePalette(
      body: Color(0xFF9BA4B4),
      belly: Color(0xFFEDF1F6),
      accent: Color(0xFF4C5468),
      detail: Color(0xFF3A4152),
    ),
    body: BodyShape.pear,
    ears: EarType.roundSmall,
    tail: TailType.ringed,
    snout: SnoutType.muzzle,
    pattern: PatternType.mask,
    eyes: EyeStyle.wide,
    limbs: LimbType.paws,
    accent: Accent.cheekTuft,
  ),

  // 18 — Otter
  CreatureSpec(
    worldId: 'day',
    tier: 18,
    palette: CreaturePalette(
      body: Color(0xFF9B7150),
      belly: Color(0xFFE7CFAE),
      accent: Color(0xFFFFB49B),
      detail: Color(0xFF5F452E),
    ),
    body: BodyShape.tall,
    ears: EarType.roundSmall,
    tail: TailType.thick,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.flippers,
    accent: Accent.bubbles,
  ),

  // 19 — Fawn
  CreatureSpec(
    worldId: 'day',
    tier: 19,
    palette: CreaturePalette(
      body: Color(0xFFC98B5C),
      belly: Color(0xFFF7E3CA),
      accent: Color(0xFFFFF3E0),
      detail: Color(0xFF6F4526),
    ),
    body: BodyShape.tall,
    ears: EarType.longUp,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    pattern: PatternType.spots,
    eyes: EyeStyle.big,
    limbs: LimbType.tallLegs,
    accent: Accent.flower,
  ),

  // 20 — Koala
  CreatureSpec(
    worldId: 'day',
    tier: 20,
    palette: CreaturePalette(
      body: Color(0xFFA9B2BE),
      belly: Color(0xFFEFF3F7),
      accent: Color(0xFFFFB3B3),
      detail: Color(0xFF4D5560),
    ),
    body: BodyShape.blob,
    ears: EarType.roundBig,
    snout: SnoutType.bigNose,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
    accent: Accent.leaf,
  ),

  // 21 — Red Panda
  CreatureSpec(
    worldId: 'day',
    tier: 21,
    palette: CreaturePalette(
      body: Color(0xFFD9663F),
      belly: Color(0xFFFFF0E2),
      accent: Color(0xFF4A3126),
      detail: Color(0xFF6E3520),
    ),
    body: BodyShape.blob,
    ears: EarType.roundBig,
    tail: TailType.ringed,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
    accent: Accent.cheekTuft,
  ),

  // 22 — Sloth
  CreatureSpec(
    worldId: 'day',
    tier: 22,
    palette: CreaturePalette(
      body: Color(0xFFB6A489),
      belly: Color(0xFFEDE0C8),
      accent: Color(0xFF7C6B52),
      detail: Color(0xFF5B4C39),
    ),
    body: BodyShape.pear,
    ears: EarType.roundSmall,
    snout: SnoutType.muzzle,
    pattern: PatternType.mask,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.paws,
    accent: Accent.leaf,
  ),

  // 23 — Zebra
  CreatureSpec(
    worldId: 'day',
    tier: 23,
    palette: CreaturePalette(
      body: Color(0xFFF7F4EF),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFF3A3A46),
      detail: Color(0xFF4A4A58),
    ),
    body: BodyShape.tall,
    ears: EarType.longUp,
    crest: CrestType.crest,
    tail: TailType.whip,
    snout: SnoutType.longFace,
    pattern: PatternType.stripes,
    eyes: EyeStyle.round,
    limbs: LimbType.tallLegs,
  ),

  // 24 — Giraffe
  CreatureSpec(
    worldId: 'day',
    tier: 24,
    palette: CreaturePalette(
      body: Color(0xFFF3C86A),
      belly: Color(0xFFFFF0CE),
      accent: Color(0xFFB2733A),
      detail: Color(0xFF8A5E2C),
    ),
    body: BodyShape.tall,
    ears: EarType.pointed,
    crest: CrestType.hornsSmall,
    tail: TailType.whip,
    snout: SnoutType.longFace,
    pattern: PatternType.patches,
    eyes: EyeStyle.big,
    limbs: LimbType.tallLegs,
    heightScale: 1.04,
    widthScale: .92,
  ),

  // 25 — Panda
  CreatureSpec(
    worldId: 'day',
    tier: 25,
    palette: CreaturePalette(
      body: Color(0xFFFAF8F5),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFF37343E),
      detail: Color(0xFF37343E),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundBig,
    snout: SnoutType.muzzle,
    pattern: PatternType.eyePatches,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
    accent: Accent.leaf,
  ),

  // 26 — Lion
  CreatureSpec(
    worldId: 'day',
    tier: 26,
    palette: CreaturePalette(
      body: Color(0xFFEFC178),
      belly: Color(0xFFFFF1D8),
      accent: Color(0xFFC97B3C),
      detail: Color(0xFF8A5424),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundSmall,
    crest: CrestType.mane,
    tail: TailType.spade,
    snout: SnoutType.wideMuzzle,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
  ),

  // 27 — Elephant
  CreatureSpec(
    worldId: 'day',
    tier: 27,
    palette: CreaturePalette(
      body: Color(0xFFA9AEC2),
      belly: Color(0xFFE6E9F2),
      accent: Color(0xFFFFB3B8),
      detail: Color(0xFF6E7386),
    ),
    body: BodyShape.chunky,
    ears: EarType.fan,
    tail: TailType.whip,
    snout: SnoutType.trunk,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.stubby,
    widthScale: 1.02,
  ),

  // 28 — Rhino
  CreatureSpec(
    worldId: 'day',
    tier: 28,
    palette: CreaturePalette(
      body: Color(0xFF8E93A8),
      belly: Color(0xFFDDE1EC),
      accent: Color(0xFF6A6F84),
      detail: Color(0xFFE8E2D4),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundSmall,
    crest: CrestType.noseHorn,
    tail: TailType.whip,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.plates,
    eyes: EyeStyle.side,
    limbs: LimbType.stubby,
    widthScale: 1.04,
  ),

  // 29 — Grizzly Bear
  CreatureSpec(
    worldId: 'day',
    tier: 29,
    palette: CreaturePalette(
      body: Color(0xFF8C6547),
      belly: Color(0xFFE4C9A6),
      accent: Color(0xFFFFB49E),
      detail: Color(0xFF5A3D27),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundBig,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
    accent: Accent.flower,
  ),

  // 30 — Golden Stag
  CreatureSpec(
    worldId: 'day',
    tier: 30,
    palette: CreaturePalette(
      body: Color(0xFFE8BC63),
      belly: Color(0xFFFFF3D2),
      accent: Color(0xFFFFF0B4),
      detail: Color(0xFF9A6E2A),
    ),
    body: BodyShape.tall,
    ears: EarType.longUp,
    crest: CrestType.antlers,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    pattern: PatternType.stars,
    eyes: EyeStyle.glow,
    limbs: LimbType.tallLegs,
    accent: Accent.sparkles,
  ),
];
