import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_fit.dart';
import 'package:mergelings/render/creature_painter.dart';

import 'support/ink_bounds.dart';

/// Every creature stays inside its paint box, at both ends of its idle bob.
///
/// The board gives each creature a box and lets it paint unclipped, so
/// anything that runs out of it lands on the neighbouring perches — and the
/// collection cards do clip, so there it is simply cut off. It happens at every
/// screen size alike, because the art scales with the box.
void main() {
  // Antialiasing and float rounding in the fit table, not overflow.
  const double slack = .006;

  for (final World world in kWorlds) {
    test('${world.id} creatures fit their tiles', () async {
      final List<String> problems = <String>[];
      for (final CreatureSpec spec in world.creatures) {
        if (!kCreatureFits.containsKey(spec.id)) {
          problems.add('${spec.id}: not measured');
          continue;
        }
        for (final double bob in const <double>[-1, 1]) {
          final Rect ink = await measureInk(spec, box: 120, bob: bob);
          if (ink.left < -slack ||
              ink.top < -slack ||
              ink.right > 1 + slack ||
              ink.bottom > 1 + slack) {
            problems.add('${spec.id} (bob $bob): ink at $ink');
            break;
          }
        }
      }
      expect(
        problems,
        isEmpty,
        reason: 'Run `flutter test tool/measure_creature_fit.dart` to '
            'remeasure after changing the art.',
      );
    });
  }

  test('no creature is shrunk past recognition to fit', () {
    // A floor on the fitted scale, so a flourish that grows out of control
    // is fixed in the art instead of quietly shrinking the animal wearing it.
    for (final World world in kWorlds) {
      for (final CreatureSpec spec in world.creatures) {
        expect(
          CreaturePainter.fitFor(spec).scale,
          greaterThanOrEqualTo(.76),
          reason: '${spec.id} has to be drawn tiny to fit its tile',
        );
      }
    }
  });
}
