import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

/// Persists the save file, coalescing rapid writes so a merge spree does not
/// hammer the disk.
///
/// Writes come in two flavours. A move, a purchase or a discovery is something
/// the player did and would notice losing, so it lands within [_debounce].
/// The income tick is not: it accrues four times a second for as long as the
/// app is open, and at the debounce interval alone it meant re-encoding the
/// whole save and handing it to the platform every two seconds forever — an
/// hour of play was eighteen hundred writes of a file nobody asked for.
/// [saveAmbient] lets that drip settle at [_ambient] instead, and the app
/// still [flush]es on the way to the background, so nothing is actually lost.
class StorageService {
  StorageService(this._prefs);

  static const String _key = 'mergelings.save.v1';
  static const Duration _debounce = Duration(seconds: 2);
  static const Duration _ambient = Duration(seconds: 30);

  final SharedPreferences _prefs;
  Timer? _pending;
  DateTime? _dueAt;
  GameState? _queued;

  static Future<StorageService> open() async =>
      StorageService(await SharedPreferences.getInstance());

  GameState load() {
    final String? raw = _prefs.getString(_key);
    if (raw == null) return GameState.fresh();
    final GameState? decoded = GameState.decode(raw);
    if (decoded == null) {
      debugPrint('Mergelings: save file unreadable, starting fresh.');
      return GameState.fresh();
    }
    return decoded;
  }

  /// Schedules a write. Safe to call on every state change.
  void save(GameState state) => _schedule(state, _debounce);

  /// Schedules a write for something that changes on its own — the income
  /// drip. Never brings a write forward, so a spree of these costs one write
  /// every [_ambient] rather than one every [_debounce].
  void saveAmbient(GameState state) => _schedule(state, _ambient);

  void _schedule(GameState state, Duration delay) {
    _queued = state;
    final DateTime due = DateTime.now().add(delay);
    final DateTime? scheduled = _dueAt;
    // A write already lands at or before this one would; let it.
    if (_pending != null && scheduled != null && !scheduled.isAfter(due)) {
      return;
    }
    _pending?.cancel();
    _dueAt = due;
    _pending = Timer(delay, () {
      _pending = null;
      _dueAt = null;
      final GameState? s = _queued;
      _queued = null;
      if (s != null) unawaited(_write(s));
    });
  }

  /// Writes immediately — used when the app is backgrounded or closing.
  Future<void> flush(GameState state) async {
    _pending?.cancel();
    _pending = null;
    _dueAt = null;
    _queued = null;
    await _write(state);
  }

  Future<void> _write(GameState state) async {
    try {
      await _prefs.setString(_key, state.encode());
    } on Object catch (e) {
      debugPrint('Mergelings: failed to save — $e');
    }
  }

  Future<void> clear() async {
    _pending?.cancel();
    _pending = null;
    _dueAt = null;
    _queued = null;
    await _prefs.remove(_key);
  }
}
