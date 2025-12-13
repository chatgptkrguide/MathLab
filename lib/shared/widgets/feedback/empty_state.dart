import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../buttons/unified_button.dart';

/// 빈 상태 표시 위젯
///
/// 데이터가 없거나 검색 결과가 없을 때 일관된 UI를 제공합니다.
///
/// 사용 예시:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: '메시지가 없습니다',
///   message: '친구에게 메시지를 보내보세요!',
///   actionText: '친구 추가',
///   onAction: () {
///     // 친구 추가 화면으로 이동
///   },
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? illustration;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.illustration,
    this.iconColor,
  });

  /// 검색 결과 없음
  factory EmptyState.search({
    String? query,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      title: '검색 결과가 없습니다',
      message: query != null ? '"$query"에 대한 결과를 찾을 수 없습니다' : '다른 검색어로 시도해보세요',
      actionText: onClear != null ? '검색 초기화' : null,
      onAction: onClear,
      iconColor: AppColors.textSecondary,
    );
  }

  /// 친구 목록 없음
  factory EmptyState.friends({
    VoidCallback? onAddFriend,
  }) {
    return EmptyState(
      icon: Icons.people_outline,
      title: '친구가 없습니다',
      message: '친구를 추가하고 함께 학습해보세요!',
      actionText: '친구 추가',
      onAction: onAddFriend,
      iconColor: AppColors.accentCyan,
    );
  }

  /// 메시지 없음
  factory EmptyState.messages() {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: '메시지가 없습니다',
      message: '친구와 대화를 시작해보세요',
      iconColor: AppColors.mathBlue,
    );
  }

  /// 학습 기록 없음
  factory EmptyState.history({
    VoidCallback? onStartLearning,
  }) {
    return EmptyState(
      icon: Icons.history,
      title: '학습 기록이 없습니다',
      message: '첫 레슨을 시작하고 기록을 남겨보세요!',
      actionText: '학습 시작',
      onAction: onStartLearning,
      iconColor: AppColors.mathGold,
    );
  }

  /// 오답 노트 없음
  factory EmptyState.wrongAnswers() {
    return EmptyState(
      icon: Icons.check_circle_outline,
      title: '틀린 문제가 없습니다',
      message: '완벽해요! 계속 열심히 하세요!',
      iconColor: AppColors.successGreen,
    );
  }

  /// 업적 없음
  factory EmptyState.achievements({
    VoidCallback? onStartLearning,
  }) {
    return EmptyState(
      icon: Icons.emoji_events_outlined,
      title: '획득한 업적이 없습니다',
      message: '학습을 시작하고 업적을 모아보세요!',
      actionText: '학습 시작',
      onAction: onStartLearning,
      iconColor: AppColors.mathGold,
    );
  }

  /// 알림 없음
  factory EmptyState.notifications() {
    return EmptyState(
      icon: Icons.notifications_none,
      title: '알림이 없습니다',
      message: '새로운 알림이 오면 여기에 표시됩니다',
      iconColor: AppColors.textSecondary,
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
            // 일러스트레이션 또는 아이콘
            if (illustration != null)
              illustration!
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.textSecondary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 50,
                  color: iconColor ?? AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: AppDimensions.spacingXL),

            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // 메시지
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingXL),
              UnifiedButton(
                text: actionText!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 인라인 빈 상태 표시 (작은 공간용)
class InlineEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? iconColor;

  const InlineEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: iconColor ?? AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
