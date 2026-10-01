/// One creature in a meadow's merge chain: who it is and where it sits.
///
/// How it looks is not data. Every creature is drawn by its own routine in
/// `lib/render/creature_art/`, found by [id], so a spec is just identity and
/// rank.
class CreatureSpec {
  const CreatureSpec({required this.worldId, required this.tier});

  final String worldId;

  /// 1-based position in its meadow's merge chain.
  final int tier;

  /// Stable identity used for save files, collection keys, name lookups and
  /// artwork.
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
