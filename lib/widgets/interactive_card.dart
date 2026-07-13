import 'dart:math' as math;
import 'package:flutter/material.dart';

/// InteractiveCard adds gestural depth to the floating photo card.
/// Dragging the card translates, rotates, and scales it, and fires
/// parallax callbacks. Releasing triggers a physical spring snap-back
/// or an off-screen dismiss.
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final ValueChanged<Offset>? onOffsetChanged;
  final VoidCallback? onDismiss;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onOffsetChanged,
    this.onDismiss,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late final AnimationController _springController;
  late Animation<Offset> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _springController.addListener(() {
      setState(() {
        _dragOffset = _springAnimation.value;
      });
      widget.onOffsetChanged?.call(_dragOffset);
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _springController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
    widget.onOffsetChanged?.call(_dragOffset);
  }

  void _onPanEnd(DragEndDetails details) {
    final double distance = _dragOffset.distance;
    final double velocity = details.velocity.pixelsPerSecond.distance;

    // Threshold for swipe dismiss: either drag exceeds 180dp or swipe speed is high (> 1000 pixels/sec)
    if (widget.onDismiss != null && (distance > 180 || velocity > 1200)) {
      final Offset direction = distance > 0 ? _dragOffset / distance : Offset.zero;
      final Offset targetOffset = direction * 900.0; // Animate completely off-screen

      _springAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: targetOffset,
      ).animate(
        CurvedAnimation(
          parent: _springController,
          curve: Curves.easeOutCubic,
        ),
      );

      _springController.duration = const Duration(milliseconds: 250);
      _springController.forward(from: 0.0).then((_) {
        widget.onDismiss?.call();
      });
    } else {
      // Physical spring bounce snap back to origin
      _springAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _springController,
          curve: const ElasticOutCurve(0.75), // Tactile spring behavior
        ),
      );

      _springController.duration = const Duration(milliseconds: 700);
      _springController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double distance = _dragOffset.distance;

    // Drag-induced scale down (scales down to 90% at 1000px drag distance)
    final double scale = (1.0 - (distance / 1200)).clamp(0.9, 1.0);

    // Dynamic rotation angle proportional to horizontal drag
    final double angle = (_dragOffset.dx / 1200).clamp(-0.1, 0.1);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
class ElasticOutCurve extends Curve {
  final double period;

  const ElasticOutCurve([this.period = 0.4]);

  @override
  double transformInternal(double t) {
    final double s = period / 4.0;
    return math.pow(2.0, -10.0 * t) * math.sin((t - s) * (math.pi * 2.0) / period) + 1.0;
  }
}
