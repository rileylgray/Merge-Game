import 'dart:convert';

import '../core/balance.dart';
import '../data/accessory.dart';
import '../data/worlds.dart';

/// One creature sitting on a meadow board.
class BoardTile {
  BoardTile({required this.id, required this.tier, this.mystery = false});

  /// Stable across a session so widgets can keep their identity while moving.
  final int id;
  int tier;

  /// A wrapped mystery basket rather than a friend: it earns nothing, merges
  /// with nothing, and is opened by tapping it. [tier] is kept valid so every
  /// render path has something sensible to fall back on.
  bool mystery;

  Map<String, Object?> toJson() => <String, Object?>{
        'i': id,
        't': tier,
        if (mystery) 'm': true,
      };

  static BoardTile fromJson(Map<String, Object?> j) => BoardTile(
        id: (j['i'] as num).toInt(),
        tier: (j['t'] as num).toInt(),
        mystery: j['m'] as bool? ?? false,
      );
}

/// The grid for a single meadow.
class BoardState {
  BoardState({
    required this.worldId,
    required int rows,
    required List<BoardTile?> cells,
  })  : _rows = rows,
        _cells = cells;

  factory BoardState.empty(String worldId) => BoardState(
        worldId: worldId,
        rows: Balance.startingRows,
        cells: List<BoardTile?>.filled(
          Balance.columns * Balance.maxRows,
          null,
        ),
      );

  final String worldId;

  /// Unlocked rows. Cells below this line exist but are not playable.
  int get rows => _rows;
  int _rows;
  set rows(int value) {
    if (value == _rows) return;
    _rows = value;
    _revision++;
  }

  final List<BoardTile?> _cells;

  /// Bumped on every change to what the meadow holds.
  ///
  /// The income tick notifies four times a second and touches none of this, so
  /// the board view watches this counter rather than the controller at large —
  /// otherwise every cell, painter and drag target is rebuilt while a creature
  /// is mid-flight under the player's thumb.
  int get revision => _revision;
  int _revision = 0;

  int get capacity => Balance.columns * rows;

  List<BoardTile?> get cells => _cells;

  BoardTile? at(int index) => index < capacity ? _cells[index] : null;

  void set(int index, BoardTile? tile) {
    if (identical(_cells[index], tile)) return;
    _cells[index] = tile;
    _revision++;
  }

  /// Records a change made to a tile in place — a merge promoting one, a
  /// mystery basket being unwrapped. Anything cached off [revision] is stale
  /// until this is called, so an in-place edit must always say so.
  void touch() => _revision++;

  bool get isFull => firstEmpty() == null;

  int? firstEmpty() {
    for (int i = 0; i < capacity; i++) {
      if (_cells[i] == null) return i;
    }
    return null;
  }

  Iterable<BoardTile> get tiles =>
      _cells.take(capacity).whereType<BoardTile>();

  /// Unopened mystery baskets currently sitting in the meadow.
  int get mysteryCount =>
      tiles.where((BoardTile t) => t.mystery).length;

  /// Total hearts per second this meadow produces, before boosts.
  /// A wrapped mystery basket pays nothing until it is opened.
  ///
  /// Cached against [revision]: this is read on every income tick and again by
  /// every HUD rebuild, and summing five boards of up to forty-eight tiles
  /// several times a second is a surprising amount of arithmetic and garbage
  /// for a number that only moves when the meadow does.
  double get income {
    if (_incomeAt != _revision) {
      double sum = 0;
      final int n = capacity;
      for (int i = 0; i < n; i++) {
        final BoardTile? t = _cells[i];
        if (t != null && !t.mystery) sum += Balance.income(t.tier);
      }
      _income = sum;
      _incomeAt = _revision;
    }
    return _income;
  }

  double _income = 0;
  int _incomeAt = -1;

  Map<String, Object?> toJson() => <String, Object?>{
        'w': worldId,
        'r': rows,
        'c': _cells
            .map((BoardTile? t) => t?.toJson())
            .toList(growable: false),
      };

  static BoardState fromJson(Map<String, Object?> j) {
    final List<Object?> raw = (j['c'] as List<Object?>?) ?? const <Object?>[];
    final List<BoardTile?> cells = List<BoardTile?>.filled(
      Balance.columns * Balance.maxRows,
      null,
    );
    for (int i = 0; i < cells.length && i < raw.length; i++) {
      final Object? cell = raw[i];
      if (cell is Map) {
        cells[i] = BoardTile.fromJson(Map<String, Object?>.from(cell));
      }
    }
    return BoardState(
      worldId: j['w'] as String,
      rows: ((j['r'] as num?)?.toInt() ?? Balance.startingRows)
          .clamp(Balance.startingRows, Balance.maxRows),
      cells: cells,
    );
  }
}

