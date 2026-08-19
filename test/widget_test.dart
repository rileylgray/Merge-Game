import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/accessory.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
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

  testWidgets('every accessory paints on every body plan',
      (WidgetTester tester) async {
    // One creature per body plan is enough: accessory art is anchored to the
    // plan's landmarks, not to ears or patterns.
    final Map<BodyShape, CreatureSpec> models = <BodyShape, CreatureSpec>{
      for (final World world in kWorlds)
        for (final CreatureSpec spec in world.creatures) spec.body: spec,
    };
    expect(models.length, BodyShape.values.length);

    for (final CreatureSpec spec in models.values) {
      for (final AccessoryType type in AccessoryType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.square(
                dimension: 96,
                child: CustomPaint(
                  painter: CreaturePainter(spec, accessory: type),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '${spec.id} + $type');
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
