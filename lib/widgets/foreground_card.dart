import 'dart:io';
import 'package:flutter/material.dart';

/// ForegroundCard displays the original photo as a floating premium card.
/// Sizing constraints are calculated and controlled dynamically by the layout builder.
class ForegroundCard extends StatelessWidget {
  final File imageFile;
  final double borderRadius;
  final double shadowBlur;
  final double shadowOpacity;
  final Widget? overlay;

  const ForegroundCard({
    super.key,
    required this.imageFile,
    this.borderRadius = 28.0,
    this.shadowBlur = 45.0,
    this.shadowOpacity = 0.25,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Ambient Light Edge (Micro border) to enhance depth on dark backdrops
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 0.8,
        ),
        boxShadow: [
          // Large soft ambient shadow
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity * 0.65),
            blurRadius: shadowBlur,
            spreadRadius: -5,
            offset: const Offset(0, 16),
          ),
          // Tight crisp occlusion shadow
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity * 0.35),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 0.8), // Align with border width
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
    );
  }
}
