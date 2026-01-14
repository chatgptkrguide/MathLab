import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/learning/wrong_answer_provider.dart';
import '../../data/models/learning/wrong_answer.dart';
import '../../shared/constants/constants.dart';
import '../../shared/widgets/widgets.dart';
import '../../shared/utils/utils.dart';
import '../problem/problem_screen.dart';
import 'widgets/review_needed_tab.dart';
import 'widgets/recent_tab.dart';
import 'widgets/mastered_tab.dart';

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: FigmaColors.homeGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 공통 헤더 위젯 사용 (메뉴 버튼 포함)
              CommonAppHeaderWithMenu(
                title: '오답 노트',
                onMenuPressed: () {
                  // TODO: 학년 선택 드로어 (필요시 추가)
                  SnackBarUtils.showInfo(context, '학년 선택 기능 준비 중입니다');
                },
              ),

              // 통계 카드 (현대적인 카드 디자인)
              _buildStatsCards(state),

              // 필터 바 (카테고리, 난이도)
              _buildFilterBar(),

              // 탭 바
              _buildTabBar(state),

              // 탭 뷰
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 복습 필요 탭
                    ReviewNeededTab(
                      provider: provider,
                      onTap: (wrongAnswer) =>
                          _navigateToProblem(context, wrongAnswer),
                    ),

                    // 최근 오답 탭
                    RecentTab(
                      provider: provider,
                      onTap: (wrongAnswer) =>
                          _navigateToProblem(context, wrongAnswer),
                    ),

                    // 완료 탭
                    MasteredTab(
                      provider: provider,
                      onTap: (wrongAnswer) =>
                          _navigateToProblem(context, wrongAnswer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 통계 카드 - 심플하고 깔끔한 디자인
  Widget _buildStatsCards(WrongAnswerState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.error_outline_rounded,
            label: '총 오답',
            value: '${state.totalCount}',
            color: AppColors.mathRed,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderLight,
          ),
          _buildStatItem(
            icon: Icons.schedule_rounded,
            label: '복습 필요',
            value: '${state.needsReviewCount}',
            color: AppColors.mathOrange,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderLight,
          ),
          _buildStatItem(
            icon: Icons.check_circle_outline_rounded,
            label: '완료',
            value: '${state.masteredCount}',
            color: AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  /// 개별 통계 항목 - 심플한 디자인
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 필터 바 - 카테고리 및 난이도 필터
  Widget _buildFilterBar() {
    final provider = ref.read(wrongAnswerProvider.notifier);
    final state = ref.watch(wrongAnswerProvider);
    final categories = provider.availableCategories;
    final difficulties = provider.availableDifficulties;

    // 필터가 없으면 표시하지 않음
    if (categories.isEmpty && difficulties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 필터
          if (categories.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '카테고리',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                if (state.selectedCategory != null ||
                    state.selectedDifficulty != null)
                  GestureDetector(
                    onTap: () {
                      provider.clearFilters();
                      AppHapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '전체 보기',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = state.selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setCategory(selected ? category : null);
                        AppHapticFeedback.selectionClick();
                      },
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.mathBlue,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.mathBlue
                              : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // 난이도 필터
          if (difficulties.isNotEmpty) ...[
            Text(
              '난이도',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: difficulties.map((difficulty) {
                  final isSelected = state.selectedDifficulty == difficulty;
                  final color = _getDifficultyColor(difficulty);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Lv $difficulty'),
                          const SizedBox(width: 4),
                          ...List.generate(
                            difficulty,
                            (index) => Icon(
                              Icons.star,
                              size: 12,
                              color: isSelected ? AppColors.surface : color,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setDifficulty(selected ? difficulty : null);
                        AppHapticFeedback.selectionClick();
                      },
                      backgroundColor: AppColors.background,
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? color : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 난이도별 색상
  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.successGreen;
      case 2:
        return AppColors.mathYellow;
      case 3:
        return AppColors.mathOrange;
      case 4:
        return AppColors.mathRed;
      case 5:
        return AppColors.mathPurple;
      default:
        return AppColors.mathBlue;
    }
  }

  /// 탭 바 - Duolingo 스타일
  Widget _buildTabBar(WrongAnswerState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
          lessonId: wrongAnswer.problem.lessonId ?? '',
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
