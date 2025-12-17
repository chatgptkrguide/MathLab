import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/providers/study_history_provider.dart';

/// 월간 상세 통계 화면
class MonthlyStatsScreen extends ConsumerStatefulWidget {
  final DateTime selectedMonth;

  const MonthlyStatsScreen({
    super.key,
    required this.selectedMonth,
  });

  @override
  ConsumerState<MonthlyStatsScreen> createState() => _MonthlyStatsScreenState();
}

class _MonthlyStatsScreenState extends ConsumerState<MonthlyStatsScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth;
  }

  /// 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  /// 다음 달로 이동
  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);

    // 미래 달은 선택 불가
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _currentMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyHistory = ref.watch(studyHistoryProvider);

    // 현재 월의 학습 기록 필터링
    final monthlyHistory = studyHistory.where((date) =>
      date.year == _currentMonth.year && date.month == _currentMonth.month
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '월간 통계',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.headerText),
                onPressed: () => Navigator.pop(context),
              ),
              gradientColors: AppColors.headerBlueGradient,
            ),

            // 통계 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 월 선택기
                    _buildMonthSelector(),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // 월간 요약 카드
                    _buildMonthlySummaryCard(monthlyHistory),
                    const SizedBox(height: AppDimensions.spacingL),

                    // 일별 학습 시간 차트
                    _buildDailyStudyChart(monthlyHistory),
                    const SizedBox(height: AppDimensions.spacingL),

                    // 카테고리별 통계
                    _buildCategoryStats(),
                    const SizedBox(height: AppDimensions.spacingL),

                    // 학습 패턴 분석
                    _buildStudyPatternAnalysis(monthlyHistory),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 월 선택기
  Widget _buildMonthSelector() {
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    final now = DateTime.now();
    final isCurrentMonth = _currentMonth.year == now.year && _currentMonth.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 달 버튼
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppColors.mathBlue),
            onPressed: _previousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // 현재 월 표시
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // 다음 달 버튼
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth ? AppColors.borderLight : AppColors.mathBlue,
            ),
            onPressed: isCurrentMonth ? null : _nextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 월간 요약 카드
  Widget _buildMonthlySummaryCard(List<DateTime> monthlyHistory) {
    final studyDays = monthlyHistory.length;
    final totalProblems = studyDays * 15; // 임시: 일 평균 15문제
    final totalTime = studyDays * 25; // 임시: 일 평균 25분
    final accuracy = 85; // 임시: 정답률 85%

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.headerBlueGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '이번 달 학습 현황',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.headerText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.calendar_today,
                  label: '학습 일수',
                  value: '$studyDays일',
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.headerText.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.access_time,
                  label: '총 학습 시간',
                  value: '$totalTime분',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Divider(color: AppColors.headerText.withValues(alpha: 0.3)),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.assignment,
                  label: '완료 문제',
                  value: '$totalProblems개',
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.headerText.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.check_circle,
                  label: '정답률',
                  value: '$accuracy%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 요약 항목
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.headerText, size: 32),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.headerText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.headerText.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// 일별 학습 시간 차트
  Widget _buildDailyStudyChart(List<DateTime> monthlyHistory) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.mathBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                '일별 학습 시간',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          SizedBox(
            height: 200,
            child: monthlyHistory.isEmpty
                ? Center(
                    child: Text(
                      '이번 달 학습 기록이 없습니다',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : _buildBarChart(monthlyHistory),
          ),
        ],
      ),
    );
  }

  /// 막대 차트
  Widget _buildBarChart(List<DateTime> monthlyHistory) {
    // 일별 학습 시간 데이터 (임시: 랜덤 값)
    final studyTimes = <int, int>{};
    for (var date in monthlyHistory) {
      studyTimes[date.day] = 20 + (date.day % 30); // 임시: 20-50분 사이
    }

    final maxTime = studyTimes.values.isEmpty ? 60 : studyTimes.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxTime.toDouble() + 10,
        barGroups: studyTimes.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppColors.mathBlue,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0 || value.toInt() == 1) {
                  return Text(
                    '${value.toInt()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.borderLight,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// 카테고리별 통계
  Widget _buildCategoryStats() {
    // 임시 데이터
    final categories = {
      '대수': 45,
      '기하': 32,
      '통계': 28,
      '미적분': 15,
    };

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: AppColors.mathBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                '카테고리별 학습',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ...categories.entries.map((entry) {
            final total = categories.values.reduce((a, b) => a + b);
            final percentage = (entry.value / total * 100).round();

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${entry.value}문제 ($percentage%)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.progressBackground,
                    valueColor: AlwaysStoppedAnimation(AppColors.mathBlue),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 학습 패턴 분석
  Widget _buildStudyPatternAnalysis(List<DateTime> monthlyHistory) {
    // 요일별 학습 빈도 계산
    final weekdayCount = <int, int>{};
    for (var date in monthlyHistory) {
      weekdayCount[date.weekday] = (weekdayCount[date.weekday] ?? 0) + 1;
    }

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final maxCount = weekdayCount.values.isEmpty ? 1 : weekdayCount.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.mathBlue, size: 24),
              const SizedBox(width: 8),
              Text(
                '학습 패턴 분석',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            '요일별 학습 빈도',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ...List.generate(7, (index) {
            final weekday = index + 1;
            final count = weekdayCount[weekday] ?? 0;
            final percentage = maxCount > 0 ? count / maxCount : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      weekdays[index],
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.progressBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.mathBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$count일',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
