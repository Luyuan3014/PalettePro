import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable GlassmorphicPanel widget implementing backdrop blur,
/// translucent color tinting, fine-drawn glowing borders, and drop shadows.
class GlassmorphicPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color tintColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const GlassmorphicPanel({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.08,
    this.tintColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tintColor.withOpacity(opacity),
              borderRadius: borderRadius,
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.0,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
