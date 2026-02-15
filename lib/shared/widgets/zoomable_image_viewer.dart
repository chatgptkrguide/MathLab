// Zoomable Image Viewer
//
// Displays problem images with tap-to-expand and pinch-to-zoom support.
// Used in problem solving screens to show diagrams, graphs, and figures.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Thumbnail image widget that opens a full-screen zoomable viewer on tap.
class ZoomableImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double? height;
  final BorderRadius? borderRadius;

  const ZoomableImageThumbnail({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black87,
            pageBuilder: (context, animation, secondaryAnimation) {
              return FullScreenImageViewer(
                imageUrl: imageUrl,
                heroTag: heroTag,
              );
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Stack(
        children: [
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: height,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: height ?? 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: borderRadius ?? BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: height ?? 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: borderRadius ?? BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          // Zoom indicator
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '확대',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays multiple problem images in a horizontal scrollable list.
class ProblemImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final String problemId;

  const ProblemImageGallery({
    super.key,
    required this.imageUrls,
    required this.problemId,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    if (imageUrls.length == 1) {
      return ZoomableImageThumbnail(
        imageUrl: imageUrls[0],
        heroTag: '${problemId}_image_0',
      );
    }

    // Multiple images: horizontal scrollable gallery
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: ZoomableImageThumbnail(
              imageUrl: imageUrls[index],
              heroTag: '${problemId}_image_$index',
              height: 200,
            ),
          );
        },
      ),
    );
  }
}

/// Full-screen image viewer with pinch-to-zoom and double-tap zoom.
class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        if (_animation != null) {
          _transformController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    final position = details.localPosition;

    if (_transformController.value != Matrix4.identity()) {
      // Zoom out
      _animation = Matrix4Tween(
        begin: _transformController.value,
        end: Matrix4.identity(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _animationController.forward(from: 0);
    } else {
      // Zoom in to 2.5x at tap position
      // ignore: deprecated_member_use
      final zoomMatrix = Matrix4.identity()
        // ignore: deprecated_member_use
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        // ignore: deprecated_member_use
        ..scale(2.5);
      _animation = Matrix4Tween(
        begin: _transformController.value,
        end: zoomMatrix,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on background tap
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          // Zoomable image
          Center(
            child: GestureDetector(
              onDoubleTapDown: _handleDoubleTap,
              onDoubleTap: () {}, // Required for onDoubleTapDown to work
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 5.0,
                clipBehavior: Clip.none,
                child: Hero(
                  tag: widget.heroTag,
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.white, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),

          // Zoom hint
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                '두 손가락으로 확대/축소 | 더블탭으로 확대',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
