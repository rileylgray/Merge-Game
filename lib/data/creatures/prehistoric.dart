import 'dart:ui' show Color;

import '../creature_spec.dart';

/// Dino Meadow — the fossil record, from Cambrian shallows to the ice age.
const List<CreatureSpec> prehistoricCreatures = <CreatureSpec>[
  // 1 — Trilobite
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 1,
    palette: CreaturePalette(
      body: Color(0xFF6CA4D4),
      belly: Color(0xFFDCEAF2),
      accent: Color(0xFFA8C6DA),
      detail: Color(0xFF4E6B82),
    ),
    body: BodyShape.wide,
    ears: EarType.antenna,
    eyes: EyeStyle.wide,
    pattern: PatternType.ringed,
    limbs: LimbType.none,
    widthScale: .86,
    heightScale: .78,
  ),

  // 2 — Ammonite
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 2,
    palette: CreaturePalette(
      body: Color(0xFFDB7C95),
      belly: Color(0xFFF9DFE6),
      accent: Color(0xFFF4AABB),
      detail: Color(0xFF8E4459),
    ),
    body: BodyShape.serpent,
    crest: CrestType.shellSpiral,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.tentacles,
    widthScale: .90,
  ),

  // 3 — Anomalocaris
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 3,
    palette: CreaturePalette(
      body: Color(0xFFE07A5C),
      belly: Color(0xFFF7C8B4),
      accent: Color(0xFFFFA88A),
      detail: Color(0xFF9E4E36),
    ),
    body: BodyShape.serpent,
    ears: EarType.antenna,
    // A fan tail on a red body fires off a starburst of spikes that reads as a
    // weapon; a soft fluke keeps the swimming silhouette without the menace.
    tail: TailType.fish,
    eyes: EyeStyle.wide,
    pattern: PatternType.ringed,
    limbs: LimbType.none,
    accent: Accent.bubbles,
    widthScale: .94,
  ),

  // 4 — Meganeura
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 4,
    palette: CreaturePalette(
      body: Color(0xFF6EA88A),
      belly: Color(0xFFCBE8D4),
      accent: Color(0xFF9ED8B4),
      detail: Color(0xFF3E6E56),
    ),
    body: BodyShape.bug,
    ears: EarType.antenna,
    wings: WingType.insect,
    tail: TailType.whip,
    eyes: EyeStyle.wide,
    limbs: LimbType.none,
    eyeSpacing: 1.24,
    widthScale: .90,
  ),

  // 5 — Arthropleura
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 5,
    palette: CreaturePalette(
      body: Color(0xFF9270C2),
      belly: Color(0xFFE9DEF7),
      accent: Color(0xFFC4ACEA),
      detail: Color(0xFF5C4386),
    ),
    body: BodyShape.serpent,
    ears: EarType.antenna,
    eyes: EyeStyle.wide,
    pattern: PatternType.ringed,
    // Tall legs under a long low body left it stilted; tiny feet tuck the
    // whole animal down onto the ground where a millipede belongs.
    limbs: LimbType.tinyFeet,
    widthScale: .98,
  ),

  // 6 — Ichthyostega
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 6,
    palette: CreaturePalette(
      body: Color(0xFF5DAD7B),
      belly: Color(0xFFDCEFC8),
      accent: Color(0xFF9EDCAA),
      detail: Color(0xFF3B7350),
    ),
    body: BodyShape.wide,
    tail: TailType.fish,
    snout: SnoutType.wideMuzzle,
    eyes: EyeStyle.wide,
    pattern: PatternType.dapple,
    limbs: LimbType.stubby,
    eyeSpacing: 1.20,
  ),

  // 7 — Dimetrodon
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 7,
    palette: CreaturePalette(
      body: Color(0xFF6C88CC),
      belly: Color(0xFFD8E2EF),
      accent: Color(0xFFE8A85C),
      detail: Color(0xFF43599C),
    ),
    body: BodyShape.wide,
    crest: CrestType.sailFin,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    eyes: EyeStyle.round,
    pattern: PatternType.belly,
    limbs: LimbType.stubby,
  ),

  // 8 — Compsognathus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 8,
    palette: CreaturePalette(
      body: Color(0xFF9ECF7A),
      belly: Color(0xFFEFF7D4),
      accent: Color(0xFFCFE89E),
      detail: Color(0xFF5C8A3E),
    ),
    body: BodyShape.bean,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    eyes: EyeStyle.round,
    pattern: PatternType.belly,
    limbs: LimbType.talons,
    widthScale: .90,
  ),

  // 9 — Microraptor
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 9,
    palette: CreaturePalette(
      body: Color(0xFF6E6890),
      belly: Color(0xFFC4BEDC),
      accent: Color(0xFF7FDCE4),
      detail: Color(0xFF474263),
    ),
    body: BodyShape.bird,
    ears: EarType.feather,
    wings: WingType.feather,
    tail: TailType.feather,
    snout: SnoutType.beakSmall,
    eyes: EyeStyle.round,
    limbs: LimbType.talons,
  ),

  // 10 — Archaeopteryx
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 10,
    palette: CreaturePalette(
      body: Color(0xFF4C93AE),
      belly: Color(0xFFD9EFF5),
      accent: Color(0xFFF2C14E),
      detail: Color(0xFF2E657A),
    ),
    body: BodyShape.bird,
    crest: CrestType.crest,
    wings: WingType.feather,
    tail: TailType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.freckles,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.talons,
  ),

  // 11 — Protoceratops
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 11,
    palette: CreaturePalette(
      body: Color(0xFF9A9CDC),
      belly: Color(0xFFE9E9FB),
      accent: Color(0xFF6E70B8),
      detail: Color(0xFF585A9C),
    ),
    body: BodyShape.wide,
    ears: EarType.frill,
    tail: TailType.thick,
    snout: SnoutType.beakSmall,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.stubby,
  ),

  // 12 — Velociraptor
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 12,
    palette: CreaturePalette(
      body: Color(0xFF7EB04C),
      belly: Color(0xFFDCE8B4),
      accent: Color(0xFFE8A85C),
      detail: Color(0xFF4E722C),
    ),
    body: BodyShape.bean,
    ears: EarType.feather,
    crest: CrestType.crest,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    pattern: PatternType.stripes,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
  ),

  // 13 — Oviraptor
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 13,
    palette: CreaturePalette(
      body: Color(0xFF7ABFB4),
      belly: Color(0xFFD4F0EA),
      accent: Color(0xFFE87A8A),
      detail: Color(0xFF48857A),
    ),
    body: BodyShape.bird,
    crest: CrestType.crest,
    tail: TailType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.talons,
    accent: Accent.crackedEgg,
  ),

  // 14 — Pachycephalosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 14,
    palette: CreaturePalette(
      body: Color(0xFFC77BB3),
      belly: Color(0xFFF6DEEF),
      accent: Color(0xFFE8AAD6),
      detail: Color(0xFF8A4479),
    ),
    body: BodyShape.bean,
    crest: CrestType.spikes,
    tail: TailType.thick,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.talons,
  ),

  // 15 — Gallimimus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 15,
    palette: CreaturePalette(
      body: Color(0xFFF3D35E),
      belly: Color(0xFFFDEED2),
      accent: Color(0xFF6FBFC4),
      detail: Color(0xFFE08A4E),
    ),
    body: BodyShape.tall,
    // Was a long beak, full-length stripes and a bare tail on a pale body: a
    // stick-faced lump with nothing to look at. A short beak, a plume and a
    // clear belly give it the ostrich read without the stick.
    crest: CrestType.crest,
    tail: TailType.feather,
    snout: SnoutType.beakSmall,
    pattern: PatternType.belly,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.tallLegs,
    widthScale: .92,
  ),

  // 16 — Dilophosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 16,
    palette: CreaturePalette(
      body: Color(0xFF4CAA8E),
      belly: Color(0xFFCFE8CF),
      accent: Color(0xFFE85C6E),
      detail: Color(0xFF2C7462),
    ),
    body: BodyShape.bean,
    ears: EarType.frill,
    crest: CrestType.crest,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    pattern: PatternType.spots,
    eyes: EyeStyle.round,
    limbs: LimbType.talons,
  ),

  // 17 — Parasaurolophus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 17,
    palette: CreaturePalette(
      body: Color(0xFF8F98E2),
      belly: Color(0xFFDCE8F7),
      accent: Color(0xFFE8B86E),
      detail: Color(0xFF5C7AA8),
    ),
    body: BodyShape.tall,
    ears: EarType.horn,
    tail: TailType.thick,
    snout: SnoutType.duckBill,
    pattern: PatternType.stripes,
    eyes: EyeStyle.round,
    limbs: LimbType.stubby,
  ),

  // 18 — Stegosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 18,
    palette: CreaturePalette(
      body: Color(0xFF5CA06A),
      belly: Color(0xFFCFE0C4),
      accent: Color(0xFFE8A85C),
      detail: Color(0xFF3A6E46),
    ),
    body: BodyShape.wide,
    crest: CrestType.plates,
    tail: TailType.spiked,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.stubby,
    widthScale: 1.02,
  ),

  // 19 — Ankylosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 19,
    palette: CreaturePalette(
      body: Color(0xFF8CBC7C),
      belly: Color(0xFFE4E8CC),
      accent: Color(0xFF6A9A5C),
      detail: Color(0xFFCCD2AE),
    ),
    body: BodyShape.shell,
    crest: CrestType.spikes,
    tail: TailType.club,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.plates,
    eyes: EyeStyle.round,
    limbs: LimbType.stubby,
    accent: Accent.shellPlate,
  ),

  // 20 — Triceratops
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 20,
    palette: CreaturePalette(
      body: Color(0xFF5BB4A6),
      belly: Color(0xFFD6F1EA),
      accent: Color(0xFFF2B45E),
      detail: Color(0xFFF7EEDC),
    ),
    body: BodyShape.chunky,
    ears: EarType.frill,
    crest: CrestType.hornsSmall,
    tail: TailType.thick,
    snout: SnoutType.beakSmall,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.stubby,
  ),

  // 21 — Pteranodon
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 21,
    palette: CreaturePalette(
      body: Color(0xFF9B90D2),
      belly: Color(0xFFEBE7FA),
      accent: Color(0xFFF2877A),
      detail: Color(0xFFE8A070),
    ),
    body: BodyShape.bird,
    ears: EarType.horn,
    wings: WingType.dragon,
    snout: SnoutType.beakLong,
    pattern: PatternType.belly,
    // Side-glancing eyes over a long beak read as shifty; facing forward it is
    // just a bird with a big nose.
    eyes: EyeStyle.round,
    limbs: LimbType.talons,
  ),

  // 22 — Plesiosaur
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 22,
    palette: CreaturePalette(
      body: Color(0xFF4E8A9E),
      belly: Color(0xFFCBE8EF),
      accent: Color(0xFF7FC4D8),
      detail: Color(0xFF2E5E70),
    ),
    body: BodyShape.serpent,
    tail: TailType.fish,
    snout: SnoutType.longJaw,
    pattern: PatternType.dapple,
    eyes: EyeStyle.round,
    limbs: LimbType.flippers,
    widthScale: 1.0,
  ),

  // 23 — Mosasaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 23,
    palette: CreaturePalette(
      body: Color(0xFF3E5C6E),
      belly: Color(0xFFBCD8E0),
      accent: Color(0xFF6E9EB4),
      detail: Color(0xFF26404E),
    ),
    body: BodyShape.finned,
    crest: CrestType.plates,
    tail: TailType.fish,
    snout: SnoutType.longJaw,
    pattern: PatternType.scales,
    eyes: EyeStyle.side,
    limbs: LimbType.flippers,
    widthScale: 1.02,
    blush: false,
  ),

  // 24 — Allosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 24,
    palette: CreaturePalette(
      body: Color(0xFFC4586F),
      belly: Color(0xFFF7D3DA),
      accent: Color(0xFFF2A45E),
      detail: Color(0xFF7E2E44),
    ),
    body: BodyShape.bean,
    ears: EarType.horn,
    crest: CrestType.crest,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    pattern: PatternType.stripes,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
    widthScale: 1.0,
  ),

  // 25 — Spinosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 25,
    palette: CreaturePalette(
      body: Color(0xFF4A8BAA),
      belly: Color(0xFFCFE0E8),
      accent: Color(0xFFE8946E),
      detail: Color(0xFF2D5E78),
    ),
    body: BodyShape.tall,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.longJaw,
    pattern: PatternType.scales,
    eyes: EyeStyle.big,
    limbs: LimbType.talons,
  ),

  // 26 — Tyrannosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 26,
    palette: CreaturePalette(
      body: Color(0xFF6C9C4C),
      belly: Color(0xFFD8E0B4),
      accent: Color(0xFFE8C45C),
      detail: Color(0xFF42662C),
    ),
    body: BodyShape.chunky,
    ears: EarType.horn,
    crest: CrestType.spikes,
    tail: TailType.thick,
    snout: SnoutType.longJaw,
    pattern: PatternType.belly,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
    widthScale: 1.02,
  ),

  // 27 — Brachiosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 27,
    palette: CreaturePalette(
      body: Color(0xFF7CB5E2),
      belly: Color(0xFFDCE4F0),
      accent: Color(0xFF8FD17A),
      detail: Color(0xFF4A76A0),
    ),
    body: BodyShape.tall,
    ears: EarType.none,
    crest: CrestType.leafSprout,
    tail: TailType.long,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.dapple,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.tallLegs,
    heightScale: 1.04,
    widthScale: .94,
  ),

  // 28 — Sabertooth
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 28,
    palette: CreaturePalette(
      body: Color(0xFFD8A86E),
      belly: Color(0xFFF7E4C8),
      accent: Color(0xFF8A6438),
      detail: Color(0xFF6E4E28),
    ),
    body: BodyShape.chunky,
    ears: EarType.cat,
    tail: TailType.thick,
    snout: SnoutType.tusks,
    pattern: PatternType.spots,
    eyes: EyeStyle.round,
    limbs: LimbType.paws,
  ),

  // 29 — Woolly Mammoth
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 29,
    palette: CreaturePalette(
      body: Color(0xFF9C6246),
      belly: Color(0xFFEAD0B2),
      accent: Color(0xFFC98E62),
      detail: Color(0xFFF7EEDC),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundSmall,
    crest: CrestType.woolTuft,
    tail: TailType.puff,
    snout: SnoutType.trunk,
    pattern: PatternType.stripes,
    eyes: EyeStyle.round,
    limbs: LimbType.stubby,
    widthScale: 1.04,
    accent: Accent.snowflake,
  ),

  // 30 — Titanosaur
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 30,
    palette: CreaturePalette(
      body: Color(0xFF4C9C8C),
      belly: Color(0xFFCFE0C8),
      accent: Color(0xFFE8C46E),
      detail: Color(0xFF2C665A),
    ),
    body: BodyShape.tall,
    ears: EarType.none,
    crest: CrestType.plates,
    tail: TailType.thick,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.plates,
    eyes: EyeStyle.round,
    limbs: LimbType.tallLegs,
    heightScale: 1.05,
    widthScale: .98,
    accent: Accent.leaf,
  ),
];
