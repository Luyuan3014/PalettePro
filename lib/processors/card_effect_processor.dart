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
      'blur': 50.0,
      'scale': 1.4,
      'brightness': 0.7,
      'saturation': 0.6,
      'radius': 28.0,
      'shadowBlur': 45.0,
      'shadowOpacity': 0.35,
      'title': '- xiao xi -',
      'subtitle': '© PalettePro Capture',
      'fontFamily': 'serif',
      'aspectRatio': 1.0,
      'palette': null, // Injected by notifier
    };
  }

  @override
  Widget buildEffect(BuildContext context, File originalImage, dynamic config) {
    final double blur = (config['blur'] as num?)?.toDouble() ?? 50.0;
    final double scale = (config['scale'] as num?)?.toDouble() ?? 1.4;
    final double brightness = (config['brightness'] as num?)?.toDouble() ?? 0.7;
    final double saturation = (config['saturation'] as num?)?.toDouble() ?? 0.6;
    final double radius = (config['radius'] as num?)?.toDouble() ?? 28.0;
    final double shadowBlur = (config['shadowBlur'] as num?)?.toDouble() ?? 45.0;
    final double shadowOpacity = (config['shadowOpacity'] as num?)?.toDouble() ?? 0.35;
    final String title = config['title']?.toString() ?? '- xiao xi -';
    final String subtitle = config['subtitle']?.toString() ?? '© PalettePro Capture';
    final String fontFamily = config['fontFamily']?.toString() ?? 'serif';
    final double aspectRatio = (config['aspectRatio'] as num?)?.toDouble() ?? 1.0;

    final AppPalette? palette = config['palette'] as AppPalette?;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Ambient Background Layer
        AmbientBackground(
          imageFile: originalImage,
          blur: blur,
          scale: scale,
          brightness: brightness,
          saturation: saturation,
          dominantColor: palette?.dominant,
          showVignette: true,
        ),

        // 2. Floating Card & Text Content
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            final canvasHeight = constraints.maxHeight;

            final titleFontSize = (canvasWidth * 0.045).clamp(14.0, 24.0);
            final subtitleFontSize = (canvasWidth * 0.030).clamp(10.0, 14.0);
            final spacingHeight = (canvasHeight * 0.035).clamp(12.0, 26.0);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ForegroundCard(
                    imageFile: originalImage,
                    aspectRatio: aspectRatio,
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
                    color: Colors.white.withOpacity(0.95),
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 3.0,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: subtitleFontSize,
                    fontStyle: FontStyle.italic,
                    fontFamily: fontFamily,
                    letterSpacing: 1.0,
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
    final double blur = (cfg['blur'] as num?)?.toDouble() ?? 50.0;
    final double scale = (cfg['scale'] as num?)?.toDouble() ?? 1.4;
    final double brightness = (cfg['brightness'] as num?)?.toDouble() ?? 0.7;
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
                  max: 100.0,
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
                  max: 2.0,
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
