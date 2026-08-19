import 'package:flutter/material.dart';

import '../../data/accessory.dart';
import '../../render/accessory_painter.dart';

/// An accessory drawn on its own, framed to fill its box.
///
/// The shop needs to show what an item is without a creature under it, and a
/// picker chip has no room for one, so the same art is reused headless.
class AccessoryIcon extends StatelessWidget {
  const AccessoryIcon(this.type, {super.key, this.size});

  final AccessoryType type;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final Widget painted = CustomPaint(
      painter: _AccessoryIconPainter(type),
      size: Size.infinite,
    );
    return size == null
        ? painted
        : SizedBox.square(dimension: size, child: painted);
  }
}

class _AccessoryIconPainter extends CustomPainter {
  const _AccessoryIconPainter(this.type);

  final AccessoryType type;

  @override
  void paint(Canvas canvas, Size size) =>
      AccessoryArt.paintIcon(canvas, size, type);

  @override
  bool shouldRepaint(covariant _AccessoryIconPainter old) => old.type != type;
}
