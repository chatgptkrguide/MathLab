import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/wrong_answer_provider.dart';
import '../../data/models/wrong_answer.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../problem/problem_screen.dart';

/// 오답 노트 화면 - 완전히 새로운 디자인
class WrongAnswerScreen extends ConsumerStatefulWidget {
  const WrongAnswerScreen({super.key});

  @override
  ConsumerState<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends ConsumerState<WrongAnswerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wrongAnswerProvider);
    final provider = ref.read(wrongAnswerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 커스텀 헤더 (GoMath 브랜드 스타일)
            _buildHeader(context),

            // 통계 카드 (현대적인 카드 디자인)
            _buildStatsCards(state),

            // 탭 바
            _buildTabBar(state),

            // 탭 뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 복습 필요 탭
                  _ReviewNeededTab(
                    provider: provider,
                    onTap: (wrongAnswer) => _navigateToProblem(context, wrongAnswer),
                  ),

                  // 최근 오답 탭
                  _RecentTab(
                    provider: provider,
                    onTap: (wrongAnswer) => _navigateToProblem(context, wrongAnswer),
                  ),

                  // 완료 탭
                  _MasteredTab(
                    provider: provider,
                    onTap: (wrongAnswer) => _navigateToProblem(context, wrongAnswer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 커스텀 헤더 - GoMath 브랜드 스타일
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.mathRed,
        boxShadow: [
          BoxShadow(
            color: AppColors.mathRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 뒤로 가기 버튼
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            child: InkWell(
              onTap: () async {
                await AppHapticFeedback.lightImpact();
                if (mounted) Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              splashColor: AppColors.surface.withValues(alpha: 0.2),
              highlightColor: AppColors.surface.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.surface,
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppDimensions.spacingM),

          // 제목 + 이모지
          Expanded(
            child: Row(
              children: [
                const Text(
                  '📚',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  '오답 노트',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드 - 현대적인 3D 카드 디자인
  Widget _buildStatsCards(WrongAnswerState state) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.error_outline_rounded,
              label: '총 오답',
              value: '${state.totalCount}',
              color: AppColors.mathRed,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: _buildStatCard(
              icon: Icons.schedule_rounded,
              label: '복습 필요',
              value: '${state.needsReviewCount}',
              color: AppColors.mathOrange,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_outline_rounded,
              label: '완료',
              value: '${state.masteredCount}',
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 통계 카드 - GoMath 3D 스타일
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.9, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 3D Shadow
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                bottom: -6,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Main Card
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingM,
                  horizontal: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 탭 바 - Duolingo 스타일
  Widget _buildTabBar(WrongAnswerState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.mathRed,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('복습 필요'),
                if (state.needsReviewCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mathRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.needsReviewCount}',
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(
            height: 44,
            text: '최근 오답',
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('완료'),
                if (state.masteredCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.masteredCount}',
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 문제 풀이 화면으로 이동
  Future<void> _navigateToProblem(
    BuildContext context,
    WrongAnswer wrongAnswer,
  ) async {
    await AppHapticFeedback.selectionClick();

    if (!context.mounted) return;

    // 단일 문제로 ProblemScreen 열기
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProblemScreen(
          lessonId: wrongAnswer.problem.lessonId,
          problems: [wrongAnswer.problem],
        ),
      ),
    );

    // 문제 풀이 후 복습 상태 업데이트
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.surface,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Text(
                  '복습 완료! 계속 노력하세요!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// 복습 필요 탭
class _ReviewNeededTab extends ConsumerWidget {
  final WrongAnswerProvider provider;
  final Function(WrongAnswer) onTap;

  const _ReviewNeededTab({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewList = provider.reviewList;

    if (reviewList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mathYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: AppColors.mathYellow,
                size: 80,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '완벽해요! 🎉',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '복습할 문제가 없어요',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: reviewList.length,
      itemBuilder: (context, index) {
        final wrongAnswer = reviewList[index];
        return _WrongAnswerCard(
          wrongAnswer: wrongAnswer,
          showUrgency: true,
          onTap: () => onTap(wrongAnswer),
        );
      },
    );
  }
}

/// 최근 오답 탭
class _RecentTab extends ConsumerWidget {
  final WrongAnswerProvider provider;
  final Function(WrongAnswer) onTap;

  const _RecentTab({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentList = provider.recentList;

    if (recentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mathBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '📝',
                style: TextStyle(fontSize: 80),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '아직 오답이 없어요',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '문제를 풀면 여기에 저장돼요',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: recentList.length,
      itemBuilder: (context, index) {
        final wrongAnswer = recentList[index];
        return _WrongAnswerCard(
          wrongAnswer: wrongAnswer,
          showReviewInfo: true,
          onTap: () => onTap(wrongAnswer),
        );
      },
    );
  }
}

/// 완료 탭
class _MasteredTab extends ConsumerWidget {
  final WrongAnswerProvider provider;
  final Function(WrongAnswer) onTap;

  const _MasteredTab({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteredList = provider.masteredList;

    if (masteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.mathYellow,
                size: 80,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              '아직 완료한 문제가 없어요',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '3번 연속 맞히면 완료돼요',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: masteredList.length,
      itemBuilder: (context, index) {
        final wrongAnswer = masteredList[index];
        return _WrongAnswerCard(
          wrongAnswer: wrongAnswer,
          isMastered: true,
          onTap: () => onTap(wrongAnswer),
        );
      },
    );
  }
}

/// 오답 카드 - 개선된 디자인
class _WrongAnswerCard extends StatelessWidget {
  final WrongAnswer wrongAnswer;
  final bool showUrgency;
  final bool showReviewInfo;
  final bool isMastered;
  final VoidCallback onTap;

  const _WrongAnswerCard({
    required this.wrongAnswer,
    this.showUrgency = false,
    this.showReviewInfo = false,
    this.isMastered = false,
    required this.onTap,
  });

  Color _getUrgencyColor() {
    switch (wrongAnswer.urgency) {
      case 2:
        return AppColors.mathRed;
      case 1:
        return AppColors.mathOrange;
      default:
        return AppColors.successGreen;
    }
  }

  String _getUrgencyText() {
    switch (wrongAnswer.urgency) {
      case 2:
        return '긴급';
      case 1:
        return '복습 시기';
      default:
        return '여유';
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isMastered
        ? AppColors.successGreen
        : showUrgency && wrongAnswer.urgency > 0
            ? _getUrgencyColor()
            : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: borderColor.withValues(alpha: 0.1),
          highlightColor: borderColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 카테고리
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mathBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.mathBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        wrongAnswer.problem.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mathBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppDimensions.spacingS),

                    // 난이도
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.disabled.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        wrongAnswer.problem.difficulty.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 긴급도 또는 완료 표시
                    if (isMastered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_rounded, color: AppColors.surface, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '완료',
                              style: TextStyle(
                                color: AppColors.surface,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (showUrgency && wrongAnswer.urgency > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getUrgencyText(),
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // 문제
                Text(
                  wrongAnswer.problem.question,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // 정보
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        showReviewInfo
                            ? '복습 ${wrongAnswer.reviewCount}/3회 • ${wrongAnswer.daysUntilReview}일 후'
                            : isMastered
                                ? '완료일: ${_formatDate(wrongAnswer.lastReviewDate)}'
                                : '틀린 날짜: ${_formatDate(wrongAnswer.timestamp)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    if (diff < 7) return '$diff일 전';

    return '${date.year}.${date.month}.${date.day}';
  }
}
