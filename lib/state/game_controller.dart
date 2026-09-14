import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/balance.dart';
import '../data/accessory.dart';
import '../data/creature_spec.dart';
import '../data/worlds.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';
import '../services/creature_names.dart';
import '../services/storage_service.dart';

/// Outcome of an attempted drag between two board cells.
enum MergeResult { none, merged, moved, maxTier }

/// Something worth celebrating, surfaced to the UI once and then cleared.
class DiscoveryEvent {
  const DiscoveryEvent(this.spec, this.gems);
  final CreatureSpec spec;
  final int gems;
}

/// Hearts banked while the app was closed, offered on the next launch.
class OfflineEarnings {
  const OfflineEarnings(this.hearts, this.away);
  final double hearts;
  final Duration away;
}

/// Everything the meadow's grid is drawn from, as one comparable value.
///
/// Hearts arrive four times a second, and the board is the most expensive
/// thing on the screen to rebuild. A `Selector` on this holds it perfectly
/// still between actual moves — including through a drag, where a rebuild
/// lands on the same frames as the pointer updates.
@immutable
class BoardSignature {
  const BoardSignature({
    required this.worldId,
    required this.revision,
    required this.rows,
    required this.mergedCell,
    required this.wardrobe,
  });

  final String worldId;
  final int revision;
  final int rows;
  final int? mergedCell;

  /// Bumped by anything that changes how a creature is *drawn* without moving
  /// it — dressing it up, or renaming it in another language.
  final int wardrobe;

  @override
  bool operator ==(Object other) =>
      other is BoardSignature &&
      other.worldId == worldId &&
      other.revision == revision &&
      other.rows == rows &&
      other.mergedCell == mergedCell &&
      other.wardrobe == wardrobe;

  @override
  int get hashCode =>
      Object.hash(worldId, revision, rows, mergedCell, wardrobe);
}

/// Fires on the income tick and on nothing else.
///
/// See [GameController.ticks].
class TickNotifier extends ChangeNotifier {
  void _fire() => notifyListeners();
}

/// The single source of truth for gameplay.
///
/// Owns the save file, the per-second income tick and every rule about
/// merging, spawning, buying and unlocking.
class GameController extends ChangeNotifier {
  GameController(this._storage, this._state, this._names, this._audio) {
    _audio.enabled = _state.soundEnabled;
    _audio.musicEnabled = _state.musicEnabled;
  }

  final StorageService _storage;
  final AudioService _audio;
  final math.Random _random = math.Random();

  GameState _state;
  CreatureNames _names;
  Timer? _ticker;
  DateTime _lastTick = DateTime.now();

  DiscoveryEvent? pendingDiscovery;
  OfflineEarnings? pendingOffline;

  /// Fires four times a second, for hearts arriving and the basket filling.
  ///
  /// Kept apart from [notifyListeners] on purpose. Every screen in the app is
  /// alive at once inside the shell's stack, so a controller-wide notification
  /// four times a second rebuilt all five of them — the meadow, the collection
  /// grid, the shop list, the meadow picker and the settings page — for a
  /// number that only two small widgets are showing. [notifyListeners] now
  /// means "something actually changed"; this means "the clock moved", and
  /// only the handful of widgets that display a running number listen to it
  /// (see `TickBuilder`, which also drops the subscription while its tab is
  /// off screen).
  final TickNotifier ticks = TickNotifier();

  /// Set when a merge just happened, so the board can play a pop animation.
  ///
  /// Cleared by any later change to the board. It is keyed by cell, so leaving
  /// it set would make the *next* arrival in that same cell — a spawn, a
  /// dropped tile — celebrate a merge that never happened.
  int? lastMergedCell;

  /// See [BoardSignature.wardrobe].
  int _wardrobe = 0;

  BoardSignature get boardSignature => BoardSignature(
        worldId: _state.activeWorldId,
        revision: board.revision,
        rows: board.rows,
        mergedCell: lastMergedCell,
        wardrobe: _wardrobe,
      );

  static Future<GameController> boot({AudioService? audio}) async {
    final StorageService storage = await StorageService.open();
    final GameState state = storage.load();
    final CreatureNames names = await CreatureNames.load(
      state.localeCode ?? _deviceLanguage(),
    );
    final GameController controller = GameController(
      storage,
      state,
      names,
      audio ?? AudioService(),
    );
    controller._computeOfflineEarnings();
    controller._start();
    return controller;
  }

  static String _deviceLanguage() {
    final String tag = PlatformDispatcher.instance.locale.languageCode;
    return CreatureNames.supported.contains(tag) ? tag : 'en';
  }

