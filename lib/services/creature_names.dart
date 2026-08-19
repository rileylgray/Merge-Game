import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Localized creature names.
///
/// These live in JSON assets rather than the ARB files: 150 creatures across
/// five languages is 750 strings that would bloat every generated localization
/// class, and they are looked up by id at runtime rather than by symbol.
class CreatureNames {
  CreatureNames._(this._names, this._fallback);

  static const List<String> supported = <String>['en', 'es', 'pt', 'fr', 'de'];

  final Map<String, String> _names;
  final Map<String, String> _fallback;

  static Map<String, String>? _englishCache;
  static final Map<String, CreatureNames> _cache = <String, CreatureNames>{};

  static Future<Map<String, String>> _loadFile(String code) async {
    final String raw = await rootBundle.loadString('assets/i18n/creatures_$code.json');
    final Map<String, Object?> decoded =
        Map<String, Object?>.from(jsonDecode(raw) as Map);
    return decoded.map(
      (String k, Object? v) => MapEntry<String, String>(k, v.toString()),
    );
  }

  static Future<CreatureNames> load(String languageCode) async {
    final String code =
        supported.contains(languageCode) ? languageCode : 'en';
    final CreatureNames? cached = _cache[code];
    if (cached != null) return cached;

    _englishCache ??= await _loadFile('en');
    Map<String, String> names = _englishCache!;
    if (code != 'en') {
      try {
        names = await _loadFile(code);
      } on Object catch (e) {
        debugPrint('Mergelings: creature names for "$code" missing — $e');
        names = _englishCache!;
      }
    }
    return _cache[code] = CreatureNames._(names, _englishCache!);
  }

  /// Falls back to English, then to the raw id, so a missing translation can
  /// never render an empty label.
  String call(String creatureId) =>
      _names[creatureId] ?? _fallback[creatureId] ?? creatureId;
}
