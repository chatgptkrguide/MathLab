import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../data/providers/user/user_provider.dart';

/// 문제 풀이 화면 헤더
///
/// Duolingo 스타일의 헤더:
/// - 뒤로가기 버튼
/// - 연속 정답 스트릭 표시
/// - 사용자 XP 표시
/// - 진행률 바
class ProblemHeader extends ConsumerWidget {
  /// 현재 진행률 (0.0 ~ 1.0)
  final double progress;

  /// 현재 연속 정답 수
  final int currentStreak;

  /// 스트릭 애니메이션 활성화 여부
  final bool showStreakAnimation;

  /// 닫기 버튼 콜백
  final VoidCallback onClose;

  const ProblemHeader({
    super.key,
    required this.progress,
    required this.currentStreak,
    this.showStreakAnimation = false,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // 뒤로가기 + 스트릭 + XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Duolingo-style close button
              _buildCloseButton(),

              // 연속 정답 스트릭 뱃지
              if (currentStreak > 0) _buildStreakBadge(),

              // Clean XP badge
              _buildXPBadge(user?.xp ?? 0),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Duolingo-style progress bar
          _buildProgressBar(),
        ],
      ),
    );
  }

  /// 닫기 버튼
  Widget _buildCloseButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.close, color: AppColors.surface, size: 20),
        padding: EdgeInsets.zero,
        onPressed: onClose,
      ),
    );
  }

  /// 스트릭 뱃지 (연속 정답)
  Widget _buildStreakBadge() {
    // 스트릭 수에 따른 색상
    final Color color = currentStreak >= 10
        ? AppColors.mathPurple
        : currentStreak >= 5
            ? AppColors.mathOrange
            : AppColors.mathYellow;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      tween: Tween(
        begin: showStreakAnimation ? 0.8 : 1.0,
        end: showStreakAnimation ? 1.2 : 1.0,
      ),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.surface,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$currentStreak',
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// XP 뱃지
  Widget _buildXPBadge(int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.diamond_outlined,
            color: AppColors.mathOrange,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '$xp',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 진행률 바
  Widget _buildProgressBar() {
    return Stack(
      children: [
        // Background bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Progress bar with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: progress),
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.05, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.mathYellow, AppColors.mathYellowDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mathYellow.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