  // ------------------------------------------------------------------ access

  GameState get state => _state;
  World get world => worldById(_state.activeWorldId);
  BoardState get board => _state.board(_state.activeWorldId);
  double get hearts => _state.hearts;
  int get gems => _state.gems;
  /// How full the basket is, 0..1. At 1 it releases a friend on its own.
  double get basketProgress => _state.basketFill.clamp(0.0, 1.0);
  bool get boostActive => _state.boostActive;
  bool get basketBoostActive => _state.basketBoostActive;

  Duration get boostRemaining => _remaining(_state.boostUntilMs);

  Duration get basketBoostRemaining => _remaining(_state.basketBoostUntilMs);

  Duration _remaining(int untilMs) => Duration(
        milliseconds:
            math.max(0, untilMs - DateTime.now().millisecondsSinceEpoch),
      );

  String nameOf(CreatureSpec spec) => _names(spec.id);

  bool isDiscovered(CreatureSpec spec) => _state.discovered.contains(spec.id);

  int highestTier(String worldId) => _state.highestTier(worldId);

  bool isWorldUnlocked(World w) => _state.isWorldUnlocked(w);

  int discoveredCount([String? worldId]) => worldId == null
      ? _state.discovered.length
      : _state.discovered.where((String id) => id.startsWith('${worldId}_')).length;

  /// Where the active meadow's progress has got to, a few rungs back. Mystery
  /// baskets draw from above it; the plain basket ignores it entirely.
  int get progressTier => Balance.progressTier(highestTier(world.id));

  // ------------------------------------------------------------------- ticks

  void _start() {
    _lastTick = DateTime.now();
    _ticker ??=
        Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  /// Stops the income tick. Nothing is lost: what the meadow earns while it is
  /// stopped is credited in one go by [_computeOfflineEarnings] on the way
  /// back in. Running it behind an ad or a locked screen only spent battery.
  void _stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    final DateTime now = DateTime.now();
    final double dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;
    if (dt <= 0) return;

    final int before = board.revision;
    _state.hearts += _state.totalIncome * dt;
    _fillBasket(dt);
    _state.lastSeenMs = now.millisecondsSinceEpoch;
    // Hearts arriving is not worth a write of its own; the basket dropping a
    // friend into the meadow is.
    if (board.revision != before) {
      _storage.save(_state);
      notifyListeners();
    } else {
      _storage.saveAmbient(_state);
    }
    ticks._fire();
  }

  /// Advances the basket by [seconds] of filling and lets it spill over.
  ///
  /// The meter stops at the brim rather than banking spare fills, so time away
  /// never returns to a meadow stuffed with friends the player did not place.
  void _fillBasket(double seconds) {
    if (_state.basketFill < 1) {
      double perSecond = 1000 / Balance.basketFillTime.inMilliseconds;
      if (_state.basketBoostActive) perSecond *= Balance.basketBoostMultiplier;
      _state.basketFill =
          math.min(1, _state.basketFill + seconds * perSecond);
    }
    if (_state.basketFill >= 1 && !board.isFull) _spawnFromBasket();
  }

  /// Empties the basket into a free cell — a friend, or now and then a
  /// wrapped surprise.
  void _spawnFromBasket() {
    _state.basketFill = 0;
    if (_rollMystery()) {
      _placeTile(progressTier, mystery: true);
      _audio.play(Sfx.discover);
      _haptic(HapticFeedbackType.heavy);
    } else {
      _placeTile(Balance.basketSpawnTier);
      _audio.play(Sfx.spawn);
      _haptic(HapticFeedbackType.light);
    }
  }

  void _computeOfflineEarnings() {
    final DateTime now = DateTime.now();
    final Duration away = Duration(
      milliseconds: now.millisecondsSinceEpoch - _state.lastSeenMs,
    );
    _fillBasket(away.inMilliseconds / 1000.0);
    if (away < const Duration(minutes: 2)) {
      // Too short to be worth a welcome-back dialog, but the tick was stopped
      // for it, so pay it out at the ordinary rate rather than swallowing it.
      if (away > Duration.zero) {
        _state.hearts += _state.totalIncome * away.inMilliseconds / 1000.0;
      }
      _state.lastSeenMs = now.millisecondsSinceEpoch;
      return;
    }
    final Duration capped = away > Balance.offlineCap ? Balance.offlineCap : away;
    // Boosts do not run while the app is closed, and the payout is held under
    // a ceiling of its own so a long absence cannot hand over a sink's worth
    // of hearts in one go.
    final double earned = math.min(
      _state.baseIncome * capped.inSeconds * Balance.offlineRate,
      Balance.offlineHeartCap(_state.bestTierAnywhere),
    );
    _state.lastSeenMs = now.millisecondsSinceEpoch;
    if (earned >= 1) pendingOffline = OfflineEarnings(earned, away);
  }

