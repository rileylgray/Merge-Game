import 'dart:ui' show Color;

import '../creature_spec.dart';

/// Night Meadow — moonlit nocturnal animals that drift into the celestial.
const List<CreatureSpec> nightCreatures = <CreatureSpec>[
  // 1 — Firefly
  CreatureSpec(
    worldId: 'night',
    tier: 1,
    palette: CreaturePalette(
      body: Color(0xFF4A4266),
      belly: Color(0xFFFFF3A8),
      accent: Color(0xFFFFE066),
      detail: Color(0xFF2C2743),
    ),
    body: BodyShape.bug,
    ears: EarType.antenna,
    wings: WingType.insect,
    eyes: EyeStyle.glow,
    accent: Accent.fireflies,
    widthScale: .88,
    heightScale: .82,
  ),

  // 2 — Moth
  CreatureSpec(
    worldId: 'night',
    tier: 2,
    palette: CreaturePalette(
      body: Color(0xFFBFAEC7),
      belly: Color(0xFFEFE4F2),
      accent: Color(0xFF8E7BA6),
      detail: Color(0xFF5B4C6E),
    ),
    body: BodyShape.bug,
    ears: EarType.feather,
    wings: WingType.butterfly,
    eyes: EyeStyle.closedHappy,
    accent: Accent.moon,
    widthScale: .86,
    heightScale: .90,
  ),

  // 3 — Glowworm
  CreatureSpec(
    worldId: 'night',
    tier: 3,
    palette: CreaturePalette(
      body: Color(0xFF7FD6B4),
      belly: Color(0xFFDDFCEF),
      accent: Color(0xFF9DFFD8),
      detail: Color(0xFF3E7F68),
    ),
    body: BodyShape.serpent,
    eyes: EyeStyle.glow,
    pattern: PatternType.glowDots,
    limbs: LimbType.none,
    widthScale: .90,
  ),

  // 4 — Cricket
  CreatureSpec(
    worldId: 'night',
    tier: 4,
    palette: CreaturePalette(
      body: Color(0xFF6E9455),
      belly: Color(0xFFD6E9BC),
      accent: Color(0xFFA8D77E),
      detail: Color(0xFF3F5B31),
    ),
    body: BodyShape.bug,
    ears: EarType.antenna,
    wings: WingType.insect,
    tail: TailType.stinger,
    eyes: EyeStyle.round,
    limbs: LimbType.tallLegs,
    widthScale: .94,
  ),

  // 5 — Bat Pup
  CreatureSpec(
    worldId: 'night',
    tier: 5,
    palette: CreaturePalette(
      body: Color(0xFF6B5E86),
      belly: Color(0xFFD9CEEC),
      accent: Color(0xFF4B3F63),
      detail: Color(0xFF352C4A),
    ),
    body: BodyShape.egg,
    ears: EarType.pointed,
    wings: WingType.bat,
    snout: SnoutType.fangs,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    widthScale: .94,
  ),

  // 6 — Dormouse
  CreatureSpec(
    worldId: 'night',
    tier: 6,
    palette: CreaturePalette(
      body: Color(0xFFC9A98A),
      belly: Color(0xFFF6E7D2),
      accent: Color(0xFFFFB6A8),
      detail: Color(0xFF7A6248),
    ),
    body: BodyShape.blob,
    ears: EarType.roundBig,
    tail: TailType.bushy,
    snout: SnoutType.dot,
    pattern: PatternType.belly,
    eyes: EyeStyle.sleepy,
    accent: Accent.star,
  ),

  // 7 — Possum
  CreatureSpec(
    worldId: 'night',
    tier: 7,
    palette: CreaturePalette(
      body: Color(0xFFC7CBD8),
      belly: Color(0xFFF2F4FA),
      accent: Color(0xFFFFB4C0),
      detail: Color(0xFF767C8E),
    ),
    body: BodyShape.pear,
    ears: EarType.roundBig,
    tail: TailType.whip,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.wide,
    limbs: LimbType.paws,
  ),

  // 8 — Owlet
  CreatureSpec(
    worldId: 'night',
    tier: 8,
    palette: CreaturePalette(
      body: Color(0xFF9C7F63),
      belly: Color(0xFFF0DFC4),
      accent: Color(0xFFD8B98C),
      detail: Color(0xFFE9A23C),
    ),
    body: BodyShape.bird,
    ears: EarType.tufted,
    wings: WingType.tiny,
    snout: SnoutType.beakSmall,
    pattern: PatternType.facialDisc,
    eyes: EyeStyle.wide,
    limbs: LimbType.talons,
    eyeSpacing: 1.12,
  ),

  // 9 — Skunk
  CreatureSpec(
    worldId: 'night',
    tier: 9,
    palette: CreaturePalette(
      body: Color(0xFF3B3846),
      belly: Color(0xFFF4F2F7),
      accent: Color(0xFFF4F2F7),
      detail: Color(0xFF23212C),
    ),
    body: BodyShape.pear,
    ears: EarType.roundSmall,
    tail: TailType.bushy,
    snout: SnoutType.dot,
    pattern: PatternType.dorsalStripe,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
  ),

  // 10 — Fennec Fox
  CreatureSpec(
    worldId: 'night',
    tier: 10,
    palette: CreaturePalette(
      body: Color(0xFFEBD3A8),
      belly: Color(0xFFFFF6E4),
      accent: Color(0xFFFFC0A8),
      detail: Color(0xFFB08A57),
    ),
    body: BodyShape.egg,
    ears: EarType.longUp,
    tail: TailType.bushy,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.big,
    limbs: LimbType.paws,
  ),

  // 11 — Tarsier
  CreatureSpec(
    worldId: 'night',
    tier: 11,
    palette: CreaturePalette(
      body: Color(0xFFB59E82),
      belly: Color(0xFFEDDFC8),
      accent: Color(0xFFFFC29E),
      detail: Color(0xFF6E5C44),
    ),
    body: BodyShape.egg,
    ears: EarType.roundBig,
    tail: TailType.whip,
    snout: SnoutType.dot,
    eyes: EyeStyle.big,
    limbs: LimbType.paws,
    eyeSpacing: 1.16,
    widthScale: .94,
  ),

  // 12 — Sugar Glider
  CreatureSpec(
    worldId: 'night',
    tier: 12,
    palette: CreaturePalette(
      body: Color(0xFFA9B6C9),
      belly: Color(0xFFF2F6FB),
      accent: Color(0xFF5C6880),
      detail: Color(0xFF3E4757),
    ),
    body: BodyShape.wide,
    ears: EarType.roundBig,
    wings: WingType.tiny,
    tail: TailType.long,
    snout: SnoutType.dot,
    pattern: PatternType.dorsalStripe,
    eyes: EyeStyle.big,
    limbs: LimbType.paws,
  ),

  // 13 — Slow Loris
  CreatureSpec(
    worldId: 'night',
    tier: 13,
    palette: CreaturePalette(
      body: Color(0xFFC4A88C),
      belly: Color(0xFFF3E5D2),
      accent: Color(0xFF6E5643),
      detail: Color(0xFF5A4535),
    ),
    body: BodyShape.blob,
    ears: EarType.roundSmall,
    snout: SnoutType.dot,
    // Eye rings, not patches: six loose blotches of a brown barely darker than
    // the coat read as staining rather than markings, and a loris's whole face
    // is the dark rings anyway.
    pattern: PatternType.eyePatches,
    eyes: EyeStyle.big,
    limbs: LimbType.paws,
    eyeSpacing: 1.10,
  ),

  // 14 — Aye-Aye
  CreatureSpec(
    worldId: 'night',
    tier: 14,
    palette: CreaturePalette(
      body: Color(0xFF4E4757),
      belly: Color(0xFFC9C0D6),
      accent: Color(0xFFFFD36E),
      detail: Color(0xFF2F2A3C),
    ),
    body: BodyShape.pear,
    ears: EarType.roundBig,
    tail: TailType.bushy,
    snout: SnoutType.dot,
    pattern: PatternType.dapple,
    eyes: EyeStyle.glow,
    limbs: LimbType.paws,
  ),

  // 15 — Badger
  CreatureSpec(
    worldId: 'night',
    tier: 15,
    palette: CreaturePalette(
      body: Color(0xFF8A8FA0),
      belly: Color(0xFFF2F3F7),
      accent: Color(0xFF2F2E38),
      detail: Color(0xFF4A4A57),
    ),
    body: BodyShape.wide,
    ears: EarType.roundSmall,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    pattern: PatternType.dorsalStripe,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
  ),

  // 16 — Armadillo
  CreatureSpec(
    worldId: 'night',
    tier: 16,
    palette: CreaturePalette(
      body: Color(0xFFB79C86),
      belly: Color(0xFFEEDCC6),
      accent: Color(0xFF8A705A),
      detail: Color(0xFF9C8168),
    ),
    body: BodyShape.shell,
    ears: EarType.pointed,
    tail: TailType.long,
    snout: SnoutType.dot,
    pattern: PatternType.ringed,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.stubby,
    accent: Accent.shellPlate,
  ),

  // 17 — Porcupine
  CreatureSpec(
    worldId: 'night',
    tier: 17,
    palette: CreaturePalette(
      body: Color(0xFF6A5B4C),
      belly: Color(0xFFD9C7AE),
      accent: Color(0xFFFFB49E),
      detail: Color(0xFFEFE3CB),
    ),
    body: BodyShape.wide,
    ears: EarType.roundSmall,
    crest: CrestType.spikes,
    snout: SnoutType.dot,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
    widthScale: 1.0,
  ),

  // 18 — Barn Owl
  CreatureSpec(
    worldId: 'night',
    tier: 18,
    palette: CreaturePalette(
      body: Color(0xFFE3D4BB),
      belly: Color(0xFFFFFAF0),
      accent: Color(0xFFC9A87C),
      detail: Color(0xFFE0A044),
    ),
    body: BodyShape.tall,
    wings: WingType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.facialDisc,
    eyes: EyeStyle.wide,
    limbs: LimbType.talons,
    eyeSpacing: 1.10,
  ),

  // 19 — Lynx
  CreatureSpec(
    worldId: 'night',
    tier: 19,
    palette: CreaturePalette(
      body: Color(0xFFC9B49B),
      belly: Color(0xFFF5EADA),
      accent: Color(0xFF7A6450),
      detail: Color(0xFF5A4737),
    ),
    body: BodyShape.tall,
    ears: EarType.tufted,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    pattern: PatternType.spots,
    eyes: EyeStyle.side,
    limbs: LimbType.paws,
    accent: Accent.cheekTuft,
  ),

  // 20 — Wolf Pup
  CreatureSpec(
    worldId: 'night',
    tier: 20,
    palette: CreaturePalette(
      body: Color(0xFF7E8AA2),
      belly: Color(0xFFE6EBF4),
      accent: Color(0xFFB9C4D6),
      detail: Color(0xFF4B5468),
    ),
    body: BodyShape.egg,
    ears: EarType.cat,
    tail: TailType.bushy,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
    accent: Accent.moon,
  ),

  // 21 — Panther
  CreatureSpec(
    worldId: 'night',
    tier: 21,
    palette: CreaturePalette(
      body: Color(0xFF34313F),
      belly: Color(0xFF4A4657),
      accent: Color(0xFF6FE3C8),
      detail: Color(0xFF211F2A),
    ),
    body: BodyShape.tall,
    ears: EarType.cat,
    tail: TailType.long,
    snout: SnoutType.muzzle,
    pattern: PatternType.dapple,
    eyes: EyeStyle.glow,
    limbs: LimbType.paws,
    blush: false,
  ),

  // 22 — Moon Hare
  CreatureSpec(
    worldId: 'night',
    tier: 22,
    palette: CreaturePalette(
      body: Color(0xFFDCE4F5),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFFFE9A8),
      detail: Color(0xFF9AA6C4),
    ),
    body: BodyShape.egg,
    ears: EarType.bunny,
    tail: TailType.puff,
    snout: SnoutType.buckTeeth,
    pattern: PatternType.stars,
    eyes: EyeStyle.sparkle,
    accent: Accent.moon,
  ),

  // 23 — Snow Leopard
  CreatureSpec(
    worldId: 'night',
    tier: 23,
    palette: CreaturePalette(
      body: Color(0xFFE6E9F2),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFF6E7590),
      detail: Color(0xFF4C536B),
    ),
    body: BodyShape.tall,
    ears: EarType.roundSmall,
    tail: TailType.thick,
    snout: SnoutType.muzzle,
    pattern: PatternType.rosettes,
    eyes: EyeStyle.side,
    limbs: LimbType.paws,
    accent: Accent.snowflake,
  ),

  // 24 — Aurora Wolf
  CreatureSpec(
    worldId: 'night',
    tier: 24,
    palette: CreaturePalette(
      body: Color(0xFF4E6FA8),
      belly: Color(0xFFBFE8F5),
      accent: Color(0xFF6FF0C0),
      detail: Color(0xFF2E4370),
    ),
    body: BodyShape.tall,
    ears: EarType.cat,
    crest: CrestType.crest,
    tail: TailType.bushy,
    snout: SnoutType.muzzle,
    pattern: PatternType.stripes,
    eyes: EyeStyle.glow,
    limbs: LimbType.paws,
    accent: Accent.sparkles,
  ),

  // 25 — Comet Cat
  CreatureSpec(
    worldId: 'night',
    tier: 25,
    palette: CreaturePalette(
      body: Color(0xFF5B4C8A),
      belly: Color(0xFFD9CBFF),
      accent: Color(0xFFFFC46B),
      detail: Color(0xFF352A55),
    ),
    body: BodyShape.egg,
    ears: EarType.cat,
    tail: TailType.long,
    snout: SnoutType.muzzle,
    pattern: PatternType.stars,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.paws,
    accent: Accent.star,
  ),

  // 26 — Dream Tapir
  CreatureSpec(
    worldId: 'night',
    tier: 26,
    palette: CreaturePalette(
      body: Color(0xFF8E7BC4),
      belly: Color(0xFFE0D6F7),
      accent: Color(0xFFFFB6E0),
      detail: Color(0xFF5B4A87),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundSmall,
    tail: TailType.puff,
    snout: SnoutType.trunk,
    pattern: PatternType.stars,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.stubby,
    accent: Accent.cloud,
  ),

  // 27 — Nebula Owl
  CreatureSpec(
    worldId: 'night',
    tier: 27,
    palette: CreaturePalette(
      body: Color(0xFF3F3670),
      belly: Color(0xFF6E5FB0),
      accent: Color(0xFFFF9EDB),
      detail: Color(0xFFFFD166),
    ),
    body: BodyShape.tall,
    ears: EarType.tufted,
    wings: WingType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.facialDisc,
    eyes: EyeStyle.glow,
    limbs: LimbType.talons,
    eyeSpacing: 1.10,
    accent: Accent.sparkles,
  ),

  // 28 — Eclipse Bear
  CreatureSpec(
    worldId: 'night',
    tier: 28,
    palette: CreaturePalette(
      body: Color(0xFF2E2B3D),
      belly: Color(0xFF4B4664),
      accent: Color(0xFFFFC85C),
      detail: Color(0xFF1D1B29),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundBig,
    crest: CrestType.halo,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.glowDots,
    eyes: EyeStyle.glow,
    limbs: LimbType.paws,
    blush: false,
  ),

  // 29 — Lunar Lynx
  CreatureSpec(
    worldId: 'night',
    tier: 29,
    palette: CreaturePalette(
      body: Color(0xFFB9C6EA),
      belly: Color(0xFFF4F7FF),
      accent: Color(0xFF8AD4FF),
      detail: Color(0xFF6C7BA8),
    ),
    body: BodyShape.tall,
    ears: EarType.tufted,
    crest: CrestType.halo,
    tail: TailType.thick,
    snout: SnoutType.muzzle,
    pattern: PatternType.stars,
    eyes: EyeStyle.glow,
    limbs: LimbType.paws,
    accent: Accent.sparkles,
  ),

  // 30 — Starweaver Stag
  CreatureSpec(
    worldId: 'night',
    tier: 30,
    palette: CreaturePalette(
      body: Color(0xFF2B2A55),
      belly: Color(0xFF5A57A0),
      accent: Color(0xFFFFE082),
      detail: Color(0xFFFFE082),
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
    blush: false,
  ),
];
