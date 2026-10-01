import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/accessory.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/render/creature_painter.dart';
import 'package:mergelings/render/smooth_stroke_canvas.dart';

/// Notes each path's size and paint as drawn. The paint is the caller's and
/// changes afterwards, so it has to be read at the call.
class _Recorder extends TestRecordingCanvas {
  final List<({Rect bounds, PaintingStyle style, double width})> paths =
      <({Rect bounds, PaintingStyle style, double width})>[];

  @override
  void drawPath(Path path, Paint paint) {
    paths.add((
      bounds: path.getBounds(),
      style: paint.style,
      width: paint.strokeWidth,
    ));
    super.drawPath(path, paint);
  }

  Iterable<Invocation> calls(Symbol name) => invocations
      .map((RecordedInvocation r) => r.invocation)
      .where((Invocation i) => i.memberName == name);
}

Paint _stroke(double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width;

Path _blob() => Path()
  ..moveTo(.2, .5)
  ..cubicTo(.2, .2, .8, .2, .8, .5)
  ..cubicTo(.8, .8, .2, .8, .2, .5)
  ..close();

void main() {
  const double k = SmoothStrokeCanvas.unit;

  test('a stroked curve is drawn enlarged under a matching shrink', () {
    final _Recorder rec = _Recorder();
    final Paint paint = _stroke(.024);
    final double width = paint.strokeWidth;
    final int saves = rec.getSaveCount();
    SmoothStrokeCanvas(rec).drawPath(_blob(), paint);

    final drawn = rec.paths.single;
    expect(drawn.bounds.width, closeTo(_blob().getBounds().width * k, 1e-3));
    expect(drawn.width, closeTo(.024 * k, 1e-6));
    expect(rec.calls(#scale).single.positionalArguments.first, 1 / k);
    expect(rec.getSaveCount(), saves, reason: 'save and restore stay paired');
    expect(paint.strokeWidth, width, reason: 'the caller gets its paint back');
  });

  test('fills, circles and arcs pass straight through', () {
    final _Recorder rec = _Recorder();
    final SmoothStrokeCanvas canvas = SmoothStrokeCanvas(rec);
    canvas.drawPath(_blob(), Paint());
    canvas.drawCircle(const Offset(.5, .5), .3, _stroke(.02));
    canvas.drawArc(
      const Rect.fromLTWH(.2, .2, .6, .6),
      0,
      2,
      false,
      _stroke(.02),
    );

    expect(rec.paths.single.bounds, _blob().getBounds());
    expect(rec.calls(#scale), isEmpty);
    expect(rec.calls(#drawCircle), hasLength(1));
    expect(rec.calls(#drawArc), hasLength(1));
  });

  test('stroked rounded rects and ovals become enlarged paths', () {
    final _Recorder rec = _Recorder();
    final SmoothStrokeCanvas canvas = SmoothStrokeCanvas(rec);
    canvas.drawRRect(
      RRect.fromLTRBR(.2, .2, .8, .8, const Radius.circular(.1)),
      _stroke(.02),
    );
    canvas.drawOval(const Rect.fromLTWH(.2, .3, .6, .4), _stroke(.02));

    expect(rec.calls(#drawRRect), isEmpty);
    expect(rec.calls(#drawOval), isEmpty);
    expect(rec.paths, hasLength(2));
    for (final drawn in rec.paths) {
      expect(drawn.bounds.width, closeTo(.6 * k, 1e-3));
    }
  });

  test('every accessory a creature wears is stroked enlarged', () {
    final spec = kWorlds.first.creatures.first;
    for (final AccessoryType type in AccessoryType.values) {
      final _Recorder rec = _Recorder();
      CreaturePainter(spec, accessory: type).paint(rec, const Size(96, 96));
      // Accessories on a creature are drawn in its unit layout, so a stroke
      // left at that size spans a unit or two at most.
      for (final drawn in rec.paths) {
        if (drawn.style != PaintingStyle.stroke) continue;
        expect(drawn.bounds.longestSide, greaterThan(8), reason: '$type');
      }
      for (final Symbol name in <Symbol>[#drawRRect, #drawOval, #drawDRRect]) {
        for (final Invocation call in rec.calls(name)) {
          final Paint paint = call.positionalArguments.last as Paint;
          expect(paint.style, PaintingStyle.fill, reason: '$type $name');
        }
      }
    }
  });
}
