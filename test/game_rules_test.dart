import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/core/balance.dart';
import 'package:mergelings/core/formatters.dart';
import 'package:mergelings/data/accessory.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/models/game_state.dart';
import 'package:mergelings/state/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The controller group loads creature names from the asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('roster', () {
    test('every meadow has exactly 30 creatures with sequential tiers', () {
      expect(kWorlds.length, 5);
      for (final World world in kWorlds) {
        expect(world.creatures.length, 30, reason: world.id);
        for (int i = 0; i < world.creatures.length; i++) {
          expect(world.creatures[i].tier, i + 1, reason: world.id);
          expect(world.creatures[i].worldId, world.id);
        }
      }
      expect(kTotalCreatures, 150);
    });

    test('creature ids are unique and resolve back to their spec', () {
      final Set<String> ids = <String>{};
      for (final World world in kWorlds) {
        for (final CreatureSpec spec in world.creatures) {
          expect(ids.add(spec.id), isTrue, reason: 'duplicate ${spec.id}');
          expect(specById(spec.id)?.id, spec.id);
        }
      }
      expect(ids.length, 150);
    });

    test('unknown ids resolve to null rather than throwing', () {
      expect(specById('nope_01'), isNull);
      expect(specById('day_99'), isNull);
      expect(specById('garbage'), isNull);
    });
  });

  group('balance', () {
    test('income and cost both rise strictly with tier', () {
      for (int t = 2; t <= 30; t++) {
        expect(Balance.income(t), greaterThan(Balance.income(t - 1)));
        expect(Balance.shopCost(t), greaterThan(Balance.shopCost(t - 1)));
      }
    });

    test('selling a creature never returns more than it costs to buy', () {
      for (int t = 1; t <= 30; t++) {
        expect(Balance.sellValue(t), lessThan(Balance.shopCost(t)));
      }
    });

    test('permanent sinks keep costing real time however far in we are', () {
      // The whole point of pricing rows and the wardrobe off progress: at flat
      // prices, income overtook them and by the high teens every one of them
      // was a few seconds' earnings.
      for (final int highest in <int>[10, 16, 22, 30]) {
        final double perSecond = Balance.meadowIncome(highest);
        for (final int rows in <int>[6, 7, 8]) {
          expect(
            Balance.rowUnlockCost(rows, highest) / perSecond,
            greaterThan(120),
            reason: 'row $rows is pocket change at tier $highest',
          );
        }
        for (int rank = 0; rank <= 4; rank++) {
          expect(
            Balance.accessoryCost(rank, highest) / perSecond,
            greaterThan(50),
            reason: 'band $rank is pocket change at tier $highest',
          );
        }
      }
    });

    test('sinks never get cheaper as the player gets further in', () {
      for (int t = 1; t <= 30; t++) {
        for (final int rows in <int>[6, 7, 8]) {
          expect(
            Balance.rowUnlockCost(rows, t),
            greaterThanOrEqualTo(Balance.rowUnlockCost(rows, t - 1)),
          );
        }
        for (int rank = 0; rank <= 4; rank++) {
          expect(
            Balance.accessoryCost(rank, t),
            greaterThanOrEqualTo(Balance.accessoryCost(rank, t - 1)),
          );
        }
      }
    });

    test('the mystery band keeps pace with progress but never exceeds it', () {
      expect(Balance.progressTier(0), 1);
      expect(Balance.progressTier(4), 1);
      expect(Balance.progressTier(12), 7);
      expect(Balance.progressTier(30), 25);
      for (final int highest in <int>[0, 8, 20, 30]) {
        expect(
          Balance.mysteryFreeMin(highest),
          greaterThan(Balance.basketSpawnTier),
          reason: 'a mystery must beat a plain basket at highest $highest',
        );
      }
    });
  });

  group('accessories', () {
    test('the wardrobe is unique, ordered and priced by band', () {
      final Set<AccessoryType> seen = <AccessoryType>{};
      for (final Accessory item in kAccessories) {
        expect(seen.add(item.type), isTrue, reason: 'duplicate ${item.id}');
      }
      // Every drawable item is for sale, or it can never be worn.
      expect(seen.length, AccessoryType.values.length);

      for (int i = 1; i < kAccessories.length; i++) {
        expect(
          kAccessories[i].rank,
          greaterThanOrEqualTo(kAccessories[i - 1].rank),
          reason: 'catalogue must list cheapest first',
        );
      }
    });

    test('cost and unlock both rise with the band, at any progress', () {
      for (final int highest in <int>[0, 1, 8, 15, 22, 30]) {
        for (int rank = 1; rank <= 4; rank++) {
          expect(
            Balance.accessoryCost(rank, highest),
            greaterThan(Balance.accessoryCost(rank - 1, highest)),
            reason: 'band $rank must beat band ${rank - 1} at tier $highest',
          );
        }
      }
      for (int rank = 1; rank <= 4; rank++) {
        expect(
          Balance.accessoryUnlock(rank),
          greaterThan(Balance.accessoryUnlock(rank - 1)),
        );
      }
    });

    test('ids round-trip and unknown ones resolve to null', () {
      for (final Accessory item in kAccessories) {
        expect(accessoryTypeById(item.id), item.type);
        expect(accessoryById(item.id)?.type, item.type);
      }
      expect(accessoryTypeById('sombrero'), isNull);
      expect(accessoryTypeById(null), isNull);
      expect(accessoryById('sombrero'), isNull);
    });
  });

  group('board', () {
    test('starts empty at the starting row count', () {
      final BoardState board = BoardState.empty('day');
      expect(board.rows, Balance.startingRows);
      expect(board.capacity, Balance.columns * Balance.startingRows);
      expect(board.isFull, isFalse);
      expect(board.income, 0);
    });

    test('reports full only when every unlocked cell is taken', () {
      final BoardState board = BoardState.empty('day');
      for (int i = 0; i < board.capacity; i++) {
        board.set(i, BoardTile(id: i, tier: 1));
      }
      expect(board.isFull, isTrue);
      expect(board.firstEmpty(), isNull);

      // Cells beyond the unlocked rows must not count as playable space.
      board.rows = Balance.maxRows;
      expect(board.isFull, isFalse);
    });

    test('income only counts tiles inside the unlocked area', () {
      final BoardState board = BoardState.empty('day');
      board.set(0, BoardTile(id: 1, tier: 3));
      board.set(board.cells.length - 1, BoardTile(id: 2, tier: 20));
      expect(board.income, closeTo(Balance.income(3), 1e-9));
    });
  });

  group('basket', () {
    late GameController game;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      game = await GameController.boot();
      game.setSound(false);
    });

    tearDown(() => game.dispose());

    // Progress must not take the bottom rung off the ladder: a meadow whose
    // basket has walked past tier 1 has nothing small left to merge.
    test('drops tier 1 however far the meadow has come', () {
      for (int tier = 1; tier <= 30; tier++) {
        game.state.discovered.add('day_${tier.toString().padLeft(2, '0')}');
      }
      expect(game.highestTier('day'), 30);

      for (int i = 0; i < 20 && !game.board.isFull; i++) {
        game.state.basketFill = 1;
        expect(game.tapBasket(), isTrue);
      }

      final List<BoardTile> dropped = game.board.cells
          .whereType<BoardTile>()
          .where((BoardTile t) => !t.mystery)
          .toList();
      expect(dropped, isNotEmpty);
      for (final BoardTile tile in dropped) {
        expect(tile.tier, 1);
      }
    });
  });

  // The merge flag drives a celebration animation keyed by cell, so a stale
  // one makes an ordinary arrival in that cell burst as if it had merged.
  group('merge flag', () {
    late GameController game;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      game = await GameController.boot();
      // There is no audio plugin behind a unit test; muting keeps the cues
      // from filling the run with MissingPluginException noise.
      game.setSound(false);
    });

    tearDown(() => game.dispose());

    /// Puts two mergeable friends on the board and returns their cells.
    (int, int) seedPair() {
      game.board.set(0, BoardTile(id: 901, tier: 2));
      game.board.set(1, BoardTile(id: 902, tier: 2));
      return (0, 1);
    }

    test('is set by a merge and names the surviving cell', () {
      final (int from, int to) = seedPair();
      expect(game.moveTile(from, to), MergeResult.merged);
      expect(game.lastMergedCell, to);
    });

    test('is cleared by a plain move', () {
      final (int from, int to) = seedPair();
      game.moveTile(from, to);

      expect(game.moveTile(to, 2), MergeResult.moved);
      expect(game.lastMergedCell, isNull);
    });

    test('is cleared by a swap', () {
      final (int from, int to) = seedPair();
      game.moveTile(from, to);
      game.board.set(2, BoardTile(id: 903, tier: 5));

      expect(game.moveTile(2, to), MergeResult.moved);
      expect(game.lastMergedCell, isNull);
    });

    test('is cleared by releasing a friend', () {
      final (int from, int to) = seedPair();
      game.moveTile(from, to);

      game.sellTile(to);
      expect(game.lastMergedCell, isNull);
    });

    test('is cleared when the basket drops someone new', () {
      final (int from, int to) = seedPair();
      game.moveTile(from, to);

      game.state.basketFill = 1;
      expect(game.tapBasket(), isTrue);
      expect(game.lastMergedCell, isNull);
    });
  });

  group('save file', () {
    test('round-trips through JSON', () {
      final GameState state = GameState.fresh()
        ..hearts = 1234.5
        ..gems = 7
        ..activeWorldId = 'water'
        ..basketFill = 0.4
        ..basketBoostUntilMs = 1730000000000
        ..localeCode = 'de'
        ..musicEnabled = false
        ..hapticsEnabled = false;
      state.discovered.addAll(<String>['day_01', 'day_02', 'water_05']);
      state.ownedAccessories.addAll(<String>['topHat', 'cape']);
      state.wornAccessories['day_02'] = 'topHat';
      state.board('water').set(4, BoardTile(id: 9, tier: 6));

      final GameState? restored = GameState.decode(state.encode());
      expect(restored, isNotNull);
      expect(restored!.hearts, closeTo(1234.5, 1e-9));
      expect(restored.gems, 7);
      expect(restored.activeWorldId, 'water');
      expect(restored.basketFill, closeTo(0.4, 1e-9));
      expect(restored.basketBoostUntilMs, 1730000000000);
      expect(restored.localeCode, 'de');
      expect(restored.musicEnabled, isFalse);
      expect(restored.hapticsEnabled, isFalse);
      expect(restored.discovered, containsAll(<String>['day_01', 'water_05']));
      expect(restored.ownedAccessories, containsAll(<String>['topHat', 'cape']));
      expect(restored.wornAccessories['day_02'], 'topHat');
      expect(restored.board('water').at(4)?.tier, 6);
    });

    test('worn accessories drop entries this build cannot render', () {
      final GameState state = GameState.fresh();
      state.wornAccessories.addAll(<String, String>{
        'day_02': 'topHat',
        'day_02_but_wrong': 'topHat',
        'day_99': 'topHat',
        'night_04': 'jetpack',
      });

      final GameState restored = GameState.decode(state.encode())!;
      expect(restored.wornAccessories, <String, String>{'day_02': 'topHat'});
    });

    test('corrupt or foreign data yields null instead of throwing', () {
      expect(GameState.decode('not json'), isNull);
      expect(GameState.decode('[1,2,3]'), isNull);
      expect(GameState.decode('{"b":"wrong type"}'), isNotNull);
    });

    test('a save written before music existed gets music switched on', () {
      // Opting an existing player out of a feature they have never seen would
      // look like it simply does not work on their device.
      final GameState? restored = GameState.decode('{"sd":true,"hp":true}');
      expect(restored, isNotNull);
      expect(restored!.musicEnabled, isTrue);
    });

    test('highestTier reads only the requested meadow', () {
      final GameState state = GameState.fresh();
      state.discovered.addAll(<String>['day_01', 'day_14', 'night_03']);
      expect(state.highestTier('day'), 14);
      expect(state.highestTier('night'), 3);
      expect(state.highestTier('water'), 0);
    });

    test('meadows unlock from the previous meadow only', () {
      final GameState state = GameState.fresh();
      expect(state.isWorldUnlocked(kWorlds[0]), isTrue);
      expect(state.isWorldUnlocked(kWorlds[1]), isFalse);

      state.discovered.add('day_10');
      expect(state.isWorldUnlocked(kWorlds[1]), isTrue);
      expect(state.isWorldUnlocked(kWorlds[2]), isFalse);

      state.discovered.add('night_12');
      expect(state.isWorldUnlocked(kWorlds[2]), isTrue);
    });
  });

  group('formatting', () {
    test('scales into suffixes without losing precision at the boundary', () {
      expect(formatCount(0), '0');
      expect(formatCount(999), '999');
      expect(formatCount(1000), '1K');
      expect(formatCount(1250), '1.25K');
      expect(formatCount(15400), '15.4K');
      expect(formatCount(999999), '1M');
      expect(formatCount(1000000), '1M');
      expect(formatCount(2500000000), '2.5B');
    });

    test('handles hostile input', () {
      expect(formatCount(double.nan), '0');
      expect(formatCount(double.infinity), '0');
      expect(formatCount(-1500), '-1.5K');
    });

    test('durations switch to hours only when needed', () {
      expect(formatDuration(const Duration(seconds: 65)), '01:05');
      expect(formatDuration(const Duration(hours: 2, minutes: 3)), '2:03:00');
      expect(formatDuration(const Duration(seconds: -5)), '00:00');
    });
  });
}
