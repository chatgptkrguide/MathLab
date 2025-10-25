import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/wrong_answer_provider.dart';
import '../../data/models/wrong_answer.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../problem/problem_screen.dart';

/// 오답 노트 화면
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '오답 노트',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () async {
            await AppHapticFeedback.lightImpact();
            if (mounted) Navigator.of(context).pop();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('복습 필요'),
                  if (state.needsReviewCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
            const Tab(text: '최근 오답'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('완료'),
                  if (state.masteredCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${state.masteredCount})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 통계 요약
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.error_outline,
                  label: '총 오답',
                  value: '${state.totalCount}',
                  color: AppColors.error,
                ),
                _StatItem(
                  icon: Icons.schedule,
                  label: '복습 필요',
                  value: '${state.needsReviewCount}',
                  color: AppColors.mathOrange,
                ),
                _StatItem(
                  icon: Icons.check_circle,
                  label: '완료',
                  value: '${state.masteredCount}',
                  color: AppColors.success,
                ),
              ],
            ),
          ),

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
      // 정답 처리 (실제로는 ProblemScreen에서 결과를 반환받아야 함)
      // 여기서는 간단하게 복습 완료로 처리
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

/// 통계 아이템
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
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
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              '복습할 문제가 없어요!',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '꾸준히 복습해서 모든 문제를 마스터했어요',
              style: AppTextStyles.bodyMedium.copyWith(
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
            const Text(
              '📝',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              '아직 오답이 없어요',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '문제를 풀면서 틀린 문제가 여기에 저장돼요',
              style: AppTextStyles.bodyMedium.copyWith(
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
            const Text(
              '💪',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              '아직 완료한 문제가 없어요',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              '문제를 3번 연속 맞히면 완료 처리돼요',
              style: AppTextStyles.bodyMedium.copyWith(
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

/// 오답 카드
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
        return AppColors.error;
      case 1:
        return AppColors.mathOrange;
      default:
        return AppColors.success;
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isMastered
              ? AppColors.success.withOpacity(0.5)
              : showUrgency && wrongAnswer.urgency > 0
                  ? _getUrgencyColor().withOpacity(0.5)
                  : AppColors.borderLight,
          width: isMastered || (showUrgency && wrongAnswer.urgency > 0) ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
                      horizontal: AppDimensions.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      wrongAnswer.problem.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppDimensions.spacingS),

                  // 난이도
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.disabled.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      wrongAnswer.problem.difficulty.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 긴급도 또는 완료 표시
                  if (isMastered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check, color: AppColors.surface, size: 14),
                          SizedBox(width: 2),
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
                        horizontal: AppDimensions.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getUrgencyColor(),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
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

              const SizedBox(height: AppDimensions.spacingS),

              // 문제
              Text(
                wrongAnswer.problem.question,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.spacingS),

              // 정보
              if (showReviewInfo)
                Text(
                  '복습 횟수: ${wrongAnswer.reviewCount}/3 • 다음 복습: ${wrongAnswer.daysUntilReview}일 후',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else if (isMastered)
                Text(
                  '완료일: ${_formatDate(wrongAnswer.lastReviewDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Text(
                  '틀린 날짜: ${_formatDate(wrongAnswer.timestamp)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
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
