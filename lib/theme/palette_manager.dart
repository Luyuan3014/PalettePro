import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Holds the extracted adaptive color scheme from the image.
class AppPalette {
  final Color dominant;
  final Color vibrant;
  final Color muted;
  final Color lightVibrant;
  final Color darkVibrant;
  final Color lightMuted;
  final Color darkMuted;

  /// Active accent color (tints buttons, sliders, highlights)
  final Color accent;
  /// Adaptive background base color (tinted with dominant color)
  final Color background;
  /// Accent text color (typically black or white depending on accent brightness)
  final Color onAccent;

  AppPalette({
    required this.dominant,
    required this.vibrant,
    required this.muted,
    required this.lightVibrant,
    required this.darkVibrant,
    required this.lightMuted,
    required this.darkMuted,
    required this.accent,
    required this.background,
    required this.onAccent,
  });

  /// Factory to generate a default dark palette when no image is loaded.
  factory AppPalette.defaultDark() {
    return AppPalette(
      dominant: const Color(0xFF1E1E1E),
      vibrant: const Color(0xFFE0E0E0),
      muted: const Color(0xFF9E9E9E),
      lightVibrant: Colors.white,
      darkVibrant: const Color(0xFF303030),
      lightMuted: const Color(0xFFB0B0B0),
      darkMuted: const Color(0xFF212121),
      accent: Colors.white,
      background: const Color(0xFF121212),
      onAccent: Colors.black,
    );
  }

  /// Extracts colors from an image file and constructs the AppPalette.
  static Future<AppPalette> extract(File imageFile) async {
    try {
      final imageProvider = FileImage(imageFile);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 16,
      );

      final dominantColor = paletteGenerator.dominantColor?.color ?? const Color(0xFF1E1E1E);
      
      // Determine the best accent color (prefer vibrant, lightVibrant, or darkVibrant)
      Color accent = paletteGenerator.vibrantColor?.color ?? 
                    paletteGenerator.lightVibrantColor?.color ?? 
                    paletteGenerator.darkVibrantColor?.color ?? 
                    paletteGenerator.dominantColor?.color ?? 
                    Colors.white;

      // Ensure accent is sufficiently visible on dark backgrounds
      // If it is too dark, we can lighten it
      if (ThemeData.estimateBrightnessForColor(accent) == Brightness.dark && accent != Colors.white) {
        accent = HSLColor.fromColor(accent).withLightness(0.65).toColor();
      }

      // Determine text color on accent background
      final onAccent = ThemeData.estimateBrightnessForColor(accent) == Brightness.light
          ? Colors.black
          : Colors.white;

      // Subtly tint the background with the dominant color
      final Color background = Color.alphaBlend(
        dominantColor.withOpacity(0.08),
        const Color(0xFF101010),
      );

      return AppPalette(
        dominant: dominantColor,
        vibrant: paletteGenerator.vibrantColor?.color ?? dominantColor,
        muted: paletteGenerator.mutedColor?.color ?? dominantColor,
        lightVibrant: paletteGenerator.lightVibrantColor?.color ?? Colors.white,
        darkVibrant: paletteGenerator.darkVibrantColor?.color ?? const Color(0xFF303030),
        lightMuted: paletteGenerator.lightMutedColor?.color ?? const Color(0xFFB0B0B0),
        darkMuted: paletteGenerator.darkMutedColor?.color ?? const Color(0xFF212121),
        accent: accent,
        background: background,
        onAccent: onAccent,
      );
    } catch (_) {
      return AppPalette.defaultDark();
    }
  }
}
