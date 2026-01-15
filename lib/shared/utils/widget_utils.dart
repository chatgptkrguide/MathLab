import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// 위젯 관련 유틸리티
class WidgetUtils {
  WidgetUtils._();

  /// 수평 간격 생성
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  /// 수직 간격 생성
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// 작은 수평 간격
  static Widget get horizontalSpaceSmall =>
      horizontalSpace(AppDimensions.spacingS);

  /// 중간 수평 간격
  static Widget get horizontalSpaceMedium =>
      horizontalSpace(AppDimensions.spacingM);

  /// 큰 수평 간격
  static Widget get horizontalSpaceLarge =>
      horizontalSpace(AppDimensions.spacingL);

  /// 매우 큰 수평 간격
  static Widget get horizontalSpaceXLarge =>
      horizontalSpace(AppDimensions.spacingXL);

  /// 작은 수직 간격
  static Widget get verticalSpaceSmall =>
      verticalSpace(AppDimensions.spacingS);

  /// 중간 수직 간격
  static Widget get verticalSpaceMedium =>
      verticalSpace(AppDimensions.spacingM);

  /// 큰 수직 간격
  static Widget get verticalSpaceLarge =>
      verticalSpace(AppDimensions.spacingL);

  /// 매우 큰 수직 간격
  static Widget get verticalSpaceXLarge =>
      verticalSpace(AppDimensions.spacingXL);

  /// Divider 생성
  static Widget divider({
    Color? color,
    double? height,
    double? thickness,
  }) {
    return Divider(
      color: color,
      height: height,
      thickness: thickness,
    );
  }

  /// 로딩 인디케이터
  static Widget loadingIndicator({
    Color? color,
    double? size,
  }) {
    return Center(
      child: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(color)
              : null,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  static Widget emptyState({
    required String message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 64, color: Colors.grey),
            verticalSpaceMedium,
          ],
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            verticalSpaceLarge,
            action,
          ],
        ],
      ),
    );
  }

  /// 에러 상태 위젯
  static Widget errorState({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          verticalSpaceMedium,
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            verticalSpaceLarge,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }

  /// 카드 래퍼
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
        child: child,
      ),
    );
  }

  /// 애니메이션 스케일 버튼 래퍼
  static Widget animatedScaleButton({
    required Widget child,
    required VoidCallback onTap,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 150),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        onTapDown: (_) {},
        onTapUp: (_) {},
        onTapCancel: () {},
        child: child,
      ),
    );
  }

  /// 그라디언트 컨테이너
  static Widget gradientContainer({
    required Widget child,
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
        ),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  /// 쉐도우 컨테이너
  static Widget shadowContainer({
    required Widget child,
    Color? shadowColor,
    double? blurRadius,
    Offset? offset,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Colors.black.withValues(alpha: 0.1),
            blurRadius: blurRadius ?? 8,
            offset: offset ?? const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
