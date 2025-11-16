import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../loading/loading_indicators.dart';

/// 최적화된 네트워크 이미지 위젯
///
/// 특징:
/// - 자동 이미지 캐싱 (메모리 + 디스크)
/// - 부드러운 페이드 인 애니메이션
/// - 로딩 인디케이터
/// - 에러 처리 및 재시도 기능
/// - 접근성 지원
class OptimizedNetworkImage extends StatelessWidget {
  /// 이미지 URL
  final String imageUrl;

  /// 이미지 너비
  final double? width;

  /// 이미지 높이
  final double? height;

  /// 이미지 맞춤 방식
  final BoxFit fit;

  /// 테두리 반경
  final BorderRadius? borderRadius;

  /// 접근성 레이블 (스크린 리더용)
  final String? semanticLabel;

  /// 에러 시 표시할 위젯 (선택사항)
  final Widget? errorWidget;

  /// 로딩 시 표시할 위젯 (선택사항)
  final Widget? loadingWidget;

  /// 메모리 캐시 활성화 여부
  final bool useMemoryCache;

  /// 디스크 캐시 활성화 여부
  final bool useDiskCache;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
    this.errorWidget,
    this.loadingWidget,
    this.useMemoryCache = true,
    this.useDiskCache = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
      useOldImageOnUrlChange: true,
      placeholder: (context, url) => loadingWidget ?? _buildDefaultLoadingWidget(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(context, url),
    );

    // 접근성 지원
    if (semanticLabel != null) {
      return Semantics(
        image: true,
        label: semanticLabel,
        child: _wrapWithBorderRadius(imageWidget),
      );
    }

    return _wrapWithBorderRadius(imageWidget);
  }

  Widget _wrapWithBorderRadius(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }

  /// 기본 로딩 위젯
  Widget _buildDefaultLoadingWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.borderLight,
      child: Center(
        child: SkeletonLoading(
          width: width ?? double.infinity,
          height: height ?? 200,
        ),
      ),
    );
  }

  /// 기본 에러 위젯 (재시도 기능 포함)
  Widget _buildDefaultErrorWidget(BuildContext context, String url) {
    return Container(
      width: width,
      height: height,
      color: AppColors.borderLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          const Text(
            '이미지를 불러올 수 없습니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          // 재시도 버튼
          TextButton.icon(
            onPressed: () {
              // 이미지 캐시 삭제 후 재시도
              CachedNetworkImage.evictFromCache(url);
              // 화면 갱신을 위해 부모에게 알림
              // (부모 위젯에서 setState를 호출하거나 상태 관리 사용)
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text(
              '재시도',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mathButtonBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 원형 프로필 이미지 (최적화)
class OptimizedCircularImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final String? semanticLabel;

  const OptimizedCircularImage({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 2,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: OptimizedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}

/// 문제 이미지 위젯 (최적화)
///
/// 문제 화면에서 사용하기 위한 전용 이미지 위젯
class ProblemImageWidget extends StatelessWidget {
  final String imageUrl;
  final String? label;

  const ProblemImageWidget({
    super.key,
    required this.imageUrl,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathBlue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 이미지
          OptimizedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            semanticLabel: '문제 관련 이미지',
          ),
          // 이미지 하단 레이블
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
