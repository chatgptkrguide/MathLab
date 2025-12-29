import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/learning/problem_management_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 문제 관리 화면
class ProblemManagementScreen extends ConsumerStatefulWidget {
  const ProblemManagementScreen({super.key});

  @override
  ConsumerState<ProblemManagementScreen> createState() =>
      _ProblemManagementScreenState();
}

class _ProblemManagementScreenState
    extends ConsumerState<ProblemManagementScreen> {
  ProblemState? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(problemStatisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            const AdaptiveAppHeader(
              title: '문제 관리',
            ),

            // 통계 요약
            _buildStatisticsSummary(statistics),

            // 필터 탭
            _buildFilterTabs(),

            // 문제 목록
            Expanded(
              child: _buildProblemList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 요약 카드
  Widget _buildStatisticsSummary(AsyncValue<ProblemStatistics> statisticsAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: statisticsAsync.when(
        data: (stats) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('전체', stats.totalProblems.toString()),
                _buildStatItem('해결', stats.solvedProblems.toString()),
                _buildStatItem('미해결', stats.unsolvedProblems.toString()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '정답률: ${stats.overallAccuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
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

  /// 통계 항목
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// 필터 탭
  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('전체', null),
            const SizedBox(width: 8),
            _buildFilterChip('미해결', ProblemState.unsolved),
            const SizedBox(width: 8),
            _buildFilterChip('해결', ProblemState.solved),
            const SizedBox(width: 8),
            _buildFilterChip('복습 필요', ProblemState.reviewing),
            const SizedBox(width: 8),
            _buildFilterChip('건너뜀', ProblemState.skipped),
          ],
        ),
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChip(String label, ProblemState? state) {
    final isSelected = _selectedFilter == state;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = state;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// 문제 목록
  Widget _buildProblemList() {
    final filter = ProblemFilter(state: _selectedFilter);
    final problemsAsync = ref.watch(filteredProblemsProvider(filter));

    return problemsAsync.when(
      data: (problems) {
        if (problems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '문제가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: problems.length,
          itemBuilder: (context, index) {
            final problemStatus = problems[index];
            return _buildProblemCard(problemStatus);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('데이터를 불러올 수 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(filteredProblemsProvider(filter));
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 문제 카드
  Widget _buildProblemCard(ProblemStatus status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: 문제 상세 화면으로 이동
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 상태 아이콘
                _buildStateIcon(status.state),
                const SizedBox(width: 16),

                // 문제 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '문제 ${status.problemId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                            '시도 ${status.attemptCount}회',
                            Icons.replay,
                          ),
                          const SizedBox(width: 8),
                          if (status.attemptCount > 0)
                            _buildInfoChip(
                              '${status.accuracyRate.toStringAsFixed(0)}%',
                              Icons.trending_up,
                            ),
                        ],
                      ),
                      if (status.lastAttemptDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '마지막: ${_formatDate(status.lastAttemptDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 화살표
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 상태 아이콘
  Widget _buildStateIcon(ProblemState state) {
    IconData icon;
    Color color;

    switch (state) {
      case ProblemState.solved:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case ProblemState.unsolved:
        icon = Icons.radio_button_unchecked;
        color = Colors.grey;
        break;
      case ProblemState.skipped:
        icon = Icons.skip_next;
        color = AppColors.warning;
        break;
      case ProblemState.reviewing:
        icon = Icons.replay_circle_filled;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  /// 정보 칩
  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
