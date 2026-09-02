// Development-only art proof sheet, zoomed.
//
// Run with:  flutter test test/zoom_preview.dart
// Renders a named list of creatures large enough to judge faces and fit, which
// the 132px contact sheets are too small for. Not part of the shipped app.
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

/// Which creatures to look at, and what to call the file.
const Map<String, List<String>> kSets = <String, List<String>>{
  'zoom_day': <String>[
    'day_19',
    'day_23',
    'day_24',
    'day_25',
    'day_28',
    'day_30',
  ],
  'zoom_water': <String>[
    'water_05',
    'water_08',
    'water_09',
    'water_13',
    'water_14',
    'water_20',
    'water_21',
    'water_22',
    'water_26',
    'water_27',
    'water_29',
    'water_30',
  ],
};

CreatureSpec _byId(String id) {
  for (final World w in kWorlds) {
    for (final CreatureSpec s in w.creatures) {
      if (s.id == id) return s;
    }
  }
  throw ArgumentError('no creature $id');
}

void main() {
  kSets.forEach((String name, List<String> ids) {
    test(name, () async {
      const double cell = 260;
      const int cols = 3;
      final int rows = (ids.length / cols).ceil();
      final ui.PictureRecorder rec = ui.PictureRecorder();
      final Canvas canvas = Canvas(rec);
      final Size size = Size(cols * cell, rows * cell);

      canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE9EDE4));

      for (int i = 0; i < ids.length; i++) {
        final CreatureSpec spec = _byId(ids[i]);
        canvas.save();
        canvas.translate((i % cols) * cell, (i ~/ cols) * cell);
        CreaturePainter(spec).paint(canvas, const Size(cell, cell));
        canvas.restore();
      }

      final ui.Image img = await rec.endRecording().toImage(
            size.width.toInt(),
            size.height.toInt(),
          );
      final ByteData? data =
          await img.toByteData(format: ui.ImageByteFormat.png);
      final Directory dir = Directory(kOutDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('$kOutDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  });
}
