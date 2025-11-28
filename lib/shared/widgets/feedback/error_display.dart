import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../buttons/primary_button.dart';

/// 에러 표시 위젯
///
/// 네트워크 오류, 데이터 로딩 실패 등의 에러 상황을 일관되게 표시합니다.
///
/// 사용 예시:
/// ```dart
/// ErrorDisplay(
///   message: '데이터를 불러올 수 없습니다',
///   onRetry: () async {
///     await loadData();
///   },
/// )
/// ```
class ErrorDisplay extends StatelessWidget {
  final String? title;
  final String message;
  final String? details;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final VoidCallback? onCancel;
  final String? cancelButtonText;

  const ErrorDisplay({
    super.key,
    this.title,
    required this.message,
    this.details,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryButtonText,
    this.onCancel,
    this.cancelButtonText,
  });

  /// 네트워크 에러 표시
  factory ErrorDisplay.network({
    VoidCallback? onRetry,
  }) {
    return ErrorDisplay(
      title: '네트워크 오류',
      message: '인터넷 연결을 확인해주세요',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryButtonText: '다시 시도',
    );
  }

  /// 데이터 없음 에러
  factory ErrorDisplay.notFound({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorDisplay(
      title: '데이터를 찾을 수 없습니다',
      message: message ?? '요청하신 내용을 찾을 수 없습니다',
      icon: Icons.search_off,
      onRetry: onRetry,
    );
  }

  /// 권한 에러
  factory ErrorDisplay.permission({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorDisplay(
      title: '권한이 필요합니다',
      message: message ?? '이 기능을 사용하려면 권한이 필요합니다',
      icon: Icons.lock_outline,
      onRetry: onRetry,
      retryButtonText: '설정으로 이동',
    );
  }

  /// 서버 에러
  factory ErrorDisplay.server({
    String? details,
    VoidCallback? onRetry,
  }) {
    return ErrorDisplay(
      title: '서버 오류',
      message: '잠시 후 다시 시도해주세요',
      details: details,
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 에러 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),

            // 제목
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingM),
            ],

            // 메시지
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // 상세 정보
            if (details != null) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  details!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],

            // 버튼들
            const SizedBox(height: AppDimensions.spacingXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 취소 버튼
                if (onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                      ),
                      child: Text(cancelButtonText ?? '취소'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                ],

                // 재시도 버튼
                if (onRetry != null)
                  Expanded(
                    child: PrimaryButton(
                      text: retryButtonText ?? '다시 시도',
                      onPressed: onRetry!,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 인라인 에러 표시 (작은 공간용)
class InlineErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.errorRed,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppDimensions.spacingM),
            TextButton(
              onPressed: onRetry,
              child: Text(
                '재시도',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
