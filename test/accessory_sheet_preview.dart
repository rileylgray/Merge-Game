// Development-only art proof sheet for accessories.
//
// Run with:  flutter test test/accessory_sheet_preview.dart
// Writes one PNG of every accessory as a shop swatch, and one of a spread of
// body plans wearing each item, so fit can be reviewed. Not part of the app.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/accessory.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/accessory_painter.dart';
import 'package:mergelings/render/creature_painter.dart';

const String kOutDir = String.fromEnvironment(
  'OUT',
  defaultValue: 'build/art_preview',
);

/// A spread of body plans, horn loads and head sizes to fit hats against.
const List<String> kModels = <String>[
  'day_01',
  'day_13',
  'day_24',
  'night_08',
  'night_30',
  'water_11',
  'water_27',
  'mythical_18',
  'mythical_30',
  'prehistoric_09',
  'prehistoric_26',
];

Future<void> _write(ui.Picture picture, Size size, String name) async {
  final ui.Image img =
      await picture.toImage(size.width.toInt(), size.height.toInt());
  final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
  final Directory dir = Directory(kOutDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File('$kOutDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
}

void _label(Canvas canvas, String text, Offset at, {double size = 11}) {
  TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: Colors.black87, fontSize: size),
    ),
    textDirection: TextDirection.ltr,
  )
    ..layout()
    ..paint(canvas, at);
}

void main() {
  test('accessory swatches', () async {
    const double cell = 96;
    const double labelH = 16;
    final Size size = Size(
      cell * kAccessories.length,
      cell + labelH,
    );
    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(rec);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFDF8F0));

    for (int i = 0; i < kAccessories.length; i++) {
      final AccessoryType type = kAccessories[i].type;
      canvas.save();
      canvas.translate(i * cell, 0);
      AccessoryArt.paintIcon(canvas, const Size(cell, cell), type);
      canvas.restore();
      _label(canvas, type.name, Offset(i * cell + 6, cell));
    }

    await _write(rec.endRecording(), size, 'accessories');
  });

  test('accessories worn', () async {
    const double cell = 116;
    const double labelH = 16;
    final Size size = Size(
      cell * (kAccessories.length + 1),
      labelH + cell * kModels.length,
    );
    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(rec);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8F7D8));

    for (int i = 0; i < kAccessories.length; i++) {
      _label(canvas, kAccessories[i].type.name, Offset((i + 1) * cell + 6, 2));
    }

    for (int r = 0; r < kModels.length; r++) {
      final CreatureSpec spec = specById(kModels[r])!;
      final double y = labelH + r * cell;
      for (int c = 0; c <= kAccessories.length; c++) {
        canvas.save();
        canvas.translate(c * cell, y);
        CreaturePainter(
          spec,
          accessory: c == 0 ? null : kAccessories[c - 1].type,
        ).paint(canvas, const Size(cell, cell));
        canvas.restore();
      }
      _label(canvas, spec.id, Offset(6, y + cell - 14), size: 10);
    }

    await _write(rec.endRecording(), size, 'accessories_worn');
  });
}
