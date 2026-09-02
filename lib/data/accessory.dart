import '../core/balance.dart';

/// Something a friend can wear.
///
/// Accessories are bought once with hearts and then belong to the player
/// forever: any discovered creature can put one on, and taking it off costs
/// nothing. They change nothing about income or merging — this is a heart sink
/// and a way to make a favourite friend yours, not a stat upgrade.
enum AccessoryType {
  flowerCrown,
  bowTie,
  partyHat,
  scarf,
  topHat,
  sunglasses,
  cape,
  headphones,
  crown,
}

/// One entry in the shop's wardrobe.
class Accessory {
  const Accessory({required this.type, required this.rank});

  final AccessoryType type;

  /// Price band, 0 = cheapest. Both the price and the unlock threshold derive
  /// from it, so the whole wardrobe re-balances from two functions.
  final int rank;

  /// Stable key used by save files.
  String get id => type.name;

  /// Priced against progress rather than fixed, so ask the controller — it is
  /// the thing that knows how far the player has got.
  double costAt(int highestTier) => Balance.accessoryCost(rank, highestTier);

  /// Creatures the player must have discovered before this is offered.
  int get unlockDiscoveries => Balance.accessoryUnlock(rank);
}

/// The wardrobe, cheapest first — the order the shop lists them in.
const List<Accessory> kAccessories = <Accessory>[
  Accessory(type: AccessoryType.flowerCrown, rank: 0),
  Accessory(type: AccessoryType.bowTie, rank: 0),
  Accessory(type: AccessoryType.partyHat, rank: 1),
  Accessory(type: AccessoryType.scarf, rank: 1),
  Accessory(type: AccessoryType.topHat, rank: 2),
  Accessory(type: AccessoryType.sunglasses, rank: 2),
  Accessory(type: AccessoryType.cape, rank: 3),
  Accessory(type: AccessoryType.headphones, rank: 3),
  Accessory(type: AccessoryType.crown, rank: 4),
];

/// Resolves a saved accessory key. Unknown keys yield null so a save written
/// by a newer build never crashes an older one.
AccessoryType? accessoryTypeById(String? id) {
  if (id == null) return null;
  for (final AccessoryType type in AccessoryType.values) {
    if (type.name == id) return type;
  }
  return null;
}

Accessory? accessoryById(String? id) {
  final AccessoryType? type = accessoryTypeById(id);
  if (type == null) return null;
  for (final Accessory a in kAccessories) {
    if (a.type == type) return a;
  }
  return null;
}
