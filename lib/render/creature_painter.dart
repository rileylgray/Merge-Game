import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/accessory.dart';
import '../data/creature_spec.dart';
import 'accessory_painter.dart';
import 'shading.dart';

/// Paints a [CreatureSpec] as fully procedural vector art.
///
/// The whole cast is drawn from code, which keeps every creature stylistically
/// consistent, crisp at any resolution and free of app-size cost. Layout is
/// normalised to a unit square and scaled to whatever box it is given, so the
/// same painter serves the 56px board tiles and the 260px collection hero.
///
/// Anatomy is built from two masses — a head and a torso — that are unioned
/// into one silhouette and lit as a single form, then separated again by a soft
/// occlusion crescent under the jaw. Drawing one merged shape keeps the light
/// consistent and leaves no seam, while the crescent is what makes a creature
/// read as an animal with a head rather than a decorated egg.
class CreaturePainter extends CustomPainter {
  const CreaturePainter(
    this.spec, {
    this.shadow = true,
    this.body = true,
    this.bob = 0,
    this.blink = 1,
    this.accessory,
  });

  final CreatureSpec spec;

  /// Worn over the finished creature, or null for an undressed one.
  final AccessoryType? accessory;

  /// Soft contact shadow under the creature.
  final bool shadow;

  /// The creature itself. Switching it off leaves nothing but the shadow.
  ///
  /// The two halves are separable because the body is the expensive one — a few
  /// dozen paths, gradients and blurs — and the only thing the idle does to it
  /// is slide it up and down. Drawn into its own layer it can be rastered once
  /// and merely nudged thereafter, while the shadow stays put on the ground.
  final bool body;

  /// -1..1 idle bob offset, applied to everything except the shadow.
  final double bob;

  /// 1 = eyes open, 0 = fully closed.
  final double blink;

  /// Margin left around the art so wings, tails and horns stay inside the tile.
  static const double kSafe = 0.93;

  /// How far [bob] of 1 lifts the body, as a fraction of the paint box's short
  /// side. Public so a caller that would rather translate the body itself lands
  /// it in exactly the same place.
  static const double bobTravel = 0.022 * kSafe;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    canvas.translate(s * (1 - kSafe) / 2, s * (1 - kSafe) / 2);
    canvas.scale(kSafe);

    final _Anatomy a = _anatomy(spec, s);

    if (shadow) _drawShadow(canvas, s, a);

    if (!body) {
      canvas.restore();
      return;
    }

    final _Rng rng = _Rng(spec.id.hashCode);

    canvas.save();
    canvas.translate(0, bob * s * 0.022);

    final AccessoryAnchor? worn = accessory == null ? null : _anchor(s, a);
    if (worn != null) AccessoryArt.paintBack(canvas, s, accessory, worn);

    _drawBackAccent(canvas, s, a);
    _drawWings(canvas, s, a);
    _drawTail(canvas, s, a);
    _drawBackCrest(canvas, s, a);
    _drawEars(canvas, s, a);
    _drawLimbs(canvas, s, a, back: true);

    _drawMass(canvas, s, a);
    _drawPattern(canvas, s, a, rng);
    _drawNeck(canvas, s, a);
    _drawMassLight(canvas, s, a);
    // A carapace sits on top of the coat's light, not under it — run beneath
    // the rim light it picks up the body's highlight and contour, and the
    // whole shell looks transparent.
    _drawShell(canvas, s, a);
    _drawShellSpiral(canvas, s, a);

