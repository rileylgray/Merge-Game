import '../data/accessory.dart';
import '../l10n/app_localizations.dart';

/// Maps an accessory to its localized name.
///
/// Accessory names live in the ARB files rather than the creature-name JSON
/// because there are a handful of them and they appear in UI chrome, not in
/// the 150-name-per-language catalogue.
String accessoryName(L l, AccessoryType type) => switch (type) {
      AccessoryType.flowerCrown => l.accessoryFlowerCrown,
      AccessoryType.bowTie => l.accessoryBowTie,
      AccessoryType.partyHat => l.accessoryPartyHat,
      AccessoryType.scarf => l.accessoryScarf,
      AccessoryType.topHat => l.accessoryTopHat,
      AccessoryType.sunglasses => l.accessorySunglasses,
      AccessoryType.cape => l.accessoryCape,
      AccessoryType.headphones => l.accessoryHeadphones,
      AccessoryType.crown => l.accessoryCrown,
    };
