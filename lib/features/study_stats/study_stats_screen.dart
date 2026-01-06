import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/learning/study_timer_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 학습 통계 화면
class StudyStatsScreen extends ConsumerStatefulWidget {
  const StudyStatsScreen({super.key});

  @override
  ConsumerState<StudyStatsScreen> createState() => _StudyStatsScreenState();
}

class _StudyStatsScreenState extends ConsumerState<StudyStatsScreen> {
  DateTime _selectedDate = DateTime.now();

  /// 날짜 선택
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 시간 포맷팅
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }

  /// 활동 유형 색상
  Color _getActivityColor(StudyActivityType type) {
    switch (type) {
      case StudyActivityType.problemSolving:
        return AppColors.primary;
      case StudyActivityType.lesson:
        return AppColors.success;
      case StudyActivityType.review:
        return AppColors.warning;
      case StudyActivityType.wrongAnswerReview:
        return AppColors.error;
      case StudyActivityType.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStats = ref.watch(dailyStudyStatsProvider(_selectedDate));
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final weeklyStats = ref.watch(weeklyStudyStatsProvider(weekStart));
    final sessionHistory = ref.watch(sessionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '학습 통계',
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ],
            ),

            // 통계 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 선택된 날짜
                    _buildDateSelector(),
                    const SizedBox(height: 24),

                    // 일일 통계
                    _buildDailyStatsCard(todayStats),
                    const SizedBox(height: 16),

                    // 주간 통계
                    _buildWeeklyStatsCard(weeklyStats),
                    const SizedBox(height: 16),

                    // 활동 유형별 분석
                    todayStats.when(
                      data: (stats) => stats != null
                          ? _buildActivityBreakdown(stats)
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // 세션 기록
                    _buildSessionHistory(sessionHistory),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 선택기
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 일일 통계 카드
  Widget _buildDailyStatsCard(AsyncValue<DailyStudyStats?> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return const Column(
              children: [
                Text(
                  '0분',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '오늘 학습 시간',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Text(
                _formatDuration(stats.totalSeconds),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '오늘 ${stats.sessionCount}개 세션 완료',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (_, __) => const Text(
          '데이터를 불러올 수 없습니다',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  /// 주간 통계 카드
  Widget _buildWeeklyStatsCard(AsyncValue<WeeklyStudyStats> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번 주 학습',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '총 시간',
                        _formatDuration(stats.totalSeconds),
                        Icons.access_time,
                      ),
                      _buildStatItem(
                        '평균 시간',
                        _formatDuration(stats.averageSecondsPerDay),
                        Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(stats),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('데이터를 불러올 수 없습니다'),
          ),
        ],
      ),
    );
  }

  /// 통계 항목
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 주간 차트
  Widget _buildWeeklyChart(WeeklyStudyStats stats) {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final maxSeconds = stats.dailyStats.isEmpty
        ? 1
        : stats.dailyStats
            .map((s) => s.totalSeconds)
            .reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(7, (index) {
        final date = stats.weekStartDate.add(Duration(days: index));
        final dayStats = stats.dailyStats.firstWhere(
          (s) => s.date.day == date.day && s.date.month == date.month,
          orElse: () => DailyStudyStats(
            date: date,
            totalSeconds: 0,
            activityDurations: {},
            sessionCount: 0,
          ),
        );

        final percentage = maxSeconds > 0
            ? (dayStats.totalSeconds / maxSeconds).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  weekDays[index],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: Text(
                  _formatDuration(dayStats.totalSeconds),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 활동 유형별 분석
  Widget _buildActivityBreakdown(DailyStudyStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '활동 유형별 시간',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.activityDurations.entries.map((entry) {
            final percentage = stats.totalSeconds > 0
                ? (entry.value / stats.totalSeconds * 100)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getActivityColor(entry.key),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key.label,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        '${_formatDuration(entry.value)} (${percentage.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        _getActivityColor(entry.key),
                      ),
                      minHeight: 6,
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

  /// 세션 기록
  Widget _buildSessionHistory(AsyncValue<List<StudySession>> historyAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 세션',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('아직 학습 기록이 없습니다'),
                  ),
                );
              }

              final recentSessions = sessions.reversed.take(10).toList();

              return Column(
                children: recentSessions.map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getActivityColor(session.activityType),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.activityType.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${session.startTime.month}/${session.startTime.day} ${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDuration(session.durationSeconds),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('데이터를 불러올 수 없습니다'),
          ),
        ],
      ),
    );
  }
}
