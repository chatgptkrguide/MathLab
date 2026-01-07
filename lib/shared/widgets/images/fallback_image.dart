import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

/// Asset이 없을 때 대체 이미지를 보여주는 위젯
///
/// 기능:
/// - Asset 존재 여부 자동 확인
/// - 타입별 커스텀 placeholder 제공
/// - 접근성 지원
class FallbackImage extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final String? semanticLabel;

  const FallbackImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.semanticLabel,
  });

  @override
  State<FallbackImage> createState() => _FallbackImageState();
}

class _FallbackImageState extends State<FallbackImage> {
  bool _assetExists = true;

  @override
  void initState() {
    super.initState();
    _checkAssetExists();
  }

  /// Asset 존재 여부 확인
  Future<void> _checkAssetExists() async {
    try {
      await rootBundle.load(widget.assetPath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _assetExists = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asset이 존재하지 않으면 placeholder 표시
    if (!_assetExists) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    final Widget imageWidget = Image.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.placeholder ?? _buildDefaultPlaceholder();
      },
    );

    // 접근성 지원
    if (widget.semanticLabel != null) {
      return Semantics(
        image: true,
        label: widget.semanticLabel,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    // Asset 경로에서 타입 추론
    if (widget.assetPath.contains('badge')) {
      return _buildBadgePlaceholder();
    } else if (widget.assetPath.contains('profile') ||
        widget.assetPath.contains('avatar')) {
      return _buildProfilePlaceholder();
    } else if (widget.assetPath.contains('google')) {
      return _buildGooglePlaceholder();
    } else if (widget.assetPath.contains('kakao')) {
      return _buildKakaoPlaceholder();
    } else if (widget.assetPath.contains('problem')) {
      return _buildProblemPlaceholder();
    }
    return _buildGenericPlaceholder();
  }

  Widget _buildBadgePlaceholder() {
    return Container(
      width: widget.width ?? 60,
      height: widget.height ?? 60,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_outline,
        color: AppColors.textSecondary,
        size: (widget.width ?? 60) * 0.5,
      ),
    );
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      width: widget.width ?? 48,
      height: widget.height ?? 48,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        color: AppColors.textSecondary,
        size: (widget.width ?? 48) * 0.6,
      ),
    );
  }

  Widget _buildGooglePlaceholder() {
    return Container(
      width: widget.width ?? 24,
      height: widget.height ?? 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderLight),
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
      width: widget.width ?? 24,
      height: widget.height ?? 24,
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

  Widget _buildProblemPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: AppColors.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            '문제 이미지',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: (widget.width != null && widget.height != null)
            ? (widget.width! + widget.height!) / 6
            : 40,
      ),
    );
  }
}
