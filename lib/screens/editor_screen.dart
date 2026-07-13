import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../state/editor_notifier.dart';
import '../widgets/ambient_background.dart';
import '../widgets/interactive_card.dart';
import '../widgets/glassmorphic_panel.dart';

/// The main immersive editor screen.
/// Implements full-screen ambient backdrop overlays, glassmorphic headers
/// and drawers, and connects the center card to spring-parallax motion.
class EditorScreen extends StatefulWidget {
  final EditorNotifier notifier;

  const EditorScreen({super.key, required this.notifier});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  Offset _parallaxOffset = Offset.zero;
  int _activeTab = 0; // 0: Styles, 1: Adjustments

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_statusListener);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_statusListener);
    super.dispose();
  }

  void _statusListener() {
    final message = widget.notifier.statusMessage;
    if (message != null && mounted) {
      // Skip export-related messages in SnackBar, since they will be shown via custom dialog
      if (message.contains("Export") || message.contains("export") || message.contains("保存") || message.contains("照片已成功")) {
        widget.notifier.clearStatus();
        return;
      }

      final accent = widget.notifier.palette.accent;
      final isSuccess = widget.notifier.isSuccessMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          backgroundColor: isSuccess
              ? Color.alphaBlend(accent.withOpacity(0.18), const Color(0xFF141F16))
              : const Color(0xFF2B1414),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSuccess ? accent.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              width: 0.8,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          duration: const Duration(seconds: 3),
        ),
      );
      widget.notifier.clearStatus();
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    final resultBytes = await widget.notifier.exportImage(_repaintKey);
    if (!mounted) return;

    if (resultBytes != null) {
      _showExportResultDialog(context, isSuccess: true, imageBytes: resultBytes);
    } else {
      final status = widget.notifier.statusMessage;
      if (status != null && !status.toLowerCase().contains("cancelled")) {
        _showExportResultDialog(context, isSuccess: false, errorMessage: status);
      }
    }
  }

  void _showExportResultDialog(
    BuildContext context, {
    required bool isSuccess,
    Uint8List? imageBytes,
    String? errorMessage,
  }) {
    final palette = widget.notifier.palette;
    final accent = palette.accent;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: GlassmorphicPanel(
                tintColor: palette.dominant,
                opacity: 0.15,
                blur: 32,
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSuccess ? accent.withOpacity(0.12) : const Color(0xFF3F1B1B).withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSuccess ? accent.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                        color: isSuccess ? accent : Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSuccess ? '导出成功' : '导出失败',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSuccess ? '图片已自动保存至系统相册' : (errorMessage ?? '未知错误，请重试'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 0.5,
                        height: 1.4,
                      ),
                    ),
                    if (isSuccess && imageBytes != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: AspectRatio(
                            aspectRatio: widget.notifier.currentCanvasAspectRatio,
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImportSourceSheet(BuildContext context) {
    final palette = widget.notifier.palette;
    final accent = palette.accent;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black54,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphicPanel(
              tintColor: palette.dominant,
              opacity: 0.16,
              blur: 32,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Grab Bar
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    '导入照片',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.notifier.pickImage(ImageSource.gallery);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.photo_library_outlined, color: accent, size: 28),
                                const SizedBox(height: 10),
                                const Text('从相册选择', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.notifier.pickImage(ImageSource.camera);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.camera_alt_outlined, color: accent, size: 28),
                                const SizedBox(height: 10),
                                const Text('拍摄照片', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, child) {
        final palette = widget.notifier.palette;

        return Scaffold(
          backgroundColor: palette.background,
          body: Stack(
            children: [
              // 1. Full-screen crossfading ambient background
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: AmbientBackground(
                    key: ValueKey(widget.notifier.originalImage?.path),
                    imageFile: widget.notifier.originalImage,
                    palette: palette,
                    parallaxOffset: _parallaxOffset,
                    // Subtle dynamic adjustments for cinematic layouts
                    brightness: widget.notifier.activeEffect.id == 'cinematic_frame' ? 0.38 : 0.55,
                    saturation: widget.notifier.activeEffect.id == 'cinematic_frame' ? 0.40 : 0.75,
                  ),
                ),
              ),

              // 2. Full-screen Viewport Layer (generous margins, breathes well)
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Navigation Bar
                      _buildTopNavigationBar(context),

                      // Center Card Viewport with generous spacing
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 24.0),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: widget.notifier.originalImage == null
                                  ? _buildPlaceholderCanvas(context)
                                  : _buildActiveCanvasPreview(context),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Floating Drawer panel
                      _buildControlSection(context),
                    ],
                  ),
                ),
              ),

              // 3. Loading Protection Overlay
              if (widget.notifier.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: CircularProgressIndicator(color: palette.accent),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    final palette = widget.notifier.palette;
    final accent = palette.accent;
    final hasImage = widget.notifier.originalImage != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassmorphicPanel(
        tintColor: palette.dominant,
        opacity: 0.12,
        blur: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Import photo icon button
            IconButton(
              icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.white.withOpacity(0.85), size: 23),
              tooltip: 'Import Photo',
              onPressed: () => _showImportSourceSheet(context),
            ),
            // Header Title Typography
            Text(
              '臻图坊 • PALETTEPRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 4.5,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 1.5), blurRadius: 3),
                ],
              ),
            ),
            // Export Button
            widget.notifier.isExporting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: accent),
                  )
                : TextButton(
                    onPressed: hasImage ? () => _handleExport(context) : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: hasImage ? Colors.white : Colors.white.withOpacity(0.04),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      '导出',
                      style: TextStyle(
                        color: hasImage ? Colors.black : Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCanvas(BuildContext context) {
    final palette = widget.notifier.palette;
    final accent = palette.accent;

    return GestureDetector(
      onTap: () => _showImportSourceSheet(context),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 440),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassmorphicPanel(
          tintColor: palette.dominant,
          opacity: 0.12,
          blur: 32,
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.015),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: accent.withOpacity(0.85),
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '臻图坊',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a photo to begin your curation',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: accent.withOpacity(0.24)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined, color: Colors.white.withOpacity(0.9), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      '导入照片',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCanvasPreview(BuildContext context) {
    return InteractiveCard(
      onOffsetChanged: (offset) {
        setState(() {
          _parallaxOffset = offset;
        });
      },
      onDismiss: () {
        widget.notifier.dismissImage();
      },
      child: AspectRatio(
        aspectRatio: widget.notifier.currentCanvasAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32), // Elegant Apple-like curve radius
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.8,
            ),
            boxShadow: [
              // Large soft depth ambient shadow matching the photo content color
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 60,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: RepaintBoundary(
            key: _repaintKey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(31.2), // Perfectly fits inside border
              child: widget.notifier.activeEffect.buildEffect(
                context,
                widget.notifier.originalImage!,
                widget.notifier.config,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlSection(BuildContext context) {
    final bool hasImage = widget.notifier.originalImage != null;
    final palette = widget.notifier.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassmorphicPanel(
        tintColor: palette.dominant,
        opacity: 0.12,
        blur: 28,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Aspect Ratio Switcher Row (Primary Control)
            if (hasImage) ...[
              _buildCanvasRatioSelector(context),
              const SizedBox(height: 14),
              const Divider(color: Colors.white10, height: 1, thickness: 0.8),
              const SizedBox(height: 14),
            ],

            // 2. Tabs toggle bar (Styles vs Parameters)
            if (hasImage)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? Colors.white.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '布局样式',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _activeTab == 0 ? Colors.white : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? Colors.white.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '调节参数',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _activeTab == 1 ? Colors.white : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Tab content wrapper
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: hasImage
                  ? (_activeTab == 0 ? _buildStylesTab(context) : _buildAdjustmentsTab(context))
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          '导入照片后可调节布局样式',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasRatioSelector(BuildContext context) {
    final palette = widget.notifier.palette;
    final accent = palette.accent;

    return Row(
      children: [
        const Text(
          '画布比例',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        Wrap(
          spacing: 6.0,
          children: CanvasRatio.values.map((ratio) {
            final isSelected = widget.notifier.canvasRatio == ratio;
            return ChoiceChip(
              label: Text(ratio.label),
              selected: isSelected,
              selectedColor: accent.withOpacity(0.24),
              backgroundColor: Colors.transparent,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isSelected ? accent.withOpacity(0.5) : Colors.white.withOpacity(0.08),
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (selected) {
                if (selected) {
                  widget.notifier.setCanvasRatio(ratio);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStylesTab(BuildContext context) {
    final palette = widget.notifier.palette;
    final accent = palette.accent;

    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.notifier.effects.length,
        itemBuilder: (context, index) {
          final effect = widget.notifier.effects[index];
          final isSelected = widget.notifier.activeEffect.id == effect.id;

          return GestureDetector(
            onTap: () => widget.notifier.selectEffect(effect),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? accent.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? accent.withOpacity(0.6) : Colors.white.withOpacity(0.05),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      effect.icon,
                      color: isSelected ? Colors.white : Colors.white38,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      effect.name.split(' ')[0],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white38,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustmentsTab(BuildContext context) {
    return widget.notifier.activeEffect.buildConfigPanel(
      context,
      widget.notifier.config,
      widget.notifier.updateConfig,
    );
  }
}
