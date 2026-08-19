import 'dart:math' as math;

/// Every tunable number in the economy lives here so balance passes are a
/// one-file change rather than an archaeology expedition.
class Balance {
  const Balance._();

  // ---------------------------------------------------------------- board
  static const int columns = 6;
  static const int startingRows = 5;
  static const int maxRows = 8;

  /// Hearts to unlock the row at [rows] (i.e. going from rows-1 to rows).
  static double rowUnlockCost(int rows) =>
      switch (rows) { 6 => 6000, 7 => 120000, _ => 2500000 };

  // --------------------------------------------------------------- basket
  /// How long the basket takes to fill on its own. Every time it brims over
  /// it drops a friend, so this is also the hands-off spawn cadence.
  static const Duration basketFillTime = Duration(seconds: 15);

  /// How much of the meter one tap adds. Four taps skip the wait entirely,
  /// so an eager player fills the meadow as fast as they like.
  static const double basketTapFill = 0.25;

  /// The rewarded basket boost: filling runs this much faster while it lasts.
  static const Duration basketBoostDuration = Duration(minutes: 5);
  static const double basketBoostMultiplier = 3.0;

  /// What an ordinary basket drops: always the smallest friend.
  ///
  /// The ladder is climbed by merging, not handed out part-built, so however
  /// far a meadow has come its baskets still start at the bottom rung.
  static const int basketSpawnTier = 1;

  /// A tier a few rungs behind the player's best, held below 25 so the very
  /// late meadows do not run away. Mystery baskets are pegged to it.
  static int progressTier(int highestTier) =>
      math.max(1, math.min(highestTier - 5, 25));

  // ------------------------------------------------------- mystery baskets
  /// Discoveries needed in a meadow before its basket starts hiding mystery
  /// baskets. Early play stays a clean merge tutorial.
  static const int mysteryMinDiscoveries = 5;

  /// Chance that a basket tap yields a mystery basket instead of a friend.
  static const double mysteryChance = 0.08;

  /// Only ever one waiting at a time, so the board never fills with them.
  static const int mysteryMaxOnBoard = 1;

  /// Lowest tier the free pick can roll — always well above the plain basket.
  static int mysteryFreeMin(int highestTier) =>
      math.max(1, progressTier(highestTier) + 1);

  /// Highest tier the free pick can roll, kept clear of the player's best.
  static int mysteryFreeMax(int highestTier) =>
      math.max(mysteryFreeMin(highestTier), highestTier - 2);

  /// Lowest tier the rewarded pick can roll — never below the free band's top.
  static int mysteryRewardMin(int highestTier) => math.max(
        mysteryFreeMax(highestTier) + 1,
        math.max(1, highestTier - 1),
      );

  /// Highest tier the rewarded pick can roll: the player's own best friend.
  static int mysteryRewardMax(int highestTier) =>
      math.max(mysteryRewardMin(highestTier), highestTier);

  // -------------------------------------------------------------- economy
  /// Hearts per second produced by one creature of [tier].
  static double income(int tier) => 0.12 * math.pow(1.95, tier - 1);

  /// Hearts refunded for releasing a creature of [tier].
  static double sellValue(int tier) => 50 * math.pow(2.05, tier - 1).toDouble();

  /// Hearts to buy a creature of [tier] in the shop.
  static double shopCost(int tier) => 150 * math.pow(2.10, tier - 1).toDouble();

  /// Highest tier the shop will offer, given what the player has discovered.
  static int maxShopTier(int highestTier) => math.max(1, highestTier - 3);

  /// Gems awarded the first time a creature is discovered.
  static int discoveryGems(int rarity) => 1 + rarity * 2;

  // ----------------------------------------------------------- accessories
  /// Hearts to buy an accessory in price band [rank] (0 = cheapest).
  ///
  /// The bands sit between the row unlocks so the wardrobe is a real choice
  /// against more space rather than pocket change beside it.
  static double accessoryCost(int rank) =>
      2500 * math.pow(6.0, rank).toDouble();

  /// Creatures the player must have discovered before band [rank] is offered.
  /// Keeps the shop short in the first minutes and gives the later bands
  /// something to be earned by.
  static int accessoryUnlock(int rank) => 3 + rank * 6;

  // --------------------------------------------------------------- offline
  static const Duration offlineCap = Duration(hours: 4);

  /// Away time earns at a reduced rate; the rewarded video doubles it.
  static const double offlineRate = 0.5;

  // ---------------------------------------------------------------- boosts
  static const Duration boostDuration = Duration(minutes: 15);
  static const double boostMultiplier = 2.0;

  // ------------------------------------------------------------------ ads
  /// Never show an interstitial less than this long after the previous one.
  static const Duration interstitialCooldown = Duration(minutes: 3);

  /// Grace period after launch before the first interstitial may appear.
  static const Duration interstitialWarmup = Duration(minutes: 2);
}
