import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/app_colors.dart';

class ImageEditorScreen extends StatefulWidget {
  final String currentImageUrl;

  const ImageEditorScreen({
    super.key,
    required this.currentImageUrl,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _cropKey = GlobalKey();

  double _zoomLevel = 1.0;
  bool _isCropping = false;
  late String _activeImageUrl;

  @override
  void initState() {
    super.initState();
    _activeImageUrl = widget.currentImageUrl;
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _zoomLevel).abs() > 0.05) {
      setState(() {
        _zoomLevel = scale.clamp(1.0, 4.0);
      });
    }
  }

  void _updateZoomLevel(double newZoom) {
    setState(() {
      _zoomLevel = newZoom;
      final matrix = Matrix4.diagonal3Values(newZoom, newZoom, 1.0);
      _transformationController.value = matrix;
    });
  }

  void _resetEditor() {
    setState(() {
      _zoomLevel = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _processAndSaveCrop() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    try {
      final boundary = _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final base64String = base64Encode(pngBytes);
          final dataUrl = 'data:image/png;base64,$base64String';
          if (mounted) {
            Navigator.pop(context, dataUrl);
            return;
          }
        }
      }
      if (mounted) {
        Navigator.pop(context, _activeImageUrl);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context, _activeImageUrl);
      }
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  Widget _buildImageView(String imagePath, double cropBoxSize) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: cropBoxSize,
        height: cropBoxSize,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } else if (imagePath.startsWith('data:image/')) {
      try {
        final base64Str = imagePath.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: cropBoxSize,
          height: cropBoxSize,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
        );
      } catch (_) {
        return _buildFallbackIcon();
      }
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: cropBoxSize,
        height: cropBoxSize,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(Icons.person, color: AppColors.accentGold, size: 64),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cropBoxSize = (screenSize.width - 48).clamp(240.0, 360.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: const Text(
          'Edit Profile Photo (1:1)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accentGold),
            tooltip: 'Reset Zoom & Position',
            onPressed: _resetEditor,
          ),
          IconButton(
            icon: _isCropping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
                  )
                : const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 26),
            tooltip: 'Save 1:1 Crop',
            onPressed: _processAndSaveCrop,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Pinch/Pan Helper Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1E1E1E),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pinch_rounded, color: AppColors.accentGold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Pinch to Zoom • Drag to Pan inside 1:1 Frame',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Strict 1:1 Square Crop Viewport with RepaintBoundary
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Dimmed Backdrop Frame
                  Container(
                    width: cropBoxSize + 24,
                    height: cropBoxSize + 24,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  // Capturable 1:1 Square Crop Box
                  RepaintBoundary(
                    key: _cropKey,
                    child: Container(
                      width: cropBoxSize,
                      height: cropBoxSize,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentGold, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1.0,
                          maxScale: 4.0,
                          boundaryMargin: const EdgeInsets.all(120),
                          child: _buildImageView(_activeImageUrl, cropBoxSize),
                        ),
                      ),
                    ),
                  ),

                  // Rule-of-Thirds Grid Line Overlay for Visual Framing
                  IgnorePointer(
                    child: SizedBox(
                      width: cropBoxSize,
                      height: cropBoxSize,
                      child: CustomPaint(
                        painter: _CropGridOverlayPainter(borderColor: AppColors.accentGold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Manual Zoom Slider & Save Action Container
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom Control Slider
                  Row(
                    children: [
                      const Icon(Icons.zoom_out_rounded, color: Colors.white70, size: 20),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.accentGold,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: AppColors.accentGoldLight,
                            overlayColor: AppColors.accentGold.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _zoomLevel,
                            min: 1.0,
                            max: 4.0,
                            onChanged: _updateZoomLevel,
                          ),
                        ),
                      ),
                      const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 20),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Save Crop CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _processAndSaveCrop,
                      icon: const Icon(Icons.crop_rounded, size: 18),
                      label: const Text(
                        'DONE & SAVE CROP (1:1)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBurgundy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter for 1:1 Crop Grid Lines and Corner Anchors
class _CropGridOverlayPainter extends CustomPainter {
  final Color borderColor;

  _CropGridOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Draw Rule-of-Thirds Grid Lines
    final w3 = size.width / 3;
    final h3 = size.height / 3;

    canvas.drawLine(Offset(w3, 0), Offset(w3, size.height), gridPaint);
    canvas.drawLine(Offset(w3 * 2, 0), Offset(w3 * 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, h3), Offset(size.width, h3), gridPaint);
    canvas.drawLine(Offset(0, h3 * 2), Offset(size.width, h3 * 2), gridPaint);

    // Draw Corner Anchors
    const cornerLength = 18.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), cornerPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), cornerPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