/// The complete persisted player profile.
class GameState {
  GameState({
    required this.boards,
    required this.discovered,
    required this.ownedAccessories,
    required this.wornAccessories,
    required this.hearts,
    required this.gems,
    required this.basketFill,
    required this.basketBoostUntilMs,
    required this.activeWorldId,
    required this.lastSeenMs,
    required this.boostUntilMs,
    required this.localeCode,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.tutorialSeen,
    required this.nextTileId,
  });

  factory GameState.fresh() => GameState(
        boards: <String, BoardState>{
          for (final World w in kWorlds) w.id: BoardState.empty(w.id),
        },
        discovered: <String>{},
        ownedAccessories: <String>{},
        wornAccessories: <String, String>{},
        hearts: 0,
        gems: 0,
        basketFill: 0,
        basketBoostUntilMs: 0,
        activeWorldId: kWorlds.first.id,
        lastSeenMs: DateTime.now().millisecondsSinceEpoch,
        boostUntilMs: 0,
        localeCode: null,
        soundEnabled: true,
        musicEnabled: true,
        hapticsEnabled: true,
        tutorialSeen: false,
        nextTileId: 1,
      );

  final Map<String, BoardState> boards;
  final Set<String> discovered;

  /// Accessory ids the player has bought. Buying is permanent and unlocks the
  /// item for every friend at once, so this is a wardrobe rather than an
  /// inventory of one-per-purchase items.
  final Set<String> ownedAccessories;

  /// Creature id -> the accessory it is wearing. Keyed by species rather than
  /// by board tile so a hat survives merging, selling and coming back later.
  final Map<String, String> wornAccessories;

  double hearts;
  int gems;

  /// How full the basket is, 0..1. It fills on its own and drops a friend
  /// each time it reaches the brim.
  double basketFill;

  /// While in the future, the basket fills at the boosted rate.
  int basketBoostUntilMs;
  String activeWorldId;
  int lastSeenMs;
  int boostUntilMs;

  /// `null` follows the device language.
  String? localeCode;
  bool soundEnabled;

  /// The looping background track, toggled independently of the cues — a
  /// player who wants merge feedback but no soundtrack is the common case.
  bool musicEnabled;
  bool hapticsEnabled;
  bool tutorialSeen;
  int nextTileId;

  static const int schemaVersion = 1;

  BoardState board(String worldId) =>
      boards[worldId] ??= BoardState.empty(worldId);

  /// Adds [id] to the collection. Returns false if it was already there.
  bool markDiscovered(String id) => discovered.add(id);

  /// Scanning the collection means a substring and a parse per entry, and by
  /// the late game that is a hundred and fifty of them — for a number that
  /// only changes when a new species is found, but that is read on every shop
  /// row, every meadow card and every basket spawn.
  ///
  /// Keyed on the size of [discovered] rather than on a flag set by
  /// [markDiscovered]: the set is public and species are only ever added, so
  /// its length is an epoch that cannot be got wrong from the outside.
  final Map<String, int> _bestByWorld = <String, int>{};
  int? _bestAnywhere;
  int _scannedAt = -1;

  void _syncScans() {
    if (_scannedAt == discovered.length) return;
    _scannedAt = discovered.length;
    _bestByWorld.clear();
    _bestAnywhere = null;
  }

  /// Highest tier ever discovered in [worldId] — progression, not board state.
  int highestTier(String worldId) {
    _syncScans();
    return _bestByWorld[worldId] ??= _scanBest(worldId);
  }

  /// Best tier reached in any meadow. The wardrobe is one wardrobe across the
  /// whole game, so it is priced against this rather than against whichever
  /// meadow the player happens to be standing in.
  int get bestTierAnywhere {
    _syncScans();
    return _bestAnywhere ??= _scanBest(null);
  }

  int _scanBest(String? worldId) {
    int best = 0;
    for (final String id in discovered) {
      final int split = id.lastIndexOf('_');
      if (split <= 0) continue;
      if (worldId != null && id.substring(0, split) != worldId) continue;
      final int tier = int.tryParse(id.substring(split + 1)) ?? 0;
      if (tier > best) best = tier;
    }
    return best;
  }