  // ------------------------------------------------------------------ board

  /// Hurries the basket along by a tap's worth of filling, dropping a friend
  /// the moment it tops up. Returns false only when the meadow has no room.
  bool tapBasket() {
    if (board.isFull) {
      _audio.play(Sfx.error);
      return false;
    }
    _state.basketFill = math.min(1, _state.basketFill + Balance.basketTapFill);
    if (_state.basketFill >= 1) {
      _spawnFromBasket();
    } else {
      _audio.play(Sfx.tap);
      _haptic(HapticFeedbackType.light);
    }
    _persist();
    return true;
  }

  /// True once the player knows the meadow well enough for a surprise, and the
  /// dice agree. One basket at a time keeps it a treat rather than clutter.
  bool _rollMystery() {
    if (!mysteryUnlocked) return false;
    if (board.mysteryCount >= Balance.mysteryMaxOnBoard) return false;
    return _random.nextDouble() < Balance.mysteryChance;
  }

  /// Whether mystery baskets can appear in the active meadow yet.
  bool get mysteryUnlocked =>
      discoveredCount(world.id) >= Balance.mysteryMinDiscoveries;

  void _placeTile(int tier, {bool mystery = false}) {
    lastMergedCell = null;
    final int capacity = board.capacity;
    int empty = 0;
    for (int i = 0; i < capacity; i++) {
      if (board.at(i) == null) empty++;
    }
    if (empty == 0) return;
    // Counted rather than collected: the same choice, without a fresh list of
    // up to forty-eight boxed ints every time the basket tips over.
    int nth = _random.nextInt(empty);
    int index = 0;
    for (int i = 0; i < capacity; i++) {
      if (board.at(i) != null) continue;
      if (nth-- == 0) {
        index = i;
        break;
      }
    }
    board.set(
      index,
      BoardTile(id: _state.nextTileId++, tier: tier, mystery: mystery),
    );
    if (!mystery) _registerDiscovery(world, tier);
  }

  /// Handles a drag from [from] onto [to]. Merges matching tiers, otherwise
  /// swaps or moves.
  MergeResult moveTile(int from, int to) {
    if (from == to) return MergeResult.none;
    final BoardTile? source = board.at(from);
    if (source == null) return MergeResult.none;
    final BoardTile? target = board.at(to);

    if (target == null) {
      board.set(to, source);
      board.set(from, null);
      lastMergedCell = null;
      _persist();
      return MergeResult.moved;
    }

    // A wrapped basket shuffles around the meadow but never merges.
    if (target.tier != source.tier || source.mystery || target.mystery) {
      board.set(to, source);
      board.set(from, target);
      lastMergedCell = null;
      _persist();
      return MergeResult.moved;
    }

    if (target.tier >= world.maxTier) {
      return MergeResult.maxTier;
    }

    target.tier += 1;
    board
      ..touch()
      ..set(from, null);
    lastMergedCell = to;
    _audio.play(Sfx.merge);
    _registerDiscovery(world, target.tier);
    _haptic(HapticFeedbackType.medium);
    _persist();
    return MergeResult.merged;
  }

  /// Releases a creature back into the wild for hearts.
  void sellTile(int index) {
    final BoardTile? tile = board.at(index);
    if (tile == null || tile.mystery) return;
    _state.hearts += Balance.sellValue(tile.tier);
    board.set(index, null);
    lastMergedCell = null;
    _audio.play(Sfx.coin);
    _haptic(HapticFeedbackType.light);
    _persist();
  }

  // --------------------------------------------------------------- mystery

  /// Tier band a free mystery pick draws from, clamped to the meadow's roster.
  (int, int) get mysteryFreeBand => _band(
        Balance.mysteryFreeMin(highestTier(world.id)),
        Balance.mysteryFreeMax(highestTier(world.id)),
      );

  /// The richer band unlocked by watching a rewarded video.
  (int, int) get mysteryRewardBand => _band(
        Balance.mysteryRewardMin(highestTier(world.id)),
        Balance.mysteryRewardMax(highestTier(world.id)),
      );

  (int, int) _band(int low, int high) {
    final int max = world.maxTier;
    final int top = high.clamp(1, max);
    return (low.clamp(1, top), top);
  }

