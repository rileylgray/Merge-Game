import 'dart:ui' show Color;

import '../creature_spec.dart';

/// Myth Meadow — folklore and legend, from hedgerow spirits to elder dragons.
const List<CreatureSpec> mythicalCreatures = <CreatureSpec>[
  // 1 — Wisp
  CreatureSpec(
    worldId: 'mythical',
    tier: 1,
    palette: CreaturePalette(
      body: Color(0xFFBFE8FF),
      belly: Color(0xFFEFFAFF),
      accent: Color(0xFF8AD8FF),
      detail: Color(0xFF7FB8D8),
    ),
    body: BodyShape.drop,
    eyes: EyeStyle.closedHappy,
    limbs: LimbType.none,
    accent: Accent.sparkles,
    widthScale: .84,
    heightScale: .84,
    blush: false,
  ),

  // 2 — Pixie
  CreatureSpec(
    worldId: 'mythical',
    tier: 2,
    palette: CreaturePalette(
      body: Color(0xFFFFC7E0),
      belly: Color(0xFFFFEBF4),
      accent: Color(0xFFB08AE8),
      detail: Color(0xFFD98AB4),
    ),
    body: BodyShape.egg,
    ears: EarType.pointed,
    wings: WingType.fairy,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.tinyFeet,
    accent: Accent.sparkles,
    widthScale: .88,
    heightScale: .88,
  ),

  // 3 — Sporeling
  CreatureSpec(
    worldId: 'mythical',
    tier: 3,
    palette: CreaturePalette(
      body: Color(0xFFEFE3CE),
      belly: Color(0xFFFFF8EC),
      accent: Color(0xFFE86B6B),
      detail: Color(0xFFC4B49A),
    ),
    body: BodyShape.egg,
    crest: CrestType.mushroomCap,
    eyes: EyeStyle.closedHappy,
    limbs: LimbType.tinyFeet,
    widthScale: .92,
    heightScale: .90,
  ),

  // 4 — Fairy
  CreatureSpec(
    worldId: 'mythical',
    tier: 4,
    palette: CreaturePalette(
      body: Color(0xFFCBEFC0),
      belly: Color(0xFFF0FBEA),
      accent: Color(0xFFFFE08A),
      detail: Color(0xFF8CC47E),
    ),
    body: BodyShape.egg,
    ears: EarType.pointed,
    wings: WingType.butterfly,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.tinyFeet,
    accent: Accent.flower,
  ),

  // 5 — Gnome
  CreatureSpec(
    worldId: 'mythical',
    tier: 5,
    palette: CreaturePalette(
      body: Color(0xFF7FA8D8),
      belly: Color(0xFFEFE2CE),
      accent: Color(0xFFE85C5C),
      detail: Color(0xFF4E6F9E),
    ),
    body: BodyShape.pear,
    crest: CrestType.flame,
    eyes: EyeStyle.closedHappy,
    limbs: LimbType.stubby,
    accent: Accent.beardTuft,
  ),

  // 6 — Imp
  CreatureSpec(
    worldId: 'mythical',
    tier: 6,
    palette: CreaturePalette(
      body: Color(0xFFE87A5C),
      belly: Color(0xFFFFD9C4),
      accent: Color(0xFFFFB08A),
      detail: Color(0xFF9E4530),
    ),
    body: BodyShape.bean,
    ears: EarType.pointed,
    crest: CrestType.hornsSmall,
    tail: TailType.spade,
    wings: WingType.bat,
    eyes: EyeStyle.side,
    snout: SnoutType.fangs,
    limbs: LimbType.tinyFeet,
  ),

  // 7 — Jackalope
  CreatureSpec(
    worldId: 'mythical',
    tier: 7,
    palette: CreaturePalette(
      body: Color(0xFFD8C4A8),
      belly: Color(0xFFF7EEDC),
      accent: Color(0xFFFFB6A8),
      detail: Color(0xFF9E8464),
    ),
    body: BodyShape.egg,
    ears: EarType.bunny,
    crest: CrestType.antlers,
    tail: TailType.puff,
    snout: SnoutType.buckTeeth,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
  ),

  // 8 — Kitsune Kit
  CreatureSpec(
    worldId: 'mythical',
    tier: 8,
    palette: CreaturePalette(
      body: Color(0xFFFFFAF2),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFE8564F),
      detail: Color(0xFFD8B48A),
    ),
    body: BodyShape.egg,
    ears: EarType.cat,
    tail: TailType.fan,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.paws,
  ),

  // 9 — Cockatrice
  CreatureSpec(
    worldId: 'mythical',
    tier: 9,
    palette: CreaturePalette(
      body: Color(0xFF8ABF6E),
      belly: Color(0xFFE4F2CE),
      accent: Color(0xFFE85C5C),
      detail: Color(0xFFF0A83C),
    ),
    body: BodyShape.bird,
    crest: CrestType.crest,
    tail: TailType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.scales,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
  ),

  // 10 — Gargoyle
  CreatureSpec(
    worldId: 'mythical',
    tier: 10,
    palette: CreaturePalette(
      body: Color(0xFF8E93A0),
      belly: Color(0xFFC4C8D2),
      accent: Color(0xFF6A6F7E),
      detail: Color(0xFF4E525E),
    ),
    body: BodyShape.chunky,
    ears: EarType.pointed,
    crest: CrestType.hornsSmall,
    wings: WingType.bat,
    tail: TailType.spade,
    snout: SnoutType.fangs,
    eyes: EyeStyle.glow,
    limbs: LimbType.stubby,
    blush: false,
  ),

  // 11 — Satyr
  CreatureSpec(
    worldId: 'mythical',
    tier: 11,
    palette: CreaturePalette(
      body: Color(0xFFB08A5C),
      belly: Color(0xFFEDD9BC),
      accent: Color(0xFF8ABF6E),
      detail: Color(0xFF6E5436),
    ),
    body: BodyShape.tall,
    ears: EarType.pointed,
    crest: CrestType.hornsCurved,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.hooves,
    accent: Accent.leaf,
  ),

  // 12 — Faun
  CreatureSpec(
    worldId: 'mythical',
    tier: 12,
    palette: CreaturePalette(
      body: Color(0xFFE0C4A0),
      belly: Color(0xFFF9EEDC),
      accent: Color(0xFFFFB6A8),
      detail: Color(0xFF9E7C52),
    ),
    body: BodyShape.tall,
    ears: EarType.longUp,
    crest: CrestType.leafSprout,
    tail: TailType.puff,
    snout: SnoutType.muzzle,
    pattern: PatternType.spots,
    eyes: EyeStyle.big,
    limbs: LimbType.hooves,
    accent: Accent.flower,
  ),

  // 13 — Kelpie
  CreatureSpec(
    worldId: 'mythical',
    tier: 13,
    palette: CreaturePalette(
      body: Color(0xFF4E7A8A),
      belly: Color(0xFFCBE8EF),
      accent: Color(0xFF7FD8C8),
      detail: Color(0xFF2E525E),
    ),
    body: BodyShape.tall,
    ears: EarType.pointed,
    crest: CrestType.crest,
    tail: TailType.fish,
    snout: SnoutType.longFace,
    pattern: PatternType.dapple,
    eyes: EyeStyle.glow,
    limbs: LimbType.hooves,
    accent: Accent.droplet,
  ),

  // 14 — Griffin Cub
  CreatureSpec(
    worldId: 'mythical',
    tier: 14,
    palette: CreaturePalette(
      body: Color(0xFFE0C48A),
      belly: Color(0xFFF7EBD2),
      accent: Color(0xFFC49A5C),
      detail: Color(0xFFEFA83C),
    ),
    body: BodyShape.egg,
    ears: EarType.feather,
    wings: WingType.feather,
    tail: TailType.spade,
    snout: SnoutType.beakSmall,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.talons,
  ),

  // 15 — Unicorn Foal
  CreatureSpec(
    worldId: 'mythical',
    tier: 15,
    palette: CreaturePalette(
      body: Color(0xFFFFF6FB),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFFFB6E0),
      detail: Color(0xFFF2CC70),
    ),
    body: BodyShape.egg,
    ears: EarType.pointed,
    crest: CrestType.unicorn,
    tail: TailType.long,
    snout: SnoutType.longFace,
    pattern: PatternType.stars,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.hooves,
    accent: Accent.sparkles,
  ),

  // 16 — Pegasus
  CreatureSpec(
    worldId: 'mythical',
    tier: 16,
    palette: CreaturePalette(
      body: Color(0xFFEFF3FC),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFCBDCF7),
      detail: Color(0xFFA8B6D8),
    ),
    body: BodyShape.tall,
    ears: EarType.pointed,
    crest: CrestType.crest,
    wings: WingType.feather,
    tail: TailType.long,
    snout: SnoutType.longFace,
    eyes: EyeStyle.round,
    limbs: LimbType.hooves,
    accent: Accent.cloud,
  ),

  // 17 — Basilisk
  CreatureSpec(
    worldId: 'mythical',
    tier: 17,
    palette: CreaturePalette(
      body: Color(0xFF5C8A4E),
      belly: Color(0xFFCFE8B4),
      accent: Color(0xFFF2D45C),
      detail: Color(0xFF35592C),
    ),
    body: BodyShape.serpent,
    crest: CrestType.crown,
    snout: SnoutType.fangs,
    pattern: PatternType.scales,
    eyes: EyeStyle.glow,
    limbs: LimbType.none,
    blush: false,
  ),

  // 18 — Chimera
  CreatureSpec(
    worldId: 'mythical',
    tier: 18,
    palette: CreaturePalette(
      body: Color(0xFFD88A4E),
      belly: Color(0xFFF7DCBC),
      accent: Color(0xFF8ABF6E),
      detail: Color(0xFF9E5A2C),
    ),
    body: BodyShape.chunky,
    ears: EarType.cat,
    crest: CrestType.hornsCurved,
    tail: TailType.stinger,
    snout: SnoutType.fangs,
    pattern: PatternType.patches,
    eyes: EyeStyle.side,
    limbs: LimbType.paws,
  ),

  // 19 — Minotaur
  CreatureSpec(
    worldId: 'mythical',
    tier: 19,
    palette: CreaturePalette(
      body: Color(0xFF8A5C42),
      belly: Color(0xFFDCBC9E),
      accent: Color(0xFFC48A6A),
      detail: Color(0xFFEFE3CE),
    ),
    body: BodyShape.chunky,
    ears: EarType.floppy,
    crest: CrestType.hornsCurved,
    tail: TailType.spade,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.side,
    limbs: LimbType.hooves,
  ),

  // 20 — Sphinx
  CreatureSpec(
    worldId: 'mythical',
    tier: 20,
    palette: CreaturePalette(
      body: Color(0xFFE8CC8A),
      belly: Color(0xFFF9EFD2),
      accent: Color(0xFF3E5A8A),
      detail: Color(0xFF2E4670),
    ),
    body: BodyShape.chunky,
    ears: EarType.cat,
    crest: CrestType.crown,
    wings: WingType.feather,
    tail: TailType.spade,
    snout: SnoutType.muzzle,
    pattern: PatternType.stripes,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.paws,
  ),

  // 21 — Nine-Tail Fox
  CreatureSpec(
    worldId: 'mythical',
    tier: 21,
    palette: CreaturePalette(
      body: Color(0xFFF7EFE4),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFE8564F),
      detail: Color(0xFFD8B06A),
    ),
    body: BodyShape.tall,
    ears: EarType.cat,
    tail: TailType.fan,
    snout: SnoutType.muzzle,
    pattern: PatternType.stars,
    eyes: EyeStyle.glow,
    limbs: LimbType.paws,
    accent: Accent.fireflies,
  ),

  // 22 — Hydra
  CreatureSpec(
    worldId: 'mythical',
    tier: 22,
    palette: CreaturePalette(
      body: Color(0xFF4E9E8A),
      belly: Color(0xFFCBEFE2),
      accent: Color(0xFF7FD8B4),
      detail: Color(0xFF2E6E5C),
    ),
    body: BodyShape.serpent,
    crest: CrestType.plates,
    tail: TailType.whip,
    snout: SnoutType.fangs,
    pattern: PatternType.scales,
    eyes: EyeStyle.glow,
    limbs: LimbType.none,
    widthScale: 1.02,
  ),

  // 23 — Griffin
  CreatureSpec(
    worldId: 'mythical',
    tier: 23,
    palette: CreaturePalette(
      body: Color(0xFFD8B06A),
      belly: Color(0xFFF7E8C4),
      accent: Color(0xFFB07C3C),
      detail: Color(0xFFEFA83C),
    ),
    body: BodyShape.chunky,
    ears: EarType.feather,
    crest: CrestType.crest,
    wings: WingType.feather,
    tail: TailType.spade,
    snout: SnoutType.beakLong,
    pattern: PatternType.belly,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
  ),

  // 24 — Unicorn
  CreatureSpec(
    worldId: 'mythical',
    tier: 24,
    palette: CreaturePalette(
      body: Color(0xFFFFFFFF),
      belly: Color(0xFFFFFAFC),
      accent: Color(0xFFB8A8F7),
      detail: Color(0xFFF2CC70),
    ),
    body: BodyShape.tall,
    ears: EarType.pointed,
    crest: CrestType.unicorn,
    tail: TailType.long,
    snout: SnoutType.longFace,
    pattern: PatternType.stars,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.hooves,
    accent: Accent.sparkles,
  ),

  // 25 — Wyvern
  CreatureSpec(
    worldId: 'mythical',
    tier: 25,
    palette: CreaturePalette(
      body: Color(0xFF6E5C9E),
      belly: Color(0xFFCBBCEF),
      accent: Color(0xFF9E8AD8),
      detail: Color(0xFF443872),
    ),
    body: BodyShape.chunky,
    ears: EarType.horn,
    crest: CrestType.spikes,
    wings: WingType.dragon,
    tail: TailType.spiked,
    snout: SnoutType.longJaw,
    pattern: PatternType.scales,
    eyes: EyeStyle.glow,
    limbs: LimbType.talons,
    blush: false,
  ),

  // 26 — Thunderbird
  CreatureSpec(
    worldId: 'mythical',
    tier: 26,
    palette: CreaturePalette(
      body: Color(0xFF3E4E7A),
      belly: Color(0xFF8AA8D8),
      accent: Color(0xFFFFDC5C),
      detail: Color(0xFFFFC83C),
    ),
    body: BodyShape.tall,
    ears: EarType.feather,
    crest: CrestType.crest,
    wings: WingType.feather,
    tail: TailType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.stripes,
    eyes: EyeStyle.glow,
    limbs: LimbType.talons,
    accent: Accent.cloud,
  ),

  // 27 — Phoenix
  CreatureSpec(
    worldId: 'mythical',
    tier: 27,
    palette: CreaturePalette(
      body: Color(0xFFF2703C),
      belly: Color(0xFFFFD48A),
      accent: Color(0xFFFFC83C),
      detail: Color(0xFFD8501C),
    ),
    body: BodyShape.bird,
    crest: CrestType.flame,
    wings: WingType.feather,
    tail: TailType.fan,
    snout: SnoutType.beakSmall,
    pattern: PatternType.stripes,
    eyes: EyeStyle.glow,
    limbs: LimbType.talons,
    accent: Accent.sparkles,
  ),

  // 28 — Leviathan
  CreatureSpec(
    worldId: 'mythical',
    tier: 28,
    palette: CreaturePalette(
      body: Color(0xFF2E5C7A),
      belly: Color(0xFF7FC8D8),
      accent: Color(0xFF5CD8C8),
      detail: Color(0xFF1C3E56),
    ),
    body: BodyShape.serpent,
    ears: EarType.sideFin,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.longJaw,
    pattern: PatternType.scales,
    eyes: EyeStyle.glow,
    limbs: LimbType.none,
    widthScale: 1.04,
    blush: false,
  ),

  // 29 — Dragon
  CreatureSpec(
    worldId: 'mythical',
    tier: 29,
    palette: CreaturePalette(
      body: Color(0xFFC0392B),
      belly: Color(0xFFF7D08A),
      accent: Color(0xFFF2703C),
      detail: Color(0xFF8A251A),
    ),
    body: BodyShape.chunky,
    ears: EarType.horn,
    crest: CrestType.spikes,
    wings: WingType.dragon,
    tail: TailType.spiked,
    snout: SnoutType.longJaw,
    pattern: PatternType.plates,
    eyes: EyeStyle.glow,
    limbs: LimbType.talons,
    widthScale: 1.02,
  ),

  // 30 — Elder Dragon
  CreatureSpec(
    worldId: 'mythical',
    tier: 30,
    palette: CreaturePalette(
      body: Color(0xFF2E2A4E),
      belly: Color(0xFF7F6ECF),
      accent: Color(0xFFFFD45C),
      detail: Color(0xFFFFE9A8),
    ),
    body: BodyShape.chunky,
    ears: EarType.horn,
    crest: CrestType.crown,
    wings: WingType.dragon,
    tail: TailType.spiked,
    snout: SnoutType.longJaw,
    pattern: PatternType.stars,
    eyes: EyeStyle.glow,
    limbs: LimbType.talons,
    widthScale: 1.04,
    accent: Accent.sparkles,
    blush: false,
  ),
];
