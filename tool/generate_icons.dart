// Generates launcher icons from the in-game creature art.
//
// Run with:  flutter test tool/generate_icons.dart
//
// Keeping the icon procedural means it can never drift from the art style of
// the app itself, and there is no binary source asset to lose.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/creature_spec.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_painter.dart';

/// The face of the app: the Day Meadow fox cub.
final CreatureSpec kIconCreature = worldById('day').creatureAt(13);

const Map<String, int> _android = <String, int>{
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const Map<String, int> _ios = <String, int>{
  'Icon-App-20x20@1x.png': 20,
  'Icon-App-20x20@2x.png': 40,
  'Icon-App-20x20@3x.png': 60,
  'Icon-App-29x29@1x.png': 29,
  'Icon-App-29x29@2x.png': 58,
  'Icon-App-29x29@3x.png': 87,
  'Icon-App-40x40@1x.png': 40,
  'Icon-App-40x40@2x.png': 80,
  'Icon-App-40x40@3x.png': 120,
  'Icon-App-60x60@2x.png': 120,
  'Icon-App-60x60@3x.png': 180,
  'Icon-App-76x76@1x.png': 76,
  'Icon-App-76x76@2x.png': 152,
  'Icon-App-83.5x83.5@2x.png': 167,
  'Icon-App-1024x1024@1x.png': 1024,
};

Future<Uint8List> _renderIcon(int size, {required bool rounded}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final double s = size.toDouble();
  final Rect bounds = Rect.fromLTWH(0, 0, s, s);

  if (rounded) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(s * .22)),
    );
  }

  // Sunny meadow backdrop.
  canvas.drawRect(
    bounds,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFBFE8FF), Color(0xFFDFF6C8)],
      ).createShader(bounds),
  );

  // Rolling hill.
  canvas.drawPath(
    Path()
      ..moveTo(-s * .1, s * .80)
      ..quadraticBezierTo(s * .5, s * .58, s * 1.1, s * .82)
      ..lineTo(s * 1.1, s * 1.1)
      ..lineTo(-s * .1, s * 1.1)
      ..close(),
    Paint()..color = const Color(0xFF8FCC6E),
  );

  // A soft sun behind the creature.
  canvas.drawCircle(
    Offset(s * .78, s * .22),
    s * .12,
    Paint()..color = const Color(0xFFFFE9A0),
  );

  canvas.save();
  canvas.translate(s * .10, s * .06);
  CreaturePainter(kIconCreature).paint(canvas, Size(s * .80, s * .80));
  canvas.restore();

  final ui.Image image = await recorder.endRecording().toImage(size, size);
  final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  test('write launcher icons', () async {
    for (final MapEntry<String, int> e in _android.entries) {
      final Directory dir = Directory('android/app/src/main/res/${e.key}');
      dir.createSync(recursive: true);
      File('${dir.path}/ic_launcher.png')
          .writeAsBytesSync(await _renderIcon(e.value, rounded: true));
    }

    // Adaptive-icon foreground: the creature alone on transparency, drawn at
    // 72/108 of the canvas so it survives Android's mask.
    for (final MapEntry<String, int> e in _android.entries) {
      final int size = (e.value * 108 / 48).round();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final double s = size.toDouble();
      canvas.save();
      canvas.translate(s * .22, s * .20);
      CreaturePainter(kIconCreature, shadow: false)
          .paint(canvas, Size(s * .56, s * .56));
      canvas.restore();
      final ui.Image img = await recorder.endRecording().toImage(size, size);
      final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
      final Directory dir = Directory('android/app/src/main/res/${e.key}');
      File('${dir.path}/ic_launcher_foreground.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    }

    for (final MapEntry<String, int> e in _ios.entries) {
      // App Store artwork must be fully opaque with square corners.
      File('ios/Runner/Assets.xcassets/AppIcon.appiconset/${e.key}')
          .writeAsBytesSync(await _renderIcon(e.value, rounded: false));
    }

    expect(
      File('ios/Runner/Assets.xcassets/AppIcon.appiconset/'
              'Icon-App-1024x1024@1x.png')
          .lengthSync(),
      greaterThan(0),
    );
    expect(math.max(1, 1), 1);
  });
}
