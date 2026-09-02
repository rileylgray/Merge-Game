import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The shading vocabulary every painter in the app shares.
///
/// Creatures and the things they wear have to sit in the same light, so the
/// ramp, the contour and the hue-swinging shade function all live in one place
/// rather than being reinvented per painter.

/// Lightness shift that also swings hue: highlights drift warm and shadows
/// drift cool, the way light actually behaves. A purely neutral ramp is what
/// makes procedural art look like plastic.
Color shade(Color c, double amount) {
  final HSLColor hsl = HSLColor.fromColor(c);
  final double target = amount > 0 ? 45 : 250;
  final double diff = ((target - hsl.hue + 540) % 360) - 180;
  final double hue = (hsl.hue + diff * amount.abs() * .30 + 360) % 360;
  final double lit = (hsl.lightness + amount).clamp(0.04, 0.97);
  double sat = (hsl.saturation + (amount < 0 ? .05 : -.06)).clamp(0.0, 1.0);

  // Saturation in HSL is measured against the room a colour has at its *own*
  // lightness, so a cream body reports a high one while being barely tinted at
  // all. Carry it straight down a long darkening and that whisper of warmth
  // opens out into brick red — which is how a white lamb ended up with the
  // eyes of a lab rat. Cap against the colour's actual chroma instead, with
  // enough slack that ordinary mid-tone shadows still deepen the way they did.
  final double chroma = (1 - (2 * hsl.lightness - 1).abs()) * hsl.saturation;
  final double room = 1 - (2 * lit - 1).abs();
  if (room > 0.001) sat = math.min(sat, chroma / room * 1.6);

  return hsl.withHue(hue).withLightness(lit).withSaturation(sat).toColor();
}

Paint fillOf(Color c) => Paint()
  ..color = c
  ..isAntiAlias = true;

Paint strokeOf(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

/// Flat colour is what makes a shape read as clip art. Every solid mass gets
/// the same top-lit vertical ramp so separate pieces sit in one light.
Paint volumeOf(Color c, Rect b, {double lift = .11, double drop = -.15}) {
  if (b.height <= 0) return fillOf(c);
  return Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[shade(c, lift), c, shade(c, drop)],
      stops: const <double>[0, .52, 1],
    ).createShader(b)
    ..isAntiAlias = true;
}
