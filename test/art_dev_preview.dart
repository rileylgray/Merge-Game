// Development-only art proof sheet that fits each creature live.
//
// Run with:  flutter test test/art_dev_preview.dart --dart-define=WORLD=day
//
// Unlike creature_sheet_preview.dart this measures every creature's ink on the
// spot rather than trusting the generated fit table, so artwork can be judged
// in its final framing while it is still being drawn. Writes a large sheet
// and a small one (board-tile size) to build/art_preview/.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_painter.dart';

import 'support/ink_bounds.dart';

const String kOutDir = String.fromEnvironment(
  'OUT',
  defaultValue: 'build/art_preview',
);
const String kWorld = String.fromEnvironment('WORLD', defaultValue: 'day');
const String kIds = String.fromEnvironment('IDS');
const int kCell = int.fromEnvironment('CELL', defaultValue: 200);
const int kSmall = int.fromEnvironment('SMALL', defaultValue: 64);
const bool kBlink = bool.fromEnvironment('BLINK');

Future<void> _sheet(
  World world,
  List<CreatureSpec> specs,
  List<CreatureFit> fits,
  double cell,
  String name,
) async {
  const int cols = 6;
  final int rows = (specs.length / cols).ceil();
  final ui.PictureRecorder rec = ui.PictureRecorder();
  final Canvas canvas = Canvas(rec);
  final Size size = Size(cols * cell, rows * cell);
  canvas.drawRect(Offset.zero & size, Paint()..color = world.skyBottom);
  for (int i = 0; i < specs.length; i++) {
    final double x = (i % cols) * cell;
    final double y = (i ~/ cols) * cell;
    canvas.drawRect(
      Rect.fromLTWH(x + 1, y + 1, cell - 2, cell - 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withValues(alpha: .08),
    );
    canvas.save();
    canvas.translate(x, y);
    CreaturePainter(
      specs[i],
      fitOverride: fits[i],
      blink: kBlink ? 0 : 1,
    ).paint(canvas, Size(cell, cell));
    canvas.restore();
  }
  final ui.Image img = await rec.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
  Directory(kOutDir).createSync(recursive: true);
  File('$kOutDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  test('dev sheet', () async {
    final World world = worldById(kWorld);
    final List<CreatureSpec> specs = kIds.isEmpty
        ? world.creatures
        : <CreatureSpec>[
            for (final String id in kIds.split(','))
              for (final World w in kWorlds)
                for (final CreatureSpec s in w.creatures)
                  if (s.id == id.trim()) s,
          ];
    final List<CreatureFit> fits = <CreatureFit>[
      for (final CreatureSpec s in specs)
        fitFromInk(await measureInk(s, fit: CreatureFit.raw)),
    ];
    for (int i = 0; i < specs.length; i++) {
      // ignore: avoid_print
      print('${specs[i].id} scale ${fits[i].scale} dx ${fits[i].dx}');
    }
    await _sheet(world, specs, fits, kCell.toDouble(), 'dev_${kWorld}_big');
    await _sheet(world, specs, fits, kSmall.toDouble(), 'dev_${kWorld}_small');
  });
}
