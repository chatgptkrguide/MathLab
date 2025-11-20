import 'package:flutter/material.dart';

/// Asset이 없을 때 대체 이미지를 보여주는 위젯
class FallbackImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const FallbackImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return placeholder ?? _buildDefaultPlaceholder();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    // Asset 경로에서 타입 추론
    if (assetPath.contains('badge')) {
      return _buildBadgePlaceholder();
    } else if (assetPath.contains('google')) {
      return _buildGooglePlaceholder();
    } else if (assetPath.contains('kakao')) {
      return _buildKakaoPlaceholder();
    }
    return _buildGenericPlaceholder();
  }

  Widget _buildBadgePlaceholder() {
    return Container(
      width: width ?? 60,
      height: height ?? 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock, color: Colors.grey),
    );
  }

  Widget _buildGooglePlaceholder() {
    return Container(
      width: width ?? 24,
      height: height ?? 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoPlaceholder() {
    return Container(
      width: width ?? 24,
      height: height ?? 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE500),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'K',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildGenericPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[600],
        size: (width != null && height != null) ? (width! + height!) / 4 : 40,
      ),
    );
  }
}