  /// Unwraps the mystery basket at [index] into a friend from the free or the
  /// rewarded band. Returns the creature granted, or null if that cell no
  /// longer holds an unopened basket.
  CreatureSpec? openMystery(int index, {required bool rewarded}) {
    final BoardTile? tile = board.at(index);
    if (tile == null || !tile.mystery) return null;

    final (int low, int high) = rewarded ? mysteryRewardBand : mysteryFreeBand;
    final int tier = low + _random.nextInt(high - low + 1);

    tile.mystery = false;
    tile.tier = tier;
    board.touch();
    lastMergedCell = index;
    _audio.play(Sfx.merge);
    _haptic(HapticFeedbackType.heavy);
    _registerDiscovery(world, tier);
    _persist();
    return world.creatureAt(tier);
  }

  void _registerDiscovery(World w, int tier) {
    final CreatureSpec? spec = w.tryCreatureAt(tier);
    if (spec == null || !_state.markDiscovered(spec.id)) return;
    final int reward = Balance.discoveryGems(spec.rarity);
    _state.gems += reward;
    pendingDiscovery = DiscoveryEvent(spec, reward);
    _audio.play(Sfx.discover);
    _haptic(HapticFeedbackType.heavy);
  }

  void clearDiscovery() {
    pendingDiscovery = null;
    notifyListeners();
  }

  // -------------------------------------------------------------------- shop

  bool canAfford(double cost) => _state.hearts >= cost;

  /// Buys a creature of [tier] into the active meadow.
  bool buyCreature(int tier) {
    final double cost = Balance.shopCost(tier);
    if (_state.hearts < cost || board.isFull) {
      _audio.play(Sfx.error);
      return false;
    }
    _state.hearts -= cost;
    _placeTile(tier);
    _audio.play(Sfx.coin);
    _haptic(HapticFeedbackType.medium);
    _persist();
    return true;
  }

  // ------------------------------------------------------------ accessories

  bool ownsAccessory(AccessoryType type) =>
      _state.ownedAccessories.contains(type.name);

  /// Accessories are gated on the collection rather than on hearts alone, so
  /// the wardrobe opens up as a reward for playing rather than all at once.
  bool accessoryUnlocked(Accessory item) =>
      discoveredCount() >= item.unlockDiscoveries;

  /// What [item] costs right now. Rises with progress, so ask again rather
  /// than holding on to the answer.
  double accessoryCost(Accessory item) =>
      item.costAt(_state.bestTierAnywhere);

  /// The wardrobe in shop order, with the still-locked bands at the end.
  List<Accessory> get accessoryCatalogue => <Accessory>[
        ...kAccessories.where(accessoryUnlocked),
        ...kAccessories.where((Accessory a) => !accessoryUnlocked(a)),
      ];

  List<Accessory> get ownedAccessories => kAccessories
      .where((Accessory a) => ownsAccessory(a.type))
      .toList(growable: false);

  /// Buying is permanent: the item joins the wardrobe and any number of
  /// friends can wear it from then on.
  bool buyAccessory(Accessory item) {
    final double price = accessoryCost(item);
    if (ownsAccessory(item.type) ||
        !accessoryUnlocked(item) ||
        _state.hearts < price) {
      _audio.play(Sfx.error);
      return false;
    }
    _state.hearts -= price;
    _state.ownedAccessories.add(item.id);
    _audio.play(Sfx.coin);
    _haptic(HapticFeedbackType.medium);
    _persist();
    return true;
  }

  AccessoryType? accessoryFor(CreatureSpec spec) =>
      accessoryTypeById(_state.wornAccessories[spec.id]);

  /// Dresses [spec] in [type], or takes off whatever it is wearing when
  /// [type] is null. Taking something off is always free.
  void wearAccessory(CreatureSpec spec, AccessoryType? type) {
    if (type == null) {
      if (_state.wornAccessories.remove(spec.id) == null) return;
    } else {
      if (!ownsAccessory(type)) return;
      if (_state.wornAccessories[spec.id] == type.name) return;
      _state.wornAccessories[spec.id] = type.name;
    }
    _wardrobe++;
    _audio.play(Sfx.tap);
    _haptic(HapticFeedbackType.light);
    _persist();
  }

  bool get canExpand => board.rows < Balance.maxRows;

  double get expandCost =>
      Balance.rowUnlockCost(board.rows + 1, highestTier(world.id));

  bool expandMeadow() {
    if (!canExpand || _state.hearts < expandCost) {
      _audio.play(Sfx.error);
      return false;
    }
    _state.hearts -= expandCost;
    board.rows += 1;
    _audio.play(Sfx.coin);
    _haptic(HapticFeedbackType.medium);
    _persist();
    return true;
  }

  // ------------------------------------------------------------------ awards