    _drawLimbs(canvas, s, a, back: false);
    _drawSnout(canvas, s, a);
    _drawFace(canvas, s, a);
    _drawFrontCrest(canvas, s, a);
    _drawFrontAccent(canvas, s, a);
    if (worn != null) AccessoryArt.paintFront(canvas, s, accessory, worn);

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CreaturePainter old) =>
      old.spec.id != spec.id ||
      old.bob != bob ||
      old.blink != blink ||
      old.shadow != shadow ||
      old.body != body ||
      old.accessory != accessory;

  // ------------------------------------------------------------------- coat

  /// How the surface is drawn: fur gets a tufted silhouette edge, feathers get
  /// broad scallops, scales get a specular sheen. Derived from the spec rather
  /// than declared, so the existing creature definitions need no changes.
  _Coat get _coat => _coatOf(spec);

  static _Coat _coatOf(CreatureSpec spec) {
    switch (spec.body) {
      case BodyShape.bird:
        return _Coat.feather;
      case BodyShape.finned:
      case BodyShape.serpent:
        return _Coat.scale;
      case BodyShape.bug:
      case BodyShape.shell:
      case BodyShape.star:
        return _Coat.smooth;
      case BodyShape.drop:
        return _Coat.slime;
      default:
        break;
    }
    // A beak alone does not make a bird: it also belongs to ceratopsians,
    // seahorses and dolphins. Wings or talons are what settle it.
    if ((spec.snout == SnoutType.beakSmall ||
            spec.snout == SnoutType.beakLong) &&
        (spec.limbs == LimbType.talons || spec.wings != WingType.none)) {
      return _Coat.feather;
    }
    if (spec.pattern == PatternType.scales) return _Coat.scale;
    // Thick hide, not coat: armour plating is skin, and an elephant given a
    // furred edge reads as a very large mouse.
    if (spec.pattern == PatternType.plates) return _Coat.smooth;
    if (spec.snout == SnoutType.trunk && spec.ears == EarType.fan) {
      return _Coat.smooth;
    }
    const Set<EarType> furry = <EarType>{
      EarType.roundSmall,
      EarType.roundBig,
      EarType.pointed,
      EarType.longUp,
      EarType.floppy,
      EarType.tufted,
      EarType.bunny,
      EarType.cat,
      EarType.fan,
    };
    if (furry.contains(spec.ears)) return _Coat.fur;
    if (spec.limbs == LimbType.paws || spec.limbs == LimbType.hooves) {
      return _Coat.fur;
    }
    // Deliberately no rule from the snout alone. A muzzle is not a mammal
    // signal — it also fits an ichthyostega, a stegosaurus and a walrus — and
    // treating it as one put a fur coat on half the fossil record.
    return _Coat.smooth;
  }

  // ---------------------------------------------------------------- geometry

  /// Layout is pure geometry and involves several path boolean ops, so results
  /// are memoised per creature and size. Idle animation repaints every frame
  /// at a handful of fixed sizes, so the hit rate is effectively 100%.
  static final Map<String, _Anatomy> _layoutCache = <String, _Anatomy>{};

  _Anatomy _anatomy(CreatureSpec spec, double s) {
    final String key = '${spec.id}@${s.toStringAsFixed(1)}';
    final _Anatomy? hit = _layoutCache[key];
    if (hit != null) return hit;
    // Bounded so a resize storm can't grow this without limit.
    if (_layoutCache.length > 256) _layoutCache.clear();
    return _layoutCache[key] = _layout(spec, s);
  }

  /// Translates anatomy into the handful of landmarks accessory art needs.
  AccessoryAnchor _anchor(double s, _Anatomy a) {
    final Rect b = a.bodyBounds;
    return AccessoryAnchor(
      headBounds: a.headBounds,
      headTop: Offset(
        a.headBounds.center.dx,
        a.headBounds.top - _hatClearance * s,
      ),
      faceCenter: a.faceCenter,
      faceRadius: a.faceRadius,
      bodyBounds: b,
      neckCenter: Offset(b.center.dx + a.lean, _collarY(a, b)),
      neckHalfWidth: a.halfW * .82,
      eyeSpacing: spec.eyeSpacing,
    );
  }

  /// Where a collar sits.
  ///
  /// The top of the torso is *behind the chin* on every separate-headed plan —
  /// a scarf tied there lands across the muzzle — so it drops to just under the
  /// jaw instead. Merged plans have no jaw to clear and keep the shoulder line,
  /// which on a fish or a jellyfish is exactly where a scarf should go.
  static double _collarY(_Anatomy a, Rect body) {
    final double shoulders = body.top + body.height * .13;
    // A head set forward of the body — fish, turtles — has its shoulder line
    // running straight across the snout, so the collar drops behind the face.
    if (a.headBounds.center.dx - (body.center.dx + a.lean) > body.width * .04) {
      return math.max(
        shoulders,
        a.headBounds.bottom - a.headBounds.height * .18,
      );
    }
    if (a.merged) return shoulders;
    return math.max(shoulders, a.headBounds.bottom + a.headBounds.height * .08);
  }

  /// How far above the skull a hat has to sit to clear what is already up
  /// there. Antlers still poke through a top hat, which is the joke; a hat
  /// planted *inside* the antlers just looks like a mistake.
  double get _hatClearance {
    const Set<CrestType> tall = <CrestType>{
      CrestType.antlers,
      CrestType.unicorn,
      CrestType.hornsCurved,
      CrestType.spikes,
      CrestType.sailFin,
      CrestType.flame,
      CrestType.lure,
      CrestType.crown,
      CrestType.starTuft,
      CrestType.mushroomCap,
      CrestType.crest,
      CrestType.shellSpiral,
    };
    const Set<EarType> upright = <EarType>{
      EarType.longUp,
      EarType.bunny,
      EarType.antenna,
      EarType.horn,
      EarType.feather,
    };
    double lift = 0;
    if (tall.contains(spec.crest)) lift += .055;
    if (upright.contains(spec.ears)) lift += .022;
    return lift;
  }

  /// Proportions for each silhouette, in unit coordinates before scaling.
  ///
  /// Heads are deliberately large — roughly a third of overall height — which
  /// is what reads as "cute" without tipping into caricature, and gives the
  /// face enough room for eyes that carry expression at 56px.
  static _Plan _plan(BodyShape shape) {
    switch (shape) {
      case BodyShape.blob:
        return const _Plan(
          bodyTop: .44,
          bodyBot: .885,
          halfW: .345,
          topRound: 1.06,
          botRound: 1.06,
          waist: .52,
          headCy: .335,
          headR: .255,
          headW: 1.06,
          headH: .96,
        );
      case BodyShape.egg:
        return const _Plan(
          bodyTop: .42,
          bodyBot: .885,
          halfW: .285,
          topRound: .92,
          botRound: 1.10,
          waist: .58,
          headCy: .315,
          headR: .235,
          headW: 1.04,
          headH: 1.0,
        );
      case BodyShape.pear:
        return const _Plan(
          bodyTop: .40,
          bodyBot: .89,
          halfW: .325,
          topRound: .70,
          botRound: 1.14,
          waist: .66,
          headCy: .285,
          headR: .215,
          headW: 1.06,
          headH: .98,
        );
      case BodyShape.tall:
        return const _Plan(
          bodyTop: .365,
          bodyBot: .885,
          halfW: .255,
          topRound: .95,
          botRound: 1.04,
          waist: .54,
          headCy: .245,
          headR: .205,
          headW: 1.05,
          headH: 1.0,
        );
      case BodyShape.wide:
        return const _Plan(
          bodyTop: .50,
          bodyBot: .885,
          halfW: .40,
          topRound: 1.02,
          botRound: 1.06,
          waist: .50,
          headCy: .385,
          headR: .245,
          headW: 1.08,
          headH: .94,
        );
      case BodyShape.bean:
        return const _Plan(
          bodyTop: .42,
          bodyBot: .885,
          halfW: .30,
          topRound: .95,
          botRound: 1.06,
          waist: .58,
          headCy: .30,
          headR: .225,
          headW: 1.04,
          headH: 1.0,
          lean: .030,
        );
      case BodyShape.chunky:
        return const _Plan(
          bodyTop: .42,
          bodyBot: .895,
          halfW: .365,
          topRound: .92,
          botRound: 1.06,
          waist: .56,
          headCy: .30,
          headR: .255,
          headW: 1.06,
          headH: .98,
        );
      case BodyShape.bird:
        return const _Plan(
          bodyTop: .40,
          bodyBot: .87,
          halfW: .275,
          topRound: .90,
          botRound: 1.12,
          waist: .60,
          headCy: .285,
          headR: .215,
          headW: 1.04,
          headH: 1.0,
        );
      case BodyShape.bug:
        return const _Plan(
          bodyTop: .46,
          bodyBot: .855,
          halfW: .30,
          topRound: 1.02,
          botRound: 1.02,
          waist: .50,
          headCy: .365,
          headR: .195,
          headW: 1.10,
          headH: .95,
        );
      case BodyShape.shell:
        // Dome of shell with the head out front and centred. The shell itself
        // is painted over the torso only, so the face never disappears under
        // it — a head buried behind the dome is what made the old turtles read
        // as a pebble with eyes.
        return const _Plan(
          bodyTop: .36,
          bodyBot: .885,
          halfW: .40,
          topRound: 1.18,
          botRound: .92,
          waist: .50,
          headCy: .665,
          headR: .195,
          headW: 1.04,
          headH: .98,
        );
      case BodyShape.finned:
        // Fish read as one fusiform mass; the head is the forward third.
        return const _Plan(
          bodyTop: .40,
          bodyBot: .84,
          halfW: .365,
          topRound: 1.05,
          botRound: 1.05,
          waist: .50,
          headCy: .565,
          headR: .215,
          headW: 1.0,
          headH: 1.0,
          headCx: .10,
          merged: true,
        );
      case BodyShape.serpent:
        // The head has to sink into the coil, not balance on it. At the old
        // proportions the bottom of the skull landed exactly on the top of the
        // body, so the two masses met at a single tangent point and the head
        // read as a loose ball resting on the animal. It also carries forward,
        // which puts the snout ahead of the coils where it belongs — and on a
        // snail leaves the back clear for the shell.
        return const _Plan(
          bodyTop: .575,
          bodyBot: .90,
          halfW: .40,
          topRound: 1.10,
          botRound: 1.02,
          waist: .50,
          headCy: .475,
          headR: .205,
          headW: 1.02,
          headH: 1.0,
          headCx: .16,
        );
      case BodyShape.drop:
        return const _Plan(
          bodyTop: .30,
          bodyBot: .87,
          halfW: .30,
          topRound: .52,
          botRound: 1.16,
          waist: .68,
          headCy: .50,
          headR: .225,
          headW: 1.0,
          headH: 1.0,
          merged: true,
        );
      case BodyShape.star:
        return const _Plan(
          bodyTop: .14,
          bodyBot: .90,
          halfW: .42,
          topRound: 1.0,
          botRound: 1.0,
          waist: .50,
          headCy: .52,
          headR: .21,
          headW: 1.0,
          headH: 1.0,
          merged: true,
        );
    }
  }

  static _Anatomy _layout(CreatureSpec spec, double s) {
    final _Plan p = _plan(spec.body);

    final double halfW = p.halfW * spec.widthScale * s;
    final double lean = p.lean * s;
    final double botY = p.bodyBot * s;

    // heightScale compresses everything toward the ground line, so a squat
    // variant keeps its feet planted instead of floating.
    double sy(double unitY) => botY - (botY - unitY * s) * spec.heightScale;

    final double topY = sy(p.bodyTop);
    const double cx = .5;
    final double bodyCx = cx * s;

    final Path body = spec.body == BodyShape.star
        ? _starBody(
            Offset(bodyCx, sy(p.bodyTop + (p.bodyBot - p.bodyTop) * .5)),
            halfW,
          )
        : _blobPath(
            cx: bodyCx,
            topY: topY,
            botY: botY,
            halfW: halfW,
            topRound: p.topRound,
            botRound: p.botRound,
            waist: p.waist,
            lean: lean,
          );

    // The head grows more slowly than the body under widthScale, so wide
    // creatures get a stout body rather than a balloon for a skull.
    final double headR = p.headR * s * math.pow(spec.widthScale, .55);
    final Offset headC = Offset(bodyCx + p.headCx * s + lean, sy(p.headCy));
    final Path head = Path()
      ..addOval(
        Rect.fromCenter(
          center: headC,
          width: headR * 2 * p.headW,
          height: headR * 2 * p.headH,
        ),
      );

    final Path silhouette = Path.combine(PathOperation.union, body, head);

    // Crescent of body left uncovered just below the head — the jaw shadow
    // that separates the two masses without a hard outline.
    final Path neck = Path.combine(
      PathOperation.difference,
      head.shift(Offset(0, headR * .30)),
      head.shift(Offset(0, -headR * .04)),
    );

    // Form lighting is built from two crescents: the sliver of the silhouette
    // that a copy shifted away from the key light leaves behind. Doing it with
    // path booleans keeps the terminator glued to the actual outline, which an
    // overlaid ellipse never manages on the odder body shapes.
    final double lift = halfW * .20;
    final Path rim = Path.combine(
      PathOperation.difference,
      silhouette,
      silhouette.shift(Offset(lift * .58, lift * .86)),
    );
    final Path occlusion = Path.combine(
      PathOperation.difference,
      silhouette,
      silhouette.shift(Offset(-lift * .40, -lift * 1.05)),
    );

    final double faceR = headR * .96;

    // Where a coat of quills is rooted. Sampling the real outline is what
    // keeps every spine attached: fitting an ellipse to the bounding box
    // instead left the side spines floating clear of the body and buried the
    // ones over the crown inside the skull.
    final List<_Bristle> bristles = <_Bristle>[];
    if (spec.crest == CrestType.spikes) {
      final Rect sb = silhouette.getBounds();
      // Down to the haunches, which is as far as a hedgehog's mantle of
      // spines reaches. Below that is bare belly.
      final double hemY = sb.top + sb.height * .74;
      for (final ui.PathMetric m in silhouette.computeMetrics()) {
        const int n = 96;
        for (int i = 0; i < n; i++) {
          final ui.Tangent? t = m.getTangentForOffset((i + .5) / n * m.length);
          if (t == null) continue;
          Offset nrm = Offset(t.vector.dy, -t.vector.dx);
          if (silhouette.contains(t.position + nrm * 2)) nrm = -nrm;
          if (t.position.dy > hemY || nrm.dy > .55) continue;
          bristles.add(_Bristle(t.position, math.atan2(nrm.dy, nrm.dx)));
        }
      }
      // Ordered around the coat so alternate ranks can be picked off evenly.
      bristles.sort((_Bristle x, _Bristle y) => x.angle.compareTo(y.angle));
    }

    // Where body markings are allowed to live. On a separate-headed creature
    // that is the chest and belly below the jaw — spread over the whole torso
    // the head eats the middle of every stripe and leaves stubs poking out
    // each side. Merged plans have no jaw, so the whole body stays available.
    final Rect bodyRect = Rect.fromLTRB(
      bodyCx - halfW,
      topY,
      bodyCx + halfW,
      botY,
    );
    final double headBot = head.getBounds().bottom;
    Rect markRect = bodyRect;
    if (!p.merged) {
      final double bandTop = math.max(topY, headBot - headR * .25);
      markRect = bandTop < botY - bodyRect.height * .30
          ? Rect.fromLTRB(bodyRect.left, bandTop, bodyRect.right, botY)
          : Rect.fromLTRB(
              bodyRect.left,
              botY - bodyRect.height * .55,
              bodyRect.right,
              botY,
            );
    }

    return _Anatomy(
      body: body,
      head: head,
      silhouette: silhouette,
      bristles: bristles,
      torso: Path.combine(PathOperation.difference, body, head),
      neck: neck,
      merged: p.merged,
      rim: rim,
      occlusion: occlusion,
      bounds: silhouette.getBounds(),
      bodyBounds: bodyRect,
      markRect: markRect,
      headBounds: head.getBounds(),
      faceCenter: Offset(headC.dx, headC.dy + headR * .06),
      faceRadius: faceR,
      headTop: Offset(headC.dx, headC.dy - headR * p.headH),
      headHalfWidth: headR * p.headW,
      halfW: halfW,
      lean: lean,
    );
  }

  /// Soft five-point star with rounded arms, for starfish and their kin.
  static Path _starBody(Offset c, double r) {
    final Path p = Path();
    const int points = 5;
    for (int i = 0; i < points; i++) {
      final double tipAng = -math.pi / 2 + i * 2 * math.pi / points;
      final double valleyAng = tipAng + math.pi / points;
      final Offset tip = Offset(
        c.dx + math.cos(tipAng) * r,
        c.dy + math.sin(tipAng) * r,
      );
      final Offset valley = Offset(
        c.dx + math.cos(valleyAng) * r * .46,
        c.dy + math.sin(valleyAng) * r * .46,
      );
      if (i == 0) p.moveTo(tip.dx, tip.dy);
      // Rounded arm: bulge outward on the way into each valley.
      p.quadraticBezierTo(
        c.dx + math.cos(tipAng + math.pi / points * .5) * r * .78,
        c.dy + math.sin(tipAng + math.pi / points * .5) * r * .78,
        valley.dx,
        valley.dy,
      );
      final double nextTip = tipAng + 2 * math.pi / points;
      p.quadraticBezierTo(
        c.dx + math.cos(nextTip - math.pi / points * .5) * r * .78,
        c.dy + math.sin(nextTip - math.pi / points * .5) * r * .78,
        c.dx + math.cos(nextTip) * r,
        c.dy + math.sin(nextTip) * r,
      );
    }
    return p..close();
  }

  /// Four-anchor cubic blob. Gives organic, squishy silhouettes that an
  /// ellipse or rounded rect never quite achieves.
  static Path _blobPath({
    required double cx,
    required double topY,
    required double botY,
    required double halfW,
    required double topRound,
    required double botRound,
    required double waist,
    double lean = 0,
  }) {
    final double midY = topY + (botY - topY) * waist;
    final double topH = midY - topY;
    final double botH = botY - midY;
    const double k = 0.5523;

    final Offset top = Offset(cx + lean, topY);
    final Offset bottom = Offset(cx - lean * .4, botY);
    final Offset right = Offset(cx + halfW + lean * .2, midY);
    final Offset left = Offset(cx - halfW + lean * .2, midY);

    final double kTopX = halfW * k * topRound;
    final double kTopY = topH * k * topRound;
    final double kBotX = halfW * k * botRound;
    final double kBotY = botH * k * botRound;

    return Path()
      ..moveTo(top.dx, top.dy)
      ..cubicTo(
        top.dx + kTopX,
        top.dy,
        right.dx,
        right.dy - kTopY,
        right.dx,
        right.dy,
      )
      ..cubicTo(
        right.dx,
        right.dy + kBotY,
        bottom.dx + kBotX,
        bottom.dy,
        bottom.dx,
        bottom.dy,
      )
      ..cubicTo(
        bottom.dx - kBotX,
        bottom.dy,
        left.dx,
        left.dy + kBotY,
        left.dx,
        left.dy,
      )
      ..cubicTo(
        left.dx,
        left.dy - kTopY,
        top.dx - kTopX,
        top.dy,
        top.dx,
        top.dy,
      )
      ..close();
  }

  // ------------------------------------------------------------------ paints

  Color get _body => spec.palette.body;
  Color get _belly => spec.palette.belly;
  Color get _accent => spec.palette.accent;
  Color get _detail => spec.palette.detail;
  Color get _line => _shade(_body, -.34);

  // Creatures and the accessories they wear have to sit in one light, so the
  // shading vocabulary is shared; these are the local names for it.
  Paint _fill(Color c) => fillOf(c);

  Paint _volume(Color c, Rect b, {double lift = .11, double drop = -.15}) =>
      volumeOf(c, b, lift: lift, drop: drop);

  /// Fill + matching contour for an appendage, so it reads as attached mass
  /// rather than a flat sticker floating beside the silhouette.
  void _part(
    Canvas canvas,
    double s,
    Path p,
    Color c, {
    double width = .011,
    double alpha = .42,
  }) {
    canvas.drawPath(p, _volume(c, p.getBounds()));
    canvas.drawPath(
      p,
      _stroke(_shade(c, -.34).withValues(alpha: alpha), s * width),
    );
  }

  Paint _stroke(Color c, double w) => strokeOf(c, w);

  static Color _shade(Color c, double amount) => shade(c, amount);

  // ------------------------------------------------------------------ layers

  /// A soft contact pool rather than a hard grey pill — a flat oval reads as a
  /// sticker edge under every creature.
  void _drawShadow(Canvas canvas, double s, _Anatomy a) {
    final Rect r = Rect.fromCenter(
      center: Offset(.5 * s, .928 * s),
      width: a.halfW * 2.15,
      height: s * .082,
    );
    const Color ink = Color(0xFF2C2A3A);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            ink.withValues(alpha: .26),
            ink.withValues(alpha: .15),
            ink.withValues(alpha: 0),
          ],
          stops: const <double>[0, .58, 1],
        ).createShader(r)
        ..isAntiAlias = true,
    );
  }

  void _drawMass(Canvas canvas, double s, _Anatomy a) {
    canvas.drawPath(
      a.silhouette,
      _volume(_body, a.bounds, lift: .13, drop: -.16),
    );

    // Ambient occlusion hugging the underside, so the mass has weight.
    canvas.save();
    canvas.clipPath(a.silhouette);
    final Color deep = _shade(_body, -.26);
    canvas.drawPath(
      a.occlusion,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            deep.withValues(alpha: 0),
            deep.withValues(alpha: .60),
          ],
          stops: const <double>[.15, 1],
        ).createShader(a.bounds)
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  /// The jaw shadow. Without it the head and body union back into one egg and
  /// every creature in the game reads as the same shape.
  void _drawNeck(Canvas canvas, double s, _Anatomy a) {
    if (a.merged) return;
    canvas.save();
    canvas.clipPath(a.silhouette);
    canvas.drawPath(
      a.neck,
      Paint()
        ..color = _shade(_body, -.30).withValues(alpha: .55)
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          a.faceRadius * .13,
        )
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  /// Rim light plus the silhouette contour. Runs after the pattern so markings
  /// sit inside the light instead of on top of it.
  void _drawMassLight(Canvas canvas, double s, _Anatomy a) {
    canvas.save();
    canvas.clipPath(a.silhouette);
    canvas.drawPath(
      a.rim,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: .50),
            Colors.white.withValues(alpha: .16),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const <double>[0, .40, .82],
        ).createShader(a.bounds)
        ..isAntiAlias = true,
    );

    // Scaly and slimy surfaces are wet: a tight specular sitting high on the
    // shoulder sells the material where a broad rim light cannot.
    final _Coat coat = _coat;
    if (coat == _Coat.scale || coat == _Coat.slime) {
      final Rect hi = Rect.fromCenter(
        center: Offset(
          a.bounds.left + a.bounds.width * .34,
          a.bounds.top + a.bounds.height * .22,
        ),
        width: a.bounds.width * .38,
        height: a.bounds.height * .20,
      );
      canvas.drawOval(
        hi,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              Colors.white.withValues(alpha: coat == _Coat.slime ? .55 : .40),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(hi)
          ..isAntiAlias = true,
      );
    }
    canvas.restore();

    canvas.drawPath(
      a.silhouette,
      _stroke(_line.withValues(alpha: .50), s * .014),
    );
  }

  /// Stripes that run the short way round the body — the direction real
  /// stripes take on a tiger, a zebra or a clownfish. Drawn as a rank of
  /// tapered bars fanning off the spine, longest over the middle of the flank.
  ///
  /// Horizontal bands are only right for a segmented abdomen, which is why a
  /// bee and a wasp get them and nothing with fur does: laid across a mammal
  /// they read as a rugby shirt rather than a coat.
  void _crossStripes(Canvas canvas, double s, Rect b, {required bool bold}) {
    final int n = bold ? 4 : 9;
    for (int i = 0; i < n; i++) {
      final double t = (i + .5) / n;
      final double x = b.left + b.width * t;
      // Bars splay away from the centre line, following the barrel of the body.
      final double lean = (t - .5) * b.width * (bold ? .20 : .34);
      final double len =
          b.height * (bold ? 1.20 : .60 + .34 * (1 - (t - .5).abs() * 2));
      final double w0 = b.width * (bold ? .11 : .038);
      final double w1 = b.width * (bold ? .10 : .017);
      canvas.drawPath(
        _taper(
          Offset(x, b.top - b.height * .06),
          Offset(x + lean * .45, b.top + len * .52),
          Offset(x + lean, b.top + len),
          w0,
          w1,
        ),
        _fill(_accent.withValues(alpha: bold ? .92 : .85)),
      );
    }
  }

  /// Segment bands for a jointed abdomen — bees, wasps, shrimp.
  void _bandStripes(Canvas canvas, double s, Rect b) {
    final Paint p = _stroke(_accent.withValues(alpha: .85), b.width * .095);
    for (int i = 0; i < 4; i++) {
      final double y = b.top + b.height * (.20 + i * .21);
      canvas.drawPath(
        Path()
          ..moveTo(b.left - 4, y)
          ..quadraticBezierTo(b.center.dx, y + b.height * .05, b.right + 4, y),
        p,
      );
    }
  }

  void _drawPattern(Canvas canvas, double s, _Anatomy a, _Rng rng) {
    if (spec.pattern == PatternType.none) return;

    // Freckles, masks and caps are face markings and belong on the head.
    // A dorsal stripe runs over both masses. Everything else clips to the
    // torso, so no stripe or spot ever crosses an eye or a mouth.
    const Set<PatternType> facial = <PatternType>{
      PatternType.freckles,
      PatternType.eyePatches,
      PatternType.topCap,
      PatternType.mask,
      PatternType.facialDisc,
    };
    canvas.save();
    canvas.clipPath(
      facial.contains(spec.pattern)
          ? a.head
          : spec.pattern == PatternType.dorsalStripe
          ? a.silhouette
          : a.torso,
    );
    final Rect b = a.markRect;

    switch (spec.pattern) {
      case PatternType.none:
        break;

      case PatternType.belly:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(b.center.dx, b.bottom - b.height * .34),
            width: b.width * .66,
            height: b.height * .74,
          ),
          _fill(_belly),
        );

      case PatternType.spots:
        // A spotted beetle also gets the seam between its wing cases, which is
        // most of what says "ladybird" rather than "red ball".
        if (spec.body == BodyShape.bug && spec.wings == WingType.none) {
          canvas.drawLine(
            Offset(b.center.dx, b.top - b.height * .10),
            Offset(b.center.dx, b.bottom),
            _stroke(_accent.withValues(alpha: .70), s * .014),
          );
        }
        for (int i = 0; i < 7; i++) {
          final double px = b.left + rng.next() * b.width;
          final double py = b.top + (.10 + rng.next() * .8) * b.height;
          canvas.drawCircle(
            Offset(px, py),
            b.width * (.045 + rng.next() * .045),
            _fill(_accent.withValues(alpha: .85)),
          );
        }

      case PatternType.stripes:
        // A segmented abdomen bands the long way; everything else is striped
        // across the barrel.
        if (spec.body == BodyShape.bug || spec.body == BodyShape.drop) {
          _bandStripes(canvas, s, b);
        } else {
          // Laid out over the whole torso rather than the marking band: the
          // head hides the middle of the rank, and starting below the jaw left
          // a zebra with two bars on each flank and nothing across the chest.
          _crossStripes(
            canvas,
            s,
            a.bodyBounds,
            bold:
                spec.body == BodyShape.finned || spec.body == BodyShape.serpent,
          );
        }

      case PatternType.patches:
        // Enough of them to read as a coat rather than three stains — a
        // giraffe with three blotches is a giraffe nobody recognises.
        for (int i = 0; i < 6; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                b.left + (.12 + rng.next() * .76) * b.width,
                b.top + (.10 + rng.next() * .80) * b.height,
              ),
              width: b.width * (.22 + rng.next() * .14),
              height: b.height * (.15 + rng.next() * .11),
            ),
            _fill(_accent.withValues(alpha: .8)),
          );
        }

      case PatternType.scales:
        final Paint p = _stroke(_shade(_body, -.12), s * .011);
        for (int row = 0; row < 4; row++) {
          final double y = b.top + b.height * (.18 + row * .19);
          for (int col = 0; col < 4; col++) {
            final double x =
                b.left + b.width * (.12 + col * .25 + (row.isOdd ? .12 : 0));
            canvas.drawArc(
              Rect.fromCenter(
                center: Offset(x, y),
                width: b.width * .22,
                height: b.height * .16,
              ),
              math.pi,
              math.pi,
              false,
              p,
            );
          }
        }

      case PatternType.freckles:
        for (int i = 0; i < 6; i++) {
          canvas.drawCircle(
            Offset(
              a.faceCenter.dx +
                  (i.isEven ? -1 : 1) * a.faceRadius * (.5 + i * .07),
              a.faceCenter.dy + a.faceRadius * (.30 + (i ~/ 2) * .13),
            ),
            s * .009,
            _fill(_accent.withValues(alpha: .7)),
          );
        }

      case PatternType.swirl:
        final Path p = Path();
        final Offset c = Offset(b.center.dx, b.center.dy);
        for (double t = 0; t < math.pi * 3.4; t += .12) {
          final double r = b.width * .05 + t * b.width * .028;
          final Offset o = Offset(
            c.dx + math.cos(t) * r,
            c.dy + math.sin(t) * r * .8,
          );
          t == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(p, _stroke(_accent.withValues(alpha: .8), s * .018));

      case PatternType.stars:
        for (int i = 0; i < 5; i++) {
          _star(
            canvas,
            Offset(
              b.left + (.15 + rng.next() * .7) * b.width,
              b.top + (.15 + rng.next() * .75) * b.height,
            ),
            b.width * (.055 + rng.next() * .03),
            _fill(_accent),
          );
        }

      case PatternType.topCap:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(a.faceCenter.dx, a.headBounds.top),
            width: a.headBounds.width * 1.12,
            height: a.headBounds.height * .68,
          ),
          _fill(_accent.withValues(alpha: .9)),
        );

      case PatternType.plates:
        for (int i = 0; i < 3; i++) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(
                b.center.dx,
                b.bottom - b.height * (.12 + i * .26),
              ),
              width: b.width * (1.0 - i * .16),
              height: b.height * .40,
            ),
            math.pi,
            math.pi,
            false,
            _stroke(_shade(_body, -.14), s * .014),
          );
        }

      case PatternType.dapple:
        for (int i = 0; i < 9; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                b.left + rng.next() * b.width,
                b.top + (.08 + rng.next() * .85) * b.height,
              ),
              width: b.width * .12,
              height: b.height * .07,
            ),
            _fill(_belly.withValues(alpha: .75)),
          );
        }

      case PatternType.ringed:
        for (int i = 0; i < 3; i++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                b.center.dx,
                b.bottom - b.height * (.10 + i * .23),
              ),
              width: b.width * (1.05 - i * .1),
              height: b.height * .13,
            ),
            _fill(_accent.withValues(alpha: .7)),
          );
        }

      case PatternType.glowDots:
        for (int i = 0; i < 5; i++) {
          final Offset o = Offset(
            b.left + rng.next() * b.width,
            b.top + (.30 + rng.next() * .62) * b.height,
          );
          canvas.drawCircle(o, s * .024, _fill(_accent.withValues(alpha: .26)));
          canvas.drawCircle(o, s * .010, _fill(_accent));
        }

      case PatternType.eyePatches:
        // Panda patches are teardrops, wider at the top and raked outward —
        // an upright oval reads as a pair of goggles.
        final double eyeDx = a.faceRadius * .46 * spec.eyeSpacing;
        for (final int sign in const <int>[-1, 1]) {
          canvas.save();
          canvas.translate(
            a.faceCenter.dx + sign * eyeDx,
            a.faceCenter.dy - a.faceRadius * .08,
          );
          canvas.rotate(sign * .38);
          final double pw = a.faceRadius * .66;
          final double ph = a.faceRadius * .92;
          canvas.drawPath(
            Path()
              ..moveTo(0, -ph * .5)
              ..quadraticBezierTo(pw * .58, -ph * .34, pw * .40, ph * .18)
              ..quadraticBezierTo(pw * .22, ph * .52, 0, ph * .50)
              ..quadraticBezierTo(-pw * .40, ph * .46, -pw * .46, ph * .02)
              ..quadraticBezierTo(-pw * .52, -ph * .34, 0, -ph * .5)
              ..close(),
            _fill(_accent),
          );
          canvas.restore();
        }

      case PatternType.mask:
        // One band across both eyes, pinched over the bridge of the nose and
        // tapering to a point at each cheek — a raccoon's bandit stripe.
        final Offset f = a.faceCenter;
        final double r = a.faceRadius;
        final double dx = r * .46 * spec.eyeSpacing;
        final double ey = f.dy - r * .06;
        final Path p = Path()
          ..moveTo(f.dx - dx - r * .74, ey - r * .30)
          ..quadraticBezierTo(f.dx - dx * .30, ey - r * .40, f.dx, ey - r * .16)
          ..quadraticBezierTo(
            f.dx + dx * .30,
            ey - r * .40,
            f.dx + dx + r * .74,
            ey - r * .30,
          )
          ..quadraticBezierTo(
            f.dx + dx + r * .60,
            ey + r * .40,
            f.dx + dx * .40,
            ey + r * .34,
          )
          ..quadraticBezierTo(f.dx, ey + r * .12, f.dx - dx * .40, ey + r * .34)
          ..quadraticBezierTo(
            f.dx - dx - r * .60,
            ey + r * .40,
            f.dx - dx - r * .74,
            ey - r * .30,
          )
          ..close();
        canvas.drawPath(p, _fill(_accent));
        // Brow flash above the band, the pale line that gives it definition.
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawPath(
            Path()
              ..moveTo(f.dx + sign * dx * .30, ey - r * .40)
              ..quadraticBezierTo(
                f.dx + sign * dx,
                ey - r * .62,
                f.dx + sign * (dx + r * .56),
                ey - r * .44,
              ),
            _stroke(_belly.withValues(alpha: .70), s * .012),
          );
        }

      case PatternType.dorsalStripe:
        // Face blaze plus a pale band down each flank. Seen head-on that is
        // what a skunk or a badger actually shows; stripes converging on the
        // neck instead read as a harness.
        final Rect hb = a.headBounds;
        canvas.drawPath(
          Path()
            ..moveTo(hb.center.dx - hb.width * .15, hb.top - 2)
            ..lineTo(hb.center.dx + hb.width * .15, hb.top - 2)
            ..quadraticBezierTo(
              hb.center.dx + hb.width * .09,
              hb.center.dy - hb.height * .10,
              hb.center.dx,
              hb.center.dy + hb.height * .04,
            )
            ..quadraticBezierTo(
              hb.center.dx - hb.width * .09,
              hb.center.dy - hb.height * .10,
              hb.center.dx - hb.width * .15,
              hb.top - 2,
            )
            ..close(),
          _fill(_belly.withValues(alpha: .95)),
        );
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawPath(
            _taper(
              Offset(
                b.center.dx + sign * b.width * .27,
                b.top - b.height * .12,
              ),
              Offset(b.center.dx + sign * b.width * .33, b.center.dy),
              Offset(b.center.dx + sign * b.width * .35, b.bottom + 2),
              b.width * .090,
              b.width * .080,
            ),
            _fill(_belly.withValues(alpha: .95)),
          );
        }

      case PatternType.facialDisc:
        // Two overlapping heart lobes with a rim — the ruff that gathers sound
        // around an owl's eyes, and the single feature that says "owl".
        final Offset f = a.faceCenter;
        final double r = a.faceRadius;
        final double dx = r * .34 * spec.eyeSpacing;
        final Path disc = Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(f.dx - dx, f.dy - r * .06),
              width: r * 1.10,
              height: r * 1.46,
            ),
          )
          ..addOval(
            Rect.fromCenter(
              center: Offset(f.dx + dx, f.dy - r * .06),
              width: r * 1.10,
              height: r * 1.46,
            ),
          );
        canvas.drawPath(disc, _fill(_belly.withValues(alpha: .92)));
        canvas.drawPath(
          disc,
          _stroke(_shade(_accent, -.10).withValues(alpha: .60), s * .010),
        );

      case PatternType.rosettes:
        for (int i = 0; i < 7; i++) {
          final Offset c = Offset(
            b.left + (.08 + rng.next() * .84) * b.width,
            b.top + (.10 + rng.next() * .80) * b.height,
          );
          final double rr = b.width * (.070 + rng.next() * .035);
          // Broken ring: two arcs with a gap, which is what a rosette is.
          for (int k = 0; k < 2; k++) {
            canvas.drawArc(
              Rect.fromCircle(center: c, radius: rr),
              k * math.pi + .34,
              math.pi - .68,
              false,
              _stroke(_accent.withValues(alpha: .80), rr * .48),
            );
          }
          canvas.drawCircle(c, rr * .30, _fill(_accent.withValues(alpha: .45)));
        }
    }
    canvas.restore();
  }

  // -------------------------------------------------------------------- ears

  /// An ear with real thickness: an outer shell in body colour, an inner
  /// cavity inset from it, and a shadow where the cavity meets the rim. A flat
  /// disc with a smaller disc on top is the tell of amateur vector art.
  /// Ear colour. A creature wearing eye patches is a panda, and a panda's ears
  /// are the same black as the patches — leaving them white loses half the
  /// animal.
  Color get _earShell =>
      spec.pattern == PatternType.eyePatches ? _accent : _body;

  void _shellEar(
    Canvas canvas,
    double s,
    Path outer,
    Path inner, {
    Color? innerColor,
  }) {
    final Color oc = _earShell;
    canvas.drawPath(outer, _volume(oc, outer.getBounds(), lift: .16));
    canvas.drawPath(
      outer,
      _stroke(_shade(oc, -.34).withValues(alpha: .48), s * .011),
    );
    final Color ic = innerColor ?? (oc == _body ? _belly : _shade(oc, .18));
    canvas.drawPath(inner, _volume(_shade(ic, -.06), inner.getBounds()));
    // Cavity shading: the inner ear is a hollow, so it is darkest at the top
    // where the rim overhangs it.
    canvas.save();
    canvas.clipPath(inner);
    final Rect ib = inner.getBounds();
    canvas.drawRect(
      ib,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            _shade(ic, -.30).withValues(alpha: .70),
            _shade(ic, -.30).withValues(alpha: 0),
          ],
          stops: const <double>[0, .60],
        ).createShader(ib)
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  void _drawEars(Canvas canvas, double s, _Anatomy a) {
    if (spec.ears == EarType.none) return;
    final double hw = a.headHalfWidth;
    final Offset top = a.headTop;
    final Paint fill = _volume(_earShell, a.headBounds, lift: .14);
    final Paint line = _stroke(
      _shade(_earShell, -.34).withValues(alpha: .45),
      s * .011,
    );

    void pair(void Function(double sign) draw) {
      draw(-1);
      draw(1);
    }

    switch (spec.ears) {
      case EarType.none:
        break;

      case EarType.roundSmall:
        pair((double sign) {
          final Offset c = Offset(top.dx + sign * hw * .74, top.dy + hw * .18);
          _shellEar(
            canvas,
            s,
            Path()..addOval(Rect.fromCircle(center: c, radius: hw * .32)),
            Path()..addOval(
              Rect.fromCircle(
                center: Offset(c.dx, c.dy + hw * .04),
                radius: hw * .17,
              ),
            ),
          );
        });

      case EarType.roundBig:
        pair((double sign) {
          final Offset c = Offset(top.dx + sign * hw * .90, top.dy + hw * .34);
          _shellEar(
            canvas,
            s,
            Path()..addOval(Rect.fromCircle(center: c, radius: hw * .50)),
            Path()..addOval(
              Rect.fromCircle(
                center: Offset(c.dx + sign * hw * .03, c.dy + hw * .06),
                radius: hw * .29,
              ),
            ),
          );
        });

      case EarType.pointed:
      case EarType.cat:
        pair((double sign) {
          final double bx = top.dx + sign * hw * .52;
          // Cat ears curve on the outer edge and run straighter on the inner,
          // which is what gives the triangle its animal read.
          final Path p = Path()
            ..moveTo(bx - sign * hw * .34, top.dy + hw * .34)
            ..quadraticBezierTo(
              bx - sign * hw * .12,
              top.dy - hw * .48,
              bx + sign * hw * .18,
              top.dy - hw * .62,
            )
            ..quadraticBezierTo(
              bx + sign * hw * .46,
              top.dy - hw * .34,
              bx + sign * hw * .44,
              top.dy + hw * .18,
            )
            ..close();
          final Path ip = Path()
            ..moveTo(bx - sign * hw * .16, top.dy + hw * .26)
            ..quadraticBezierTo(
              bx - sign * hw * .02,
              top.dy - hw * .26,
              bx + sign * hw * .16,
              top.dy - hw * .38,
            )
            ..quadraticBezierTo(
              bx + sign * hw * .30,
              top.dy - hw * .18,
              bx + sign * hw * .28,
              top.dy + hw * .14,
            )
            ..close();
          _shellEar(canvas, s, p, ip, innerColor: _accent);
        });

      case EarType.longUp:
      case EarType.bunny:
        pair((double sign) {
          final Rect r = Rect.fromCenter(
            center: Offset(top.dx + sign * hw * .40, top.dy - hw * .48),
            width: hw * .44,
            height: hw * 1.46,
          );
          canvas.save();
          canvas.translate(r.center.dx, r.center.dy);
          canvas.rotate(sign * .18);
          canvas.translate(-r.center.dx, -r.center.dy);
          _shellEar(
            canvas,
            s,
            Path()..addOval(r),
            Path()..addOval(
              Rect.fromCenter(
                center: Offset(r.center.dx, r.center.dy + hw * .10),
                width: r.width * .48,
                height: r.height * .72,
              ),
            ),
            innerColor: _accent,
          );
          canvas.restore();
        });

      case EarType.floppy:
        pair((double sign) {
          // Hangs from the side of the skull and widens toward the tip, the
          // way weight actually pulls a soft ear down.
          final Path p = Path()
            ..moveTo(top.dx + sign * hw * .52, top.dy + hw * .22)
            ..quadraticBezierTo(
              top.dx + sign * hw * 1.34,
              top.dy + hw * .28,
              top.dx + sign * hw * 1.14,
              top.dy + hw * 1.36,
            )
            ..quadraticBezierTo(
              top.dx + sign * hw * .92,
              top.dy + hw * 1.66,
              top.dx + sign * hw * .70,
              top.dy + hw * 1.24,
            )
            ..quadraticBezierTo(
              top.dx + sign * hw * .56,
              top.dy + hw * .78,
              top.dx + sign * hw * .52,
              top.dy + hw * .22,
            )
            ..close();
          canvas.drawPath(p, fill);
          canvas.drawPath(p, line);
          canvas.save();
          canvas.clipPath(p);
          final Rect pb = p.getBounds();
          canvas.drawRect(
            pb,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  _shade(_body, -.24).withValues(alpha: .55),
                  _shade(_body, -.24).withValues(alpha: 0),
                ],
                stops: const <double>[0, .45],
              ).createShader(pb)
              ..isAntiAlias = true,
          );
          canvas.restore();
        });

      case EarType.tufted:
        pair((double sign) {
          final Path p = Path()
            ..moveTo(top.dx + sign * hw * .30, top.dy + hw * .28)
            ..quadraticBezierTo(
              top.dx + sign * hw * .34,
              top.dy - hw * .70,
              top.dx + sign * hw * .74,
              top.dy - hw * .34,
            )
            ..quadraticBezierTo(
              top.dx + sign * hw * .82,
              top.dy + hw * .18,
              top.dx + sign * hw * .30,
              top.dy + hw * .28,
            )
            ..close();
          canvas.drawPath(p, _volume(_accent, p.getBounds()));
          canvas.drawPath(p, line);
        });

      case EarType.sideFin:
        pair((double sign) {
          final Path p = Path()
            ..moveTo(
              a.faceCenter.dx + sign * a.faceRadius * .80,
              a.faceCenter.dy - a.faceRadius * .10,
            )
            ..quadraticBezierTo(
              a.faceCenter.dx + sign * a.faceRadius * 1.85,
              a.faceCenter.dy - a.faceRadius * .55,
              a.faceCenter.dx + sign * a.faceRadius * 1.58,
              a.faceCenter.dy + a.faceRadius * .58,
            )
            ..quadraticBezierTo(
              a.faceCenter.dx + sign * a.faceRadius * 1.10,
              a.faceCenter.dy + a.faceRadius * .34,
              a.faceCenter.dx + sign * a.faceRadius * .80,
              a.faceCenter.dy - a.faceRadius * .10,
            )
            ..close();
          canvas.drawPath(p, _volume(_belly, p.getBounds()));
          canvas.drawPath(p, line);
          // Fin rays.
          for (int i = 0; i < 3; i++) {
            canvas.drawPath(
              Path()
                ..moveTo(
                  a.faceCenter.dx + sign * a.faceRadius * .95,
                  a.faceCenter.dy - a.faceRadius * (.02 - i * .10),
                )
                ..lineTo(
                  a.faceCenter.dx + sign * a.faceRadius * 1.50,
                  a.faceCenter.dy - a.faceRadius * (.30 - i * .30),
                ),
              _stroke(_shade(_belly, -.22).withValues(alpha: .55), s * .007),
            );
          }
        });

      case EarType.frill:
        // A scalloped shield fanning up and out behind the skull. A plain ring
        // of circles read as a lion's mane; the scallops and the radiating
        // ribs are what make it bone.
        final Offset fc = a.faceCenter;
        final double fr = a.faceRadius;
        final Offset c = Offset(fc.dx, fc.dy + fr * .22);
        final double rx = fr * 1.60;
        final double ry = fr * 1.48;
        Offset at(double ang, double k) => Offset(
          c.dx + math.cos(ang) * rx * k,
          c.dy + math.sin(ang) * ry * k,
        );
        const double a0 = math.pi * 1.06;
        const double a1 = -math.pi * .06;
        const int n = 7;
        final Path p = Path()..moveTo(at(a0, 1).dx, at(a0, 1).dy);
        for (int i = 0; i < n; i++) {
          final double t0 = a0 + (a1 - a0) * i / n;
          final double t1 = a0 + (a1 - a0) * (i + 1) / n;
          final Offset ctrl = at((t0 + t1) * .5, 1.20);
          final Offset end = at(t1, 1);
          p.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
        }
        p.close();
        canvas.drawPath(p, _volume(_accent, p.getBounds(), lift: .16));
        canvas.drawPath(p, _stroke(_shade(_accent, -.26), s * .011));
        for (int i = 1; i < n; i++) {
          final double t = a0 + (a1 - a0) * i / n;
          canvas.drawLine(
            at(t, .40),
            at(t, .94),
            _stroke(_shade(_accent, -.22).withValues(alpha: .45), s * .008),
          );
        }

      case EarType.antenna:
        pair((double sign) {
          final Offset base = Offset(
            top.dx + sign * hw * .32,
            top.dy + hw * .10,
          );
          final Offset tip = Offset(
            top.dx + sign * hw * .82,
            top.dy - hw * .85,
          );
          canvas.drawPath(
            Path()
              ..moveTo(base.dx, base.dy)
              ..quadraticBezierTo(
                base.dx + sign * hw * .18,
                top.dy - hw * .70,
                tip.dx,
                tip.dy,
              ),
            _stroke(_detail, s * .015),
          );
          canvas.drawCircle(
            tip,
            hw * .18,
            _volume(_accent, Rect.fromCircle(center: tip, radius: hw * .18)),
          );
          canvas.drawCircle(
            Offset(tip.dx - hw * .06, tip.dy - hw * .06),
            hw * .06,
            _fill(Colors.white.withValues(alpha: .60)),
          );
        });

      case EarType.feather:
        pair((double sign) {
          canvas.save();
          canvas.translate(top.dx + sign * hw * .42, top.dy + hw * .12);
          canvas.rotate(sign * .55);
          final Rect r = Rect.fromCenter(
            center: Offset(0, -hw * .48),
            width: hw * .36,
            height: hw * 1.08,
          );
          canvas.drawOval(r, _volume(_accent, r));
          canvas.drawLine(
            Offset(0, -hw * .02),
            Offset(0, -hw * .94),
            _stroke(_shade(_accent, -.22).withValues(alpha: .55), s * .006),
          );
          canvas.restore();
        });

      case EarType.horn:
        pair((double sign) {
          final Path p = Path()
            ..moveTo(top.dx + sign * hw * .34, top.dy + hw * .24)
            ..quadraticBezierTo(
              top.dx + sign * hw * 1.00,
              top.dy - hw * .30,
              top.dx + sign * hw * .84,
              top.dy - hw * .82,
            )
            ..quadraticBezierTo(
              top.dx + sign * hw * .58,
              top.dy - hw * .22,
              top.dx + sign * hw * .34,
              top.dy + hw * .24,
            )
            ..close();
          _part(canvas, s, p, _detail);
        });

      case EarType.fan:
        // Broad flat ears fanned out to each side — elephants, big rays.
        pair((double sign) {
          final Rect r = Rect.fromCenter(
            center: Offset(
              a.faceCenter.dx + sign * a.faceRadius * 1.16,
              a.faceCenter.dy - a.faceRadius * .12,
            ),
            width: a.faceRadius * 1.34,
            height: a.faceRadius * 1.70,
          );
          _shellEar(
            canvas,
            s,
            Path()..addOval(r),
            Path()..addOval(r.deflate(a.faceRadius * .28)),
          );
        });
    }
  }

  // ------------------------------------------------------------------ crests

  /// One tapered, gently curved quill growing from [base].
  ///
  /// [ang] points from the body out through the tip and [bend] sweeps that tip
  /// sideways, so a rank of them fans instead of bristling in a dead-straight
  /// star — the difference between a coat of spines and a cog wheel.
  static Path _quill(
    Offset base,
    double ang,
    double len,
    double halfW,
    double bend,
  ) {
    final Offset dir = Offset(math.cos(ang), math.sin(ang));
    final Offset perp = Offset(-dir.dy, dir.dx);
    final Offset tip = base + dir * len + perp * (len * bend);
    final Offset mid = base + dir * (len * .58) + perp * (len * bend * .30);
    return Path()
      ..moveTo(base.dx - perp.dx * halfW, base.dy - perp.dy * halfW)
      ..quadraticBezierTo(
        mid.dx - perp.dx * halfW * .58,
        mid.dy - perp.dy * halfW * .58,
        tip.dx,
        tip.dy,
      )
      ..quadraticBezierTo(
        mid.dx + perp.dx * halfW * .58,
        mid.dy + perp.dy * halfW * .58,
        base.dx + perp.dx * halfW,
        base.dy + perp.dy * halfW,
      )
      ..close();
  }

  void _drawBackCrest(Canvas canvas, double s, _Anatomy a) {
    final double hw = a.headHalfWidth;
    final Offset top = a.headTop;
    switch (spec.crest) {
      case CrestType.antlers:
        for (final int sign in const <int>[-1, 1]) {
          final Paint p = _stroke(_detail, s * .026);
          final Offset base = Offset(
            top.dx + sign * hw * .34,
            top.dy + hw * .16,
          );
          final Offset mid = Offset(
            base.dx + sign * hw * .34,
            base.dy - hw * .58,
          );
          final Offset tip = Offset(
            mid.dx + sign * hw * .24,
            mid.dy - hw * .62,
          );
          canvas.drawPath(
            Path()
              ..moveTo(base.dx, base.dy)
              ..quadraticBezierTo(
                base.dx + sign * hw * .06,
                base.dy - hw * .34,
                mid.dx,
                mid.dy,
              )
              ..quadraticBezierTo(
                mid.dx + sign * hw * .04,
                mid.dy - hw * .34,
                tip.dx,
                tip.dy,
              ),
            p,
          );
          canvas.drawPath(
            Path()
              ..moveTo(mid.dx - sign * hw * .04, mid.dy + hw * .06)
              ..quadraticBezierTo(
                mid.dx + sign * hw * .40,
                mid.dy - hw * .10,
                mid.dx + sign * hw * .52,
                mid.dy - hw * .40,
              ),
            _stroke(_detail, s * .019),
          );
          canvas.drawPath(
            Path()
              ..moveTo(mid.dx + sign * hw * .14, mid.dy - hw * .40)
              ..quadraticBezierTo(
                mid.dx - sign * hw * .10,
                mid.dy - hw * .64,
                mid.dx - sign * hw * .18,
                mid.dy - hw * .86,
              ),
            _stroke(_detail, s * .016),
          );
        }

      case CrestType.halo:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(top.dx, top.dy - hw * .60),
            width: hw * 1.30,
            height: hw * .38,
          ),
          _stroke(_accent, s * .018),
        );

      case CrestType.sailFin:
        final Rect b = a.bodyBounds;
        final double cxf = b.center.dx;
        final Path p = Path()
          ..moveTo(cxf - b.width * .34, b.top + b.height * .22)
          ..quadraticBezierTo(
            cxf - b.width * .16,
            b.top - b.height * .26,
            cxf + b.width * .02,
            b.top - b.height * .26,
          )
          ..quadraticBezierTo(
            cxf + b.width * .24,
            b.top - b.height * .06,
            cxf + b.width * .34,
            b.top + b.height * .22,
          )
          ..close();
        canvas.drawPath(p, _volume(_shade(_body, -.12), p.getBounds()));
        canvas.drawPath(p, _stroke(_shade(_body, -.28), s * .009));
        // Membrane ribs.
        for (int i = -1; i <= 1; i++) {
          canvas.drawPath(
            Path()
              ..moveTo(cxf + i * b.width * .14, b.top + b.height * .18)
              ..lineTo(cxf + i * b.width * .10, b.top - b.height * .18),
            _stroke(_shade(_body, -.26).withValues(alpha: .5), s * .007),
          );
        }

      case CrestType.plates:
        final Rect b = a.bodyBounds;
        for (int i = 0; i < 5; i++) {
          final double t = -.62 + i * .31;
          final double w = b.width * (.20 - t.abs() * .07);
          final Offset c = Offset(
            b.center.dx + b.width * t * .78,
            b.top + b.height * (.02 + t.abs() * t.abs() * .70),
          );
          final Path p = Path()
            ..moveTo(c.dx - w, c.dy + w * .70)
            ..quadraticBezierTo(
              c.dx - w * .70,
              c.dy - w * 1.30,
              c.dx,
              c.dy - w * 1.35,
            )
            ..quadraticBezierTo(
              c.dx + w * .70,
              c.dy - w * 1.30,
              c.dx + w,
              c.dy + w * .70,
            )
            ..close();
          _part(canvas, s, p, _accent, width: .008, alpha: .35);
        }

      case CrestType.mane:
        // Layered rather than one ring of circles: an outer dark rank reads as
        // depth behind a brighter inner one.
        final double mr = a.faceRadius * 1.58;
        for (int layer = 0; layer < 2; layer++) {
          final double rad = mr * (layer == 0 ? 1.0 : .84);
          final Color c = layer == 0 ? _shade(_accent, -.16) : _accent;
          for (int i = 0; i < 12; i++) {
            final double ang = i * math.pi * 2 / 12 + (layer == 0 ? .26 : 0);
            canvas.drawCircle(
              Offset(
                a.faceCenter.dx + math.cos(ang) * rad * .92,
                a.faceCenter.dy + math.sin(ang) * rad * .92,
              ),
              rad * .30,
              _fill(c),
            );
          }
        }
        canvas.drawCircle(
          a.faceCenter,
          mr * .90,
          _volume(_accent, a.headBounds.inflate(mr * .2)),
        );

      case CrestType.spikes:
        // Every quill is rooted on the silhouette itself and points along the
        // outward normal there, so the coat is bedded into the back however
        // odd the body plan is. The previous ellipse fit to the bounding box
        // floated the side quills clear of the animal and buried the ones over
        // the crown inside the skull.
        final List<_Bristle> roots = a.bristles;
        if (roots.isEmpty) break;
        final double span = a.bounds.width;
        final double len = span * .185;
        final double halfW = span * .044;
        // Rooted a little way inside the outline: a quill that starts exactly
        // on the edge shows a seam where its base meets the body.
        const double sink = .35;

        // Back rank first — darker, shorter, half a step out of phase — so the
        // front rank reads as lying on a thick coat rather than a paper comb.
        for (int rank = 0; rank < 2; rank++) {
          final bool back = rank == 0;
          final Color c = back ? _shade(_detail, -.18) : _detail;
          const int stride = 6;
          for (int i = back ? 3 : 0; i < roots.length; i += stride) {
            final _Bristle q = roots[i];
            final Offset dir = Offset(math.cos(q.angle), math.sin(q.angle));
            final Offset base = q.at - dir * len * sink;
            // Longest where the coat faces straight up, shorter round the
            // flanks, which is how a real mantle of spines tapers off.
            final double l =
                len * (back ? .80 : 1) * (.80 + .20 * math.max(0.0, -dir.dy));
            final double bend = .18 * dir.dx.sign * dir.dx.abs();
            _part(
              canvas,
              s,
              _quill(base, q.angle, l, halfW, bend),
              c,
              width: .006,
              alpha: .30,
            );
            if (!back) {
              // A lit ridge down the middle. A pale *tip* band is the more
              // literal quill marking, but at this size it detaches and reads
              // as a second floating triangle; a ridge just gives volume.
              canvas.drawPath(
                _quill(base, q.angle, l * .82, halfW * .42, bend),
                _fill(_shade(c, .13).withValues(alpha: .75)),
              );
            }
          }
        }

      default:
        break;
    }
  }

  /// The shell a snail or an ammonite carries on its back.
  ///
  /// Sits on the body with the head subtracted out of it, which is the one
  /// arrangement that both reads and keeps clear of the face: drawn fully in
  /// front it put the creature's own mouth on the shell, and pushed fully
  /// behind it shrank to a sliver poking out one side.
  void _drawShellSpiral(Canvas canvas, double s, _Anatomy a) {
    if (spec.crest != CrestType.shellSpiral) return;
    final Rect b = a.bodyBounds;
    final Offset c = Offset(
      b.center.dx - a.halfW * .34,
      b.center.dy - b.height * .30,
    );
    final double rr = a.halfW * .80;
    final Rect box = Rect.fromCircle(center: c, radius: rr);
    final Path shell = Path.combine(
      PathOperation.difference,
      Path()..addOval(box),
      a.head,
    );
    canvas.drawPath(shell, _volume(_belly, box, lift: .18));
    // Whorl: wound tight at the centre and opening outward, clipped to the
    // shell so the outermost turn stops at the rim instead of running off it.
    canvas.save();
    canvas.clipPath(shell);
    for (int pass = 0; pass < 2; pass++) {
      final Path sp = Path();
      for (double t = 0; t < math.pi * 3.2; t += .08) {
        final double r = rr * .07 + t * rr * .092;
        final Offset o = Offset(
          c.dx + math.cos(t + math.pi * .4) * r,
          c.dy + math.sin(t + math.pi * .4) * r,
        );
        t == 0 ? sp.moveTo(o.dx, o.dy) : sp.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
        sp,
        pass == 0
            ? _stroke(_shade(_belly, -.30).withValues(alpha: .80), s * .015)
            : _stroke(_shade(_belly, .20).withValues(alpha: .50), s * .006),
      );
    }
    canvas.restore();
    canvas.drawPath(
      shell,
      _stroke(_shade(_belly, -.30).withValues(alpha: .75), s * .013),
    );
  }

  void _drawFrontCrest(Canvas canvas, double s, _Anatomy a) {
    final double hw = a.headHalfWidth;
    final Offset top = a.headTop;
    switch (spec.crest) {
      case CrestType.hornsSmall:
        for (final int sign in const <int>[-1, 1]) {
          final Path p = Path()
            ..moveTo(top.dx + sign * hw * .30, top.dy + hw * .18)
            ..quadraticBezierTo(
              top.dx + sign * hw * .46,
              top.dy - hw * .20,
              top.dx + sign * hw * .50,
              top.dy - hw * .52,
            )
            ..quadraticBezierTo(
              top.dx + sign * hw * .62,
              top.dy - hw * .16,
              top.dx + sign * hw * .62,
              top.dy + hw * .10,
            )
            ..close();
          _part(canvas, s, p, _detail, width: .008, alpha: .30);
        }

      case CrestType.hornsCurved:
        for (final int sign in const <int>[-1, 1]) {
          _part(
            canvas,
            s,
            _taper(
              Offset(top.dx + sign * hw * .68, top.dy + hw * .32),
              Offset(top.dx + sign * hw * 1.34, top.dy - hw * .24),
              Offset(top.dx + sign * hw * .84, top.dy - hw * .74),
              hw * .17,
              hw * .05,
            ),
            _detail,
            width: .008,
            alpha: .30,
          );
        }

      case CrestType.unicorn:
        final Path p = Path()
          ..moveTo(top.dx - hw * .17, top.dy + hw * .12)
          ..quadraticBezierTo(
            top.dx - hw * .06,
            top.dy - hw * .46,
            top.dx + hw * .02,
            top.dy - hw * .94,
          )
          ..quadraticBezierTo(
            top.dx + hw * .12,
            top.dy - hw * .40,
            top.dx + hw * .19,
            top.dy + hw * .12,
          )
          ..close();
        canvas.drawPath(p, _volume(_detail, p.getBounds(), lift: .20));
        canvas.drawPath(p, _stroke(_shade(_detail, -.20), s * .008));
        // Spiral ridges, the detail that makes a horn a horn.
        for (int i = 1; i <= 3; i++) {
          final double t = i / 4;
          canvas.drawPath(
            Path()
              ..moveTo(
                top.dx - hw * .16 * (1 - t) - hw * .01,
                top.dy + hw * (.12 - t * 1.02),
              )
              ..quadraticBezierTo(
                top.dx,
                top.dy + hw * (.20 - t * 1.02),
                top.dx + hw * .17 * (1 - t) + hw * .02,
                top.dy + hw * (.12 - t * 1.02),
              ),
            _stroke(_shade(_detail, -.22).withValues(alpha: .60), s * .006),
          );
        }

      case CrestType.flame:
        for (int i = 0; i < 3; i++) {
          final double off = (i - 1) * hw * .34;
          final double hgt = hw * (1.05 - (i - 1).abs() * .32);
          final Path p = Path()
            ..moveTo(top.dx + off - hw * .20, top.dy + hw * .14)
            ..quadraticBezierTo(
              top.dx + off - hw * .26,
              top.dy - hgt * .70,
              top.dx + off,
              top.dy - hgt,
            )
            ..quadraticBezierTo(
              top.dx + off + hw * .26,
              top.dy - hgt * .70,
              top.dx + off + hw * .20,
              top.dy + hw * .14,
            )
            ..close();
          canvas.drawPath(
            p,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  _shade(_accent, -.10),
                  _accent,
                  _shade(_accent, .26),
                ],
              ).createShader(p.getBounds())
              ..isAntiAlias = true,
          );
        }

      case CrestType.leafSprout:
        canvas.drawPath(
          Path()
            ..moveTo(top.dx, top.dy + hw * .12)
            ..quadraticBezierTo(
              top.dx + hw * .06,
              top.dy - hw * .40,
              top.dx,
              top.dy - hw * .62,
            ),
          _stroke(_detail, s * .012),
        );
        for (final int sign in const <int>[-1, 1]) {
          final Path p = Path()
            ..moveTo(top.dx, top.dy - hw * .30)
            ..quadraticBezierTo(
              top.dx + sign * hw * .62,
              top.dy - hw * .78,
              top.dx + sign * hw * .10,
              top.dy - hw * .70,
            )
            ..close();
          canvas.drawPath(p, _volume(_accent, p.getBounds()));
          canvas.drawPath(
            Path()
              ..moveTo(top.dx + sign * hw * .06, top.dy - hw * .40)
              ..quadraticBezierTo(
                top.dx + sign * hw * .30,
                top.dy - hw * .62,
                top.dx + sign * hw * .12,
                top.dy - hw * .68,
              ),
            _stroke(_shade(_accent, -.22).withValues(alpha: .6), s * .006),
          );
        }

      case CrestType.mushroomCap:
        final Rect cap = Rect.fromCenter(
          center: Offset(top.dx, top.dy + hw * .10),
          width: hw * 1.85,
          height: hw * 1.15,
        );
        canvas.drawArc(
          cap,
          math.pi,
          math.pi,
          true,
          _volume(_accent, cap, lift: .18),
        );
        canvas.drawArc(
          cap,
          math.pi,
          math.pi,
          false,
          _stroke(_shade(_accent, -.24).withValues(alpha: .5), s * .008),
        );
        canvas.drawCircle(
          Offset(top.dx - hw * .40, top.dy - hw * .12),
          hw * .16,
          _fill(Colors.white.withValues(alpha: .85)),
        );
        canvas.drawCircle(
          Offset(top.dx + hw * .44, top.dy - hw * .04),
          hw * .12,
          _fill(Colors.white.withValues(alpha: .85)),
        );

      case CrestType.lure:
        final Offset tip = Offset(top.dx + hw * .55, top.dy - hw * 1.00);
        canvas.drawPath(
          Path()
            ..moveTo(top.dx - hw * .10, top.dy + hw * .10)
            ..quadraticBezierTo(
              top.dx - hw * .30,
              top.dy - hw * .90,
              tip.dx,
              tip.dy,
            ),
          _stroke(_detail, s * .014),
        );
        canvas.drawCircle(tip, hw * .38, _fill(_accent.withValues(alpha: .28)));
        canvas.drawCircle(tip, hw * .22, _fill(_accent.withValues(alpha: .55)));
        canvas.drawCircle(
          tip,
          hw * .13,
          _fill(Colors.white.withValues(alpha: .9)),
        );

      case CrestType.crown:
        final double y = top.dy + hw * .16;
        final Path p = Path()..moveTo(top.dx - hw * .72, y);
        for (int i = 0; i < 3; i++) {
          final double x0 = top.dx - hw * .72 + i * hw * .48;
          p.lineTo(x0 + hw * .24, y - hw * .60);
          p.lineTo(x0 + hw * .48, y);
        }
        p.close();
        canvas.drawPath(p, _volume(_detail, p.getBounds(), lift: .20));
        canvas.drawPath(
          p,
          _stroke(_shade(_detail, -.24).withValues(alpha: .5), s * .007),
        );
        canvas.drawCircle(
          Offset(top.dx, y - hw * .52),
          hw * .13,
          _fill(_accent),
        );

      case CrestType.crest:
        final Path p = Path()..moveTo(top.dx - hw * .34, top.dy + hw * .22);
        for (int i = 0; i < 3; i++) {
          p.quadraticBezierTo(
            top.dx - hw * .20 + i * hw * .30,
            top.dy - hw * (.85 - i * .16),
            top.dx + hw * (-.05 + i * .30),
            top.dy + hw * .10,
          );
        }
        p.close();
        canvas.drawPath(p, _volume(_accent, p.getBounds(), lift: .16));

      case CrestType.bubbleCap:
        for (int i = 0; i < 3; i++) {
          final Offset c = Offset(
            top.dx + (i - 1) * hw * .48,
            top.dy - hw * (.18 + (i == 1 ? .30 : 0)),
          );
          final double r = hw * (i == 1 ? .34 : .24);
          canvas.drawCircle(c, r, _fill(Colors.white.withValues(alpha: .30)));
          canvas.drawCircle(
            c,
            r,
            _stroke(Colors.white.withValues(alpha: .55), s * .005),
          );
          canvas.drawCircle(
            Offset(c.dx - r * .34, c.dy - r * .36),
            r * .20,
            _fill(Colors.white.withValues(alpha: .75)),
          );
        }

      case CrestType.starTuft:
        _star(
          canvas,
          Offset(top.dx, top.dy - hw * .44),
          hw * .40,
          _fill(_accent),
        );

      case CrestType.snowCap:
        final Rect b = a.headBounds;
        canvas.save();
        canvas.clipPath(a.silhouette);
        canvas.drawPath(
          Path()
            ..moveTo(b.left - 2, b.top + b.height * .22)
            ..quadraticBezierTo(
              b.center.dx - b.width * .22,
              b.top + b.height * .01,
              b.center.dx,
              b.top + b.height * .16,
            )
            ..quadraticBezierTo(
              b.center.dx + b.width * .26,
              b.top + b.height * .30,
              b.right + 2,
              b.top + b.height * .08,
            )
            ..lineTo(b.right + 2, b.top - 2)
            ..lineTo(b.left - 2, b.top - 2)
            ..close(),
          _fill(Colors.white.withValues(alpha: .94)),
        );
        canvas.restore();

      case CrestType.noseHorn:
        // Tall, forward-curving and planted on the bridge, with the second
        // smaller horn behind it. The old stub sat so low on the muzzle that
        // the rhino read as a hippo.
        final Offset f = a.faceCenter;
        final double r = a.faceRadius;
        final Path back = Path()
          ..moveTo(f.dx - r * .16, f.dy - r * .16)
          ..quadraticBezierTo(
            f.dx,
            f.dy - r * .60,
            f.dx + r * .10,
            f.dy - r * .64,
          )
          ..quadraticBezierTo(
            f.dx + r * .18,
            f.dy - r * .30,
            f.dx + r * .18,
            f.dy - r * .14,
          )
          ..close();
        _part(canvas, s, back, _shade(_detail, -.06), width: .007, alpha: .30);
        final Path p = Path()
          ..moveTo(f.dx - r * .28, f.dy + r * .34)
          ..quadraticBezierTo(
            f.dx - r * .10,
            f.dy - r * .58,
            f.dx + r * .26,
            f.dy - r * 1.02,
          )
          ..quadraticBezierTo(
            f.dx + r * .16,
            f.dy - r * .34,
            f.dx + r * .30,
            f.dy + r * .30,
          )
          ..close();
        canvas.drawPath(p, _volume(_detail, p.getBounds(), lift: .20));
        canvas.drawPath(p, _stroke(_shade(_detail, -.18), s * .008));
        canvas.drawPath(
          Path()
            ..moveTo(f.dx - r * .22, f.dy + r * .14)
            ..quadraticBezierTo(
              f.dx - r * .02,
              f.dy - r * .40,
              f.dx + r * .20,
              f.dy - r * .78,
            ),
          _stroke(_shade(_detail, .18).withValues(alpha: .55), s * .008),
        );

      case CrestType.woolTuft:
        // A fleece forelock: overlapping curls, densest at the crown.
        for (int i = 0; i < 5; i++) {
          final double t = (i - 2) / 2;
          final Offset c = Offset(
            top.dx + t * hw * .52,
            top.dy + hw * (.04 + t.abs() * .22) - hw * .26,
          );
          final double rr = hw * (.34 - t.abs() * .07);
          canvas.drawCircle(
            c,
            rr,
            _volume(_belly, Rect.fromCircle(center: c, radius: rr), lift: .18),
          );
          canvas.drawCircle(
            c,
            rr,
            _stroke(_shade(_belly, -.24).withValues(alpha: .40), s * .008),
          );
        }

      default:
        break;
    }
  }

  // -------------------------------------------------------------------- tail

  void _drawTail(Canvas canvas, double s, _Anatomy a) {
    if (spec.tail == TailType.none) return;
    final Rect b = a.bodyBounds;
    // Rooted well inside the silhouette: tails are drawn behind the body, so a
    // root on the outline leaves a visible seam where the two shapes meet.
    final Offset root = Offset(
      b.left + b.width * .22,
      b.bottom - b.height * .32,
    );

    switch (spec.tail) {
      case TailType.none:
        break;

      case TailType.puff:
        final Offset c = Offset(
          root.dx - b.width * .20,
          root.dy + b.height * .10,
        );
        final double r = b.width * .17;
        canvas.drawCircle(
          c,
          r,
          _volume(_belly, Rect.fromCircle(center: c, radius: r)),
        );
        canvas.drawCircle(
          c,
          r,
          _stroke(_shade(_belly, -.28).withValues(alpha: .40), s * .010),
        );

      case TailType.long:
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .06, root.dy),
            Offset(root.dx - b.width * .52, root.dy + b.height * .10),
            Offset(root.dx - b.width * .46, root.dy - b.height * .62),
            b.width * .090,
            b.width * .040,
          ),
          _body,
        );

      case TailType.curl:
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .06, root.dy + b.height * .10),
            Offset(root.dx - b.width * .40, root.dy + b.height * .16),
            Offset(root.dx - b.width * .14, root.dy - b.height * .16),
            b.width * .075,
            b.width * .035,
          ),
          _body,
        );

      case TailType.bushy:
      case TailType.ringed:
        // A brush that sweeps out of the hip and *up* past the shoulder. Curled
        // low behind the body it disappeared almost entirely — on a squirrel or
        // a fox the plume standing above the back is the whole silhouette.
        final Offset r0 = Offset(
          b.left + b.width * .18,
          b.bottom - b.height * .24,
        );
        final Offset mid = Offset(
          b.left - b.width * .32,
          b.center.dy + b.height * .10,
        );
        final Offset tip = Offset(
          b.left - b.width * .12,
          b.top - b.height * .12,
        );
        Offset onSpine(double t) => Offset(
          (1 - t) * (1 - t) * r0.dx + 2 * (1 - t) * t * mid.dx + t * t * tip.dx,
          (1 - t) * (1 - t) * r0.dy + 2 * (1 - t) * t * mid.dy + t * t * tip.dy,
        );

        // Lobes strung along the spine and unioned into the sweep. A stroke of
        // constant width reads as a tube; the bulges are what make it fur.
        Path brush = _taper(r0, mid, tip, b.width * .20, b.width * .17);
        for (int i = 0; i < 4; i++) {
          final Offset c = onSpine(.18 + i * .24);
          brush = Path.combine(
            PathOperation.union,
            brush,
            Path()..addOval(
              Rect.fromCircle(center: c, radius: b.width * (.215 - i * .012)),
            ),
          );
        }
        _part(canvas, s, brush, _body, width: .010, alpha: .38);

        if (spec.tail == TailType.ringed) {
          // Bands wrapped round the brush, square to the spine at each step.
          canvas.save();
          canvas.clipPath(brush);
          for (int i = 0; i < 4; i++) {
            final double t = .16 + i * .22;
            final Offset c = onSpine(t);
            final Offset d = onSpine(t + .04) - onSpine(t - .04);
            canvas.save();
            canvas.translate(c.dx, c.dy);
            canvas.rotate(math.atan2(d.dy, d.dx));
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: b.width * .105,
                height: b.width * .70,
              ),
              _fill(_accent.withValues(alpha: .85)),
            );
            canvas.restore();
          }
          canvas.restore();
        }
        // Pale tip, the way a fox or squirrel brush reads.
        canvas.drawCircle(
          tip,
          b.width * .155,
          _volume(_belly, Rect.fromCircle(center: tip, radius: b.width * .155)),
        );
        canvas.drawCircle(
          tip,
          b.width * .155,
          _stroke(_shade(_belly, -.30).withValues(alpha: .35), s * .009),
        );

      case TailType.fish:
        // Overlaps the body generously; a fluke that only kisses the outline
        // reads as a separate wedge floating behind the animal.
        final Offset r0 = Offset(
          b.left + b.width * .16,
          b.center.dy + b.height * .10,
        );
        final Path p = Path()
          ..moveTo(r0.dx + b.width * .16, r0.dy)
          ..quadraticBezierTo(
            r0.dx - b.width * .14,
            r0.dy - b.height * .16,
            r0.dx - b.width * .30,
            r0.dy - b.height * .32,
          )
          ..quadraticBezierTo(
            r0.dx - b.width * .14,
            r0.dy,
            r0.dx - b.width * .30,
            r0.dy + b.height * .30,
          )
          ..quadraticBezierTo(
            r0.dx - b.width * .12,
            r0.dy + b.height * .16,
            r0.dx + b.width * .16,
            r0.dy,
          )
          ..close();
        _part(canvas, s, p, _shade(_body, -.06));
        // Fin rays so the fluke reads as membrane over bone.
        for (int i = -1; i <= 1; i++) {
          canvas.drawPath(
            Path()
              ..moveTo(r0.dx + b.width * .02, r0.dy + i * b.height * .04)
              ..lineTo(r0.dx - b.width * .24, r0.dy + i * b.height * .22),
            _stroke(_shade(_body, -.28).withValues(alpha: .45), s * .007),
          );
        }

      case TailType.whip:
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .04, root.dy),
            Offset(root.dx - b.width * .46, root.dy - b.height * .06),
            Offset(root.dx - b.width * .58, root.dy - b.height * .46),
            b.width * .058,
            b.width * .016,
          ),
          _body,
        );

      case TailType.spade:
        final Offset tip = Offset(
          root.dx - b.width * .40,
          root.dy - b.height * .34,
        );
        // The stalk carries the same weight as the blade, so the two read as
        // one tail instead of a triangle hovering next to a thread.
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .04, root.dy + b.height * .02),
            Offset(root.dx - b.width * .40, root.dy + b.height * .04),
            tip,
            b.width * .065,
            b.width * .030,
          ),
          _body,
        );
        _part(
          canvas,
          s,
          Path()
            ..moveTo(tip.dx + b.width * .02, tip.dy - b.height * .22)
            ..quadraticBezierTo(
              tip.dx - b.width * .16,
              tip.dy - b.height * .02,
              tip.dx - b.width * .11,
              tip.dy + b.height * .09,
            )
            ..quadraticBezierTo(
              tip.dx + b.width * .02,
              tip.dy + b.height * .13,
              tip.dx + b.width * .13,
              tip.dy + b.height * .07,
            )
            ..quadraticBezierTo(
              tip.dx + b.width * .14,
              tip.dy - b.height * .06,
              tip.dx + b.width * .02,
              tip.dy - b.height * .22,
            )
            ..close(),
          _accent,
        );

      case TailType.feather:
        for (int i = 0; i < 3; i++) {
          canvas.save();
          canvas.translate(root.dx, root.dy);
          canvas.rotate(-.45 + i * .42);
          final Rect r = Rect.fromCenter(
            center: Offset(-b.width * .28, 0),
            width: b.width * .56,
            height: b.height * .19,
          );
          final Color c = i.isEven ? _accent : _belly;
          canvas.drawOval(r, _volume(c, r));
          canvas.drawOval(
            r,
            _stroke(_shade(c, -.30).withValues(alpha: .34), s * .008),
          );
          canvas.drawLine(
            Offset(r.left + r.width * .1, r.center.dy),
            Offset(r.right - r.width * .1, r.center.dy),
            _stroke(_shade(c, -.24).withValues(alpha: .35), s * .005),
          );
          canvas.restore();
        }

      case TailType.thick:
        // Heavy at the hip and lifting away from the body, so the mass clears
        // the silhouette instead of hiding inside it.
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .08, root.dy + b.height * .04),
            Offset(root.dx - b.width * .42, root.dy + b.height * .04),
            Offset(root.dx - b.width * .54, root.dy - b.height * .40),
            b.width * .155,
            b.width * .085,
          ),
          _body,
        );

      case TailType.spiked:
        final Offset tip = Offset(
          root.dx - b.width * .48,
          root.dy - b.height * .34,
        );
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .04, root.dy),
            Offset(root.dx - b.width * .48, root.dy + b.height * .04),
            tip,
            b.width * .080,
            b.width * .034,
          ),
          _body,
        );
        for (int i = 0; i < 3; i++) {
          canvas.drawPath(
            Path()
              ..moveTo(
                tip.dx - b.width * .05,
                tip.dy + b.height * (.10 - i * .09),
              )
              ..lineTo(
                tip.dx + b.width * .01,
                tip.dy + b.height * (.20 - i * .09),
              )
              ..lineTo(
                tip.dx + b.width * .07,
                tip.dy + b.height * (.09 - i * .09),
              )
              ..close(),
            _fill(_detail),
          );
        }

      case TailType.fan:
        for (int i = 0; i < 5; i++) {
          canvas.save();
          canvas.translate(root.dx, root.dy);
          canvas.rotate(-.85 + i * .34);
          final Rect r = Rect.fromCenter(
            center: Offset(-b.width * .32, 0),
            width: b.width * .66,
            height: b.height * .13,
          );
          final Color c = i.isEven ? _accent : _belly;
          canvas.drawOval(r, _volume(c, r));
          canvas.drawOval(
            r,
            _stroke(_shade(c, -.30).withValues(alpha: .30), s * .007),
          );
          canvas.restore();
        }

      case TailType.stinger:
        // A short barb tucked under the rear. A long curl swinging up the side
        // of the body reads as a handle rather than a sting.
        final Offset tip = Offset(
          b.left - b.width * .16,
          b.bottom - b.height * .04,
        );
        _part(
          canvas,
          s,
          _taper(
            Offset(b.left + b.width * .30, b.bottom - b.height * .34),
            Offset(b.left + b.width * .02, b.bottom - b.height * .20),
            tip,
            b.width * .13,
            b.width * .012,
          ),
          _detail,
          alpha: .28,
        );

      case TailType.club:
        final Offset tip = Offset(
          root.dx - b.width * .44,
          root.dy - b.height * .30,
        );
        _part(
          canvas,
          s,
          _taper(
            Offset(root.dx + b.width * .04, root.dy),
            Offset(root.dx - b.width * .42, root.dy + b.height * .06),
            tip,
            b.width * .085,
            b.width * .050,
          ),
          _body,
        );
        final Rect knob = Rect.fromCircle(center: tip, radius: b.width * .16);
        canvas.drawOval(knob, _volume(_detail, knob, lift: .16));
        canvas.drawOval(
          knob,
          _stroke(_shade(_detail, -.30).withValues(alpha: .40), s * .010),
        );
    }
  }

  // ------------------------------------------------------------------- wings

  void _drawWings(Canvas canvas, double s, _Anatomy a) {
    // Every wing type sits behind the body so the face always stays readable.
    if (spec.wings == WingType.none) return;

    final Rect b = a.bodyBounds;
    final Offset root = Offset(b.center.dx, b.top + b.height * .34);

    for (final int sign in const <int>[-1, 1]) {
      switch (spec.wings) {
        case WingType.none:
          break;

        case WingType.feather:
          final Path p = Path()
            ..moveTo(root.dx + sign * b.width * .24, root.dy - b.height * .12)
            ..quadraticBezierTo(
              root.dx + sign * b.width * .82,
              root.dy - b.height * .44,
              root.dx + sign * b.width * .68,
              root.dy + b.height * .32,
            )
            ..quadraticBezierTo(
              root.dx + sign * b.width * .48,
              root.dy + b.height * .12,
              root.dx + sign * b.width * .24,
              root.dy - b.height * .12,
            )
            ..close();
          canvas.drawPath(p, _volume(_belly, p.getBounds(), lift: .14));
          canvas.drawPath(p, _stroke(_shade(_belly, -.22), s * .010));
          // Overlapping covert rows rather than three loose scratches.
          for (int i = 0; i < 3; i++) {
            canvas.drawPath(
              Path()
                ..moveTo(
                  root.dx + sign * b.width * .28,
                  root.dy - b.height * (.06 - i * .10),
                )
                ..quadraticBezierTo(
                  root.dx + sign * b.width * (.54 + i * .04),
                  root.dy + b.height * (-.20 + i * .12),
                  root.dx + sign * b.width * (.62 - i * .03),
                  root.dy + b.height * (.04 + i * .11),
                ),
              _stroke(_shade(_belly, -.20).withValues(alpha: .70), s * .008),
            );
          }

        case WingType.bat:
          // A real bat wing is an arm, not a fan: the leading edge sweeps out
          // and *up* to a raised tip, and the trailing edge comes back in a
          // run of scoops that bow **toward** the body between the finger
          // tips. Bulging those scoops outward — which is what this used to
          // do — is exactly what made it read as a scalloped cloud.
          final double ww = math.min(b.width, s * .58);
          final double wh = b.height;
          Offset at(double x, double y) =>
              Offset(root.dx + sign * ww * x, root.dy + wh * y);

          final Offset shoulder = at(.13, -.02);
          final Offset wrist = at(.52, -.26);
          final Offset tip = at(.84, -.40);
          final Offset f2 = at(.70, .08);
          final Offset f3 = at(.47, .28);
          final Offset ankle = at(.14, .30);

          final Path p = Path()
            ..moveTo(shoulder.dx, shoulder.dy)
            // Leading edge: upper arm out through the wrist, then on to the tip.
            ..quadraticBezierTo(
              at(.33, -.24).dx,
              at(.33, -.24).dy,
              wrist.dx,
              wrist.dy,
            )
            ..quadraticBezierTo(
              at(.71, -.40).dx,
              at(.71, -.40).dy,
              tip.dx,
              tip.dy,
            )
            // Trailing edge: one concave scoop per finger.
            ..quadraticBezierTo(
              at(.63, -.10).dx,
              at(.63, -.10).dy,
              f2.dx,
              f2.dy,
            )
            ..quadraticBezierTo(at(.47, .10).dx, at(.47, .10).dy, f3.dx, f3.dy)
            ..quadraticBezierTo(
              at(.29, .13).dx,
              at(.29, .13).dy,
              ankle.dx,
              ankle.dy,
            )
            ..close();
          canvas.drawPath(p, _volume(_accent, p.getBounds(), lift: .16));
          canvas.drawPath(p, _stroke(_shade(_accent, -.28), s * .009));

          // Bones: the arm to the wrist, then fingers radiating from it —
          // which is what sells the membrane as stretched between them.
          final Paint bone = _stroke(
            _shade(_accent, -.32).withValues(alpha: .60),
            s * .008,
          );
          canvas.drawLine(shoulder, wrist, bone);
          canvas.drawLine(wrist, f2, bone);
          canvas.drawLine(wrist, f3, bone);
          canvas.drawLine(
            wrist,
            ankle,
            _stroke(_shade(_accent, -.32).withValues(alpha: .34), s * .007),
          );

        case WingType.butterfly:
          // Generous: on a butterfly or a moth the wings are the animal, and
          // tucked in behind a bug body they barely showed at all.
          final Rect up = Rect.fromCenter(
            center: Offset(
              root.dx + sign * b.width * .62,
              root.dy - b.height * .26,
            ),
            width: b.width * .92,
            height: b.height * .82,
          );
          final Rect lo = Rect.fromCenter(
            center: Offset(
              root.dx + sign * b.width * .50,
              root.dy + b.height * .38,
            ),
            width: b.width * .68,
            height: b.height * .56,
          );
          canvas.drawOval(up, _volume(_accent, up, lift: .16));
          canvas.drawOval(lo, _volume(_belly, lo, lift: .16));
          canvas.drawOval(
            up,
            _stroke(_shade(_accent, -.26).withValues(alpha: .55), s * .008),
          );
          canvas.drawOval(
            lo,
            _stroke(_shade(_belly, -.26).withValues(alpha: .55), s * .008),
          );
          // Eyespot markings — the read that says "butterfly" instantly.
          canvas.drawCircle(
            up.center,
            up.width * .16,
            _fill(_shade(_accent, -.24).withValues(alpha: .55)),
          );
          canvas.drawCircle(
            up.center,
            up.width * .07,
            _fill(Colors.white.withValues(alpha: .70)),
          );

        case WingType.insect:
          canvas.save();
          canvas.translate(root.dx, root.dy);
          canvas.rotate(sign * .40);
          final Rect r = Rect.fromCenter(
            center: Offset(sign * b.width * .52, -b.height * .10),
            width: b.width * .96,
            height: b.height * .34,
          );
          canvas.drawOval(
            r,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Colors.white.withValues(alpha: .58),
                  Colors.white.withValues(alpha: .30),
                ],
              ).createShader(r)
              ..isAntiAlias = true,
          );
          canvas.drawOval(
            r,
            _stroke(Colors.white.withValues(alpha: .60), s * .006),
          );
          // Venation.
          for (int i = 0; i < 2; i++) {
            canvas.drawPath(
              Path()
                ..moveTo(sign * b.width * .06, -b.height * .10)
                ..quadraticBezierTo(
                  sign * b.width * .55,
                  -b.height * (.16 - i * .10),
                  sign * b.width * .96,
                  -b.height * (.12 - i * .06),
                ),
              _stroke(Colors.white.withValues(alpha: .45), s * .005),
            );
          }
          canvas.restore();

        case WingType.fairy:
          for (int i = 0; i < 2; i++) {
            final Rect r = Rect.fromCenter(
              center: Offset(
                root.dx + sign * b.width * (.40 + i * .06),
                root.dy + b.height * (-.20 + i * .42),
              ),
              width: b.width * (.56 - i * .14),
              height: b.height * (.46 - i * .12),
            );
            canvas.drawOval(
              r,
              Paint()
                ..shader = RadialGradient(
                  colors: <Color>[
                    _accent.withValues(alpha: .50),
                    _accent.withValues(alpha: .18),
                  ],
                ).createShader(r)
                ..isAntiAlias = true,
            );
            canvas.drawOval(
              r,
              _stroke(_accent.withValues(alpha: .55), s * .006),
            );
          }

        case WingType.dragon:
          final Path p = Path()
            ..moveTo(root.dx + sign * b.width * .18, root.dy - b.height * .08)
            ..lineTo(root.dx + sign * b.width * .74, root.dy - b.height * .42)
            ..quadraticBezierTo(
              root.dx + sign * b.width * .70,
              root.dy + b.height * .04,
              root.dx + sign * b.width * .52,
              root.dy + b.height * .26,
            )
            ..quadraticBezierTo(
              root.dx + sign * b.width * .38,
              root.dy + b.height * .08,
              root.dx + sign * b.width * .18,
              root.dy - b.height * .08,
            )
            ..close();
          canvas.drawPath(p, _volume(_accent, p.getBounds(), lift: .14));
          canvas.drawPath(p, _stroke(_shade(_accent, -.24), s * .009));
          for (int i = 0; i < 2; i++) {
            canvas.drawLine(
              Offset(root.dx + sign * b.width * .22, root.dy - b.height * .06),
              Offset(
                root.dx + sign * b.width * (.60 - i * .10),
                root.dy + b.height * (.06 + i * .18),
              ),
              _stroke(_shade(_accent, -.26).withValues(alpha: .55), s * .007),
            );
          }

        case WingType.tiny:
          final Rect r = Rect.fromCenter(
            center: Offset(
              root.dx + sign * b.width * .44,
              root.dy + b.height * .10,
            ),
            width: b.width * .34,
            height: b.height * .32,
          );
          canvas.drawOval(r, _volume(_belly, r, lift: .14));
          canvas.drawOval(
            r,
            _stroke(_shade(_belly, -.26).withValues(alpha: .45), s * .008),
          );
      }
    }
  }

  // ------------------------------------------------------------------- limbs

  /// A foot with a top surface and toes, overlapping the body so it reads as
  /// the end of a leg rather than a pebble parked underneath.
  void _foot(
    Canvas canvas,
    double s,
    Offset c,
    double w,
    double h,
    Color c0, {
    int toes = 3,
    Color? padColor,
  }) {
    final Rect r = Rect.fromCenter(center: c, width: w, height: h);
    final Path p = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          r,
          topLeft: Radius.circular(h * .70),
          topRight: Radius.circular(h * .70),
          bottomLeft: Radius.circular(h * .46),
          bottomRight: Radius.circular(h * .46),
        ),
      );
    canvas.drawPath(p, _volume(c0, r, lift: .12, drop: -.13));
    canvas.drawPath(
      p,
      _stroke(_shade(c0, -.32).withValues(alpha: .42), s * .009),
    );
    if (toes <= 0) return;
    // Toe creases in the front face, spaced across the middle of the foot.
    for (int i = 1; i < toes; i++) {
      final double x = r.left + r.width * i / toes;
      canvas.drawLine(
        Offset(x, r.center.dy + h * .04),
        Offset(x, r.bottom - h * .12),
        _stroke(_shade(c0, -.30).withValues(alpha: .50), s * .008),
      );
    }
    if (padColor != null) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + h * .10),
          width: w * .48,
          height: h * .40,
        ),
        _fill(padColor.withValues(alpha: .85)),
      );
    }
  }

  /// A limb rooted inside the silhouette and tapering to the joint, so the
  /// mass is continuous from body to foot.
  void _leg(
    Canvas canvas,
    double s,
    Offset from,
    Offset to,
    double w0,
    double w1,
    Color c,
  ) {
    _part(
      canvas,
      s,
      _taper(from, Offset.lerp(from, to, .5)!, to, w0, w1),
      c,
      width: .009,
      alpha: .34,
    );
  }

  void _drawLimbs(Canvas canvas, double s, _Anatomy a, {required bool back}) {
    final Rect b = a.bodyBounds;
    final Color legC = _shade(_body, -.08);

    if (back) {
      // The far pair, darker and set behind, which is what gives the stance
      // depth instead of two feet stamped on a flat card.
      final Color farC = _shade(_body, -.20);
      switch (spec.limbs) {
        case LimbType.tinyFeet:
        case LimbType.paws:
        case LimbType.stubby:
        case LimbType.hooves:
          for (final int sign in const <int>[-1, 1]) {
            _foot(
              canvas,
              s,
              Offset(
                b.center.dx + sign * b.width * .33,
                b.bottom - b.height * .01,
              ),
              b.width * .27,
              b.height * .14,
              farC,
              toes: 0,
            );
          }
        case LimbType.tallLegs:
          for (final int sign in const <int>[-1, 1]) {
            final double x = b.center.dx + sign * b.width * .34;
            _leg(
              canvas,
              s,
              Offset(x, b.bottom - b.height * .26),
              Offset(x + sign * b.width * .04, b.bottom + s * .058),
              b.width * .058,
              b.width * .040,
              farC,
            );
          }
        case LimbType.flippers:
          for (final int sign in const <int>[-1, 1]) {
            canvas.drawOval(
              Rect.fromCenter(
                center: Offset(
                  b.center.dx + sign * b.width * .34,
                  b.bottom - b.height * .02,
                ),
                width: b.width * .34,
                height: b.height * .13,
              ),
              _volume(farC, b),
            );
          }
        case LimbType.tentacles:
          for (int i = 0; i < 5; i++) {
            final double x = b.left + b.width * (.12 + i * .19);
            final int dir = i.isEven ? 1 : -1;
            _part(
              canvas,
              s,
              _taper(
                Offset(x, b.bottom - b.height * .18),
                Offset(x + dir * b.width * .07, b.bottom + s * .035),
                Offset(x - dir * b.width * .05, b.bottom + s * .080),
                b.width * .055,
                b.width * .014,
              ),
              i.isOdd ? _shade(_body, -.12) : _body,
              width: .008,
              alpha: .30,
            );
          }
        case LimbType.claws:
          // Spindly walking legs behind the shell, so the pincers in front
          // have something to belong to.
          for (final int sign in const <int>[-1, 1]) {
            for (int i = 0; i < 3; i++) {
              final double x = b.center.dx + sign * b.width * (.20 + i * .16);
              _leg(
                canvas,
                s,
                Offset(x, b.bottom - b.height * .30),
                Offset(
                  x + sign * b.width * (.12 + i * .06),
                  b.bottom + s * .050,
                ),
                b.width * .038,
                b.width * .022,
                farC,
              );
            }
          }
        case LimbType.talons:
        case LimbType.none:
          break;
      }
      return;
    }

    // The near pair plus arms, drawn over the body so they attach to it.
    switch (spec.limbs) {
      case LimbType.none:
        break;

      case LimbType.tinyFeet:
      case LimbType.stubby:
        final bool stubby = spec.limbs == LimbType.stubby;
        for (final int sign in const <int>[-1, 1]) {
          _foot(
            canvas,
            s,
            Offset(
              b.center.dx + sign * b.width * (stubby ? .32 : .27),
              b.bottom - b.height * .02,
            ),
            b.width * (stubby ? .34 : .28),
            b.height * (stubby ? .19 : .15),
            legC,
            toes: 3,
          );
        }

      case LimbType.paws:
        for (final int sign in const <int>[-1, 1]) {
          _foot(
            canvas,
            s,
            Offset(
              b.center.dx + sign * b.width * .30,
              b.bottom - b.height * .02,
            ),
            b.width * .34,
            b.height * .19,
            legC,
            toes: 3,
            padColor: _belly,
          );
        }
        // Forearms angle down and inward to rest against the belly. Held out
        // horizontally they read as a teddy bear with its arms pinned open.
        for (final int sign in const <int>[-1, 1]) {
          final Offset c = Offset(
            b.center.dx + sign * b.width * .40,
            b.center.dy + b.height * .30,
          );
          _leg(
            canvas,
            s,
            Offset(
              b.center.dx + sign * b.width * .34,
              b.center.dy - b.height * .04,
            ),
            c,
            b.width * .085,
            b.width * .070,
            legC,
          );
          canvas.drawCircle(
            c,
            b.width * .090,
            _volume(legC, Rect.fromCircle(center: c, radius: b.width * .090)),
          );
          canvas.drawCircle(
            c,
            b.width * .090,
            _stroke(_shade(legC, -.30).withValues(alpha: .40), s * .008),
          );
          canvas.drawCircle(
            Offset(c.dx, c.dy + b.width * .015),
            b.width * .038,
            _fill(_belly.withValues(alpha: .85)),
          );
        }

      case LimbType.hooves:
        for (final int sign in const <int>[-1, 1]) {
          final double x = b.center.dx + sign * b.width * .30;
          _leg(
            canvas,
            s,
            Offset(x, b.bottom - b.height * .30),
            Offset(x, b.bottom + b.height * .01),
            b.width * .085,
            b.width * .062,
            legC,
          );
          final Rect r = Rect.fromCenter(
            center: Offset(x, b.bottom + b.height * .04),
            width: b.width * .16,
            height: b.height * .11,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(r, Radius.circular(s * .012)),
            _volume(_detail, r, lift: .14),
          );
          // Cloven split.
          canvas.drawLine(
            Offset(x, r.top + r.height * .3),
            Offset(x, r.bottom),
            _stroke(_shade(_detail, -.30).withValues(alpha: .6), s * .007),
          );
        }

      case LimbType.tallLegs:
        for (final int sign in const <int>[-1, 1]) {
          final double x = b.center.dx + sign * b.width * .24;
          final Offset knee = Offset(
            x + sign * b.width * .05,
            b.bottom + s * .030,
          );
          // Two segments with a knee, which is what stops long legs reading
          // as drinking straws.
          _leg(
            canvas,
            s,
            Offset(x, b.bottom - b.height * .24),
            knee,
            b.width * .075,
            b.width * .045,
            legC,
          );
          _leg(
            canvas,
            s,
            knee,
            Offset(x + sign * b.width * .01, b.bottom + s * .086),
            b.width * .045,
            b.width * .034,
            legC,
          );
          final Rect r = Rect.fromCenter(
            center: Offset(x + sign * b.width * .01, b.bottom + s * .094),
            width: s * .066,
            height: s * .032,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(r, Radius.circular(s * .010)),
            _volume(_detail, r, lift: .14),
          );
        }

      case LimbType.flippers:
        for (final int sign in const <int>[-1, 1]) {
          _foot(
            canvas,
            s,
            Offset(
              b.center.dx + sign * b.width * .29,
              b.bottom - b.height * .02,
            ),
            b.width * .34,
            b.height * .14,
            _shade(_body, -.05),
            toes: 3,
          );
          canvas.save();
          canvas.translate(
            b.center.dx + sign * b.width * .42,
            b.center.dy + b.height * .22,
          );
          canvas.rotate(sign * .62);
          final Rect r = Rect.fromCenter(
            center: Offset.zero,
            width: b.width * .21,
            height: b.height * .38,
          );
          canvas.drawOval(r, _volume(_shade(_body, -.07), r));
          canvas.drawOval(
            r,
            _stroke(_shade(_body, -.32).withValues(alpha: .40), s * .008),
          );
          canvas.restore();
        }

      case LimbType.talons:
        for (final int sign in const <int>[-1, 1]) {
          final double x = b.center.dx + sign * b.width * .26;
          // Scaled shank with real thickness, then three forward toes.
          _leg(
            canvas,
            s,
            Offset(x, b.bottom - b.height * .12),
            Offset(x, b.bottom + s * .040),
            b.width * .055,
            b.width * .038,
            _detail,
          );
          for (int i = -1; i <= 1; i++) {
            canvas.drawPath(
              Path()
                ..moveTo(x, b.bottom + s * .040)
                ..quadraticBezierTo(
                  x + i * s * .020,
                  b.bottom + s * .062,
                  x + i * s * .036,
                  b.bottom + s * .066,
                ),
              _stroke(_detail, s * .012),
            );
          }
          canvas.drawCircle(
            Offset(x, b.bottom + s * .040),
            s * .016,
            _fill(_shade(_detail, .04)),
          );
        }

      case LimbType.claws:
        // A pincer is two fingers off one arm: a fixed jaw and a thumb, with a
        // gap between them. A solid mitten reads as a boxing glove.
        for (final int sign in const <int>[-1, 1]) {
          final Offset shoulder = Offset(
            b.center.dx + sign * b.width * .30,
            b.center.dy + b.height * .06,
          );
          final Offset wrist = Offset(
            b.center.dx + sign * b.width * .72,
            b.center.dy - b.height * .18,
          );
          _leg(
            canvas,
            s,
            shoulder,
            wrist,
            b.width * .075,
            b.width * .060,
            _shade(_body, -.06),
          );
          canvas.save();
          canvas.translate(wrist.dx, wrist.dy);
          canvas.rotate(sign * -.42);
          final double cw = b.width * .30;
          // Fixed jaw.
          final Path lower = Path()
            ..moveTo(-cw * .30, cw * .10)
            ..quadraticBezierTo(cw * .30, cw * .34, cw * .92, cw * .06)
            ..quadraticBezierTo(cw * .30, cw * .02, -cw * .30, -cw * .18)
            ..close();
          // Thumb, opening upward.
          final Path upper = Path()
            ..moveTo(-cw * .30, -cw * .10)
            ..quadraticBezierTo(cw * .26, -cw * .46, cw * .86, -cw * .16)
            ..quadraticBezierTo(cw * .26, -cw * .06, -cw * .30, cw * .06)
            ..close();
          _part(canvas, s, lower, _body, width: .008, alpha: .34);
          _part(canvas, s, upper, _shade(_body, .05), width: .008, alpha: .34);
          canvas.restore();
        }

      case LimbType.tentacles:
        for (int i = 0; i < 4; i++) {
          final double x = b.left + b.width * (.21 + i * .19);
          final int dir = i.isEven ? -1 : 1;
          _part(
            canvas,
            s,
            _taper(
              Offset(x, b.bottom - b.height * .22),
              Offset(x + dir * b.width * .08, b.bottom + s * .030),
              Offset(x - dir * b.width * .04, b.bottom + s * .072),
              b.width * .062,
              b.width * .016,
            ),
            _shade(_body, -.04),
            width: .008,
            alpha: .30,
          );
        }
    }
  }

  // ------------------------------------------------------------------- snout

  /// A muzzle drawn as a raised mass — its own light ramp plus a contact
  /// shadow where it meets the face. A flat oval of belly colour is what made
  /// the old snouts look pasted on.
  void _muzzle(Canvas canvas, double s, Offset c, double w, double h) {
    final Rect r = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawOval(
      r,
      Paint()
        ..color = _shade(_body, -.24).withValues(alpha: .38)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, h * .16)
        ..isAntiAlias = true,
    );
    canvas.drawOval(r, _volume(_belly, r, lift: .16, drop: -.12));
  }

  /// A nose with a highlight and a soft underside — the single detail that
  /// most sells a snout as three-dimensional.
  void _nose(Canvas canvas, double s, Offset c, double w, double h) {
    final Path p = Path()
      ..moveTo(c.dx - w * .5, c.dy - h * .34)
      ..quadraticBezierTo(c.dx, c.dy - h * .78, c.dx + w * .5, c.dy - h * .34)
      ..quadraticBezierTo(c.dx + w * .40, c.dy + h * .62, c.dx, c.dy + h * .66)
      ..quadraticBezierTo(
        c.dx - w * .40,
        c.dy + h * .62,
        c.dx - w * .5,
        c.dy - h * .34,
      )
      ..close();
    final Color nc = _shade(_detail, -.10);
    canvas.drawPath(p, _volume(nc, p.getBounds(), lift: .22, drop: -.10));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - w * .16, c.dy - h * .22),
        width: w * .30,
        height: h * .22,
      ),
      _fill(Colors.white.withValues(alpha: .55)),
    );
  }

  void _drawSnout(Canvas canvas, double s, _Anatomy a) {
    final Offset f = a.faceCenter;
    final double r = a.faceRadius;
    final double my = f.dy + r * .46;

    switch (spec.snout) {
      case SnoutType.none:
        break;

      case SnoutType.dot:
        _nose(canvas, s, Offset(f.dx, my), r * .26, r * .20);

      case SnoutType.muzzle:
        _muzzle(canvas, s, Offset(f.dx, my + r * .08), r * .82, r * .56);
        _nose(canvas, s, Offset(f.dx, my - r * .06), r * .28, r * .21);
        // Philtrum running from nose to lip.
        canvas.drawLine(
          Offset(f.dx, my + r * .08),
          Offset(f.dx, my + r * .22),
          _stroke(_shade(_belly, -.30).withValues(alpha: .55), s * .008),
        );

      case SnoutType.wideMuzzle:
        _muzzle(canvas, s, Offset(f.dx, my + r * .12), r * 1.10, r * .62);
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(f.dx + sign * r * .24, my + r * .02),
              width: r * .16,
              height: r * .12,
            ),
            _fill(_shade(_belly, -.34)),
          );
        }
        canvas.drawLine(
          Offset(f.dx, my + r * .12),
          Offset(f.dx, my + r * .28),
          _stroke(_shade(_belly, -.30).withValues(alpha: .55), s * .008),
        );

      case SnoutType.beakSmall:
        // Upper and lower mandible with a seam, rather than one flat triangle.
        final Path upper = Path()
          ..moveTo(f.dx - r * .26, my - r * .10)
          ..quadraticBezierTo(f.dx, my - r * .16, f.dx + r * .26, my - r * .10)
          ..quadraticBezierTo(f.dx + r * .10, my + r * .22, f.dx, my + r * .30)
          ..quadraticBezierTo(
            f.dx - r * .10,
            my + r * .22,
            f.dx - r * .26,
            my - r * .10,
          )
          ..close();
        canvas.drawPath(upper, _volume(_detail, upper.getBounds(), lift: .20));
        canvas.drawPath(
          Path()
            ..moveTo(f.dx - r * .20, my + r * .04)
            ..quadraticBezierTo(
              f.dx,
              my + r * .10,
              f.dx + r * .20,
              my + r * .04,
            ),
          _stroke(_shade(_detail, -.30).withValues(alpha: .70), s * .008),
        );

      case SnoutType.seahorse:
        final Path p = Path()
          ..moveTo(f.dx - r * .12, my - r * .12)
          ..quadraticBezierTo(
            f.dx + r * .18,
            my - r * .15,
            f.dx + r * .48,
            my - r * .02,
          )
          ..quadraticBezierTo(
            f.dx + r * .62,
            my + r * .06,
            f.dx + r * .54,
            my + r * .18,
          )
          ..quadraticBezierTo(
            f.dx + r * .42,
            my + r * .28,
            f.dx + r * .18,
            my + r * .23,
          )
          ..quadraticBezierTo(
            f.dx - r * .02,
            my + r * .18,
            f.dx - r * .12,
            my + r * .12,
          )
          ..close();
        canvas.drawPath(p, _volume(_detail, p.getBounds(), lift: .18));
        canvas.drawLine(
          Offset(f.dx + r * .43, my + r * .10),
          Offset(f.dx + r * .57, my + r * .12),
          _stroke(_shade(_detail, -.34).withValues(alpha: .72), s * .008),
        );

      case SnoutType.beakLong:
        final Path p = Path()
          ..moveTo(f.dx - r * .16, my - r * .08)
          ..quadraticBezierTo(
            f.dx + r * .40,
            my - r * .06,
            f.dx + r * .70,
            my + r * .10,
          )
          ..quadraticBezierTo(
            f.dx + r * .34,
            my + r * .24,
            f.dx - r * .14,
            my + r * .26,
          )
          ..close();
        canvas.drawPath(p, _volume(_detail, p.getBounds(), lift: .20));
        canvas.drawPath(
          Path()
            ..moveTo(f.dx - r * .14, my + r * .06)
            ..quadraticBezierTo(
              f.dx + r * .28,
              my + r * .06,
              f.dx + r * .64,
              my + r * .11,
            ),
          _stroke(_shade(_detail, -.30).withValues(alpha: .65), s * .008),
        );
        canvas.drawCircle(
          Offset(f.dx - r * .02, my - r * .02),
          r * .045,
          _fill(_shade(_detail, -.34)),
        );

      case SnoutType.trunk:
        final Path p = _taper(
          Offset(f.dx, my - r * .10),
          Offset(f.dx - r * .02, my + r * .70),
          Offset(f.dx + r * .34, my + r * 1.06),
          r * .24,
          r * .13,
        );
        canvas.drawPath(
          p,
          _volume(_shade(_body, -.04), p.getBounds(), lift: .14),
        );
        canvas.drawPath(
          p,
          _stroke(_shade(_body, -.32).withValues(alpha: .40), s * .009),
        );
        // Trunk rings.
        for (int i = 1; i <= 3; i++) {
          final double t = i / 4;
          final Offset o = Offset(
            f.dx - r * .02 * t + r * .34 * t * t,
            my - r * .10 + (r * 1.16) * t,
          );
          canvas.drawPath(
            Path()
              ..moveTo(o.dx - r * (.20 - t * .07), o.dy)
              ..quadraticBezierTo(
                o.dx,
                o.dy + r * .07,
                o.dx + r * (.20 - t * .07),
                o.dy,
              ),
            _stroke(_shade(_body, -.28).withValues(alpha: .45), s * .007),
          );
        }

      case SnoutType.duckBill:
        final Rect r0 = Rect.fromCenter(
          center: Offset(f.dx, my + r * .20),
          width: r * 1.24,
          height: r * .62,
        );
        canvas.drawOval(r0, _volume(_detail, r0, lift: .18));
        canvas.drawPath(
          Path()
            ..moveTo(r0.left + r0.width * .12, r0.center.dy)
            ..quadraticBezierTo(
              r0.center.dx,
              r0.center.dy + r0.height * .22,
              r0.right - r0.width * .12,
              r0.center.dy,
            ),
          _stroke(_shade(_detail, -.28).withValues(alpha: .65), s * .008),
        );
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawCircle(
            Offset(f.dx + sign * r * .18, r0.top + r0.height * .22),
            r * .045,
            _fill(_shade(_detail, -.32)),
          );
        }

      case SnoutType.longJaw:
        // A soft rounded muzzle with two small fangs — toothy but friendly.
        final Rect r0 = Rect.fromCenter(
          center: Offset(f.dx, my + r * .12),
          width: r * 1.02,
          height: r * .58,
        );
        canvas.drawOval(
          r0,
          Paint()
            ..color = _shade(_body, -.24).withValues(alpha: .38)
            ..maskFilter = ui.MaskFilter.blur(
              ui.BlurStyle.normal,
              r0.height * .16,
            )
            ..isAntiAlias = true,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(r0, Radius.circular(r * .26)),
          _volume(_belly, r0, lift: .16),
        );
        canvas.drawPath(
          Path()
            ..moveTo(f.dx - r * .26, my + r * .16)
            ..quadraticBezierTo(
              f.dx,
              my + r * .34,
              f.dx + r * .26,
              my + r * .16,
            ),
          _stroke(_shade(_belly, -.32), r * .07),
        );
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawPath(
            Path()
              ..moveTo(f.dx + sign * r * .18, my + r * .18)
              ..lineTo(f.dx + sign * r * .30, my + r * .18)
              ..lineTo(f.dx + sign * r * .24, my + r * .42)
              ..close(),
            _fill(Colors.white),
          );
        }
        _nose(canvas, s, Offset(f.dx, my - r * .16), r * .26, r * .19);

      case SnoutType.tusks:
        _muzzle(canvas, s, Offset(f.dx, my + r * .10), r * .84, r * .54);
        for (final int sign in const <int>[-1, 1]) {
          _part(
            canvas,
            s,
            _taper(
              Offset(f.dx + sign * r * .34, my + r * .00),
              Offset(f.dx + sign * r * .60, my + r * .44),
              Offset(f.dx + sign * r * .40, my + r * .82),
              r * .10,
              r * .04,
            ),
            const Color(0xFFFFF6E3),
            width: .007,
            alpha: .30,
          );
        }
        _nose(canvas, s, Offset(f.dx, my - r * .08), r * .26, r * .19);

      case SnoutType.buckTeeth:
        _muzzle(canvas, s, Offset(f.dx, my + r * .02), r * .66, r * .44);
        _nose(canvas, s, Offset(f.dx, my - r * .10), r * .24, r * .18);
        final Rect t = Rect.fromCenter(
          center: Offset(f.dx, my + r * .40),
          width: r * .36,
          height: r * .36,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(t, Radius.circular(r * .07)),
          _volume(Colors.white, t, lift: .03, drop: -.10),
        );
        canvas.drawLine(
          Offset(f.dx, t.top + r * .03),
          Offset(f.dx, t.bottom - r * .03),
          _stroke(const Color(0xFFD9CFC0), r * .04),
        );

      case SnoutType.fangs:
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawPath(
            Path()
              ..moveTo(f.dx + sign * r * .10, my + r * .30)
              ..lineTo(f.dx + sign * r * .22, my + r * .30)
              ..lineTo(f.dx + sign * r * .16, my + r * .58)
              ..close(),
            _fill(Colors.white),
          );
        }

      case SnoutType.longFace:
        // The muzzle a horse, a zebra or a giraffe carries: a tapered mass
        // hanging below the skull, not a patch drawn on the front of it. It is
        // the single feature that stops a hoofed creature reading as a rabbit.
        final Rect r0 = Rect.fromCenter(
          center: Offset(f.dx, my + r * .46),
          width: r * .74,
          height: r * 1.24,
        );
        canvas.drawOval(
          r0,
          Paint()
            ..color = _shade(_body, -.26).withValues(alpha: .34)
            ..maskFilter = ui.MaskFilter.blur(
              ui.BlurStyle.normal,
              r0.height * .12,
            )
            ..isAntiAlias = true,
        );
        final Path p = Path()
          ..moveTo(f.dx - r * .46, my - r * .28)
          ..quadraticBezierTo(
            f.dx - r * .40,
            my + r * .74,
            f.dx - r * .28,
            my + r * .94,
          )
          ..quadraticBezierTo(f.dx, my + r * 1.16, f.dx + r * .28, my + r * .94)
          ..quadraticBezierTo(
            f.dx + r * .40,
            my + r * .74,
            f.dx + r * .46,
            my - r * .28,
          )
          ..close();
        canvas.drawPath(
          p,
          _volume(_belly, p.getBounds(), lift: .16, drop: -.14),
        );
        canvas.drawPath(
          p,
          _stroke(_shade(_belly, -.30).withValues(alpha: .40), s * .009),
        );
        for (final int sign in const <int>[-1, 1]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(f.dx + sign * r * .16, my + r * .56),
              width: r * .13,
              height: r * .17,
            ),
            _fill(_shade(_belly, -.38)),
          );
        }
        canvas.drawPath(
          Path()
            ..moveTo(f.dx - r * .17, my + r * .82)
            ..quadraticBezierTo(
              f.dx,
              my + r * .94,
              f.dx + r * .17,
              my + r * .82,
            ),
          _stroke(_shade(_belly, -.32).withValues(alpha: .70), s * .010),
        );

      case SnoutType.bigNose:
        // Koalas and bear cubs lead with the nose — a broad soft spoon that
        // takes up most of the lower face.
        final Rect r0 = Rect.fromCenter(
          center: Offset(f.dx, my + r * .06),
          width: r * .72,
          height: r * .84,
        );
        final Path p = Path()
          ..moveTo(r0.center.dx, r0.top)
          ..quadraticBezierTo(
            r0.right + r0.width * .10,
            r0.top + r0.height * .22,
            r0.right - r0.width * .10,
            r0.center.dy + r0.height * .18,
          )
          ..quadraticBezierTo(
            r0.center.dx + r0.width * .30,
            r0.bottom,
            r0.center.dx,
            r0.bottom,
          )
          ..quadraticBezierTo(
            r0.center.dx - r0.width * .30,
            r0.bottom,
            r0.left + r0.width * .10,
            r0.center.dy + r0.height * .18,
          )
          ..quadraticBezierTo(
            r0.left - r0.width * .10,
            r0.top + r0.height * .22,
            r0.center.dx,
            r0.top,
          )
          ..close();
        final Color nc = _shade(_detail, -.06);
        canvas.drawPath(p, _volume(nc, r0, lift: .24, drop: -.12));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              r0.center.dx - r0.width * .18,
              r0.top + r0.height * .26,
            ),
            width: r0.width * .34,
            height: r0.height * .22,
          ),
          _fill(Colors.white.withValues(alpha: .50)),
        );
    }
  }

  // -------------------------------------------------------------------- face

  void _drawFace(Canvas canvas, double s, _Anatomy a) {
    final Offset f = a.faceCenter;
    final double r = a.faceRadius;
    final double eyeDx = r * .46 * spec.eyeSpacing;
    final double eyeY = f.dy - r * .06;
    final double eyeR = r * .215;
    final Color ink = _shade(_body, -.55);

    void eyePair(void Function(Offset c, int sign) draw) {
      draw(Offset(f.dx - eyeDx, eyeY), -1);
      draw(Offset(f.dx + eyeDx, eyeY), 1);
    }

    /// Eyes carry nearly all the character at tile size, so each one gets a
    /// socket shadow behind it, a graded iris, two catchlights and a lid line
    /// over the top. The lid is what makes an eye sit *in* a face.
    void glossyEye(Offset c, double rad, {Color? irisColor}) {
      final double squash = 0.35 + 0.65 * blink;
      final Rect r0 = Rect.fromCenter(
        center: c,
        width: rad * 2,
        height: rad * 2 * squash,
      );
      final Color base = irisColor ?? ink;

      // Socket: a soft darkening of the coat, so the eye is set into the head.
      final Rect socket = r0.inflate(rad * .30);
      canvas.drawOval(
        socket,
        Paint()
          ..color = _shade(_body, -.24).withValues(alpha: .30)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, rad * .34)
          ..isAntiAlias = true,
      );

      // Depth: the pupil is darkest at the top where the lid shades it, and
      // catches a faint bounce of the body colour along the bottom rim.
      canvas.drawOval(
        r0,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_shade(base, -.06), base, _shade(base, .16)],
            stops: const <double>[0, .62, 1],
          ).createShader(r0)
          ..isAntiAlias = true,
      );

      if (blink > .55) {
        // Bounce light pooled low in the eye.
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + rad * .40 * squash),
            width: rad * 1.30,
            height: rad * .80 * squash,
          ),
          _fill(_shade(base, .26).withValues(alpha: .55)),
        );
        // Primary catchlight, plus a small opposing spark.
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx - rad * .32, c.dy - rad * .36 * squash),
            width: rad * .78,
            height: rad * .70 * squash,
          ),
          _fill(Colors.white.withValues(alpha: .95)),
        );
        canvas.drawCircle(
          Offset(c.dx + rad * .34, c.dy + rad * .28 * squash),
          rad * .17,
          _fill(Colors.white.withValues(alpha: .68)),
        );

        // Upper lid, clipped to the eye so it hugs the curve.
        canvas.save();
        canvas.clipPath(Path()..addOval(r0));
        canvas.drawPath(
          Path()
            ..moveTo(r0.left - rad * .1, r0.top + rad * .10 * squash)
            ..quadraticBezierTo(
              c.dx,
              r0.top + rad * .62 * squash,
              r0.right + rad * .1,
              r0.top + rad * .10 * squash,
            )
            ..lineTo(r0.right + rad * .1, r0.top - rad)
            ..lineTo(r0.left - rad * .1, r0.top - rad)
            ..close(),
          _fill(_shade(base, -.22).withValues(alpha: .85)),
        );
        canvas.restore();
      }
    }

    switch (spec.eyes) {
      case EyeStyle.round:
        eyePair((Offset c, _) => glossyEye(c, eyeR));

      case EyeStyle.big:
        eyePair((Offset c, _) => glossyEye(c, eyeR * 1.28));

      case EyeStyle.wide:
        eyePair((Offset c, _) {
          canvas.drawCircle(c, eyeR * 1.22, _fill(Colors.white));
          canvas.drawCircle(
            c,
            eyeR * 1.22,
            _stroke(ink.withValues(alpha: .35), s * .008),
          );
          glossyEye(Offset(c.dx, c.dy + eyeR * .12), eyeR * .62);
        });

      case EyeStyle.sparkle:
        eyePair((Offset c, _) {
          glossyEye(c, eyeR * 1.12);
          if (blink > .55) {
            _star(
              canvas,
              Offset(c.dx - eyeR * .22, c.dy - eyeR * .28),
              eyeR * .52,
              _fill(Colors.white),
            );
          }
        });

      case EyeStyle.sleepy:
        eyePair((Offset c, _) {
          canvas.drawPath(
            Path()
              ..moveTo(c.dx - eyeR, c.dy)
              ..quadraticBezierTo(c.dx, c.dy + eyeR * 1.15, c.dx + eyeR, c.dy),
            _stroke(ink, s * .015),
          );
        });

      case EyeStyle.closedHappy:
        eyePair((Offset c, _) {
          canvas.drawPath(
            Path()
              ..moveTo(c.dx - eyeR, c.dy + eyeR * .35)
              ..quadraticBezierTo(
                c.dx,
                c.dy - eyeR * .95,
                c.dx + eyeR,
                c.dy + eyeR * .35,
              ),
            _stroke(ink, s * .015),
          );
        });

      case EyeStyle.glow:
        eyePair((Offset c, _) {
          canvas.drawCircle(
            c,
            eyeR * 1.75,
            _fill(_accent.withValues(alpha: .30)),
          );
          glossyEye(c, eyeR, irisColor: _accent);
        });

      case EyeStyle.side:
        eyePair((Offset c, int sign) {
          canvas.drawCircle(c, eyeR * 1.15, _fill(Colors.white));
          canvas.drawCircle(
            c,
            eyeR * 1.15,
            _stroke(ink.withValues(alpha: .3), s * .008),
          );
          glossyEye(Offset(c.dx + sign * eyeR * .34, c.dy), eyeR * .58);
        });

      case EyeStyle.mono:
        canvas.drawCircle(Offset(f.dx, eyeY), eyeR * 1.65, _fill(Colors.white));
        canvas.drawCircle(
          Offset(f.dx, eyeY),
          eyeR * 1.65,
          _stroke(ink.withValues(alpha: .35), s * .009),
        );
        glossyEye(Offset(f.dx, eyeY), eyeR * .90);
    }

    // Brows: a whisper of one above each eye adds age and focus. Skipped for
    // closed and single-eye styles where there is nothing to sit above.
    if (spec.eyes != EyeStyle.closedHappy &&
        spec.eyes != EyeStyle.sleepy &&
        spec.eyes != EyeStyle.mono) {
      for (final int sign in const <int>[-1, 1]) {
        canvas.drawPath(
          Path()
            ..moveTo(f.dx + sign * eyeDx - eyeR * .70, eyeY - eyeR * 1.42)
            ..quadraticBezierTo(
              f.dx + sign * eyeDx,
              eyeY - eyeR * 1.86,
              f.dx + sign * eyeDx + eyeR * .70,
              eyeY - eyeR * 1.46,
            ),
          _stroke(_shade(_body, -.30).withValues(alpha: .38), s * .010),
        );
      }
    }

    if (spec.blush) {
      for (final int sign in const <int>[-1, 1]) {
        // Feathered rather than a hard flat lozenge, which used to read as a
        // sticker sitting on top of the cheek.
        final Rect r0 = Rect.fromCenter(
          center: Offset(f.dx + sign * r * .80, eyeY + r * .38),
          width: r * .52,
          height: r * .32,
        );
        canvas.drawOval(
          r0,
          Paint()
            ..shader = RadialGradient(
              colors: <Color>[
                _accent.withValues(alpha: .50),
                _accent.withValues(alpha: .28),
                _accent.withValues(alpha: 0),
              ],
              stops: const <double>[0, .55, 1],
            ).createShader(r0)
            ..isAntiAlias = true,
        );
      }
    }

    // Mouth — skipped where the snout already provides one.
    const Set<SnoutType> mouthless = <SnoutType>{
      SnoutType.beakSmall,
      SnoutType.beakLong,
      SnoutType.duckBill,
      SnoutType.longJaw,
      SnoutType.trunk,
      SnoutType.buckTeeth,
      SnoutType.longFace,
    };
    if (!mouthless.contains(spec.snout)) {
      final double my =
          f.dy +
          r *
              switch (spec.snout) {
                SnoutType.none => .42,
                // Clear of the nose, which on these two reaches well down the
                // face and would otherwise swallow the smile.
                SnoutType.bigNose => 1.02,
                _ => .66,
              };
      // A shallow double curve reads as a smiling muzzle; a single arc reads
      // as a drawn-on frown at small sizes.
      canvas.drawPath(
        Path()
          ..moveTo(f.dx - r * .22, my - r * .02)
          ..quadraticBezierTo(f.dx - r * .10, my + r * .16, f.dx, my + r * .05)
          ..quadraticBezierTo(
            f.dx + r * .10,
            my + r * .16,
            f.dx + r * .22,
            my - r * .02,
          ),
        _stroke(ink.withValues(alpha: .80), s * .013),
      );
    }
  }

  // ----------------------------------------------------------------- accents

  void _drawBackAccent(Canvas canvas, double s, _Anatomy a) {
    switch (spec.accent) {
      case Accent.cloud:
        final Rect b = a.bodyBounds;
        final Paint p = _fill(Colors.white.withValues(alpha: .55));
        canvas.drawCircle(
          Offset(b.left + b.width * .10, b.bottom),
          b.width * .22,
          p,
        );
        canvas.drawCircle(
          Offset(b.center.dx, b.bottom + s * .012),
          b.width * .27,
          p,
        );
        canvas.drawCircle(
          Offset(b.right - b.width * .10, b.bottom),
          b.width * .22,
          p,
        );
      case Accent.moon:
        canvas.drawPath(
          Path()
            ..addOval(
              Rect.fromCircle(
                center: Offset(.80 * s, .20 * s),
                radius: s * .085,
              ),
            )
            ..addOval(
              Rect.fromCircle(
                center: Offset(.845 * s, .175 * s),
                radius: s * .072,
              ),
            )
            ..fillType = PathFillType.evenOdd,
          _fill(const Color(0xFFFFE9A8)),
        );
      case Accent.sparkles:
        for (final Offset o in const <Offset>[
          Offset(.16, .26),
          Offset(.86, .34),
          Offset(.24, .70),
        ]) {
          _star(
            canvas,
            Offset(o.dx * s, o.dy * s),
            s * .040,
            _fill(_accent.withValues(alpha: .9)),
          );
        }
      case Accent.bubbles:
        for (final Offset o in const <Offset>[
          Offset(.84, .24),
          Offset(.90, .40),
          Offset(.16, .32),
        ]) {
          final Offset c = Offset(o.dx * s, o.dy * s);
          canvas.drawCircle(
            c,
            s * .034,
            _fill(Colors.white.withValues(alpha: .34)),
          );
          canvas.drawCircle(
            c,
            s * .034,
            _stroke(Colors.white.withValues(alpha: .55), s * .005),
          );
          canvas.drawCircle(
            Offset(c.dx - s * .011, c.dy - s * .012),
            s * .008,
            _fill(Colors.white.withValues(alpha: .8)),
          );
        }
      case Accent.fireflies:
        for (final Offset o in const <Offset>[
          Offset(.14, .34),
          Offset(.88, .28),
          Offset(.82, .62),
        ]) {
          final Offset c = Offset(o.dx * s, o.dy * s);
          canvas.drawCircle(c, s * .038, _fill(_accent.withValues(alpha: .28)));
          canvas.drawCircle(c, s * .014, _fill(_accent));
        }
      case Accent.snowflake:
        final Offset c = Offset(.85 * s, .24 * s);
        for (int i = 0; i < 3; i++) {
          final double ang = i * math.pi / 3;
          canvas.drawLine(
            Offset(
              c.dx - math.cos(ang) * s * .05,
              c.dy - math.sin(ang) * s * .05,
            ),
            Offset(
              c.dx + math.cos(ang) * s * .05,
              c.dy + math.sin(ang) * s * .05,
            ),
            _stroke(Colors.white.withValues(alpha: .85), s * .011),
          );
        }
      default:
        break;
    }
  }

  /// The carapace, laid over the back after the body is lit and clipped to the
  /// torso so it stops at the neck. Drawn behind the creature it was invisible;
  /// drawn unclipped it swallowed the face.
  void _drawShell(Canvas canvas, double s, _Anatomy a) {
    if (spec.accent != Accent.shellPlate) return;
    final Rect b = a.bodyBounds;
    final Rect dome = Rect.fromCenter(
      center: Offset(b.center.dx, b.top + b.height * .48),
      width: b.width * 1.06,
      height: b.height * 1.24,
    );
    // The rim bows down in the middle rather than cutting straight across, so
    // the shell wraps the back instead of sitting on it like a lid.
    final Path shell = Path()
      ..moveTo(dome.left, dome.center.dy)
      ..arcTo(dome, math.pi, math.pi, false)
      ..quadraticBezierTo(
        dome.center.dx,
        dome.center.dy + dome.height * .20,
        dome.left,
        dome.center.dy,
      )
      ..close();
    canvas.save();
    canvas.clipPath(a.torso);
    canvas.drawPath(shell, _volume(_shade(_detail, .04), dome, lift: .18));
    // Scutes: a ring of marginal plates around the rim and a row of vertebrals
    // over the crown. Without them the dome is just a second body colour.
    final Paint seam = _stroke(
      _shade(_detail, -.26).withValues(alpha: .80),
      s * .010,
    );
    final Rect inner = Rect.fromCenter(
      center: dome.center,
      width: dome.width * .64,
      height: dome.height * .64,
    );
    for (int i = -3; i <= 3; i++) {
      final double ang = math.pi + (i + 3.5) / 7 * math.pi;
      canvas.drawLine(
        Offset(
          dome.center.dx + math.cos(ang) * inner.width * .5,
          dome.center.dy + math.sin(ang) * inner.height * .5,
        ),
        Offset(
          dome.center.dx + math.cos(ang) * dome.width * .5,
          dome.center.dy + math.sin(ang) * dome.height * .5,
        ),
        seam,
      );
    }
    canvas.drawArc(inner, math.pi, math.pi, false, seam);
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(inner.center.dx + i * inner.width * .30, inner.center.dy),
        Offset(
          inner.center.dx + i * inner.width * .34,
          inner.top + inner.height * .06,
        ),
        seam,
      );
    }
    canvas.drawPath(shell, _stroke(_shade(_detail, -.24), s * .013));
    canvas.restore();
  }

  void _drawFrontAccent(Canvas canvas, double s, _Anatomy a) {
    final Offset f = a.faceCenter;
    final double r = a.faceRadius;
    final Rect b = a.bodyBounds;

    switch (spec.accent) {
      case Accent.flower:
        final Offset c = Offset(f.dx + r * 1.02, f.dy - r * .94);
        for (int i = 0; i < 5; i++) {
          final double ang = i * math.pi * 2 / 5;
          final Offset pc = Offset(
            c.dx + math.cos(ang) * r * .24,
            c.dy + math.sin(ang) * r * .24,
          );
          canvas.drawCircle(
            pc,
            r * .18,
            _volume(_accent, Rect.fromCircle(center: pc, radius: r * .18)),
          );
        }
        canvas.drawCircle(c, r * .14, _fill(const Color(0xFFFFE07A)));
        canvas.drawCircle(
          Offset(c.dx - r * .04, c.dy - r * .04),
          r * .05,
          _fill(Colors.white.withValues(alpha: .6)),
        );

      case Accent.petals:
        for (int i = 0; i < 4; i++) {
          final double ang = -1.9 + i * .55;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(
                f.dx + math.cos(ang) * r * 1.15,
                f.dy + math.sin(ang) * r * 1.15,
              ),
              width: r * .34,
              height: r * .20,
            ),
            _fill(_accent.withValues(alpha: .9)),
          );
        }

      case Accent.leaf:
        final Path p = Path()
          ..moveTo(f.dx + r * .55, f.dy - r * 1.00)
          ..quadraticBezierTo(
            f.dx + r * 1.45,
            f.dy - r * 1.45,
            f.dx + r * 1.20,
            f.dy - r * .70,
          )
          ..quadraticBezierTo(
            f.dx + r * .85,
            f.dy - r * .72,
            f.dx + r * .55,
            f.dy - r * 1.00,
          )
          ..close();
        canvas.drawPath(
          p,
          _volume(const Color(0xFF7FC97F), p.getBounds(), lift: .16),
        );
        canvas.drawPath(
          Path()
            ..moveTo(f.dx + r * .62, f.dy - r * .98)
            ..quadraticBezierTo(
              f.dx + r * 1.02,
              f.dy - r * 1.02,
              f.dx + r * 1.24,
              f.dy - r * .82,
            ),
          _stroke(const Color(0xFF5EA85E).withValues(alpha: .8), s * .007),
        );

      case Accent.scarf:
        // Sits at the neck and stays inside the shoulders — a band wider than
        // the body at that height reads as a bar floating in front of it.
        final double y = b.top + b.height * .12;
        final Rect band = Rect.fromCenter(
          center: Offset(b.center.dx, y),
          width: b.width * .70,
          height: b.height * .15,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(band, Radius.circular(s * .016)),
          _volume(_accent, band, lift: .14),
        );
        final Rect tail = Rect.fromCenter(
          center: Offset(b.center.dx + b.width * .22, y + b.height * .18),
          width: b.width * .15,
          height: b.height * .26,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(tail, Radius.circular(s * .012)),
          _volume(_shade(_accent, -.08), tail),
        );

      case Accent.bow:
        final Offset c = Offset(f.dx + r * .98, f.dy - r * .92);
        for (final int sign in const <int>[-1, 1]) {
          final Rect r0 = Rect.fromCenter(
            center: Offset(c.dx + sign * r * .26, c.dy),
            width: r * .40,
            height: r * .32,
          );
          canvas.drawOval(r0, _volume(_accent, r0, lift: .16));
          canvas.drawOval(
            r0,
            _stroke(_shade(_accent, -.26).withValues(alpha: .5), s * .006),
          );
        }
        canvas.drawCircle(c, r * .11, _fill(_shade(_accent, -.12)));

      case Accent.glasses:
        final double eyeDx = r * .46 * spec.eyeSpacing;
        final Paint p = _stroke(_detail, s * .011);
        for (final int sign in const <int>[-1, 1]) {
          final Offset c = Offset(f.dx + sign * eyeDx, f.dy - r * .06);
          // Faint glass so the lens reads as a surface, not an empty ring.
          canvas.drawCircle(
            c,
            r * .34,
            _fill(Colors.white.withValues(alpha: .16)),
          );
          canvas.drawCircle(c, r * .34, p);
          canvas.drawPath(
            Path()
              ..moveTo(c.dx - r * .22, c.dy - r * .14)
              ..lineTo(c.dx - r * .06, c.dy - r * .26),
            _stroke(Colors.white.withValues(alpha: .55), s * .008),
          );
        }
        canvas.drawLine(
          Offset(f.dx - eyeDx + r * .34, f.dy - r * .06),
          Offset(f.dx + eyeDx - r * .34, f.dy - r * .06),
          p,
        );

      case Accent.cheekTuft:
        for (final int sign in const <int>[-1, 1]) {
          for (int i = 0; i < 3; i++) {
            final Offset c = Offset(
              f.dx + sign * r * (1.02 + i * .05),
              f.dy + r * (.05 + i * .30),
            );
            canvas.drawCircle(
              c,
              r * .20,
              _volume(_belly, Rect.fromCircle(center: c, radius: r * .20)),
            );
          }
        }

      case Accent.beardTuft:
        final Rect r0 = Rect.fromCenter(
          center: Offset(f.dx, f.dy + r * 1.05),
          width: r * .60,
          height: r * .78,
        );
        canvas.drawOval(r0, _volume(_belly, r0, lift: .14));

      case Accent.gem:
        final Offset c = Offset(f.dx, f.dy - r * .78);
        final Path p = Path()
          ..moveTo(c.dx, c.dy - r * .26)
          ..lineTo(c.dx + r * .20, c.dy)
          ..lineTo(c.dx, c.dy + r * .28)
          ..lineTo(c.dx - r * .20, c.dy)
          ..close();
        canvas.drawPath(
          p,
          _volume(_accent, p.getBounds(), lift: .24, drop: -.18),
        );
        // Facet split, so the gem catches light on one side only.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - r * .26)
            ..lineTo(c.dx - r * .20, c.dy)
            ..lineTo(c.dx, c.dy + r * .28)
            ..close(),
          _fill(Colors.white.withValues(alpha: .28)),
        );

      case Accent.star:
        _star(
          canvas,
          Offset(f.dx + r * 1.00, f.dy - r * .95),
          r * .34,
          _fill(_accent),
        );

      case Accent.droplet:
        final Path p = Path()
          ..moveTo(f.dx + r * 1.05, f.dy - r * 1.20)
          ..quadraticBezierTo(
            f.dx + r * 1.34,
            f.dy - r * .78,
            f.dx + r * 1.05,
            f.dy - r * .70,
          )
          ..quadraticBezierTo(
            f.dx + r * .78,
            f.dy - r * .78,
            f.dx + r * 1.05,
            f.dy - r * 1.20,
          )
          ..close();
        canvas.drawPath(
          p,
          _volume(const Color(0xFF8FD6FF), p.getBounds(), lift: .20),
        );
        canvas.drawCircle(
          Offset(f.dx + r * .98, f.dy - r * .86),
          r * .06,
          _fill(Colors.white.withValues(alpha: .75)),
        );

      case Accent.crackedEgg:
        // Jagged rim across the top, then one curve that carries the sides
        // under the body. A flat base read as a bucket the chick was standing
        // in rather than the bottom half of a shell it is sitting in.
        final double lx = b.left + b.width * .02;
        final double ly = b.bottom - b.height * .30;
        final Path p = Path()
          ..moveTo(lx, ly)
          ..lineTo(b.left + b.width * .20, b.bottom - b.height * .44)
          ..lineTo(b.left + b.width * .38, b.bottom - b.height * .28)
          ..lineTo(b.left + b.width * .56, b.bottom - b.height * .44)
          ..lineTo(b.left + b.width * .76, b.bottom - b.height * .28)
          ..lineTo(b.left + b.width * .98, b.bottom - b.height * .42)
          // Controls sit outside and below the body so the bowl bulges past
          // the rim on the way down and bottoms out just under the baseline.
          ..cubicTo(
            b.right + b.width * .08,
            b.bottom + b.height * .14,
            b.left - b.width * .08,
            b.bottom + b.height * .14,
            lx,
            ly,
          )
          ..close();
        canvas.drawPath(
          p,
          _volume(
            const Color(0xFFFFF3DC),
            p.getBounds(),
            lift: .06,
            drop: -.12,
          ),
        );
        canvas.drawPath(p, _stroke(const Color(0xFFE0CDA9), s * .010));

      default:
        break;
    }
  }

  // ----------------------------------------------------------------- helpers

  /// A solid shape that tapers from [w0] at [a] to [w1] at [b] along a
  /// quadratic spine. Tails and horns built this way have real thickness where
  /// they meet the body, which is what stops them reading as loose wires.
  static Path _taper(Offset a, Offset c, Offset b, double w0, double w1) {
    final Offset n0 = _perp(c - a) * w0;
    final Offset n1 = _perp(b - c) * w1;
    return Path()
      ..moveTo(a.dx + n0.dx, a.dy + n0.dy)
      ..quadraticBezierTo(
        c.dx + (n0.dx + n1.dx) * .5,
        c.dy + (n0.dy + n1.dy) * .5,
        b.dx + n1.dx,
        b.dy + n1.dy,
      )
      ..lineTo(b.dx - n1.dx, b.dy - n1.dy)
      ..quadraticBezierTo(
        c.dx - (n0.dx + n1.dx) * .5,
        c.dy - (n0.dy + n1.dy) * .5,
        a.dx - n0.dx,
        a.dy - n0.dy,
      )
      ..close();
  }

  /// Unit normal to a vector, or a safe default for a zero-length one.
  static Offset _perp(Offset v) {
    final double len = v.distance;
    if (len < 1e-6) return const Offset(0, 1);
    return Offset(-v.dy / len, v.dx / len);
  }

  static void _star(Canvas canvas, Offset c, double r, Paint p) {
    final Path path = Path();
    for (int i = 0; i < 10; i++) {
      final double ang = -math.pi / 2 + i * math.pi / 5;
      final double rad = i.isEven ? r : r * .44;
      final Offset o = Offset(
        c.dx + math.cos(ang) * rad,
        c.dy + math.sin(ang) * rad,
      );
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }
}

