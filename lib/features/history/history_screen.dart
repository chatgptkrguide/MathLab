import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/figma_colors.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/dialogs/grade_selection_dialog.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/learning/study_history_provider.dart';
import 'monthly_stats_screen.dart';

/// 학습 이력 화면 (Figma 디자인 03)
/// 챌린지 진행 상황과 캘린더를 표시
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

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
              // 통합 헤더 (학습 화면과 동일한 디자인)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.headerBlueGradient,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.headerText, size: 28),
                      onPressed: () {
                        final currentGrade = user?.currentGrade ?? '중1';
                        showDialog(
                          context: context,
                          builder: (context) => GradeSelectionDialog(
                            currentGrade: currentGrade,
                            onGradeSelected: (newGrade) {
                              ref.read(userProvider.notifier).updateUser(
                                user!.copyWith(currentGrade: newGrade),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('학년이 $newGrade(으)로 변경되었습니다'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        '학습이력',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.headerText,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // 대칭을 위한 빈 공간
                  ],
                ),
              ),
              Expanded(
                child: ResponsiveWrapper(
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 메인 컨텐츠 (챌린지 + 캘린더)
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChallengeSection(),
            const SizedBox(height: AppDimensions.spacingXXL),
            _buildCalendarSection(),
          ],
        ),
      ),
    );
  }

  /// 챌린지 섹션
  Widget _buildChallengeSection() {
    final user = ref.watch(userProvider);
    final currentStreak = user?.streakDays ?? 0;
    final challengeGoal = 30; // 30일 챌린지
    final remaining = challengeGoal - currentStreak;
    final progress = (currentStreak / challengeGoal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '30일 챌린지',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$currentStreak/$challengeGoal',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.mathBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        // 진행률 바
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.disabled,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Stack(
              children: [
                // 진행률 그라디언트
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4A90E2),
                          Color(0xFF357ABD),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXL),
        Row(
          children: [
            Expanded(
              child: _buildChallengeCardWithAnimation(
                icon: Icons.local_fire_department,
                label: '연속 학습',
                value: '$currentStreak일',
                delay: 0,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildChallengeCardWithAnimation(
                icon: Icons.calendar_today,
                label: '남은 일수',
                value: '${remaining > 0 ? remaining : 0}일',
                delay: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 애니메이션이 있는 챌린지 카드 래퍼
  Widget _buildChallengeCardWithAnimation({
    required IconData icon,
    required String label,
    required String value,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: _buildChallengeCard(
            icon: icon,
            label: label,
            value: value,
          ),
        );
      },
    );
  }

  Widget _buildChallengeCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderLight.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.mathBlue, size: 28),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 캘린더 섹션
  Widget _buildCalendarSection() {
    // 현재 날짜 가져오기
    final now = DateTime.now();
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    final currentMonth = '${months[now.month - 1]} ${now.year}';

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.mathBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentMonth,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyStatsScreen(
                        selectedMonth: DateTime.now(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart, size: 18),
                label: Text(
                  '통계',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.mathBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildCalendar(),
        ],
    );
  }

  Widget _buildCalendar() {
    // 간단한 캘린더 UI (table_calendar 패키지 필요)
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: AppDimensions.spacingM),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['월', '화', '수', '목', '금', '토', '일']
          .map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final studyHistory = ref.watch(studyHistoryProvider);

    // 현재 월의 첫날과 마지막 날
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // 첫 날의 요일 (월요일=1, 일요일=7)
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // 실제 학습 기록에서 완료한 날짜들 가져오기
    final completedDays = studyHistory
        .where((date) => date.year == now.year && date.month == now.month)
        .map((date) => date.day)
        .toList();

    // 주 단위로 날짜 그룹화
    List<List<int?>> weeks = [];
    List<int?> currentWeek = [];

    // 첫 주의 빈 칸 채우기
    for (int i = 1; i < firstWeekday; i++) {
      currentWeek.add(null);
    }

    // 날짜 채우기
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }

    // 마지막 주의 빈 칸 채우기
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(List.from(currentWeek));
    }

    return Column(
      children: weeks.map((week) => _buildWeekRow(week, completedDays)).toList(),
    );
  }

  Widget _buildWeekRow(List<int?> days, List<int> completedDays) {
    final now = DateTime.now();
    final today = now.day;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          if (day == null) {
            return const SizedBox(width: 40, height: 40);
          }

          final isCompleted = completedDays.contains(day);
          final isToday = day == today;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isCompleted ? () {
                // 완료한 날짜 탭 시 해당 날의 학습 기록 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$day일 학습 기록: 문제 15개 완료 🎉'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.mathBlue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.mathBlue : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(
                    color: AppColors.mathBlue,
                    width: 2,
                  ) : null,
                  boxShadow: isCompleted ? [
                    BoxShadow(
                      color: AppColors.mathBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isCompleted ? AppColors.surface :
                                 isToday ? AppColors.mathBlue : AppColors.textPrimary,
                          fontWeight: isCompleted || isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
