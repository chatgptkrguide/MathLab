import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// SnackBar 표시 유틸리티
///
/// 앱 전체에서 일관된 스타일의 SnackBar를 표시하기 위한 헬퍼 클래스
/// - 성공, 에러, 정보, 경고 메시지 지원
/// - Floating 스타일로 통일
/// - 둥근 모서리 디자인
class SnackBarUtils {
  /// 성공 메시지 표시 (녹색)
  ///
  /// 예: 데이터 저장 성공, 작업 완료
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.mathGreen,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  /// 에러 메시지 표시 (빨간색)
  ///
  /// 예: 데이터 로드 실패, 네트워크 오류
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.mathRed,
      icon: Icons.error,
      duration: duration,
    );
  }

  /// 정보 메시지 표시 (파란색)
  ///
  /// 예: 일반 안내, 알림
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.primary,
      icon: Icons.info,
      duration: duration,
    );
  }

  /// 경고 메시지 표시 (주황색)
  ///
  /// 예: 주의 사항, 확인 필요
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppColors.mathOrange,
      icon: Icons.warning,
      duration: duration,
    );
  }

  /// 커스텀 SnackBar 표시
  ///
  /// 특수한 경우에 사용
  static void showCustom(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  /// 내부 구현 메서드
  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    IconData? icon,
    required Duration duration,
  }) {
    // 기존 SnackBar 제거
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 액션 버튼이 있는 SnackBar 표시
  ///
  /// 사용자 액션이 필요한 경우 사용
  static void showWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onActionPressed,
    Color backgroundColor = AppColors.primary,
    IconData? icon,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onActionPressed();
          },
        ),
      ),
    );
  }
}
