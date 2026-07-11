import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/effect_processor.dart';
import '../processors/card_effect_processor.dart';
import '../processors/cinema_effect_processor.dart';

/// State management controller for the PalettePro editor.
/// Uses native [ChangeNotifier] to manage editor state, image imports, and high-res exports.
class EditorNotifier extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  /// Supported visual effects list
  final List<EffectProcessor> effects = [
    CardEffectProcessor(),
    CinemaEffectProcessor(),
  ];

  File? _originalImage;
  late EffectProcessor _activeEffect;
  dynamic _config;
  double? _imageAspectRatio;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _statusMessage;
  bool _isSuccessMessage = true;

  // Getters
  File? get originalImage => _originalImage;
  EffectProcessor get activeEffect => _activeEffect;
  dynamic get config => _config;
  double? get imageAspectRatio => _imageAspectRatio;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get statusMessage => _statusMessage;
  bool get isSuccessMessage => _isSuccessMessage;

  EditorNotifier() {
    // Select Charming Creek Card Effect by default
    _activeEffect = effects[0];
    _config = _activeEffect.createDefaultConfig();
  }

  /// Sets the active layout effect template.
  void selectEffect(EffectProcessor effect) {
    if (_activeEffect.id == effect.id) return;
    _activeEffect = effect;
    _config = effect.createDefaultConfig();
    if (_imageAspectRatio != null) {
      _config['aspectRatio'] = _imageAspectRatio!;
    }
    notifyListeners();
  }

  /// Updates the configuration parameters of the active effect.
  void updateConfig(dynamic newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  /// Imports a photo using the image picker.
  Future<void> pickImage(ImageSource source) async {
    try {
      _isLoading = true;
      _statusMessage = null;
      notifyListeners();

      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (file != null) {
        final File selectedFile = File(file.path);
        // Calculate original image aspect ratio
        final double ratio = await _calculateAspectRatio(selectedFile);
        
        _originalImage = selectedFile;
        _imageAspectRatio = ratio;
        _config['aspectRatio'] = ratio;
        
        _statusMessage = "Photo imported successfully.";
        _isSuccessMessage = true;
      }
    } catch (e) {
      _statusMessage = "Failed to import photo: $e";
      _isSuccessMessage = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to calculate image's aspect ratio.
  Future<double> _calculateAspectRatio(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image.width / fi.image.height;
  }

  /// Exports the canvas in high-resolution using [RepaintBoundary].
  Future<void> exportImage(GlobalKey repaintKey) async {
    if (_originalImage == null) {
      _statusMessage = "Please import a photo first.";
      _isSuccessMessage = false;
      notifyListeners();
      return;
    }

    try {
      _isExporting = true;
      _statusMessage = null;
      notifyListeners();

      // Ensure repaint boundary is ready and has layout completed
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("Render canvas is not ready.");
      }

      // Capture at high scale ratio to get precise gradients and details
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to convert canvas to bytes.");
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Let user pick output path cross-platform
      final String defaultName = "palette_pro_${DateTime.now().millisecondsSinceEpoch}.png";
      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export Beautiful Image',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['png'],
        bytes: pngBytes,
      );

      if (outputFile != null) {
        // If file_picker did not write the bytes directly (e.g. on Desktop), do it here.
        final File file = File(outputFile);
        await file.writeAsBytes(pngBytes);
        _statusMessage = "Photo exported to ${file.uri.pathSegments.last} successfully.";
        _isSuccessMessage = true;
      } else {
        _statusMessage = "Export cancelled.";
        _isSuccessMessage = false;
      }
    } catch (e) {
      _statusMessage = "Failed to export image: $e";
      _isSuccessMessage = false;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Clears the current status message.
  void clearStatus() {
    _statusMessage = null;
    notifyListeners();
  }
}
