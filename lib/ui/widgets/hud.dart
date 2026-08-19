import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';

/// A pill showing one currency. Kept deliberately compact so both fit on the
/// narrowest supported phone alongside the boost chip.
///
/// It flashes when the balance jumps by more than the passive drip can
/// explain, which is what ties a sale or a reward back to the number it moved.
class CurrencyPill extends StatefulWidget {
  const CurrencyPill({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    this.subtitle,
    this.passiveRate = 0,
  });

  final IconData icon;
  final Color color;
  final double value;
  final String? subtitle;

  /// How fast this currency rises on its own, per second.
  ///
  /// Anything arriving faster than this is something the player *did* — a
  /// sale, a collected pile, a discovery bonus — and is worth a flash. Without
  /// it the hearts pill would strobe on every income tick.
  final double passiveRate;

  @override
  State<CurrencyPill> createState() => _CurrencyPillState();
}

class _CurrencyPillState extends State<CurrencyPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  late double _last = widget.value;
  DateTime _lastAt = DateTime.now();

  @override
  void didUpdateWidget(covariant CurrencyPill old) {
    super.didUpdateWidget(old);
    final DateTime now = DateTime.now();
    final double seconds = now.difference(_lastAt).inMicroseconds / 1e6;
    final double gain = widget.value - _last;
    _last = widget.value;
    _lastAt = now;

    // Half a unit of slack absorbs rounding noise, and makes a single gem read
    // as a gain while a fraction of a heart does not. The 1.5x margin covers a
    // tick that ran late without letting a real reward slip through.
    if (gain > widget.passiveRate * seconds * 1.5 + .5) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        // One hump: out and back, so the pill never settles anywhere but rest.
        final double swell = math.sin(_pulse.value * math.pi);
        return Transform.scale(
          scale: 1 + .13 * swell,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
                // A halo in the currency's own colour, so hearts and gems are
                // still tellable apart out of the corner of an eye.
                if (swell > 0)
                  BoxShadow(
                    color: widget.color.withValues(alpha: .55 * swell),
                    blurRadius: 16 * swell,
                    spreadRadius: 2 * swell,
                  ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: .18),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                formatCount(widget.value),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1.1,
                  color: AppTheme.ink,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink.withValues(alpha: .55),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The basket button: a grocery cart that fills from the wheels up and tips a
/// friend out at the brim, and every tap pours in a little more.
///
/// The level rises vertically rather than around a ring, so how close the next
/// friend is reads as a glance at a filling cart instead of an arc to measure.
///
/// This is the button the player touches more than every other control put
/// together, so it answers a press immediately rather than waiting for the
/// level to catch up, and it kicks when a friend actually drops out.
class BasketButton extends StatefulWidget {
  const BasketButton({
    super.key,
    required this.progress,
    required this.accent,
    required this.onTap,
    required this.label,
    this.full = false,
  });

  /// How full the basket is, 0..1.
  final double progress;
  final Color accent;
  final VoidCallback onTap;
  final String label;

  /// The meadow has no room, so the basket holds at the brim.
  final bool full;

  @override
  State<BasketButton> createState() => _BasketButtonState();
}

class _BasketButtonState extends State<BasketButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  bool _pressed = false;

  @override
  void didUpdateWidget(covariant BasketButton old) {
    super.didUpdateWidget(old);
    // The cart only ever empties when it has just tipped over the brim, so a
    // sharp drop is the one unambiguous signal that a friend came out.
    if (widget.progress < old.progress - .3) _spill.forward(from: 0);
  }

  @override
  void dispose() {
    _spill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      value: '${(widget.progress * 100).round()}%',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: SizedBox(
          width: 78,
          height: 78,
          child: AnimatedScale(
            scale: _pressed ? .93 : 1,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: Center(
              child: AnimatedScale(
                scale: widget.full ? .92 : 1,
                duration: const Duration(milliseconds: 200),
                // Tweening keeps the level gliding between game ticks instead
                // of stepping four times a second.
                child: _spillKick(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: widget.progress),
                    duration: const Duration(milliseconds: 240),
                    builder: (
                      BuildContext context,
                      double level,
                      Widget? child,
                    ) =>
                        _cart(level),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A quick swell on the basket face the moment it empties out.
  Widget _spillKick({required Widget child}) {
    return AnimatedBuilder(
      animation: _spill,
      builder: (BuildContext context, Widget? inner) => Transform.scale(
        scale: 1 + .16 * math.sin(_spill.value * math.pi),
        child: inner,
      ),
      child: child,
    );
  }

  /// The cart at [level] full, 0..1.
  ///
  /// Two layers rise together: the tile behind the cart takes on the meadow's
  /// colour from the bottom up, and the cart glyph itself is drawn twice —
  /// faint underneath, solid on top and cropped to the level — so the load
  /// climbs the cart the way groceries would.
  Widget _cart(double level) {
    final Color tint = widget.full ? Colors.grey : widget.accent;
    final double fill = level.clamp(0.0, 1.0);
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: widget.full ? Colors.white70 : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: fill,
                child: ColoredBox(color: tint.withValues(alpha: .20)),
              ),
            ),
            // A hard-edged gradient rather than a clip: the cut lands on the
            // exact same line whatever the glyph does, and there is no second
            // copy of the icon to keep in register with the first.
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) => LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  tint,
                  tint,
                  tint.withValues(alpha: .26),
                  tint.withValues(alpha: .26),
                ],
                stops: <double>[0, fill, fill, 1],
              ).createShader(bounds),
              child: const Icon(
                Icons.shopping_cart_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small chip announcing a temporary boost and the time it has left.
class BoostChip extends StatelessWidget {
  const BoostChip({
    super.key,
    required this.label,
    this.icon = Icons.bolt_rounded,
    this.color = AppTheme.heart,
    this.semanticsLabel,
  });

  final String label;
  final IconData icon;
  final Color color;

  /// Spoken instead of the bare countdown, which says nothing on its own.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (semanticsLabel == null) return chip;
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(child: chip),
    );
  }
}
