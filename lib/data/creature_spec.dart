import 'dart:ui' show Color;

/// Overall silhouette of the creature's single "chibi" body-plus-head blob.
enum BodyShape {
  /// Wide, low, very round. Reads as a friendly ball.
  blob,

  /// Classic egg — narrower at the top.
  egg,

  /// Narrow shoulders, heavy bottom.
  pear,

  /// Taller than wide, upright posture.
  tall,

  /// Much wider than tall, low to the ground.
  wide,

  /// Slightly leaning bean, gives a bit of attitude.
  bean,

  /// Long horizontal body with a raised head bump (snakes, worms, eels).
  serpent,

  /// Teardrop with a pointed rear — fish and sea creatures.
  finned,

  /// Dome sitting on a wide base — turtles, snails, beetles.
  shell,

  /// Big and heavy, wide flat bottom — bears, dinos, mammoths.
  chunky,

  /// Rounded with a small head bump — birds.
  bird,

  /// Small segmented oval — bugs and tiny fliers.
  bug,

  /// Vertical drop with a tapered top — jellyfish, ghosts, flames.
  drop,

  /// Five-point rounded star — starfish.
  star,
}

/// Ears (or the closest analogue) drawn behind and above the body.
enum EarType {
  none,
  roundSmall,
  roundBig,
  pointed,
  longUp,
  floppy,
  tufted,
  sideFin,
  frill,
  antenna,
  feather,
  bunny,
  cat,
  horn,
  fan,
}

/// Head-top decoration drawn in front of the ears.
enum CrestType {
  none,
  hornsSmall,
  hornsCurved,
  antlers,
  unicorn,
  spikes,
  plates,
  sailFin,
  mane,
  halo,
  flame,
  leafSprout,
  mushroomCap,
  lure,
  crown,
  crest,
  bubbleCap,
  starTuft,
  snowCap,
  shellSpiral,

  /// Single horn on the snout rather than the forehead — rhinos.
  noseHorn,

  /// Curly fleece topknot — lambs.
  woolTuft,
}

enum TailType {
  none,
  puff,
  long,
  curl,
  bushy,
  fish,
  whip,
  spade,
  feather,
  thick,
  spiked,
  fan,
  stinger,
  club,

  /// Banded brush — raccoons, red pandas, lemurs.
  ringed,
}

enum WingType { none, feather, bat, butterfly, insect, fairy, dragon, tiny }

enum SnoutType {
  none,
  dot,
  muzzle,
  wideMuzzle,
  beakSmall,
  beakLong,
  trunk,
  duckBill,
  longJaw,
  tusks,
  buckTeeth,
  fangs,

  /// Long tapered muzzle carried below the skull — horses, zebras, giraffes.
  longFace,

  /// Broad spoon-shaped nose filling the lower face — koalas, bears.
  bigNose,
}

enum PatternType {
  none,
  belly,
  spots,
  stripes,
  patches,
  scales,
  freckles,
  swirl,
  stars,
  topCap,
  plates,
  dapple,
  ringed,
  glowDots,

  /// Dark teardrops around both eyes — pandas.
  eyePatches,

  /// One band across both eyes, joined over the bridge — raccoons, badgers.
  mask,

  /// Pale stripe running up the spine and over the crown — skunks, gliders.
  dorsalStripe,

  /// Heart-shaped facial disc with a rim — owls.
  facialDisc,

  /// Broken rings with a dark centre — leopards, jaguars.
  rosettes,
}

enum EyeStyle { round, sparkle, sleepy, wide, closedHappy, big, glow, side, mono }

enum LimbType {
  none,
  tinyFeet,
  paws,
  hooves,
  flippers,
  talons,
  tentacles,
  stubby,
  tallLegs,

  /// Walking legs plus a pair of raised pincers — crabs, lobsters, scorpions.
  claws,
}

/// One extra flourish that gives a creature its signature read.
enum Accent {
  none,
  flower,
  leaf,
  scarf,
  bow,
  glasses,
  cheekTuft,
  beardTuft,
  gem,
  sparkles,
  cloud,
  bubbles,
  snowflake,
  moon,
  star,
  fireflies,
  shellPlate,
  crackedEgg,
  petals,
  droplet,
}

/// The four colours every creature is built from.
class CreaturePalette {
  const CreaturePalette({
    required this.body,
    required this.belly,
    required this.accent,
    required this.detail,
  });

  /// Main silhouette colour.
  final Color body;

  /// Belly patch, muzzle and inner-ear colour.
  final Color belly;

  /// Cheeks, pattern and small flourishes.
  final Color accent;

  /// Horns, beak, feet and hard parts.
  final Color detail;
}

/// A complete, deterministic description of one creature's artwork and stats.
///
/// Everything the renderer needs lives here, so artwork is pure code: no image
/// assets to download, no resolution ceiling, and every creature stays visually
/// consistent with the rest of its meadow.
class CreatureSpec {
  const CreatureSpec({
    required this.worldId,
    required this.tier,
    required this.palette,
    required this.body,
    this.ears = EarType.none,
    this.crest = CrestType.none,
    this.tail = TailType.none,
    this.wings = WingType.none,
    this.snout = SnoutType.none,
    this.pattern = PatternType.none,
    this.eyes = EyeStyle.round,
    this.limbs = LimbType.tinyFeet,
    this.accent = Accent.none,
    this.widthScale = 1.0,
    this.heightScale = 1.0,
    this.eyeSpacing = 1.0,
    this.blush = true,
  });

  final String worldId;

  /// 1-based position in its meadow's merge chain.
  final int tier;

  final CreaturePalette palette;
  final BodyShape body;
  final EarType ears;
  final CrestType crest;
  final TailType tail;
  final WingType wings;
  final SnoutType snout;
  final PatternType pattern;
  final EyeStyle eyes;
  final LimbType limbs;
  final Accent accent;

  /// Fine silhouette tuning, applied on top of [body].
  final double widthScale;
  final double heightScale;
  final double eyeSpacing;
  final bool blush;

  /// Stable identity used for save files, collection keys and name lookups.
  String get id => '${worldId}_${tier.toString().padLeft(2, '0')}';

  /// 0-4. Drives card frames, discovery fanfare and gem rewards.
  int get rarity {
    if (tier >= 28) return 4;
    if (tier >= 22) return 3;
    if (tier >= 15) return 2;
    if (tier >= 8) return 1;
    return 0;
  }
}
