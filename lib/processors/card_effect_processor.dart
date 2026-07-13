import 'dart:io';
import 'package:flutter/material.dart';
import '../models/effect_processor.dart';
import '../widgets/ambient_background.dart';
import '../widgets/foreground_card.dart';
import '../theme/palette_manager.dart';

/// Charming Creek (溪谷卡片) Card Layout Effect.
/// Renders a blurred, tint-adjusted background, a floating photo card,
/// and serif titles.
class CardEffectProcessor extends EffectProcessor {
  @override
  String get id => 'charming_creek';

  @override
  String get name => 'Charming Creek (溪谷)';

  @override
  IconData get icon => Icons.filter_hdr_outlined;

  @override
  dynamic createDefaultConfig() {
    return {
      'blur': 90.0,
      'scale': 2.0,
      'brightness': 0.55,
      'saturation': 0.8,
      'radius': 28.0,
      'shadowBlur': 55.0,
      'shadowOpacity': 0.24,
      'title': '- xiao xi -',
      'subtitle': '© PalettePro Capture',
      'fontFamily': 'serif',
      'aspectRatio': 1.0,
      'palette': null, // Injected by notifier
    };
  }

  @override
  Widget buildEffect(BuildContext context, File originalImage, dynamic config) {
    final double blur = (config['blur'] as num?)?.toDouble() ?? 90.0;
    final double scale = (config['scale'] as num?)?.toDouble() ?? 2.0;
    final double brightness = (config['brightness'] as num?)?.toDouble() ?? 0.55;
    final double saturation = (config['saturation'] as num?)?.toDouble() ?? 0.8;
    final double radius = (config['radius'] as num?)?.toDouble() ?? 28.0;
    final double shadowBlur = (config['shadowBlur'] as num?)?.toDouble() ?? 55.0;
    final double shadowOpacity = (config['shadowOpacity'] as num?)?.toDouble() ?? 0.24;
    final String title = config['title']?.toString() ?? '- xiao xi -';
    final String subtitle = config['subtitle']?.toString() ?? '© PalettePro Capture';
    final String fontFamily = config['fontFamily']?.toString() ?? 'serif';
    final double aspectRatio = (config['aspectRatio'] as num?)?.toDouble() ?? 1.0;

    final AppPalette? palette = config['palette'] as AppPalette?;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Ambient Background Layer (Full Bleed)
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

        // 2. Translucent dark overlays (delicate top and bottom air washes)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 90,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.18),
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
          height: 150,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // 3. Adaptive Sizing & Premium Breathing Typography
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

            final titleFontSize = (canvasWidth * 0.046).clamp(13.0, 22.0);
            final subtitleFontSize = (canvasWidth * 0.030).clamp(9.0, 13.0);
            final spacingHeight = (canvasHeight * 0.040).clamp(14.0, 28.0);

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
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 4.0,
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontFamily: fontFamily,
                    letterSpacing: 2.0,
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
    final double brightness = (cfg['brightness'] as num?)?.toDouble() ?? 0.55;
    final double radius = (cfg['radius'] as num?)?.toDouble() ?? 28.0;
    final String title = cfg['title']?.toString() ?? '- xiao xi -';
    final String subtitle = cfg['subtitle']?.toString() ?? '© PalettePro Capture';
    final String fontFamily = cfg['fontFamily']?.toString() ?? 'serif';

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
          // Text Fields (Title, Subtitle)
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
                    controller: TextEditingController(text: title)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: title.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Enter title...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      cfg['title'] = val;
                      onUpdate(cfg);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: subtitle)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: subtitle.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Enter subtitle...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      cfg['subtitle'] = val;
                      onUpdate(cfg);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Font Style Selection
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 2.0),
                child: Text('Typography (排版): ', style: labelStyle),
              ),
              ChoiceChip(
                label: const Text('Serif (衬线)'),
                selected: fontFamily == 'serif',
                selectedColor: accentColor.withOpacity(0.24),
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: fontFamily == 'serif' ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: fontFamily == 'serif' ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: fontFamily == 'serif' ? accentColor.withOpacity(0.5) : Colors.white10),
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (selected) {
                  if (selected) {
                    cfg['fontFamily'] = 'serif';
                    onUpdate(cfg);
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Sans-Serif (无衬线)'),
                selected: fontFamily == 'sans-serif',
                selectedColor: accentColor.withOpacity(0.24),
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: fontFamily == 'sans-serif' ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: fontFamily == 'sans-serif' ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: fontFamily == 'sans-serif' ? accentColor.withOpacity(0.5) : Colors.white10),
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (selected) {
                  if (selected) {
                    cfg['fontFamily'] = 'sans-serif';
                    onUpdate(cfg);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
