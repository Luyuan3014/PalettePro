import 'dart:io';
import 'package:flutter/material.dart';

/// ForegroundCard displays the original photo as a floating premium card.
/// It strictly respects the original aspect ratio and scales proportionally
/// to stay within 90% of container width and 70% of container height.
class ForegroundCard extends StatelessWidget {
  final File imageFile;
  final double aspectRatio;
  final double borderRadius;
  final double shadowBlur;
  final double shadowOpacity;
  final Widget? overlay;

  const ForegroundCard({
    super.key,
    required this.imageFile,
    required this.aspectRatio,
    this.borderRadius = 28.0,
    this.shadowBlur = 45.0,
    this.shadowOpacity = 0.35,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double parentWidth = constraints.maxWidth;
        final double parentHeight = constraints.maxHeight;

        // Limit size according to specifications (Width <= 90%, Height <= 70%)
        final double maxWidthLimit = parentWidth * 0.90;
        final double maxHeightLimit = parentHeight * 0.70;

        // Proportional layout math
        double cardWidth = maxWidthLimit;
        double cardHeight = maxWidthLimit / aspectRatio;

        if (cardHeight > maxHeightLimit) {
          cardHeight = maxHeightLimit;
          cardWidth = maxHeightLimit * aspectRatio;
        }

        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  blurRadius: shadowBlur,
                  spreadRadius: 2,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // High-fidelity original photo
                  Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                  // Optional custom overlay
                  if (overlay != null) overlay!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
