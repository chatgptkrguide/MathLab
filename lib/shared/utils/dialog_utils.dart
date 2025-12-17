import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 다이얼로그 표시 유틸리티
///
/// 앱 전체에서 일관된 스타일의 다이얼로그를 표시하기 위한 헬퍼 클래스
/// - 확인 다이얼로그
/// - 알림 다이얼로그
/// - 커스텀 다이얼로그
class DialogUtils {
  /// 확인 다이얼로그 표시
  ///
  /// 사용자의 확인/취소 선택이 필요한 경우 사용
  /// 반환값: true(확인), false(취소), null(다이얼로그 밖 클릭)
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    Color? confirmColor,
    bool barrierDismissible = true,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 알림 다이얼로그 표시
  ///
  /// 사용자에게 정보를 전달하고 확인 버튼만 표시
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 성공 다이얼로그 표시
  ///
  /// 작업 성공 시 사용
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    return showAlert(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.check_circle,
      iconColor: AppColors.mathGreen,
    );
  }

  /// 에러 다이얼로그 표시
  ///
  /// 오류 발생 시 사용
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    return showAlert(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.error,
      iconColor: AppColors.mathRed,
    );
  }

  /// 경고 다이얼로그 표시
  ///
  /// 주의가 필요한 경우 사용
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    return showAlert(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.warning,
      iconColor: AppColors.mathOrange,
    );
  }

  /// 삭제 확인 다이얼로그
  ///
  /// 데이터 삭제 시 사용 (빨간색 확인 버튼)
  static Future<bool?> showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '삭제',
    String cancelText = '취소',
  }) async {
    return showConfirmation(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: AppColors.mathRed,
    );
  }

  /// 로딩 다이얼로그 표시
  ///
  /// 비동기 작업 중 사용
  /// 주의: 작업 완료 후 Navigator.pop()으로 닫아야 함
  static void showLoading(
    BuildContext context, {
    String message = '처리 중...',
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 커스텀 컨텐츠 다이얼로그 표시
  ///
  /// 특수한 경우 사용자 정의 위젯을 표시
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required Widget content,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: title != null
            ? Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        content: content,
        actions: actions,
      ),
    );
  }

  /// 선택 다이얼로그 표시
  ///
  /// 여러 옵션 중 하나를 선택하는 경우 사용
  /// 반환값: 선택된 항목의 인덱스
  static Future<int?> showOptions(
    BuildContext context, {
    required String title,
    required List<String> options,
    int? selectedIndex,
  }) async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            options.length,
            (index) => ListTile(
              title: Text(
                options[index],
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: selectedIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              leading: selectedIndex == index
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      color: AppColors.textSecondary,
                    ),
              onTap: () => Navigator.pop(context, index),
            ),
          ),
        ),
      ),
    );
  }
}
