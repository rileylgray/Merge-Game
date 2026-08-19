import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

/// Persists the save file, coalescing rapid writes so a merge spree does not
/// hammer the disk.
class StorageService {
  StorageService(this._prefs);

  static const String _key = 'mergelings.save.v1';
  static const Duration _debounce = Duration(seconds: 2);

  final SharedPreferences _prefs;
  Timer? _pending;
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
  void save(GameState state) {
    _queued = state;
    _pending ??= Timer(_debounce, () {
      _pending = null;
      final GameState? s = _queued;
      _queued = null;
      if (s != null) unawaited(_write(s));
    });
  }

  /// Writes immediately — used when the app is backgrounded or closing.
  Future<void> flush(GameState state) async {
    _pending?.cancel();
    _pending = null;
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
    _queued = null;
    await _prefs.remove(_key);
  }
}
