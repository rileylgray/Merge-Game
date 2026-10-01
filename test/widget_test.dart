import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/accessory.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_art/creature_art.dart';
import 'package:mergelings/render/creature_painter.dart';
import 'package:mergelings/ui/widgets/creature_view.dart';

void main() {
  testWidgets('every creature paints without throwing',
      (WidgetTester tester) async {
    for (final World world in kWorlds) {
      for (final CreatureSpec spec in world.creatures) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.square(
                dimension: 96,
                child: CustomPaint(painter: CreaturePainter(spec)),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: spec.id);
      }
    }
  });

  test('every creature has its own artwork, and no artwork is orphaned', () {
    final Set<String> ids = <String>{
      for (final World world in kWorlds)
        for (final CreatureSpec spec in world.creatures) spec.id,
    };
    for (final String id in ids) {
      expect(kCreatureArt.containsKey(id), isTrue,
          reason: '$id has no artwork');
    }
    for (final String id in kCreatureArt.keys) {
      expect(ids.contains(id), isTrue,
          reason: 'artwork for unknown creature $id');
    }
  });

  test('every accessory paints on every creature', () {
    // Accessories hang from landmarks each drawing records for itself, so
    // every creature is its own case.
    for (final World world in kWorlds) {
      for (final CreatureSpec spec in world.creatures) {
        for (final AccessoryType type in AccessoryType.values) {
          final ui.PictureRecorder rec = ui.PictureRecorder();
          CreaturePainter(spec, accessory: type, blink: 0)
              .paint(Canvas(rec), const Size.square(96));
          rec.endRecording().dispose();
        }
      }
    }
  });

  testWidgets('CreatureView animates and disposes cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: CreatureView(kWorlds.first.creatureAt(1), size: 80)),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CreatureView), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    expect(tester.takeException(), isNull);
  });
}