/// Surface treatment, inferred from the spec rather than declared on it.
enum _Coat { fur, feather, scale, smooth, slime }

/// Unit-space proportions for one [BodyShape].
class _Plan {
  const _Plan({
    required this.bodyTop,
    required this.bodyBot,
    required this.halfW,
    required this.topRound,
    required this.botRound,
    required this.waist,
    required this.headCy,
    required this.headR,
    required this.headW,
    required this.headH,
    this.headCx = 0,
    this.lean = 0,
    this.merged = false,
  });

  final double bodyTop;
  final double bodyBot;
  final double halfW;
  final double topRound;
  final double botRound;
  final double waist;

  /// Head centre, as an offset from the body centre line.
  final double headCx;
  final double headCy;
  final double headR;
  final double headW;
  final double headH;

  final double lean;

  /// True where head and body are one continuous form — fish, jellyfish,
  /// starfish — so no jaw shadow is drawn between them.
  final bool merged;
}

class _Anatomy {
  const _Anatomy({
    required this.body,
    required this.head,
    required this.silhouette,
    required this.bristles,
    required this.torso,
    required this.neck,
    required this.merged,
    required this.rim,
    required this.occlusion,
    required this.bounds,
    required this.bodyBounds,
    required this.markRect,
    required this.headBounds,
    required this.faceCenter,
    required this.faceRadius,
    required this.headTop,
    required this.headHalfWidth,
    required this.halfW,
    required this.lean,
  });

