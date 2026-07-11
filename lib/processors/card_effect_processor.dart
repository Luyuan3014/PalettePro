import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/effect_processor.dart';

/// Charming Creek (溪谷卡片) Card Layout Effect.
/// Features a blurred background, a rounded, shadowed card for the original photo,
/// and elegant centered typography.
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
      'blur': 25.0,
      'radius': 24.0,
      'shadowBlur': 18.0,
      'shadowOpacity': 0.3,
      'title': '- xiao xi -',
      'subtitle': '© PalettePro Capture',
      'fontFamily': 'serif', // uses native platform serif font
      'aspectRatio': 1.0, // Updated dynamically by the notifier
    };
  }

  @override
  Widget buildEffect(BuildContext context, File originalImage, dynamic config) {
    // Gracefully handle missing configuration fields using default values
    final double blur = (config['blur'] as num?)?.toDouble() ?? 25.0;
    final double radius = (config['radius'] as num?)?.toDouble() ?? 24.0;
    final double shadowBlur = (config['shadowBlur'] as num?)?.toDouble() ?? 18.0;
    final double shadowOpacity = (config['shadowOpacity'] as num?)?.toDouble() ?? 0.3;
    final String title = config['title']?.toString() ?? '- xiao xi -';
    final String subtitle = config['subtitle']?.toString() ?? '© PalettePro Capture';
    final String fontFamily = config['fontFamily']?.toString() ?? 'serif';
    final double aspectRatio = (config['aspectRatio'] as num?)?.toDouble() ?? 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;

        // Visual proportions relative to container width
        final titleFontSize = (canvasWidth * 0.048).clamp(16.0, 26.0);
        final subtitleFontSize = (canvasWidth * 0.032).clamp(11.0, 16.0);
        final spacingHeight = (canvasHeight * 0.04).clamp(16.0, 36.0);
        final paddingHorizontal = canvasWidth * 0.08;
        final paddingVertical = canvasHeight * 0.06;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Background Layer (Blurred Original Image)
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Image.file(
                    originalImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Dark wash overlay for contrast
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.18),
              ),
            ),
            // 2. Middle & Overlay Layer Stack
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: paddingVertical,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Centered Card Holding Unblurred Original Image
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(shadowOpacity),
                            blurRadius: shadowBlur,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Image.file(
                            originalImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacingHeight),
                  // Text Overlay Layer
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.0,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: subtitleFontSize,
                      fontStyle: FontStyle.italic,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildConfigPanel(
    BuildContext context,
    dynamic config,
    ValueChanged<dynamic> onUpdate,
  ) {
    final Map<String, dynamic> cfg = Map<String, dynamic>.from(config as Map);
    final double blur = (cfg['blur'] as num?)?.toDouble() ?? 25.0;
    final double radius = (cfg['radius'] as num?)?.toDouble() ?? 24.0;
    final double shadowBlur = (cfg['shadowBlur'] as num?)?.toDouble() ?? 18.0;
    final String title = cfg['title']?.toString() ?? '- xiao xi -';
    final String subtitle = cfg['subtitle']?.toString() ?? '© PalettePro Capture';
    final String fontFamily = cfg['fontFamily']?.toString() ?? 'serif';

    // Premium styling constants
    const labelStyle = TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500);
    const sliderTheme = SliderThemeData(
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.white12,
      thumbColor: Colors.white,
      overlayColor: Colors.white10,
    );

    return SliderTheme(
      data: sliderTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider 1: Blur
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Blur (模糊)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: blur,
                  min: 0.0,
                  max: 50.0,
                  onChanged: (val) {
                    cfg['blur'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(blur.toStringAsFixed(0), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
          // Slider 2: Radius
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Radius (圆角)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: radius,
                  min: 0.0,
                  max: 50.0,
                  onChanged: (val) {
                    cfg['radius'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(radius.toStringAsFixed(0), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
          // Slider 3: Shadow Blur
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Shadow (阴影)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: shadowBlur,
                  min: 0.0,
                  max: 40.0,
                  onChanged: (val) {
                    cfg['shadowBlur'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(shadowBlur.toStringAsFixed(0), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Text Inputs
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: title)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: title.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Enter title...',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: subtitle)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: subtitle.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Enter subtitle...',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          const SizedBox(height: 8),
          // Font Style Selection
          Row(
            children: [
              const Text('Font Style (字体): ', style: labelStyle),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Serif (衬线)'),
                selected: fontFamily == 'serif',
                selectedColor: Colors.white24,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(color: fontFamily == 'serif' ? Colors.white : Colors.white54, fontSize: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: fontFamily == 'serif' ? Colors.white54 : Colors.white12),
                  borderRadius: BorderRadius.circular(6),
                ),
                onSelected: (selected) {
                  if (selected) {
                    cfg['fontFamily'] = 'serif';
                    onUpdate(cfg);
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Sans-Serif (无衬线)'),
                selected: fontFamily == 'sans-serif',
                selectedColor: Colors.white24,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(color: fontFamily == 'sans-serif' ? Colors.white : Colors.white54, fontSize: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: fontFamily == 'sans-serif' ? Colors.white54 : Colors.white12),
                  borderRadius: BorderRadius.circular(6),
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
