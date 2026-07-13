import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/palette_manager.dart';

/// AmbientBackground renders the blurred, color-adjusted background layer.
/// It implements cover-scaling, Gaussian blur, brightness reduction,
/// saturation reduction, vignette, film noise grain, and subtle parallax movement.
class AmbientBackground extends StatefulWidget {
  final File? imageFile;
  final double blur;
  final double scale;
  final double brightness;
  final double saturation;
  final Color? dominantColor; // Kept for backward compatibility
  final AppPalette? palette;
  final Offset parallaxOffset;
  final bool showVignette;

  const AmbientBackground({
    super.key,
    required this.imageFile,
    this.blur = 90.0,
    this.scale = 2.0,
    this.brightness = 0.55,
    this.saturation = 0.8,
    this.dominantColor,
    this.palette,
    this.parallaxOffset = Offset.zero,
    this.showVignette = true,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> {
  static ui.Image? _noiseImage;
  static bool _isGeneratingNoise = false;

  @override
  void initState() {
    super.initState();
    _ensureNoiseGenerated();
  }

  void _ensureNoiseGenerated() {
    if (_noiseImage != null || _isGeneratingNoise) return;
    _isGeneratingNoise = true;

    Future.microtask(() async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      final random = math.Random(12345); // Fixed seed to ensure stable grain position

      for (int x = 0; x < 128; x++) {
        for (int y = 0; y < 128; y++) {
          final int alpha = random.nextInt(18); // Ultra-subtle analog grain (max ~7% opacity)
          final int grey = random.nextInt(256);
          paint.color = Color.fromARGB(alpha, grey, grey, grey);
          canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(128, 128);
      _noiseImage = img;
      _isGeneratingNoise = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageFile == null) {
      return Container(color: const Color(0xFF0F0F11));
    }

    // Saturation adjustment matrix - boosted by 15% to prevent desaturation from blur
    final double s = (widget.saturation * 1.15).clamp(0.0, 2.0);
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
    final double br = widget.brightness;
    final List<double> brightnessMatrix = [
      br, 0, 0, 0, 0,
      0, br, 0, 0, 0,
      0, 0, br, 0, 0,
      0, 0, 0, 1, 0,
    ];

    // Contrast adjustment matrix (5% boost to ensure crisp bokeh details)
    final double c = 1.05;
    final double contrastOffset = 0.5 * (1.0 - c) * 255;
    final List<double> contrastMatrix = [
      c, 0, 0, 0, contrastOffset,
      0, c, 0, 0, contrastOffset,
      0, 0, c, 0, contrastOffset,
      0, 0, 0, 1, 0,
    ];

    // Parallax transformation: make it extremely subtle (5% offset)
    final double tx = widget.parallaxOffset.dx * 0.05;
    final double ty = widget.parallaxOffset.dy * 0.05;

    // Build color properties
    final Color domColor = widget.palette?.dominant ?? widget.dominantColor ?? const Color(0xFF1A1A1C);
    final Color vibrantColor = widget.palette?.vibrant ?? domColor;
    final Color darkDomColor = widget.palette?.darkVibrant ?? widget.palette?.darkMuted ?? Colors.black;

    return Stack(
      children: [
        // 1. Scaled, Blurred, and Color-Adjusted Background Image
        Positioned.fill(
          child: ClipRect(
            child: Transform.scale(
              scale: widget.scale,
              child: Transform.translate(
                offset: Offset(tx, ty),
                child: RepaintBoundary(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      (widget.palette?.lightVibrant ?? Colors.white).withOpacity(0.08),
                      BlendMode.screen,
                    ),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(contrastMatrix),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(brightnessMatrix),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(saturationMatrix),
                            child: Image.file(
                              widget.imageFile!,
                              fit: BoxFit.cover,
                              cacheWidth: 350,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2a. Liquid Color Flow Gradient Overlay (Screen blended for glow/bokeh)
        Positioned.fill(
          child: CustomPaint(
            painter: BlendModePainter(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  vibrantColor.withOpacity(0.20),
                  Colors.transparent,
                ],
              ),
              blendMode: BlendMode.screen,
            ),
          ),
        ),

        // 2b. Ambient Darkening Gradient (Normal blend mode to ground the canvas and text)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  darkDomColor.withOpacity(0.38),
                ],
              ),
            ),
          ),
        ),

        // 3. Film Grain Noise Texture Layer
        if (_noiseImage != null)
          Positioned.fill(
            child: CustomPaint(
              painter: NoisePainter(_noiseImage),
              willChange: false,
            ),
          ),

        // 4. Elegant Vignette overlay for depth
        if (widget.showVignette)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.25,
                  colors: [
                    Colors.transparent,
                    darkDomColor.withOpacity(0.45),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tiling painter for Film Noise Texture.
class NoisePainter extends CustomPainter {
  final ui.Image? noiseImage;
  NoisePainter(this.noiseImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (noiseImage == null) return;

    final paint = Paint()
      ..shader = ImageShader(
        noiseImage!,
        ui.TileMode.repeated,
        ui.TileMode.repeated,
        Float64List.fromList([
          1.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          0.0, 0.0, 0.0, 1.0,
        ]),
      )
      ..blendMode = BlendMode.srcOver;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return oldDelegate.noiseImage != noiseImage;
  }
}

/// Renders a gradient overlay using a custom blend mode
class BlendModePainter extends CustomPainter {
  final Gradient gradient;
  final BlendMode blendMode;

  BlendModePainter({required this.gradient, required this.blendMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..blendMode = blendMode;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant BlendModePainter oldDelegate) {
    return oldDelegate.gradient != gradient || oldDelegate.blendMode != blendMode;
  }
}
