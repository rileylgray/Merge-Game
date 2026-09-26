// Development-only fit proof sheet.
//
// Run with:  flutter test test/fit_preview.dart
// Draws each creature twice — as laid out, and as fitted — over an outline of
// its paint box, so overflow and the shrink it costs can be judged by eye.
// Pass --dart-define=IDS=day_15,night_26 to pick creatures; the default is the
// ones the fit shrinks most. Not part of the shipped app.
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
const String kIds = String.fromEnvironment('IDS');

void main() {
  test('fit sheet', () async {
    final List<CreatureSpec> all = <CreatureSpec>[
      for (final World w in kWorlds) ...w.creatures,
    ];
    final List<CreatureSpec> specs = kIds.isEmpty
        ? (all.toList()
                ..sort(
                  (CreatureSpec a, CreatureSpec b) => CreaturePainter.fitFor(a)
                      .scale
                      .compareTo(CreaturePainter.fitFor(b).scale),
                ))
            .take(24)
            .toList()
        : <CreatureSpec>[
            for (final String id in kIds.split(','))
              all.firstWhere((CreatureSpec s) => s.id == id.trim()),
          ];

    const double box = 150;
    const double pad = 40;
    const double pairW = box * 2 + pad * 3;
    const double rowH = box + pad * 2;
    const int cols = 3;
    final int rows = (specs.length / cols).ceil();
    final Size size = Size(pairW * cols, rowH * rows);

    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(rec);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEFF3E6));
    final Paint outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFCC3344);
    final Paint ground = Paint()
      ..strokeWidth = 1
      ..color = const Color(0x663355CC);

    for (int i = 0; i < specs.length; i++) {
      final CreatureSpec spec = specs[i];
      final double x0 = (i % cols) * pairW;
      final double y0 = (i ~/ cols) * rowH + pad;
      for (int v = 0; v < 2; v++) {
        final Offset o = Offset(x0 + pad + v * (box + pad), y0);
        canvas.drawRect(o & const Size.square(box), outline);
        canvas.drawLine(
          o + const Offset(0, box * CreatureFit.kGroundTarget),
          o + const Offset(box, box * CreatureFit.kGroundTarget),
          ground,
        );
        canvas.save();
        canvas.translate(o.dx, o.dy);
        CreaturePainter(
          spec,
          fitOverride:
              v == 0 ? const CreatureFit(CreatureFit.maxScale, 0) : null,
        ).paint(canvas, const Size.square(box));
        canvas.restore();
      }
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '${spec.id}  ${CreaturePainter.fitFor(spec).scale}',
          style: const TextStyle(color: Colors.black87, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x0 + pad, y0 + box + 6));
    }

    final ui.Image img = await rec.endRecording().toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(kOutDir).createSync(recursive: true);
    File('$kOutDir/fit.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}
