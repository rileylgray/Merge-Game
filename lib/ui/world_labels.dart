import '../l10n/app_localizations.dart';

/// Maps a meadow id to its localized name.
///
/// Meadow names live in the ARB files rather than the creature-name JSON
/// because they appear in sentences ("Discover tier 10 in Day Meadow") that
/// the generated localization API already handles.
String worldName(L l, String worldId) => switch (worldId) {
      'day' => l.worldDay,
      'night' => l.worldNight,
      'water' => l.worldWater,
      'mythical' => l.worldMythical,
      _ => l.worldPrehistoric,
    };

String worldDescription(L l, String worldId) => switch (worldId) {
      'day' => l.worldDayDesc,
      'night' => l.worldNightDesc,
      'water' => l.worldWaterDesc,
      'mythical' => l.worldMythicalDesc,
      _ => l.worldPrehistoricDesc,
    };
