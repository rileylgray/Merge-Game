import 'day.dart';
import 'kit.dart';
import 'mythical.dart';
import 'night.dart';
import 'prehistoric.dart';
import 'water.dart';

export 'kit.dart' show Pen;

/// One creature's artwork: a drawing routine plus the size of its footprint.
class CreatureArt {
  const CreatureArt(this.draw, {this.shadow = .28, this.shadowDx = 0});

  /// Paints the creature into the unit layout.
  final void Function(Pen p) draw;

  /// Half-width of the contact shadow, in unit layout.
  final double shadow;

  /// Sideways offset of the contact shadow, for creatures that stand off-centre.
  final double shadowDx;
}

/// Every creature's artwork, keyed by creature id.
const Map<String, CreatureArt> kCreatureArt = <String, CreatureArt>{
  ...dayArt,
  ...nightArt,
  ...waterArt,
  ...mythicalArt,
  ...prehistoricArt,
};