  /// Torso alone.
  final Path body;

  /// Head alone.
  final Path head;

  /// Union of [body] and [head] — the shape that gets lit as one form.
  final Path silhouette;

  /// Roots for a coat of quills, sampled off the upper outline. Empty unless
  /// the creature actually wears spikes.
  final List<_Bristle> bristles;

  /// The torso with the head subtracted out. Body markings clip to this, so a
  /// stripe or a spot can never run across the face.
  final Path torso;

  /// Crescent under the jaw that separates head from body.
  final Path neck;

  final bool merged;

  /// Lit crescent along the top-left edge of [silhouette].
  final Path rim;

  /// Shaded crescent along the bottom-right edge of [silhouette].
  final Path occlusion;

  final Rect bounds;
  final Rect bodyBounds;

  /// The band of torso that body markings are laid out across — below the jaw
  /// on separate-headed plans, the whole body on merged ones.
  final Rect markRect;

  final Rect headBounds;
  final Offset faceCenter;
  final double faceRadius;
  final Offset headTop;
  final double headHalfWidth;
  final double halfW;
  final double lean;
}

/// One quill root: a point on the silhouette and the outward normal there.
class _Bristle {
  const _Bristle(this.at, this.angle);

  final Offset at;
  final double angle;
}

/// Tiny deterministic PRNG so a creature's freckles never move between frames.
class _Rng {
  _Rng(int seed) : _s = (seed & 0x7fffffff) | 1;
  int _s;

  double next() {
    _s = (_s * 1103515245 + 12345) & 0x7fffffff;
    return _s / 0x7fffffff;
  }
}
