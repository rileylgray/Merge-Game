// Development-only art proof sheet for the water world at large scale.
//
// Run with:  flutter test test/water_zoom_preview.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_painter.dart';

const String kOutDir = String.fromEnvironment(
  'OUT',
  defaultValue: 'build/art_preview',
);

/// Comma separated tiers, e.g. --dart-define=TIERS=5,8,13
const String kTiers = String.fromEnvironment('TIERS', defaultValue: '');

void main() {
  test('water zoom', () async {
    final World world = kWorlds.firstWhere((World w) => w.id == 'water');
    final List<CreatureSpec> specs = kTiers.isEmpty
        ? world.creatures
        : <CreatureSpec>[
            for (final String t in kTiers.split(','))
              world.creatures.firstWhere(
                (CreatureSpec c) => c.tier == int.parse(t.trim()),
              ),
          ];

    const double cell = 300;
    final int cols = specs.length < 4 ? specs.length : 4;
    final int rows = (specs.length / cols).ceil();
    const double labelH = 22;
    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(rec);
    final Size size = Size(cols * cell, rows * (cell + labelH));

    canvas.drawRect(Offset.zero & size, Paint()..color = world.skyBottom);

    for (int i = 0; i < specs.length; i++) {
      final CreatureSpec spec = specs[i];
      final double x = (i % cols) * cell;
      final double y = (i ~/ cols) * (cell + labelH);
      canvas.save();
      canvas.translate(x, y);
      CreaturePainter(spec).paint(canvas, const Size(cell, cell));
      canvas.restore();

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '${spec.tier}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 8, y + cell));
    }

    final ui.Image img = await rec.endRecording().toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    final Directory dir = Directory(kOutDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('$kOutDir/water_zoom.png').writeAsBytesSync(
      data!.buffer.asUint8List(),
    );
  });
}
