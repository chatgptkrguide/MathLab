import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../indicators/loading_widgets.dart';

/// 전체 화면 로딩 오버레이
///
/// 사용 예시:
/// ```dart
/// LoadingOverlay.show(context, message: '데이터 로딩 중...');
/// // 작업 완료 후
/// LoadingOverlay.hide(context);
/// ```
class LoadingOverlay {
  static OverlayEntry? _currentOverlay;

  /// 로딩 오버레이 표시
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    // 이미 표시 중이면 무시
    if (_currentOverlay != null) return;

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => LoadingOverlayWidget(
        message: message,
        barrierDismissible: barrierDismissible,
        onDismiss: () {
          hide(context);
        },
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// 로딩 오버레이 숨기기
  static void hide(BuildContext context) {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// 비동기 작업과 함께 사용
  ///
  /// 사용 예시:
  /// ```dart
  /// await LoadingOverlay.during(
  ///   context,
  ///   future: apiCall(),
  ///   message: '저장 중...',
  /// );
  /// ```
  static Future<T> during<T>(
    BuildContext context, {
    required Future<T> future,
    String? message,
  }) async {
    show(context, message: message);
    try {
      return await future;
    } finally {
      hide(context);
    }
  }
}

/// 로딩 오버레이 위젯
class LoadingOverlayWidget extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;
  final VoidCallback? onDismiss;

  const LoadingOverlayWidget({
    super.key,
    this.message,
    this.barrierDismissible = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: InkWell(
        onTap: barrierDismissible ? onDismiss : null,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DuolingoLoadingIndicator(size: 60),
                if (message != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    message!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
