import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/stepped_animation.dart';

/// The wrapped basket that sits in a cell until the player taps it.
///
/// It rocks and glows on a loop so it reads as "open me" at a glance, even in
/// a meadow already crowded with idling creatures.
class MysteryBasketView extends StatefulWidget {
  const MysteryBasketView({
    super.key,
    required this.accent,
    this.animate = true,
  });

  final Color accent;
  final bool animate;

  @override
  State<MysteryBasketView> createState() => _MysteryBasketViewState();
}

class _MysteryBasketViewState extends State<MysteryBasketView>
    with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(milliseconds: 1600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  /// Every frame of this rebuilds three gradients and two blurred shadows, so
  /// it is sampled rather than followed — see [SteppedAnimation].
  late final SteppedAnimation _clock =
      SteppedAnimation.fps(_controller, cycle: _cycle);

  /// Held still when the platform asks for less motion. The halo and the
  /// question mark still make the basket the loudest thing in the meadow, so
  /// nothing is lost but the rocking.
  bool get _animating =>
      widget.animate && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  void _syncAnimation() {
    if (_animating) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  // Reads MediaQuery, so the decision cannot be made in initState.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant MysteryBasketView old) {
    super.didUpdateWidget(old);
    _syncAnimation();
  }

  @override
  void dispose() {
    _clock.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool animating = _animating;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double side = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 64,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 64,
        );

        // The rock and the pulse both run at sixty frames a second, and the
        // halo and the lid's drop shadow are gradients and blurs. Left in the
        // shared layer they drag the whole meadow through a repaint with them.
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _clock,
            builder: (BuildContext context, Widget? child) {
              final double t = _clock.value;
              final double wobble =
                  animating ? math.sin(t * math.pi * 2) * .08 : 0;
              final double pulse =
                  animating ? (math.sin(t * math.pi * 4) * .5 + .5) : .5;

              return Center(
                child: SizedBox.square(
                  dimension: side,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Halo — the part that carries across a busy backdrop.
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              Colors.white
                                  .withValues(alpha: .30 + pulse * .30),
                              widget.accent.withValues(alpha: .16),
                              widget.accent.withValues(alpha: 0),
                            ],
                            stops: const <double>[0, .55, 1],
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: wobble,
                        child: Container(
                          width: side * .62,
                          height: side * .62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color.alphaBlend(
                                  Colors.white.withValues(alpha: .35),
                                  widget.accent,
                                ),
                                widget.accent,
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .22),
                                blurRadius: side * .10,
                                offset: Offset(0, side * .05),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            size: side * .36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // The question mark rides above the lid, off to one side
                      // so it never sits on top of the icon it is annotating.
                      Positioned(
                        right: side * .10,
                        top: side * .08,
                        child: Container(
                          width: side * .30,
                          height: side * .30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .18),
                                blurRadius: side * .06,
                              ),
                            ],
                          ),
                          child: FittedBox(
                            child: Padding(
                              padding: EdgeInsets.all(side * .04),
                              child: Text(
                                '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: widget.accent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
