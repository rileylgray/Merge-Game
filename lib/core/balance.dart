import 'dart:math' as math;

/// Every tunable number in the economy lives here so balance passes are a
/// one-file change rather than an archaeology expedition.
class Balance {
  const Balance._();

  // ---------------------------------------------------------------- board
  static const int columns = 6;
  static const int startingRows = 5;
  static const int maxRows = 8;

  /// Hearts to unlock the row at [rows] (i.e. going from rows-1 to rows), in a
  /// meadow whose best friend so far is [highestTier].
  ///
  /// Priced in minutes of that meadow's own income rather than in flat hearts.
  /// See [meadowIncome] for why.
  static double rowUnlockCost(int rows, int highestTier) {
    final double flat = switch (rows) {
      6 => 6000.0,
      7 => 120000.0,
      _ => 2500000.0,
    };
    final double minutes = switch (rows) { 6 => 3.0, 7 => 8.0, _ => 20.0 };
    return math.max(flat, minutes * 60 * meadowIncome(highestTier));
  }

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
  ///
  /// Two dials, and they do different jobs. The coefficient moves every tier by
  /// the same factor — it sets how fast the opening minutes go. The growth rate
  /// is the one that decides whether the middle of the game runs away, because
  /// it compounds against [shopCost]'s 2.10 thirty times over.
  ///
  /// It used to be 1.95, a gap of only 7.7% per tier, which is close enough to
  /// break even that a mid-game meadow out-earned everything it could spend on
  /// faster and faster: by the high teens the row unlocks and the whole
  /// wardrobe were a minute's income apiece and the shop stopped being a
  /// choice. At 1.90 the gap is 10.5% a tier, so each rung costs meaningfully
  /// more of the player's time than the last and the climb keeps its shape.
  ///
  /// Net effect against the original 0.12/1.95: about 2.4x slower at the start,
  /// 3x by tier 10, and 5x by tier 30 — the brake gets firmer the further in
  /// the player is, which is where the runaway was.
  static double income(int tier) => 0.05 * math.pow(1.90, tier - 1);

  /// Hearts refunded for releasing a creature of [tier].
  static double sellValue(int tier) => 50 * math.pow(2.05, tier - 1).toDouble();

  /// Hearts to buy a creature of [tier] in the shop.
  static double shopCost(int tier) => 150 * math.pow(2.10, tier - 1).toDouble();

  /// Highest tier the shop will offer, given what the player has discovered.
  static int maxShopTier(int highestTier) => math.max(1, highestTier - 3);

  // ---------------------------------------------------------------- sinks
  /// Roughly what a whole meadow earns per second when its best friend is
  /// [tier]: the top rung plus the tail of smaller friends underneath it.
  ///
  /// The permanent sinks — rows and the wardrobe — are priced in *minutes of
  /// this* rather than in flat hearts, because a flat price is exactly what
  /// let the middle of the game run away. Income climbs 1.90x a tier while
  /// 2,500,000 stays 2,500,000, so by the high teens the last row and the
  /// entire wardrobe were a few seconds' income apiece and there was nothing
  /// left in the game to want. Priced this way a row costs the same number of
  /// minutes at tier 12 as it does at tier 28.
  ///
  /// The 8x is a deliberate approximation of a working board — four or so
  /// friends on each of the top handful of rungs — not a number read off any
  /// particular save. It only has to be the right order of magnitude; it sets
  /// the scale of the sinks, and the minute counts do the rest.
  static double meadowIncome(int tier) => 8 * income(math.max(1, tier));

  /// Gems awarded the first time a creature is discovered.
  static int discoveryGems(int rarity) => 1 + rarity * 2;

  // ----------------------------------------------------------- accessories
  /// Hearts to buy an accessory in price band [rank] (0 = cheapest), for a
  /// player whose best friend anywhere is [highestTier].
  ///
  /// The bands sit between the row unlocks so the wardrobe is a real choice
  /// against more space rather than pocket change beside it — which means it
  /// has to be priced the same way they are, or it stops being a choice the
  /// moment income outgrows it. The wardrobe is shared across every meadow, so
  /// this one is pegged to the best tier anywhere rather than to one board.
  static double accessoryCost(int rank, int highestTier) {
    final double flat = 2500 * math.pow(6.0, rank).toDouble();
    final double minutes = switch (rank) {
      0 => 1.0,
      1 => 2.5,
      2 => 6.0,
      3 => 15.0,
      _ => 40.0,
    };
    return math.max(flat, minutes * 60 * meadowIncome(highestTier));
  }

  /// Creatures the player must have discovered before band [rank] is offered.
  /// Keeps the shop short in the first minutes and gives the later bands
  /// something to be earned by.
  static int accessoryUnlock(int rank) => 3 + rank * 6;

  // --------------------------------------------------------------- offline
  static const Duration offlineCap = Duration(hours: 4);

  /// Away time earns at a reduced rate; the rewarded video doubles it.
  static const double offlineRate = 0.5;

  /// Ceiling on a single welcome-back payout, in minutes of income.
  ///
  /// [offlineCap] bounds the *time* credited, not the hearts. A player with a
  /// packed board across several meadows earns well above the [meadowIncome]
  /// approximation, so four hours of it came back as a lump big enough to pay
  /// off a row and a wardrobe band at once — exactly the runaway the sinks are
  /// priced in minutes to avoid. This bounds the hearts the same way they are
  /// priced, so it keeps its shape as the meadows grow instead of going stale
  /// the way a flat number would.
  ///
  /// Pegged to the best tier *anywhere* because offline earnings come from
  /// every meadow at once. At 45 it bites only once a save is earning more
  /// than about a board and a half's worth — early and mid meadows still
  /// collect the full four hours.
  static const double offlineCapMinutes = 45;

  /// The most hearts one welcome-back may hand over before the rewarded video
  /// doubles it — so twice this is the true ceiling on the dialog.
  static double offlineHeartCap(int bestTierAnywhere) =>
      offlineCapMinutes * 60 * meadowIncome(bestTierAnywhere);

  // ---------------------------------------------------------------- boosts
  static const Duration boostDuration = Duration(minutes: 15);
  static const double boostMultiplier = 2.0;

  // ------------------------------------------------------------------ ads
  /// Never show an interstitial less than this long after the previous one.
  static const Duration interstitialCooldown = Duration(minutes: 3);

  /// Grace period after launch before the first interstitial may appear.
  static const Duration interstitialWarmup = Duration(minutes: 2);
}
