import 'dart:io';
import 'package:flutter/material.dart';
import '../models/effect_processor.dart';
import '../widgets/ambient_background.dart';
import '../widgets/foreground_card.dart';
import '../theme/palette_manager.dart';

/// Cinematic Frame (电影画幅) Layout Effect.
/// Renders the image over an ultra-darkened ambient backdrop, preserving
/// the photo card's aspect ratio, with film technical details below.
class CinemaEffectProcessor extends EffectProcessor {
  @override
  String get id => 'cinematic_frame';

  @override
  String get name => 'Cinematic Frame (电影)';

  @override
  IconData get icon => Icons.movie_filter_outlined;

  @override
  dynamic createDefaultConfig() {
    return {
      'blur': 90.0,
      'scale': 2.0,
      'brightness': 0.38, // Darker cinematic backdrop
      'saturation': 0.50, // More muted desaturated backdrop
      'radius': 24.0,
      'shadowBlur': 50.0,
      'shadowOpacity': 0.40,
      'device': 'SHOT ON DEVICE',
      'metadata': 'ISO 100  •  f/1.8  •  1/125s  •  50mm',
      'aspectRatio': 1.0,
      'palette': null,
    };
  }

  @override
  Widget buildEffect(BuildContext context, File originalImage, dynamic config) {
    final double blur = (config['blur'] as num?)?.toDouble() ?? 90.0;
    final double scale = (config['scale'] as num?)?.toDouble() ?? 2.0;
    final double brightness = (config['brightness'] as num?)?.toDouble() ?? 0.38;
    final double saturation = (config['saturation'] as num?)?.toDouble() ?? 0.50;
    final double radius = (config['radius'] as num?)?.toDouble() ?? 24.0;
    final double shadowBlur = (config['shadowBlur'] as num?)?.toDouble() ?? 50.0;
    final double shadowOpacity = (config['shadowOpacity'] as num?)?.toDouble() ?? 0.40;
    final String device = config['device']?.toString() ?? 'SHOT ON DEVICE';
    final String metadata = config['metadata']?.toString() ?? 'ISO 100  •  f/1.8  •  1/125s  •  50mm';
    final double aspectRatio = (config['aspectRatio'] as num?)?.toDouble() ?? 1.0;

    final AppPalette? palette = config['palette'] as AppPalette?;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Cinematic Ambient Background (deeply dimmed and desaturated ambient color bleed)
        Positioned.fill(
          child: AmbientBackground(
            imageFile: originalImage,
            blur: blur,
            scale: scale,
            brightness: brightness,
            saturation: saturation,
            palette: palette,
            showVignette: true,
          ),
        ),

        // 2. Translucent Cinematic overlays
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 180,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // 3. Content Stack (Card + Technical Text Details)
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            final canvasHeight = constraints.maxHeight;

            // Calculate card dimensions dynamically based on canvas ratios to preserve breathing room
            final double maxImgWidth = canvasWidth * 0.82;
            final double maxImgHeight = canvasHeight * 0.54;

            double imgWidth = maxImgWidth;
            double imgHeight = maxImgWidth / aspectRatio;

            if (imgHeight > maxImgHeight) {
              imgHeight = maxImgHeight;
              imgWidth = maxImgHeight * aspectRatio;
            }

            final deviceFontSize = (canvasWidth * 0.032).clamp(10.0, 13.0);
            final metadataFontSize = (canvasWidth * 0.026).clamp(8.0, 11.0);
            final spacingHeight = (canvasHeight * 0.035).clamp(12.0, 24.0);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: imgWidth,
                  height: imgHeight,
                  child: ForegroundCard(
                    imageFile: originalImage,
                    borderRadius: radius,
                    shadowBlur: shadowBlur,
                    shadowOpacity: shadowOpacity,
                  ),
                ),
                SizedBox(height: spacingHeight),
                Text(
                  device.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: deviceFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.5,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  metadata,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.42),
                    fontSize: metadataFontSize,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget buildConfigPanel(
    BuildContext context,
    dynamic config,
    ValueChanged<dynamic> onUpdate,
  ) {
    final Map<String, dynamic> cfg = Map<String, dynamic>.from(config as Map);
    final double blur = (cfg['blur'] as num?)?.toDouble() ?? 90.0;
    final double scale = (cfg['scale'] as num?)?.toDouble() ?? 2.0;
    final double brightness = (cfg['brightness'] as num?)?.toDouble() ?? 0.38;
    final double radius = (cfg['radius'] as num?)?.toDouble() ?? 24.0;
    final String device = cfg['device']?.toString() ?? 'SHOT ON DEVICE';
    final String metadata = cfg['metadata']?.toString() ?? 'ISO 100  •  f/1.8  •  1/125s  •  50mm';

    final AppPalette? palette = cfg['palette'] as AppPalette?;
    final Color accentColor = palette?.accent ?? Colors.white;

    const labelStyle = TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);

    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: Colors.white10,
        thumbColor: accentColor,
        overlayColor: accentColor.withOpacity(0.12),
        trackHeight: 3.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider: Blur
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Blur (模糊)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: blur,
                  min: 10.0,
                  max: 120.0,
                  onChanged: (val) {
                    cfg['blur'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(blur.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
              ),
            ],
          ),
          // Slider: Background Scale
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Scale (缩放)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: scale,
                  min: 1.0,
                  max: 2.5,
                  onChanged: (val) {
                    cfg['scale'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text('${scale.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
              ),
            ],
          ),
          // Slider: Brightness
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Dim (暗度)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: 1.0 - brightness,
                  min: 0.0,
                  max: 0.8,
                  onChanged: (val) {
                    cfg['brightness'] = 1.0 - val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text('${((1.0 - brightness) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
              ),
            ],
          ),
          // Slider: Radius
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Radius (圆角)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: radius,
                  min: 0.0,
                  max: 48.0,
                  onChanged: (val) {
                    cfg['radius'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(radius.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Text Fields (Device, Metadata)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: device)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: device.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Device info (e.g. Shot on...)',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      cfg['device'] = val;
                      onUpdate(cfg);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: metadata)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: metadata.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Camera metrics (e.g. ISO 100...)',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      cfg['metadata'] = val;
                      onUpdate(cfg);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