  void grantOffline({required bool doubled}) {
    final OfflineEarnings? offline = pendingOffline;
    pendingOffline = null;
    if (offline != null) {
      _state.hearts += offline.hearts * (doubled ? 2 : 1);
      _audio.play(Sfx.coin);
    }
    _persist();
  }

  void startBoost() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int from = math.max(now, _state.boostUntilMs);
    _state.boostUntilMs = from + Balance.boostDuration.inMilliseconds;
    _audio.play(Sfx.coin);
    _persist();
  }

  /// Speeds the basket up for a while. Watching again stacks the time rather
  /// than the rate, so the meadow never fills faster than one boosted basket.
  void startBasketBoost() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int from = math.max(now, _state.basketBoostUntilMs);
    _state.basketBoostUntilMs =
        from + Balance.basketBoostDuration.inMilliseconds;
    _audio.play(Sfx.coin);
    _persist();
  }

  /// The rewarded "free friend" gift: a few tiers below the player's best.
  int get giftTier => math.max(1, math.min(highestTier(world.id) - 2, world.maxTier));

  bool grantGiftCreature() {
    if (board.isFull) {
      _audio.play(Sfx.error);
      return false;
    }
    _placeTile(giftTier);
    _audio.play(Sfx.spawn);
    _persist();
    return true;
  }

  // ----------------------------------------------------------------- worlds

  bool switchWorld(String worldId) {
    final World target = worldById(worldId);
    if (!isWorldUnlocked(target)) {
      _audio.play(Sfx.error);
      return false;
    }
    _state.activeWorldId = worldId;
    _audio.play(Sfx.tap);
    _persist();
    return true;
  }

  // --------------------------------------------------------------- settings

  Future<void> setLocale(String? code) async {
    _state.localeCode = code;
    _names = await CreatureNames.load(code ?? _deviceLanguage());
    // Creature names reach the board only as screen-reader labels, but they do
    // reach it, so the board has to hear about a language change.
    _wardrobe++;
    _persist();
  }

  void setSound(bool value) {
    _state.soundEnabled = value;
    _audio.enabled = value;
    // Play the confirmation *after* enabling so switching on is audible.
    if (value) _audio.play(Sfx.tap);
    _persist();
  }

  void setMusic(bool value) {
    _state.musicEnabled = value;
    _audio.musicEnabled = value;
    _persist();
  }

  void setHaptics(bool value) {
    _state.hapticsEnabled = value;
    _persist();
  }

  void markTutorialSeen() {
    if (_state.tutorialSeen) return;
    _state.tutorialSeen = true;
    _persist();
  }

  Future<void> resetProgress() async {
    await _storage.clear();
    _state = GameState.fresh();
    // A fresh state turns the audio settings back on, and the service has to
    // hear about it — otherwise the switches read as on while nothing plays.
    _audio.enabled = _state.soundEnabled;
    _audio.musicEnabled = _state.musicEnabled;
    pendingDiscovery = null;
    pendingOffline = null;
    // A fresh board starts its revision counter over, so nudge the signature by
    // hand or the meadow keeps drawing the creatures that were just cleared.
    _wardrobe++;
    _persist();
  }

  // ------------------------------------------------------------- lifecycle

  /// Builds the audio players ahead of the first cue so the first merge does
  /// not pay for platform-channel setup.
  Future<void> warmUpAudio() => _audio.warmUp();

  /// Starts the background track if the player has it switched on.
  Future<void> startMusic() => _audio.startMusic();

  /// Silences the music without changing the setting — for a full-screen ad,
  /// which brings its own soundtrack.
  void duckMusicForAd({required bool ducked}) =>
      _audio.duckMusic(MusicInterruption.fullScreenAd, ducked: ducked);

  /// Plays the generic UI press cue.
  void playTap() => _audio.play(Sfx.tap);

  Future<void> onPaused() async {
    _stop();
    _audio.duckMusic(MusicInterruption.backgrounded, ducked: true);
    _state.lastSeenMs = DateTime.now().millisecondsSinceEpoch;
    await _storage.flush(_state);
  }

  void onResumed() {
    _audio.duckMusic(MusicInterruption.backgrounded, ducked: false);
    _computeOfflineEarnings();
    _start();
    notifyListeners();
  }

  void _persist() {
    _storage.save(_state);
    notifyListeners();
  }

  void _haptic(HapticFeedbackType type) {
    if (!_state.hapticsEnabled) return;
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.selectionClick();
      case HapticFeedbackType.medium:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    ticks.dispose();
    unawaited(_audio.dispose());
    super.dispose();
  }
}

enum HapticFeedbackType { light, medium, heavy }
