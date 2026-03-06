import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/indicators/circular_progress_ring.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/game_constants.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 홈 화면 로봇 섹션 (2026-01-25 업데이트 - 실시간 데이터 연동)
///
/// 포함 내용:
/// - 로봇 캐릭터 이미지
/// - 원형 진행률 링 (실제 일일 XP 진행률 표시)
/// - 탭하면 동기부여 메시지 표시
class HomeRobotSection extends ConsumerWidget {
  const HomeRobotSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    // 일일 XP 진행률 계산
    final dailyXP = user?.dailyXP ?? 0;
    final dailyGoal = GameConstants.dailyGoalXP;
    final progress = (dailyXP / dailyGoal).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    return GestureDetector(
      onTap: () {
        _showMotivationalMessage(context, progress, dailyXP, dailyGoal);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 부모 Flexible에 맞춰 크기 결정
          final available = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 140.0;
          final containerSize = available.clamp(80.0, 160.0);
          final ringSize = containerSize * 0.93;
          final characterContainerSize = containerSize * 0.67;
          final characterSize = containerSize * 0.6;

          return SizedBox(
            width: containerSize,
            height: containerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Figma 원형 진행률 링 (실시간 데이터)
                CircularProgressRing(
                  progress: progress,
                  size: ringSize,
                  strokeWidth: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$progressPercent%',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        progressPercent >= 100 ? '목표 달성!' : '진행 중',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // 로봇 캐릭터 (중앙에 오버레이)
                Container(
                  width: characterContainerSize,
                  height: characterContainerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/robot_character.png',
                      width: characterSize,
                      height: characterSize,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/icons/character_design.png',
                          width: characterSize,
                          height: characterSize,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              '🤖',
                              style: TextStyle(fontSize: containerSize * 0.33),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 진행률에 따른 동기부여 메시지 표시
  void _showMotivationalMessage(
    BuildContext context,
    double progress,
    int dailyXP,
    int dailyGoal,
  ) {
    String message;
    String emoji;
    Color backgroundColor;

    if (progress >= 1.0) {
      message = '오늘의 목표를 달성했어요! 정말 대단해요! 🎉';
      emoji = '🏆';
      backgroundColor = AppColors.mathGreen;
    } else if (progress >= 0.75) {
      message = '거의 다 왔어요! 조금만 더 힘내요! 💪';
      emoji = '⭐';
      backgroundColor = AppColors.mathOrange;
    } else if (progress >= 0.5) {
      message = '벌써 반이나 했어요! 잘하고 있어요! 😊';
      emoji = '🌟';
      backgroundColor = AppColors.mathBlue;
    } else if (progress >= 0.25) {
      message = '좋은 시작이에요! 계속 해봐요! 🚀';
      emoji = '✨';
      backgroundColor = AppColors.mathBlue;
    } else {
      message = '오늘도 수학 공부 시작해볼까요? 💫';
      emoji = '🤖';
      backgroundColor = AppColors.skyBlue;
    }

    final remaining = (dailyGoal - dailyXP).clamp(0, dailyGoal);
    final detail = progress >= 1.0
        ? '목표 ${dailyGoal}XP 달성 완료!'
        : '목표까지 ${remaining}XP 남았어요!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
