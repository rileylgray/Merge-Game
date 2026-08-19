// Development-only art proof sheet.
//
// Run with:  flutter test test/merge_burst_preview.dart
// Writes a filmstrip of the merge celebration to build/art_preview so the
// timing and the spread of the sparks can be judged frame by frame — the
// effect lasts half a second on a device, which is too quick to review live.
// Not part of the shipped app.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/core/balance.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_painter.dart';
import 'package:mergelings/render/merge_burst.dart';
import 'package:mergelings/render/perch_painter.dart';

const String kOutDir = String.fromEnvironment(
  'OUT',
  defaultValue: 'build/art_preview',
);

/// Where in the burst each frame is sampled. Weighted towards the start,
/// where everything interesting happens.
const List<double> kFrames = <double>[
  .0, .06, .12, .20, .30, .42, .55, .70, .85, .97,
];

void main() {
  test('merge burst filmstrip', () async {
    const double cell = 148;
    const double labelH = 18;
    // One row per meadow, so each accent gets checked against its own sky.
    final Size size = Size(
      kFrames.length * cell,
      kWorlds.length * (cell + labelH),
    );

    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(rec);

    for (int w = 0; w < kWorlds.length; w++) {
      final World world = kWorlds[w];
      final PerchPalette palette = PerchPalette.of(world);
      final double y = w * (cell + labelH);

      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, cell + labelH),
        Paint()..color = world.skyBottom,
      );

      for (int f = 0; f < kFrames.length; f++) {
        final double t = kFrames[f];
        final double x = f * cell;

        canvas.save();
        canvas.translate(x, y);

        PerchPainter(
          palette: palette,
          style: perchStyleFor(world, f, Balance.columns),
          seed: f,
        ).paint(canvas, const Size(cell, cell));

        // The creature sits where the board puts it: upper 80% of the cell,
        // inset a tenth from the left.
        canvas.save();
        canvas.translate(cell * .10, 0);
        CreaturePainter(world.creatureAt(6))
            .paint(canvas, const Size(cell * .80, cell * .80));
        MergeBurstPainter(t: t, color: world.accent)
            .paint(canvas, const Size(cell * .80, cell * .80));
        canvas.restore();

        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: 't=${t.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.black87, fontSize: 11),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, const Offset(6, cell));

        canvas.restore();
      }
    }

    final ui.Image img = await rec.endRecording().toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    final Directory dir = Directory(kOutDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('$kOutDir/merge_burst.png').writeAsBytesSync(
      data!.buffer.asUint8List(),
    );
  });
}
