import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/problem_provider.dart';
import '../problem/problem_screen.dart';

/// 홈 화면 - 새 디자인 적용
/// 더 둥근 모서리, 생동감 있는 색상, 특별한 레슨 카드
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final problems = ref.watch(problemProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildStatsGrid(user),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildDailyGoalCard(user),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildSpecialLessonCard(problems),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildStartLearningButton(context, ref, problems),
                const SizedBox(height: AppDimensions.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 상단 헤더 (스트릭 표시 포함)
  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요, ${user.name}님!',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Row(
                  children: [
                    Text(
                      '중1 수학을 학습하고 있어요',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text('😊', style: AppTextStyles.emojiSmall),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: _buildStreakBadge(user.streakDays),
          ),
        ],
      ),
    );
  }

  /// 스트릭 배지 (새 디자인)
  Widget _buildStreakBadge(int streakDays) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningOrange,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: AppTextStyles.emojiSmall),
          const SizedBox(width: AppDimensions.spacingXS),
          Text(
            '$streakDays',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드 그리드 (XP 150, 레벨 2, 연속 5일)
  Widget _buildStatsGrid(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          if (isSmallScreen) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildXPCard(user)),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(child: _buildLevelCard(user)),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingM),
                SizedBox(
                  width: constraints.maxWidth * 0.5,
                  child: _buildStreakCard(user),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _buildXPCard(user)),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(child: _buildLevelCard(user)),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(child: _buildStreakCard(user)),
            ],
          );
        },
      ),
    );
  }

  /// XP 카드 (노란색 아이콘)
  Widget _buildXPCard(User user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFFFFC107), // 노란색
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'XP',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            user.xp.toString(),
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 레벨 카드 (파란색 아이콘)
  Widget _buildLevelCard(User user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentCyan,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            '레벨',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            user.level.toString(),
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 연속 카드 (초록색 아이콘)
  Widget _buildStreakCard(User user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.track_changes,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            '연속',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            '${user.streakDays}일',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘의 목표 카드 (초록 진행률)
  Widget _buildDailyGoalCard(User user) {
    const targetXP = 100;
    final currentXP = user.xp.remainder(targetXP);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 목표',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currentXP/100 XP',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: LinearProgressIndicator(
              value: currentXP / targetXP,
              backgroundColor: AppColors.progressBackground,
              valueColor: AlwaysStoppedAnimation(AppColors.progressActiveGreen),
              borderRadius: BorderRadius.circular(6),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Text(
                '목표까지 ${targetXP - currentXP} XP 남았습니다!',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text('💪', style: AppTextStyles.emojiSmall),
            ],
          ),
        ],
      ),
    );
  }

  /// 특별 레슨 카드 (파란색 테두리 + 트로피)
  Widget _buildSpecialLessonCard(List<Problem> problems) {
    final lessonProblems = problems.where((p) => p.lessonId == 'lesson001').toList();

    return SpecialProgressCard(
      title: '레벨 2',
      subtitle: '다음 레슨까지',
      currentValue: 50, // 새 디자인 기준
      targetValue: 200,
      unit: 'XP',
      emoji: '🏆',
    );
  }

  /// 학습 시작하기 버튼 (둥근 초록 버튼)
  Widget _buildStartLearningButton(BuildContext context, WidgetRef ref, List<Problem> problems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: ElevatedButton(
        onPressed: () => _startLearning(context, ref, problems),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXXL,
            vertical: AppDimensions.paddingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '학습 시작하기',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            const Icon(
              Icons.arrow_forward,
              size: AppDimensions.iconM,
            ),
          ],
        ),
      ),
    );
  }

  // 이벤트 핸들러

  void _startLearning(BuildContext context, WidgetRef ref, List<Problem> problems) async {
    if (problems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('문제 데이터를 로드하는 중입니다...'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    // 사용자 레벨에 맞는 추천 문제들 가져오기
    final user = ref.read(userProvider);
    if (user == null) return;

    final recommendedProblems = ref
        .read(problemProvider.notifier)
        .getRecommendedProblems(user.level, count: 5);

    if (recommendedProblems.isEmpty) {
      // 추천 문제가 없으면 첫 번째 레슨 문제들 사용
      final lesson1Problems = ref
          .read(problemProvider.notifier)
          .getProblemsByLesson('lesson001');

      if (lesson1Problems.isNotEmpty) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProblemScreen(
              lessonId: 'lesson001',
              problems: lesson1Problems.take(5).toList(),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } else {
      // 추천 문제들로 학습 시작
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ProblemScreen(
            lessonId: 'recommended',
            problems: recommendedProblems,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }
}