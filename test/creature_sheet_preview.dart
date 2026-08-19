// Development-only art proof sheet.
//
// Run with:  flutter test test/creature_sheet_preview.dart
// Writes a PNG contact sheet of every creature so silhouettes can be reviewed
// side by side. Not part of the shipped app.
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

void main() {
  for (final World world in kWorlds) {
    test('sheet ${world.id}', () async {
      const double cell = 132;
      const int cols = 6;
      final int rows = (world.creatures.length / cols).ceil();
      const double labelH = 16;
      final ui.PictureRecorder rec = ui.PictureRecorder();
      final Canvas canvas = Canvas(rec);
      final Size size = Size(cols * cell, rows * (cell + labelH));

      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = world.skyBottom,
      );

      for (int i = 0; i < world.creatures.length; i++) {
        final CreatureSpec spec = world.creatures[i];
        final int c = i % cols;
        final int r = i ~/ cols;
        final double x = c * cell;
        final double y = r * (cell + labelH);

        canvas.save();
        canvas.translate(x, y);
        CreaturePainter(spec).paint(canvas, const Size(cell, cell));
        canvas.restore();

        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: '${spec.tier}',
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 6, y + cell - 2));
      }

      final ui.Image img = await rec.endRecording().toImage(
            size.width.toInt(),
            size.height.toInt(),
          );
      final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
      final Directory dir = Directory(kOutDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('$kOutDir/${world.id}.png').writeAsBytesSync(
        data!.buffer.asUint8List(),
      );
    });
  }
}
