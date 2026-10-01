import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// A canvas that keeps stroked curves smooth on Impeller.
///
/// Impeller, the renderer on Android and iOS, flattens a stroked curve into
/// straight segments as though one unit of its path were one pixel, whatever
/// the canvas is scaled by. The creatures and their accessories are drawn in a
/// unit square and scaled up to the tile, so a curve a third of a unit long
/// came out as two straight lines and every outline as a polygon. Fills,
/// clips, circles and arcs are flattened properly and need no help, and Skia
/// (which `flutter test` renders with) draws all of it smoothly anyway.
///
/// Everything passes straight through to the wrapped canvas except stroked
/// paths, ovals and rounded rects. Those are drawn [enlarge] times their size
/// under a matching 1 / [enlarge] scale: the same picture, but with curves long
/// enough in their own units for Impeller to flatten finely.
class SmoothStrokeCanvas implements Canvas {
  SmoothStrokeCanvas(this._canvas, {this.enlarge = unit})
    : _up = Float64List.fromList(<double>[
        enlarge, 0, 0, 0, //
        0, enlarge, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]);

  final Canvas _canvas;

  /// How much stroked geometry is enlarged before it is drawn: at least as
  /// many device pixels as one unit of the canvas will ever span. Overshooting
  /// costs a few extra segments, undershooting brings the corners back.
  final double enlarge;

  /// The [enlarge] for art drawn in a unit square: more pixels than any
  /// creature is ever shown at.
  static const double unit = 1024;

  /// The [enlarge] for art drawn in logical pixels: the densest screens.
  static const double logical = 4;

  final Float64List _up;

  /// Whether [paint] needs drawing at the enlarged size. A shader or mask
  /// filter is laid out in the canvas's own units, and would be pulled out of
  /// place by the rescale, so those strokes are left as they are.
  static bool _enlarges(Paint paint) =>
      paint.style == PaintingStyle.stroke &&
      paint.shader == null &&
      paint.maskFilter == null;

  void _stroke(Path path, Paint paint) {
    final double width = paint.strokeWidth;
    _canvas.save();
    _canvas.scale(1 / enlarge);
    // The paint is the caller's and may be drawn with again, so its width is
    // put back once the call has copied it.
    paint.strokeWidth = width * enlarge;
    _canvas.drawPath(path.transform(_up), paint);
    paint.strokeWidth = width;
    _canvas.restore();
  }

  // ------------------------------------------------------------ the fix

  @override
  void drawPath(Path path, Paint paint) =>
      _enlarges(paint) ? _stroke(path, paint) : _canvas.drawPath(path, paint);

  @override
  void drawRRect(RRect rrect, Paint paint) => _enlarges(paint)
      ? _stroke(Path()..addRRect(rrect), paint)
      : _canvas.drawRRect(rrect, paint);

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) => _enlarges(paint)
      ? _stroke(
          Path()
            ..addRRect(outer)
            ..addRRect(inner),
          paint,
        )
      : _canvas.drawDRRect(outer, inner, paint);

  @override
  void drawRSuperellipse(ui.RSuperellipse rsuperellipse, Paint paint) =>
      _enlarges(paint)
      ? _stroke(Path()..addRSuperellipse(rsuperellipse), paint)
      : _canvas.drawRSuperellipse(rsuperellipse, paint);

  @override
  void drawOval(Rect rect, Paint paint) => _enlarges(paint)
      ? _stroke(Path()..addOval(rect), paint)
      : _canvas.drawOval(rect, paint);

  // ------------------------------------------------------ pass-through

  @override
  void save() => _canvas.save();

  @override
  void saveLayer(Rect? bounds, Paint paint) => _canvas.saveLayer(bounds, paint);

  @override
  void restore() => _canvas.restore();

  @override
  void restoreToCount(int count) => _canvas.restoreToCount(count);

  @override
  int getSaveCount() => _canvas.getSaveCount();

  @override
  void translate(double dx, double dy) => _canvas.translate(dx, dy);

  @override
  void scale(double sx, [double? sy]) => _canvas.scale(sx, sy);

  @override
  void rotate(double radians) => _canvas.rotate(radians);

  @override
  void skew(double sx, double sy) => _canvas.skew(sx, sy);

  @override
  void transform(Float64List matrix4) => _canvas.transform(matrix4);

  @override
  Float64List getTransform() => _canvas.getTransform();

  @override
  void clipRect(
    Rect rect, {
    ui.ClipOp clipOp = ui.ClipOp.intersect,
    bool doAntiAlias = true,
  }) => _canvas.clipRect(rect, clipOp: clipOp, doAntiAlias: doAntiAlias);

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) =>
      _canvas.clipRRect(rrect, doAntiAlias: doAntiAlias);

  @override
  void clipRSuperellipse(
    ui.RSuperellipse rsuperellipse, {
    bool doAntiAlias = true,
  }) => _canvas.clipRSuperellipse(rsuperellipse, doAntiAlias: doAntiAlias);

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) =>
      _canvas.clipPath(path, doAntiAlias: doAntiAlias);

  @override
  Rect getLocalClipBounds() => _canvas.getLocalClipBounds();

  @override
  Rect getDestinationClipBounds() => _canvas.getDestinationClipBounds();

  @override
  void drawColor(Color color, BlendMode blendMode) =>
      _canvas.drawColor(color, blendMode);

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) =>
      _canvas.drawLine(p1, p2, paint);

  @override
  void drawPaint(Paint paint) => _canvas.drawPaint(paint);

  @override
  void drawRect(Rect rect, Paint paint) => _canvas.drawRect(rect, paint);

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      _canvas.drawCircle(c, radius, paint);

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) => _canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);

  @override
  void drawImage(ui.Image image, Offset offset, Paint paint) =>
      _canvas.drawImage(image, offset, paint);

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) =>
      _canvas.drawImageRect(image, src, dst, paint);

  @override
  void drawImageNine(ui.Image image, Rect center, Rect dst, Paint paint) =>
      _canvas.drawImageNine(image, center, dst, paint);

  @override
  void drawPicture(ui.Picture picture) => _canvas.drawPicture(picture);

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) =>
      _canvas.drawParagraph(paragraph, offset);

  @override
  void drawPoints(ui.PointMode pointMode, List<Offset> points, Paint paint) =>
      _canvas.drawPoints(pointMode, points, paint);

  @override
  void drawRawPoints(ui.PointMode pointMode, Float32List points, Paint paint) =>
      _canvas.drawRawPoints(pointMode, points, paint);

  @override
  void drawVertices(ui.Vertices vertices, BlendMode blendMode, Paint paint) =>
      _canvas.drawVertices(vertices, blendMode, paint);

  @override
  void drawAtlas(
    ui.Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) => _canvas.drawAtlas(
    atlas,
    transforms,
    rects,
    colors,
    blendMode,
    cullRect,
    paint,
  );

  @override
  void drawRawAtlas(
    ui.Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) => _canvas.drawRawAtlas(
    atlas,
    rstTransforms,
    rects,
    colors,
    blendMode,
    cullRect,
    paint,
  );

  @override
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) => _canvas.drawShadow(path, color, elevation, transparentOccluder);
}
