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
        // Ambient Light Edge (Micro border) to enhance depth on dark backdrops - refined to 0.5px
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: 0.5,
        ),
        boxShadow: [
          // 1. Bottom Ambient Shadow (Large blur, subtle spread, low opacity)
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity * 0.60),
            blurRadius: shadowBlur,
            spreadRadius: 2.0,
            offset: const Offset(0, 10),
          ),
          // 2. Top Core Drop Shadow (Smaller blur, tight spread, slightly higher relative opacity)
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity * 0.40),
            blurRadius: (shadowBlur * 0.33).clamp(4.0, 30.0),
            spreadRadius: -1.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 0.5), // Align with new border width
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
