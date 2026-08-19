import 'package:flutter/material.dart';

import 'creature_spec.dart';
import 'creatures/day.dart';
import 'creatures/mythical.dart';
import 'creatures/night.dart';
import 'creatures/prehistoric.dart';
import 'creatures/water.dart';

/// A meadow: one self-contained merge chain with its own board and look.
class World {
  const World({
    required this.id,
    required this.order,
    required this.creatures,
    required this.skyTop,
    required this.skyBottom,
    required this.ground,
    required this.accent,
    required this.onAccent,
    required this.unlockRequirement,
  });

  final String id;

  /// 0-based position in the meadow list.
  final int order;

  final List<CreatureSpec> creatures;

  final Color skyTop;
  final Color skyBottom;
  final Color ground;

  /// Drives buttons and highlights while this meadow is active.
  final Color accent;
  final Color onAccent;

  /// Highest tier the player must have discovered in the *previous* meadow
  /// before this one opens. 0 means unlocked from the start.
  final int unlockRequirement;

  int get maxTier => creatures.length;

  CreatureSpec creatureAt(int tier) => creatures[tier - 1];

  CreatureSpec? tryCreatureAt(int tier) =>
      tier >= 1 && tier <= creatures.length ? creatures[tier - 1] : null;
}

const List<World> kWorlds = <World>[
  World(
    id: 'day',
    order: 0,
    creatures: dayCreatures,
    skyTop: Color(0xFFBFE8FF),
    skyBottom: Color(0xFFE8F7D8),
    ground: Color(0xFF9FD37E),
    accent: Color(0xFF4CAF50),
    onAccent: Colors.white,
    unlockRequirement: 0,
  ),
  World(
    id: 'night',
    order: 1,
    creatures: nightCreatures,
    skyTop: Color(0xFF1B1A3A),
    skyBottom: Color(0xFF3B2E64),
    ground: Color(0xFF2C2550),
    accent: Color(0xFF7C6BE8),
    onAccent: Colors.white,
    unlockRequirement: 10,
  ),
  World(
    id: 'water',
    order: 2,
    creatures: waterCreatures,
    skyTop: Color(0xFF6FD3F2),
    skyBottom: Color(0xFF1F7FB8),
    ground: Color(0xFF15618F),
    accent: Color(0xFF16A0C8),
    onAccent: Colors.white,
    unlockRequirement: 12,
  ),
  World(
    id: 'mythical',
    order: 3,
    creatures: mythicalCreatures,
    skyTop: Color(0xFFF6D7F5),
    skyBottom: Color(0xFFCBB6F0),
    ground: Color(0xFF9E86D6),
    accent: Color(0xFF9B59D0),
    onAccent: Colors.white,
    unlockRequirement: 14,
  ),
  World(
    id: 'prehistoric',
    order: 4,
    creatures: prehistoricCreatures,
    skyTop: Color(0xFFFFD9A0),
    skyBottom: Color(0xFFE9A97C),
    ground: Color(0xFFB97A55),
    accent: Color(0xFFD2691E),
    onAccent: Colors.white,
    unlockRequirement: 16,
  ),
];

World worldById(String id) => kWorlds.firstWhere((World w) => w.id == id);

CreatureSpec? specById(String creatureId) {
  final int split = creatureId.lastIndexOf('_');
  if (split <= 0) return null;
  final String worldId = creatureId.substring(0, split);
  final int? tier = int.tryParse(creatureId.substring(split + 1));
  if (tier == null) return null;
  final int idx = kWorlds.indexWhere((World w) => w.id == worldId);
  if (idx < 0) return null;
  return kWorlds[idx].tryCreatureAt(tier);
}

/// Total creatures across every meadow — used by the collection progress ring.
int get kTotalCreatures =>
    kWorlds.fold(0, (int sum, World w) => sum + w.creatures.length);
