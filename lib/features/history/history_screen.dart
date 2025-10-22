import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../data/providers/user_provider.dart';

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
      backgroundColor: AppColors.mathBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: ResponsiveWrapper(
            child: Column(
              children: [
                _buildHeader(context),
                _buildUserStats(
                  streakDays: user?.streakDays ?? 0,
                  xp: user?.xp ?? 0,
                  level: user?.level ?? 1,
                ),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (뒤로가기 + 로고)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'GoMATH',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.mathButtonBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 사용자 통계
  Widget _buildUserStats({
    required int streakDays,
    required int xp,
    required int level,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '소인수분해',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          _buildStatItem('🔥', streakDays.toString()),
          const SizedBox(width: AppDimensions.spacingM),
          _buildStatItem('🔶', xp.toString()),
          const SizedBox(width: AppDimensions.spacingM),
          _buildStatItem('⭐', level.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 메인 컨텐츠 (챌린지 + 캘린더)
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
              'Challenges (30 Days)',
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
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.progressBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mathBlue),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXL),
        Row(
          children: [
            Expanded(
              child: _buildChallengeCard(
                icon: '🔥',
                label: 'Current Streak',
                value: '$currentStreak Days',
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildChallengeCard(
                icon: '📅',
                label: 'Remaining',
                value: '${remaining > 0 ? remaining : 0} Days',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChallengeCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'December 2022',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // VIEW 액션
              },
              child: Text(
                'VIEW',
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
      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
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
    // 12월 달력 데이터 (2022년 12월은 목요일부터 시작, 31일까지)
    final completedDays = [13, 14, 15, 16, 17, 18]; // 파란 원으로 표시된 날들

    return Column(
      children: [
        // 1주차 (빈칸 3개 + 1일)
        _buildWeekRow([null, null, null, 1, 2, 3, 4], completedDays),
        _buildWeekRow([5, 6, 7, 8, 9, 10, 11], completedDays),
        _buildWeekRow([12, 13, 14, 15, 16, 17, 18], completedDays),
        _buildWeekRow([19, 20, 21, 22, 23, 24, 25], completedDays),
        _buildWeekRow([26, 27, 28, 29, 30, 31, null], completedDays),
      ],
    );
  }

  Widget _buildWeekRow(List<int?> days, List<int> completedDays) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          if (day == null) {
            return const SizedBox(width: 40, height: 40);
          }

          final isCompleted = completedDays.contains(day);

          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.mathBlue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isCompleted ? Colors.white : AppColors.textPrimary,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
