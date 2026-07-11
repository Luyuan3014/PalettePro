import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../state/editor_notifier.dart';

/// The main editor workspace screen.
/// Features a Slate dark background layout focusing all visual weight on the photographic preview.
class EditorScreen extends StatefulWidget {
  final EditorNotifier notifier;

  const EditorScreen({super.key, required this.notifier});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey _repaintKey = GlobalKey();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          backgroundColor: widget.notifier.isSuccessMessage 
              ? const Color(0xFF1E3A20) // Deep luxurious forest green
              : const Color(0xFF3F1B1B), // Deep slate red
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: widget.notifier.isSuccessMessage 
                  ? Colors.green.withOpacity(0.3) 
                  : Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          duration: const Duration(seconds: 3),
        ),
      );
      widget.notifier.clearStatus();
    }
  }

  void _showImportSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 10,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
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
                  '选择导入照片来源',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
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
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.photo_library_outlined, color: Colors.white70, size: 28),
                              SizedBox(height: 10),
                              Text('从相册导入', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 28),
                              SizedBox(height: 10),
                              Text('拍照导入', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Mode Slate background
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.notifier,
          builder: (context, child) {
            return Column(
              children: [
                // 1. Navigation Action Bar
                _buildTopNavigationBar(context),

                // 2. Editor Preview Canvas (70% Height)
                Expanded(
                  flex: 7,
                  child: Stack(
                    children: [
                      Center(
                        child: widget.notifier.originalImage == null
                            ? _buildPlaceholderCanvas(context)
                            : _buildActiveCanvasPreview(context),
                      ),
                      if (widget.notifier.isLoading)
                        Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),

                // 3. Dynamic Properties Configuration Panel & Effect Toolbar
                _buildControlSection(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Import Icon
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white70, size: 26),
            tooltip: 'Import Photo',
            onPressed: () => _showImportSourceSheet(context),
          ),
          // App Title
          const Text(
            'PalettePro (臻图坊)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          // Export Button
          widget.notifier.isExporting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFCCCCCC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: widget.notifier.originalImage == null
                          ? null
                          : () => widget.notifier.exportImage(_repaintKey),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.ios_share,
                              color: widget.notifier.originalImage == null ? Colors.black38 : Colors.black,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'EXPORT',
                              style: TextStyle(
                                color: widget.notifier.originalImage == null ? Colors.black38 : Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCanvas(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImportSourceSheet(context),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 460),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle grid design overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.02,
                  child: GridPaper(
                    color: Colors.white,
                    divisions: 1,
                    subdivisions: 1,
                    interval: 30,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white.withOpacity(0.4),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '臻图坊 • PALETTEPRO',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select a photo to begin your curation',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined, color: Colors.white.withOpacity(0.7), size: 15),
                          const SizedBox(width: 8),
                          Text(
                            '导入照片',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCanvasPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 4 / 5, // Classic premium card showcase ratio
          child: RepaintBoundary(
            key: _repaintKey,
            child: widget.notifier.activeEffect.buildEffect(
              context,
              widget.notifier.originalImage!,
              widget.notifier.config,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlSection(BuildContext context) {
    final bool hasImage = widget.notifier.originalImage != null;

    return Column(
      children: [
        // 3a. Divider
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.04),
        ),

        // 3b. Quick Slider Panel (Contextual Configuration)
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: const Color(0xFF161616),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: hasImage ? 20 : 16,
          ),
          child: hasImage
              ? widget.notifier.activeEffect.buildConfigPanel(
                  context,
                  widget.notifier.config,
                  widget.notifier.updateConfig,
                )
              : const Center(
                  child: Text(
                    '导入照片后可调节布局样式',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
        ),

        // 3c. Divider
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.04),
        ),

        // 3d. Bottom Effect Selector Toolbar (Carousel of layout styles)
        Container(
          height: 110,
          color: const Color(0xFF0F0F0F),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: widget.notifier.effects.length,
            itemBuilder: (context, index) {
              final effect = widget.notifier.effects[index];
              final isSelected = widget.notifier.activeEffect.id == effect.id;

              return GestureDetector(
                onTap: () => widget.notifier.selectEffect(effect),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 130,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.04) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.white70 : Colors.white.withOpacity(0.06),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            effect.icon,
                            color: isSelected ? Colors.white : Colors.white38,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            effect.name.split(' ')[0], // Get short name
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
