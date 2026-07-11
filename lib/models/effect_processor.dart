import 'dart:io';
import 'package:flutter/material.dart';

/// Abstract class defining a custom visual layout effect processor.
/// Follows the Open-Closed Principle (OCP) to enable adding new effects in the future.
abstract class EffectProcessor {
  /// Unique identifier of the effect.
  String get id;

  /// Human-readable name of the effect.
  String get name;

  /// Icon representing the effect in the UI.
  IconData get icon;

  /// Builds the visual presentation canvas representing the layout.
  Widget buildEffect(BuildContext context, File originalImage, dynamic config);

  /// Builds the control panel widget for modifying the parameters of this effect.
  Widget buildConfigPanel(
    BuildContext context,
    dynamic config,
    ValueChanged<dynamic> onUpdate,
  );

  /// Generates the default configuration for this effect.
  dynamic createDefaultConfig();
}
