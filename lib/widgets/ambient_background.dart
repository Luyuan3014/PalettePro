import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// AmbientBackground renders the blurred, color-adjusted background layer.
/// It implements cover-scaling, Gaussian blur, brightness reduction,
/// saturation reduction, vignette, and subtle parallax movement.
class AmbientBackground extends StatelessWidget {
  final File? imageFile;
  final double blur;
  final double scale;
  final double brightness;
  final double saturation;
  final Color? dominantColor;
  final Offset parallaxOffset;
  final bool showVignette;

  const AmbientBackground({
    super.key,
    required this.imageFile,
    this.blur = 50.0,
    this.scale = 1.4,
    this.brightness = 0.7,
    this.saturation = 0.6,
    this.dominantColor,
    this.parallaxOffset = Offset.zero,
    this.showVignette = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(color: const Color(0xFF101010));
    }

    // Saturation adjustment matrix
    final double s = saturation;
    final double r = 0.2126 * (1 - s);
    final double g = 0.7152 * (1 - s);
    final double b = 0.0722 * (1 - s);
    final List<double> saturationMatrix = [
      r + s, g, b, 0, 0,
      r, g + s, b, 0, 0,
      r, g, b + s, 0, 0,
      0, 0, 0, 1, 0,
    ];

    // Brightness adjustment matrix
    final List<double> brightnessMatrix = [
      brightness, 0, 0, 0, 0,
      0, brightness, 0, 0, 0,
      0, 0, brightness, 0, 0,
      0, 0, 0, 1, 0,
    ];

    // Parallax transformation: make it extremely subtle (5% offset)
    final double tx = parallaxOffset.dx * 0.05;
    final double ty = parallaxOffset.dy * 0.05;

    return Stack(
      children: [
        // 1. Scaled, Blurred, and Color-Adjusted Background Image
        Positioned.fill(
          child: ClipRect(
            child: Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: Offset(tx, ty),
                child: RepaintBoundary(
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(brightnessMatrix),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(saturationMatrix),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          // Performance Optimization: downsample cache width for background blur
                          // to dramatically reduce processing overhead of the Gaussian blur filter.
                          cacheWidth: 300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Translucent tint overlay (mixes dark wash with a hint of dominant color)
        Positioned.fill(
          child: Container(
            color: dominantColor != null
                ? Color.alphaBlend(
                    dominantColor!.withOpacity(0.12),
                    Colors.black.withOpacity(0.25),
                  )
                : Colors.black.withOpacity(0.35),
          ),
        ),

        // 3. Vignette overlay for elegant depth and focus
        if (showVignette)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
