import 'dart:ui' show Color;

import '../creature_spec.dart';

/// Sea Meadow — reef shallows down to the deep, cold blue.
const List<CreatureSpec> waterCreatures = <CreatureSpec>[
  // 1 — Krill
  CreatureSpec(
    worldId: 'water',
    tier: 1,
    palette: CreaturePalette(
      body: Color(0xFFFFC0A8),
      belly: Color(0xFFFFE6DA),
      accent: Color(0xFFFF9E86),
      detail: Color(0xFFD4795C),
    ),
    body: BodyShape.bug,
    ears: EarType.antenna,
    tail: TailType.fish,
    eyes: EyeStyle.round,
    limbs: LimbType.none,
    widthScale: .84,
    heightScale: .80,
  ),

  // 2 — Sea Snail
  CreatureSpec(
    worldId: 'water',
    tier: 2,
    palette: CreaturePalette(
      body: Color(0xFFA8DCE8),
      belly: Color(0xFFF6D9A8),
      accent: Color(0xFFFFC0B0),
      detail: Color(0xFF5F93A8),
    ),
    body: BodyShape.serpent,
    ears: EarType.antenna,
    crest: CrestType.shellSpiral,
    eyes: EyeStyle.sleepy,
    limbs: LimbType.none,
    widthScale: .90,
  ),

  // 3 — Clam
  CreatureSpec(
    worldId: 'water',
    tier: 3,
    palette: CreaturePalette(
      body: Color(0xFFF3C7D8),
      belly: Color(0xFFFFF0F6),
      accent: Color(0xFFCFA8E0),
      detail: Color(0xFFE0A4BE),
    ),
    body: BodyShape.shell,
    eyes: EyeStyle.closedHappy,
    pattern: PatternType.plates,
    limbs: LimbType.none,
    accent: Accent.gem,
    heightScale: .86,
  ),

  // 4 — Shrimp
  CreatureSpec(
    worldId: 'water',
    tier: 4,
    palette: CreaturePalette(
      body: Color(0xFFFF9E7A),
      belly: Color(0xFFFFE0CE),
      accent: Color(0xFFFFC4A8),
      detail: Color(0xFFD16A48),
    ),
    body: BodyShape.serpent,
    ears: EarType.antenna,
    tail: TailType.fish,
    eyes: EyeStyle.round,
    pattern: PatternType.ringed,
    limbs: LimbType.none,
    widthScale: .92,
  ),

  // 5 — Seahorse
  CreatureSpec(
    worldId: 'water',
    tier: 5,
    palette: CreaturePalette(
      body: Color(0xFFF7C86B),
      belly: Color(0xFFFFEFC8),
      accent: Color(0xFFFFA9C0),
      detail: Color(0xFFC98F35),
    ),
    body: BodyShape.tall,
    crest: CrestType.crest,
    tail: TailType.curl,
    snout: SnoutType.seahorse,
    pattern: PatternType.ringed,
    eyes: EyeStyle.round,
    limbs: LimbType.none,
    widthScale: .84,
  ),

  // 6 — Starfish
  CreatureSpec(
    worldId: 'water',
    tier: 6,
    palette: CreaturePalette(
      body: Color(0xFFFF9BB0),
      belly: Color(0xFFFFDCE4),
      accent: Color(0xFFFFF0A8),
      detail: Color(0xFFD96E88),
    ),
    body: BodyShape.star,
    eyes: EyeStyle.closedHappy,
    pattern: PatternType.spots,
    limbs: LimbType.none,
    accent: Accent.bubbles,
  ),

  // 7 — Jellyfish
  CreatureSpec(
    worldId: 'water',
    tier: 7,
    palette: CreaturePalette(
      body: Color(0xFFCBAEF0),
      belly: Color(0xFFEFE2FF),
      accent: Color(0xFFFFB6E8),
      detail: Color(0xFF8E6FC0),
    ),
    body: BodyShape.drop,
    eyes: EyeStyle.sparkle,
    limbs: LimbType.tentacles,
    pattern: PatternType.glowDots,
    accent: Accent.bubbles,
  ),

  // 8 — Clownfish
  CreatureSpec(
    worldId: 'water',
    tier: 8,
    palette: CreaturePalette(
      body: Color(0xFFFF8A3D),
      belly: Color(0xFFFFF3E0),
      accent: Color(0xFFFFFFFF),
      detail: Color(0xFF2E2A33),
    ),
    body: BodyShape.finned,
    ears: EarType.sideFin,
    tail: TailType.fish,
    eyes: EyeStyle.round,
    pattern: PatternType.stripes,
    limbs: LimbType.none,
  ),

  // 9 — Pufferfish
  CreatureSpec(
    worldId: 'water',
    tier: 9,
    palette: CreaturePalette(
      body: Color(0xFFF7DE8A),
      belly: Color(0xFFFFF6D6),
      accent: Color(0xFFC9A24A),
      detail: Color(0xFF8F7530),
    ),
    body: BodyShape.blob,
    ears: EarType.sideFin,
    crest: CrestType.spikes,
    tail: TailType.fish,
    eyes: EyeStyle.wide,
    pattern: PatternType.spots,
    limbs: LimbType.none,
    eyeSpacing: 1.14,
  ),

  // 10 — Crab
  CreatureSpec(
    worldId: 'water',
    tier: 10,
    palette: CreaturePalette(
      body: Color(0xFFE85C4A),
      belly: Color(0xFFFFD9CE),
      accent: Color(0xFFFF9C86),
      detail: Color(0xFFB03A2B),
    ),
    body: BodyShape.wide,
    ears: EarType.antenna,
    eyes: EyeStyle.round,
    pattern: PatternType.belly,
    limbs: LimbType.claws,
    accent: Accent.bubbles,
  ),

  // 11 — Octopus
  CreatureSpec(
    worldId: 'water',
    tier: 11,
    palette: CreaturePalette(
      body: Color(0xFFD98AC4),
      belly: Color(0xFFFFDCF2),
      accent: Color(0xFFFFB0D8),
      detail: Color(0xFF9E5A8C),
    ),
    body: BodyShape.egg,
    eyes: EyeStyle.big,
    pattern: PatternType.spots,
    limbs: LimbType.tentacles,
    accent: Accent.bubbles,
  ),

  // 12 — Sea Turtle
  CreatureSpec(
    worldId: 'water',
    tier: 12,
    palette: CreaturePalette(
      body: Color(0xFF6FBF9A),
      belly: Color(0xFFDCF3E4),
      accent: Color(0xFFFFC0A8),
      detail: Color(0xFF3F8A6A),
    ),
    body: BodyShape.shell,
    snout: SnoutType.dot,
    eyes: EyeStyle.round,
    limbs: LimbType.flippers,
    accent: Accent.shellPlate,
  ),

  // 13 — Angelfish
  CreatureSpec(
    worldId: 'water',
    tier: 13,
    palette: CreaturePalette(
      body: Color(0xFFFFE08A),
      belly: Color(0xFFFFF7DC),
      accent: Color(0xFF5B5470),
      detail: Color(0xFFCFA24A),
    ),
    body: BodyShape.finned,
    ears: EarType.sideFin,
    crest: CrestType.sailFin,
    tail: TailType.fan,
    eyes: EyeStyle.round,
    pattern: PatternType.stripes,
    limbs: LimbType.none,
  ),

  // 14 — Eel
  CreatureSpec(
    worldId: 'water',
    tier: 14,
    palette: CreaturePalette(
      body: Color(0xFF6E8F6A),
      belly: Color(0xFFD4E6C4),
      accent: Color(0xFF9EC98A),
      detail: Color(0xFF44603F),
    ),
    body: BodyShape.serpent,
    snout: SnoutType.longJaw,
    eyes: EyeStyle.side,
    pattern: PatternType.dapple,
    limbs: LimbType.none,
  ),

  // 15 — Lobster
  CreatureSpec(
    worldId: 'water',
    tier: 15,
    palette: CreaturePalette(
      body: Color(0xFFC0392B),
      belly: Color(0xFFFFD0C0),
      accent: Color(0xFFFF8A70),
      detail: Color(0xFF8A251A),
    ),
    body: BodyShape.serpent,
    ears: EarType.antenna,
    tail: TailType.fish,
    eyes: EyeStyle.round,
    pattern: PatternType.ringed,
    limbs: LimbType.claws,
  ),

  // 16 — Stingray
  CreatureSpec(
    worldId: 'water',
    tier: 16,
    palette: CreaturePalette(
      body: Color(0xFF9AA8C4),
      belly: Color(0xFFF0F3FA),
      accent: Color(0xFF6E7B96),
      detail: Color(0xFF4E5A72),
    ),
    body: BodyShape.wide,
    ears: EarType.sideFin,
    tail: TailType.stinger,
    eyes: EyeStyle.sleepy,
    pattern: PatternType.spots,
    limbs: LimbType.none,
    widthScale: 1.06,
    heightScale: .84,
  ),

  // 17 — Penguin
  CreatureSpec(
    worldId: 'water',
    tier: 17,
    palette: CreaturePalette(
      body: Color(0xFF3A3E4C),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFFFB0B8),
      detail: Color(0xFFF5A623),
    ),
    body: BodyShape.egg,
    wings: WingType.tiny,
    snout: SnoutType.beakSmall,
    pattern: PatternType.belly,
    eyes: EyeStyle.round,
    limbs: LimbType.flippers,
  ),

  // 18 — Seal Pup
  CreatureSpec(
    worldId: 'water',
    tier: 18,
    palette: CreaturePalette(
      body: Color(0xFFEFEDE6),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFFFB6B0),
      detail: Color(0xFF3A3A44),
    ),
    body: BodyShape.blob,
    snout: SnoutType.wideMuzzle,
    tail: TailType.fish,
    eyes: EyeStyle.big,
    pattern: PatternType.dapple,
    limbs: LimbType.flippers,
  ),

  // 19 — Walrus
  CreatureSpec(
    worldId: 'water',
    tier: 19,
    palette: CreaturePalette(
      body: Color(0xFFB07A6E),
      belly: Color(0xFFE8CFC2),
      accent: Color(0xFFFFB0A0),
      detail: Color(0xFF7A4E44),
    ),
    body: BodyShape.chunky,
    snout: SnoutType.tusks,
    tail: TailType.fish,
    eyes: EyeStyle.sleepy,
    pattern: PatternType.belly,
    limbs: LimbType.flippers,
  ),

  // 20 — Dolphin
  CreatureSpec(
    worldId: 'water',
    tier: 20,
    palette: CreaturePalette(
      body: Color(0xFF6FB8DC),
      belly: Color(0xFFEAF6FC),
      accent: Color(0xFFA8DDF2),
      detail: Color(0xFF3E7FA8),
    ),
    body: BodyShape.finned,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.beakLong,
    eyes: EyeStyle.sparkle,
    pattern: PatternType.belly,
    limbs: LimbType.flippers,
  ),

  // 21 — Swordfish
  CreatureSpec(
    worldId: 'water',
    tier: 21,
    palette: CreaturePalette(
      body: Color(0xFF4E6E9E),
      belly: Color(0xFFDCE9F5),
      accent: Color(0xFF8AB4D8),
      detail: Color(0xFF2E4667),
    ),
    body: BodyShape.finned,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.beakLong,
    eyes: EyeStyle.side,
    pattern: PatternType.belly,
    limbs: LimbType.none,
  ),

  // 22 — Hammerhead
  CreatureSpec(
    worldId: 'water',
    tier: 22,
    palette: CreaturePalette(
      body: Color(0xFF8C9AA8),
      belly: Color(0xFFF0F4F7),
      accent: Color(0xFF5E6C7A),
      detail: Color(0xFF3E4A56),
    ),
    body: BodyShape.finned,
    ears: EarType.fan,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.fangs,
    eyes: EyeStyle.side,
    pattern: PatternType.belly,
    limbs: LimbType.none,
    eyeSpacing: 1.34,
  ),

  // 23 — Anglerfish
  CreatureSpec(
    worldId: 'water',
    tier: 23,
    palette: CreaturePalette(
      body: Color(0xFF3E3A52),
      belly: Color(0xFF5E5878),
      accent: Color(0xFF9CF0D8),
      detail: Color(0xFF272338),
    ),
    body: BodyShape.blob,
    crest: CrestType.lure,
    tail: TailType.fish,
    snout: SnoutType.fangs,
    eyes: EyeStyle.glow,
    pattern: PatternType.glowDots,
    limbs: LimbType.none,
    blush: false,
  ),

  // 24 — Manta Ray
  CreatureSpec(
    worldId: 'water',
    tier: 24,
    palette: CreaturePalette(
      body: Color(0xFF3E5A82),
      belly: Color(0xFFE4EEF7),
      accent: Color(0xFF7FA8D0),
      detail: Color(0xFF25395A),
    ),
    body: BodyShape.wide,
    wings: WingType.dragon,
    tail: TailType.whip,
    eyes: EyeStyle.sleepy,
    pattern: PatternType.spots,
    limbs: LimbType.none,
    widthScale: .96,
    heightScale: .86,
  ),

  // 25 — Narwhal
  CreatureSpec(
    worldId: 'water',
    tier: 25,
    palette: CreaturePalette(
      body: Color(0xFFA8B6D8),
      belly: Color(0xFFF0F4FC),
      accent: Color(0xFFCBDCF2),
      detail: Color(0xFFEFE6D2),
    ),
    body: BodyShape.finned,
    crest: CrestType.unicorn,
    tail: TailType.fish,
    eyes: EyeStyle.sparkle,
    pattern: PatternType.dapple,
    limbs: LimbType.flippers,
    accent: Accent.sparkles,
  ),

  // 26 — Orca
  CreatureSpec(
    worldId: 'water',
    tier: 26,
    palette: CreaturePalette(
      body: Color(0xFF2E323E),
      belly: Color(0xFFFFFFFF),
      accent: Color(0xFFFFFFFF),
      detail: Color(0xFF1C1F27),
    ),
    body: BodyShape.finned,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    eyes: EyeStyle.round,
    pattern: PatternType.eyePatches,
    limbs: LimbType.flippers,
    widthScale: 1.02,
  ),

  // 27 — Great White
  CreatureSpec(
    worldId: 'water',
    tier: 27,
    palette: CreaturePalette(
      body: Color(0xFF7E8C99),
      belly: Color(0xFFF2F5F7),
      accent: Color(0xFF5A6773),
      detail: Color(0xFF39434D),
    ),
    body: BodyShape.finned,
    crest: CrestType.sailFin,
    tail: TailType.fish,
    snout: SnoutType.longJaw,
    eyes: EyeStyle.side,
    pattern: PatternType.belly,
    limbs: LimbType.none,
    widthScale: 1.04,
    blush: false,
  ),

  // 28 — Giant Squid
  CreatureSpec(
    worldId: 'water',
    tier: 28,
    palette: CreaturePalette(
      body: Color(0xFFB05A6E),
      belly: Color(0xFFF0C4CE),
      accent: Color(0xFFFF9EB4),
      detail: Color(0xFF7A3448),
    ),
    body: BodyShape.drop,
    ears: EarType.sideFin,
    eyes: EyeStyle.big,
    pattern: PatternType.spots,
    limbs: LimbType.tentacles,
    eyeSpacing: 1.14,
  ),

  // 29 — Blue Whale
  CreatureSpec(
    worldId: 'water',
    tier: 29,
    palette: CreaturePalette(
      body: Color(0xFF4A7FB8),
      belly: Color(0xFFDCEAF7),
      accent: Color(0xFF8ABEE0),
      detail: Color(0xFF2E5580),
    ),
    body: BodyShape.finned,
    tail: TailType.fish,
    eyes: EyeStyle.round,
    pattern: PatternType.belly,
    limbs: LimbType.flippers,
    widthScale: 1.06,
    accent: Accent.bubbles,
  ),

  // 30 — Tidecaller Whale
  CreatureSpec(
    worldId: 'water',
    tier: 30,
    palette: CreaturePalette(
      body: Color(0xFF2E5F8A),
      belly: Color(0xFF7FE0E8),
      accent: Color(0xFF9CF7E8),
      detail: Color(0xFFFFE9A8),
    ),
    body: BodyShape.finned,
    crest: CrestType.crown,
    tail: TailType.fish,
    eyes: EyeStyle.glow,
    pattern: PatternType.glowDots,
    limbs: LimbType.flippers,
    widthScale: 1.06,
    accent: Accent.sparkles,
  ),
];
