import 'dart:ui' show Color;

import '../creature_spec.dart';

/// Dino Meadow — the fossil record, from Cambrian shallows to the ice age.
const List<CreatureSpec> prehistoricCreatures = <CreatureSpec>[
  // 1 — Trilobite
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 1,
    palette: CreaturePalette(
      body: Color(0xFF7FA0B8),
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
      body: Color(0xFFB08A6A),
      belly: Color(0xFFE8D4B4),
      accent: Color(0xFFD8B48A),
      detail: Color(0xFF7A5C42),
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
      body: Color(0xFFC98F52),
      belly: Color(0xFFF7DFB8),
      accent: Color(0xFFEFB877),
      detail: Color(0xFF8A5A2E),
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
      body: Color(0xFF7A9E6E),
      belly: Color(0xFFDCEFC8),
      accent: Color(0xFFA8CF94),
      detail: Color(0xFF4E6E42),
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
      body: Color(0xFF7A8AA8),
      belly: Color(0xFFD8E2EF),
      accent: Color(0xFFE8A85C),
      detail: Color(0xFF4E5C7A),
    ),
    body: BodyShape.wide,
    crest: CrestType.sailFin,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    eyes: EyeStyle.side,
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
      body: Color(0xFFC49E5C),
      belly: Color(0xFFF2E2BC),
      accent: Color(0xFFE8B86E),
      detail: Color(0xFF8A6A34),
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
      body: Color(0xFFCFA88A),
      belly: Color(0xFFF2DCC4),
      accent: Color(0xFF9E7048),
      detail: Color(0xFF7A5636),
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
      body: Color(0xFF8A9E5C),
      belly: Color(0xFFDCE8B4),
      accent: Color(0xFFE8A85C),
      detail: Color(0xFF5C6E38),
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
      body: Color(0xFFB88A6E),
      belly: Color(0xFFEBD4BC),
      accent: Color(0xFFD8A88A),
      detail: Color(0xFF8A5C42),
    ),
    body: BodyShape.bean,
    crest: CrestType.spikes,
    tail: TailType.thick,
    snout: SnoutType.wideMuzzle,
    pattern: PatternType.belly,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
  ),

  // 15 — Gallimimus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 15,
    palette: CreaturePalette(
      body: Color(0xFFE8B978),
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
      body: Color(0xFF6E9E7A),
      belly: Color(0xFFCFE8CF),
      accent: Color(0xFFE85C6E),
      detail: Color(0xFF44705C),
    ),
    body: BodyShape.bean,
    ears: EarType.frill,
    crest: CrestType.crest,
    tail: TailType.long,
    snout: SnoutType.longJaw,
    pattern: PatternType.spots,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
  ),

  // 17 — Parasaurolophus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 17,
    palette: CreaturePalette(
      body: Color(0xFF8AA8D8),
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
      body: Color(0xFF6E8A6E),
      belly: Color(0xFFCFE0C4),
      accent: Color(0xFFE8A85C),
      detail: Color(0xFF44603E),
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
      body: Color(0xFF9CAE8C),
      belly: Color(0xFFE4E8CC),
      accent: Color(0xFF7A8A6A),
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
      body: Color(0xFFC0A075),
      belly: Color(0xFFF2E3C6),
      accent: Color(0xFF7FA868),
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
      body: Color(0xFFD8A88E),
      belly: Color(0xFFF7E4D2),
      accent: Color(0xFFEF8A66),
      detail: Color(0xFFE0906A),
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
      body: Color(0xFFB86E4E),
      belly: Color(0xFFEDC8A8),
      accent: Color(0xFFE8A05C),
      detail: Color(0xFF7A4028),
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
      body: Color(0xFF5C7A8A),
      belly: Color(0xFFCFE0E8),
      accent: Color(0xFFE8946E),
      detail: Color(0xFF3A5260),
    ),
    body: BodyShape.tall,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.longJaw,
    pattern: PatternType.scales,
    eyes: EyeStyle.side,
    limbs: LimbType.talons,
  ),

  // 26 — Tyrannosaurus
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 26,
    palette: CreaturePalette(
      body: Color(0xFF7A8A5C),
      belly: Color(0xFFD8E0B4),
      accent: Color(0xFFC4A85C),
      detail: Color(0xFF4E5C38),
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
      body: Color(0xFF8A9EB8),
      belly: Color(0xFFDCE4F0),
      accent: Color(0xFFB4C4D8),
      detail: Color(0xFF5C6E88),
    ),
    body: BodyShape.tall,
    ears: EarType.roundSmall,
    crest: CrestType.crest,
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
    eyes: EyeStyle.side,
    limbs: LimbType.paws,
  ),

  // 29 — Woolly Mammoth
  CreatureSpec(
    worldId: 'prehistoric',
    tier: 29,
    palette: CreaturePalette(
      body: Color(0xFFC98A5E),
      belly: Color(0xFFF2D2AE),
      accent: Color(0xFFE8AE80),
      detail: Color(0xFFF7EEDC),
    ),
    body: BodyShape.chunky,
    ears: EarType.roundSmall,
    crest: CrestType.mane,
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
      body: Color(0xFF6E8A72),
      belly: Color(0xFFCFE0C8),
      accent: Color(0xFFE8C46E),
      detail: Color(0xFF44603E),
    ),
    body: BodyShape.tall,
    ears: EarType.roundSmall,
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
