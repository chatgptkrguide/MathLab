import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 공통 Dialog 기본 클래스
///
/// 모든 커스텀 Dialog에서 사용할 수 있는 기본 구조를 제공합니다.
/// - 일관된 디자인과 애니메이션
/// - 반복되는 코드 최소화
/// - 유지보수성 향상
abstract class BaseDialog extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double borderRadius;

  const BaseDialog({
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.padding,
    this.width,
    this.borderRadius = 24.0,
  });

  /// Dialog 컨텐츠를 구현하는 추상 메서드
  Widget buildContent(BuildContext context);

  /// Dialog 액션 버튼들을 구현하는 추상 메서드 (옵션)
  Widget? buildActions(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            buildContent(context),
            if (buildActions(context) != null) ...[
              const SizedBox(height: 20),
              buildActions(context)!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 확인 Dialog 기본 클래스
class ConfirmationDialog extends BaseDialog {
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color confirmColor;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    super.title,
    super.icon,
    super.iconColor,
    required this.message,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.onConfirm,
    this.onCancel,
    this.confirmColor = AppColors.primary,
    this.isDangerous = false,
  });

  @override
  Widget buildContent(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey.shade700,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              onCancel?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              cancelText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: isDangerous ? AppColors.error : confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog 헬퍼 유틸리티
class DialogHelper {
  DialogHelper._();

  /// 기본 확인 Dialog 표시
  static Future<bool?> showConfirmation(
    BuildContext context, {
    String? title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    IconData? icon,
    Color? iconColor,
    Color confirmColor = AppColors.primary,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        confirmColor: confirmColor,
        isDangerous: isDangerous,
      ),
    );
  }

  /// 위험한 작업 확인 Dialog (삭제 등)
  static Future<bool?> showDangerousConfirmation(
    BuildContext context, {
    String? title,
    required String message,
    String confirmText = '삭제',
    String cancelText = '취소',
  }) {
    return showConfirmation(
      context,
      title: title ?? '경고',
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: Icons.warning_rounded,
      iconColor: AppColors.error,
      confirmColor: AppColors.error,
      isDangerous: true,
    );
  }

  /// 정보 Dialog 표시
  static Future<void> showInfo(
    BuildContext context, {
    String? title,
    required String message,
    String buttonText = '확인',
    IconData? icon,
    Color? iconColor,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: title != null
            ? Text(
                title,
                textAlign: TextAlign.center,
              )
            : null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
