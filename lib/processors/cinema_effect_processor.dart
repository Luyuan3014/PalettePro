import 'dart:io';
import 'package:flutter/material.dart';
import '../models/effect_processor.dart';

/// Cinematic Frame (电影画幅) Layout Effect.
/// Centers the image on a deep cinematic black canvas with custom margin padding,
/// and adds minimalist technical camera metadata in the bottom margin.
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
      'margin': 40.0,
      'device': 'SHOT ON DEVICE',
      'metadata': 'ISO 100  •  f/1.8  •  1/125s  •  50mm',
      'aspectRatio': 1.0, // Updated dynamically by the notifier
    };
  }

  @override
  Widget buildEffect(BuildContext context, File originalImage, dynamic config) {
    // Gracefully handle missing configuration fields using default values
    final double margin = (config['margin'] as num?)?.toDouble() ?? 40.0;
    final String device = config['device']?.toString() ?? 'SHOT ON DEVICE';
    final String metadata = config['metadata']?.toString() ?? 'ISO 100  •  f/1.8  •  1/125s  •  50mm';
    final double aspectRatio = (config['aspectRatio'] as num?)?.toDouble() ?? 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;

        // Visual proportions relative to container width
        final deviceFontSize = (canvasWidth * 0.032).clamp(11.0, 15.0);
        final metadataFontSize = (canvasWidth * 0.026).clamp(9.0, 12.0);

        // Calculate bottom offset for technical text based on margin sizes
        final double textBottomPadding = (margin / 2).clamp(10.0, 40.0);
        // Ensure image padding takes into account the metadata text height so they don't overlap
        final double imageBottomPadding = margin + 35.0;

        return Container(
          color: const Color(0xFF0A0A0A), // Deep cinematic black background
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Centered Original Image with Margins
              Padding(
                padding: EdgeInsets.only(
                  left: margin,
                  right: margin,
                  top: margin,
                  bottom: imageBottomPadding,
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Image.file(
                      originalImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // 2. Metadata Overlay Layer in the Margin
              Positioned(
                bottom: textBottomPadding,
                left: margin,
                right: margin,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      device.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: deviceFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      metadata,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: metadataFontSize,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final double margin = (cfg['margin'] as num?)?.toDouble() ?? 40.0;
    final String device = cfg['device']?.toString() ?? 'SHOT ON DEVICE';
    final String metadata = cfg['metadata']?.toString() ?? 'ISO 100  •  f/1.8  •  1/125s  •  50mm';

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
          // Slider: Margin
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Margin (边距)', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: margin,
                  min: 15.0,
                  max: 80.0,
                  onChanged: (val) {
                    cfg['margin'] = val;
                    onUpdate(cfg);
                  },
                ),
              ),
              SizedBox(
                width: 35,
                child: Text(margin.toStringAsFixed(0), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Text inputs for metadata
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
                    controller: TextEditingController(text: device)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: device.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Device info (e.g., Shot on Phone)',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: metadata)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: metadata.length)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Camera settings (e.g., ISO 100 • f/1.8 • 1/125s)',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