  bool isWorldUnlocked(World world) {
    if (world.order == 0) return true;
    final World previous = kWorlds[world.order - 1];
    return highestTier(previous.id) >= world.unlockRequirement;
  }

  bool get boostActive => boostUntilMs > DateTime.now().millisecondsSinceEpoch;

  bool get basketBoostActive =>
      basketBoostUntilMs > DateTime.now().millisecondsSinceEpoch;

  /// Hearts per second across every meadow, before any boost.
  double get baseIncome {
    double sum = 0;
    for (final BoardState b in boards.values) {
      sum += b.income;
    }
    return sum;
  }

  /// Hearts per second across every meadow, including any active boost.
  double get totalIncome =>
      boostActive ? baseIncome * Balance.boostMultiplier : baseIncome;

  Map<String, Object?> toJson() => <String, Object?>{
        'v': schemaVersion,
        'b': boards.map(
          (String k, BoardState v) => MapEntry<String, Object?>(k, v.toJson()),
        ),
        'd': discovered.toList(growable: false),
        'oa': ownedAccessories.toList(growable: false),
        'wa': wornAccessories,
        'h': hearts,
        'g': gems,
        'bf': basketFill,
        'bb': basketBoostUntilMs,
        'aw': activeWorldId,
        'ls': lastSeenMs,
        'bu': boostUntilMs,
        'lc': localeCode,
        'sd': soundEnabled,
        'ms': musicEnabled,
        'hp': hapticsEnabled,
        'tu': tutorialSeen,
        'ni': nextTileId,
      };

  String encode() => jsonEncode(toJson());

  /// Keeps only entries a build understands: an accessory or a creature that
  /// no longer exists is dropped rather than carried around as a dead key.
  static Map<String, String> _decodeWorn(Object? raw) {
    if (raw is! Map) return <String, String>{};
    final Map<String, String> worn = <String, String>{};
    for (final MapEntry<Object?, Object?> e in raw.entries) {
      final Object? key = e.key;
      final Object? value = e.value;
      if (key is String &&
          value is String &&
          specById(key) != null &&
          accessoryTypeById(value) != null) {
        worn[key] = value;
      }
    }
    return worn;
  }

  static GameState? decode(String source) {
    try {
      final Object? raw = jsonDecode(source);
      if (raw is! Map) return null;
      final Map<String, Object?> j = Map<String, Object?>.from(raw);

      final Map<String, BoardState> boards = <String, BoardState>{};
      final Object? rawBoards = j['b'];
      if (rawBoards is Map) {
        for (final MapEntry<Object?, Object?> e in rawBoards.entries) {
          final Object? value = e.value;
          if (value is Map) {
            boards[e.key as String] =
                BoardState.fromJson(Map<String, Object?>.from(value));
          }
        }
      }
      for (final World w in kWorlds) {
        boards.putIfAbsent(w.id, () => BoardState.empty(w.id));
      }

      final String activeWorld = j['aw'] as String? ?? kWorlds.first.id;
      return GameState(
        boards: boards,
        discovered: <String>{
          ...((j['d'] as List<Object?>?) ?? const <Object?>[])
              .whereType<String>(),
        },
        ownedAccessories: <String>{
          ...((j['oa'] as List<Object?>?) ?? const <Object?>[])
              .whereType<String>(),
        },
        wornAccessories: _decodeWorn(j['wa']),
        hearts: (j['h'] as num?)?.toDouble() ?? 0,
        gems: (j['g'] as num?)?.toInt() ?? 0,
        basketFill: (j['bf'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 0,
        basketBoostUntilMs: (j['bb'] as num?)?.toInt() ?? 0,
        activeWorldId:
            kWorlds.any((World w) => w.id == activeWorld) ? activeWorld : kWorlds.first.id,
        lastSeenMs: (j['ls'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        boostUntilMs: (j['bu'] as num?)?.toInt() ?? 0,
        localeCode: j['lc'] as String?,
        soundEnabled: j['sd'] as bool? ?? true,
        // Absent from saves written before music existed. Those players should
        // get it, not be silently opted out of something they never saw.
        musicEnabled: j['ms'] as bool? ?? true,
        hapticsEnabled: j['hp'] as bool? ?? true,
        tutorialSeen: j['tu'] as bool? ?? false,
        nextTileId: (j['ni'] as num?)?.toInt() ?? 1,
      );
    } on Object {
      // A corrupt save should cost the player their progress, not the app.
      return null;
    }
  }
}
