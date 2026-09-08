import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/stepped_animation.dart';
import '../data/worlds.dart';

/// The scenery behind a meadow.
///
/// Like the creatures, this is drawn entirely from code: every layer is derived
/// from the meadow's own palette, so a new world gets a matching sky, horizon
/// and weather for free. Only the *style* of each flourish is chosen per world.
///
/// The static layers sit behind a [RepaintBoundary] and the drifting motes get
/// their own painter, so the slow ambient animation never repaints the hills.
class MeadowBackdrop extends StatefulWidget {
  const MeadowBackdrop({super.key, required this.world, required this.child});

  final World world;
  final Widget child;

  @override
  State<MeadowBackdrop> createState() => _MeadowBackdropState();
}

class _MeadowBackdropState extends State<MeadowBackdrop>
    with SingleTickerProviderStateMixin {
  // Long and prime-ish so nothing visibly loops with the creature idles.
  static const Duration _cycle = Duration(seconds: 23);

  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: _cycle,
  )..repeat();

  /// The motes cover the whole screen, so every distinct value of this is a
  /// full-screen layer redrawn and re-uploaded. At the refresh rate that is
  /// the most expensive thing in the app for the least visible motion: a mote
  /// crosses the meadow in half a minute.
  late final SteppedAnimation _driftClock =
      SteppedAnimation.fps(_drift, cycle: _cycle);

  @override
  void dispose() {
    _driftClock.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _Scene scene = _sceneFor(widget.world.id);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        RepaintBoundary(
          child: CustomPaint(
            painter: _ScenePainter(widget.world, scene),
            size: Size.infinite,
            isComplex: true,
          ),
        ),
        if (scene.motes != _Motes.none)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _driftClock,
              builder: (BuildContext context, Widget? _) => CustomPaint(
                painter: _MotesPainter(widget.world, scene, _driftClock.value),
                size: Size.infinite,
                willChange: true,
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

// --------------------------------------------------------------- scene setup

/// The flourish drawn high in the sky.
enum _Sky { sun, moon, shafts, aurora, haze }

/// Silhouette of the land along the horizon.
enum _Ridge { rolling, jagged }

/// Slow ambient particles.
enum _Motes { none, fireflies, bubbles, sparkles, ash, pollen }

class _Scene {
  const _Scene(this.sky, this.ridge, this.motes, {this.flora = false});

  final _Sky sky;
  final _Ridge ridge;
  final _Motes motes;

  /// Tufts and blooms dotted along the horizon.
  final bool flora;
}

_Scene _sceneFor(String worldId) => switch (worldId) {
      'day' => const _Scene(_Sky.sun, _Ridge.rolling, _Motes.pollen, flora: true),
      'night' =>
        const _Scene(_Sky.moon, _Ridge.rolling, _Motes.fireflies, flora: true),
      'water' => const _Scene(_Sky.shafts, _Ridge.rolling, _Motes.bubbles),
      'mythical' =>
        const _Scene(_Sky.aurora, _Ridge.rolling, _Motes.sparkles, flora: true),
      'prehistoric' => const _Scene(_Sky.haze, _Ridge.jagged, _Motes.ash),
      _ => const _Scene(_Sky.sun, _Ridge.rolling, _Motes.none),
    };

/// Where the land meets the sky, as a fraction of the meadow's height.
const double _kHorizon = .46;

/// Lightens ([amount] > 0) or darkens ([amount] < 0) without shifting hue.
Color _shade(Color c, double amount) {
  final HSLColor hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

// ------------------------------------------------------------ static scenery

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.world, this.scene);

  final World world;
  final _Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double horizon = size.height * _kHorizon;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[world.skyTop, world.skyBottom],
        ).createShader(rect),
    );

    switch (scene.sky) {
      case _Sky.sun:
        _drawSun(canvas, size);
      case _Sky.moon:
        _drawStars(canvas, size, horizon);
        _drawMoon(canvas, size);
      case _Sky.shafts:
        _drawShafts(canvas, size);
      case _Sky.aurora:
        _drawStars(canvas, size, horizon);
        _drawAurora(canvas, size);
      case _Sky.haze:
        _drawHaze(canvas, size);
    }

    _drawClouds(canvas, size, horizon);

    // Three land layers, each darker and closer than the one behind it, so the
    // meadow reads as depth rather than a flat colour block.
    _drawLand(canvas, size, horizon - size.height * .05, .16, 2.2, 11);
    _drawLand(canvas, size, horizon, .09, 3.1, 29);
    _drawLand(canvas, size, horizon + size.height * .06, .0, 4.3, 47);

    if (scene.flora) _drawFlora(canvas, size, horizon + size.height * .06);

    // A soft vignette settles the edges and lifts the board off the scenery.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: .95,
          colors: <Color>[
            Colors.transparent,
            Colors.black.withValues(alpha: .16),
          ],
          stops: const <double>[.55, 1],
        ).createShader(rect),
    );
  }

  // ------------------------------------------------------------------- sky

  void _drawSun(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * .78, size.height * .11);
    final double r = size.width * .11;
    canvas.drawCircle(
      c,
      r * 3.4,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: .55),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r * 3.4)),
    );
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: .92));
  }

  void _drawMoon(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * .76, size.height * .12);
    final double r = size.width * .095;
    canvas.drawCircle(
      c,
      r * 3.0,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: .30),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r * 3.0)),
    );
    // A crescent, cut rather than drawn, keeps the edge perfectly round.
    final Path crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()
        ..addOval(
          Rect.fromCircle(center: c.translate(r * .46, -r * .28), radius: r * .92),
        ),
    );
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFFFF6DA));
  }

  void _drawStars(Canvas canvas, Size size, double horizon) {
    final math.Random rng = math.Random(world.id.hashCode ^ 0x5EED);
    final Paint paint = Paint()..color = Colors.white;
    for (int i = 0; i < 60; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = rng.nextDouble() * horizon * .92;
      final double r = .6 + rng.nextDouble() * 1.5;
      paint.color = Colors.white.withValues(alpha: .25 + rng.nextDouble() * .55);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _drawShafts(Canvas canvas, Size size) {
    // Underwater light: wide, near-vertical wedges falling from the surface.
    final math.Random rng = math.Random(world.id.hashCode ^ 0xBEEF);
    for (int i = 0; i < 5; i++) {
      final double x = size.width * (.06 + i * .21 + rng.nextDouble() * .05);
      final double top = size.width * (.05 + rng.nextDouble() * .05);
      final double lean = size.width * .10;
      final double len = size.height * (.5 + rng.nextDouble() * .25);
      final Path shaft = Path()
        ..moveTo(x - top, 0)
        ..lineTo(x + top, 0)
        ..lineTo(x + top + lean, len)
        ..lineTo(x - top + lean, len)
        ..close();
      canvas.drawPath(
        shaft,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.white.withValues(alpha: .22),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, len))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  void _drawAurora(Canvas canvas, Size size) {
    for (int band = 0; band < 3; band++) {
      final double baseY = size.height * (.10 + band * .07);
      final double amp = size.height * (.035 + band * .012);
      final Path ribbon = Path()..moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += size.width / 40) {
        ribbon.lineTo(
          x,
          baseY + math.sin(x / size.width * math.pi * 2.4 + band) * amp,
        );
      }
      for (double x = size.width; x >= 0; x -= size.width / 40) {
        ribbon.lineTo(
          x,
          baseY +
              size.height * .055 +
              math.sin(x / size.width * math.pi * 2.4 + band) * amp,
        );
      }
      ribbon.close();
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              world.accent.withValues(alpha: .0),
              world.accent.withValues(alpha: .30),
              Colors.white.withValues(alpha: .34),
              world.accent.withValues(alpha: .0),
            ],
          ).createShader(Offset.zero & size)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  void _drawHaze(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * .68, size.height * .18);
    canvas.drawCircle(
      c,
      size.width * .42,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: .42),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: size.width * .42)),
    );
  }

  void _drawClouds(Canvas canvas, Size size, double horizon) {
    if (scene.sky == _Sky.shafts) return;
    final math.Random rng = math.Random(world.id.hashCode ^ 0xC10D);
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: scene.sky == _Sky.moon ? .10 : .28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (int i = 0; i < 4; i++) {
      final double cx = rng.nextDouble() * size.width;
      final double cy = horizon * (.20 + rng.nextDouble() * .58);
      final double w = size.width * (.16 + rng.nextDouble() * .16);
      for (int puff = 0; puff < 3; puff++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + (puff - 1) * w * .42, puff.isEven ? cy : cy - 2),
            width: w * (puff == 1 ? 1.0 : .72),
            height: w * (puff == 1 ? .46 : .34),
          ),
          paint,
        );
      }
    }
  }

  // ------------------------------------------------------------------ land

  void _drawLand(
    Canvas canvas,
    Size size,
    double baseY,
    double lighten,
    double waves,
    int seed,
  ) {
    final Color color = _shade(world.ground, lighten);
    final Path land = Path()..moveTo(0, baseY);

    switch (scene.ridge) {
      case _Ridge.rolling:
        final double amp = size.height * .035 * (1 + lighten * 2);
        final double step = size.width / 48;
        for (double x = 0; x <= size.width; x += step) {
          final double p = x / size.width;
          land.lineTo(
            x,
            baseY -
                amp * (math.sin(p * math.pi * waves + seed) * .5 + .5) -
                amp * .35 * math.sin(p * math.pi * waves * 2.7 + seed),
          );
        }
      case _Ridge.jagged:
        final math.Random rng = math.Random(seed);
        const int peaks = 7;
        for (int i = 0; i <= peaks; i++) {
          final double x = size.width * i / peaks;
          final double h = size.height * (.02 + rng.nextDouble() * .06);
          land.lineTo(x, baseY - (i.isEven ? h : h * .25));
        }
    }

    land
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      land,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[color, _shade(color, -.07)],
        ).createShader(Rect.fromLTWH(0, baseY - 40, size.width, size.height)),
    );
  }

  void _drawFlora(Canvas canvas, Size size, double baseY) {
    final math.Random rng = math.Random(world.id.hashCode ^ 0xF10A);
    final Color blade = _shade(world.ground, -.13);
    final Paint bladePaint = Paint()
      ..color = blade
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .006;

    for (int i = 0; i < 26; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = baseY + rng.nextDouble() * size.height * .10;
      final double h = size.height * (.012 + rng.nextDouble() * .016);
      for (int b = -1; b <= 1; b++) {
        canvas.drawPath(
          Path()
            ..moveTo(x + b * h * .30, y)
            ..quadraticBezierTo(x + b * h * .55, y - h * .6, x + b * h * .95, y - h),
          bladePaint,
        );
      }
      // Every few tufts, a bloom in the meadow's accent colour.
      if (i % 5 == 0) {
        final Offset c = Offset(x + h * .4, y - h * 1.15);
        final double r = h * .26;
        final Paint petal = Paint()..color = world.accent.withValues(alpha: .85);
        for (int p = 0; p < 5; p++) {
          final double a = p * math.pi * 2 / 5;
          canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, r * .8, petal);
        }
        canvas.drawCircle(c, r * .62, Paint()..color = const Color(0xFFFFE9A3));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.world.id != world.id || old.scene != scene;
}

// -------------------------------------------------------------------- motes

class _MotesPainter extends CustomPainter {
  const _MotesPainter(this.world, this.scene, this.t);

  final World world;
  final _Scene scene;

  /// 0..1, wrapping. Every mote derives its position from this plus a per-mote
  /// offset, so the loop never snaps.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Reseeded every frame, so each mote keeps its own lane and speed.
    final math.Random rng = math.Random(world.id.hashCode ^ 0x770735);
    final int count = switch (scene.motes) {
      _Motes.bubbles => 22,
      _Motes.fireflies => 16,
      _Motes.sparkles => 20,
      _Motes.ash => 26,
      _Motes.pollen => 18,
      _Motes.none => 0,
    };

    for (int i = 0; i < count; i++) {
      final double lane = rng.nextDouble();
      final double phase = rng.nextDouble();
      final double speed = .6 + rng.nextDouble() * .8;
      final double scale = .5 + rng.nextDouble() * .9;
      final double p = (t * speed + phase) % 1.0;
      final double sway =
          math.sin((p + phase) * math.pi * 2 * 2) * size.width * .035;

      switch (scene.motes) {
        case _Motes.bubbles:
          final Offset c =
              Offset(lane * size.width + sway, size.height * (1 - p));
          final double r = size.width * .008 * scale + 1.5;
          canvas.drawCircle(
            c,
            r,
            Paint()
              ..color = Colors.white.withValues(alpha: .30)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2,
          );
          canvas.drawCircle(
            c.translate(-r * .32, -r * .32),
            r * .28,
            Paint()..color = Colors.white.withValues(alpha: .55),
          );

        case _Motes.fireflies:
          // Fireflies wander in the lower half, where the meadow is dark.
          final Offset c = Offset(
            lane * size.width + sway * 2,
            size.height * (.34 + .62 * ((p * 1.3 + phase) % 1.0)),
          );
          final double glow = math.sin(p * math.pi * 2 * 3) * .5 + .5;
          final double r = 2.2 * scale + 1;
          canvas.drawCircle(
            c,
            r * 4,
            Paint()
              ..color = const Color(0xFFFFE083).withValues(alpha: .22 * glow),
          );
          canvas.drawCircle(
            c,
            r,
            Paint()
              ..color = const Color(0xFFFFF3C4).withValues(alpha: .35 + .6 * glow),
          );

        case _Motes.sparkles:
          final Offset c = Offset(
            lane * size.width + sway,
            size.height * (1 - p) * .9,
          );
          final double twinkle =
              math.sin((p + phase) * math.pi * 2 * 4) * .5 + .5;
          _star(canvas, c, (3.0 * scale + 1) * (.4 + twinkle),
              Colors.white.withValues(alpha: .30 + .5 * twinkle));

        case _Motes.ash:
          final Offset c = Offset(
            (lane * size.width + p * size.width * .18) % size.width,
            size.height * p,
          );
          canvas.drawCircle(
            c,
            1.4 * scale + .6,
            Paint()..color = const Color(0xFFE8D5C0).withValues(alpha: .34),
          );

        case _Motes.pollen:
          final Offset c = Offset(
            lane * size.width + sway,
            size.height * (1 - p) * .95,
          );
          canvas.drawCircle(
            c,
            1.8 * scale + .8,
            Paint()..color = Colors.white.withValues(alpha: .34),
          );

        case _Motes.none:
          break;
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final Path path = Path();
    for (int i = 0; i < 8; i++) {
      final double a = i * math.pi / 4;
      final double rr = i.isEven ? r : r * .34;
      final Offset p = c + Offset(math.cos(a), math.sin(a)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MotesPainter old) =>
      old.t != t || old.world.id != world.id;
}
