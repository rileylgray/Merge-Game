export 'creature_fits.g.dart' show kCreatureFits;

/// How one creature is sized and placed inside its paint box.
///
/// The layout is drawn in a unit square and then scaled about its ground line
/// ([groundY]) by [scale], shifted sideways by [dx], and pinned so the ground
/// lands at [groundTarget]. All three are fractions of the box's short side.
class CreatureFit {
  const CreatureFit(this.scale, this.dx, [this.groundTarget = kGroundTarget]);

  /// No fit at all: the unit layout exactly as drawn, overflow included. Only
  /// the measuring tool wants this.
  static const CreatureFit raw = CreatureFit(1, 0, groundY);

  /// Where the ground line sits in the unit layout.
  static const double groundY = 0.90;

  /// The largest scale any creature is drawn at, so a snail is not blown up to
  /// the size of a lion just because it has the room.
  static const double maxScale = 0.93;

  /// Where the ground line lands in the paint box. Every creature is pinned to
  /// it, so a stag shrunk to fit its antlers still stands on its perch like
  /// everyone else instead of floating a few pixels above it.
  static const double kGroundTarget = .5 + maxScale * (groundY - .5);

  final double scale;
  final double dx;
  final double groundTarget;

  @override
  bool operator ==(Object other) =>
      other is CreatureFit &&
      other.scale == scale &&
      other.dx == dx &&
      other.groundTarget == groundTarget;

  @override
  int get hashCode => Object.hash(scale, dx, groundTarget);
}
