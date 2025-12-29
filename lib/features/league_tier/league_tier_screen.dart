import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/gamification/league_tier_provider.dart';
import '../../data/services/league_service.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';

/// 리그 티어 관리 화면
class TierLevelScreen extends ConsumerWidget {
  const TierLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueInfoAsync = ref.watch(userTierLevelInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '리그 티어',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 리그 정보
            Expanded(
              child: _buildTierInfo(context, ref, leagueInfoAsync),
            ),
          ],
        ),
      ),
    );
  }

  /// 리그 정보 표시
  Widget _buildTierInfo(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<TierInfo?> leagueInfoAsync,
  ) {
    return leagueInfoAsync.when(
      data: (league) {
        if (league == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '리그 정보를 불러올 수 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 현재 티어 카드
              _buildTierCard(league),

              const SizedBox(height: 16),

              // 강등 경고 또는 복구 진행 상황
              if (league.isDemotionTarget)
                _buildDemotionWarning(league)
              else if (league.canRecover)
                _buildRecoveryProgress(league),

              const SizedBox(height: 16),

              // 활동 상태
              _buildActivityStatus(league),

              const SizedBox(height: 16),

              // 포인트 정보
              _buildPointsInfo(league),

              const SizedBox(height: 24),

              // 티어 진행 상황
              _buildTierProgression(),

              const SizedBox(height: 24),

              // 시스템 설명
              _buildSystemInfo(),
            ],
          ),
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
                ref.invalidate(userTierLevelInfoProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 현재 티어 카드
  Widget _buildTierCard(TierInfo league) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTierColor(league.currentTier),
            _getTierColor(league.currentTier).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getTierColor(league.currentTier).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 티어 아이콘과 이름
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getTierIcon(league.currentTier),
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Text(
                league.currentTier.label,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 순위 정보
          if (league.rank > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${league.rank}위',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 강등 경고
  Widget _buildDemotionWarning(TierInfo league) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '강등 위험!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${league.consecutiveInactiveDays}일 동안 활동하지 않았습니다.\n문제를 풀어 강등을 피하세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: league.consecutiveInactiveDays / LeagueService.demotionDays,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(AppColors.error),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${LeagueService.demotionDays - league.consecutiveInactiveDays}일 남음',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  /// 복구 진행 상황
  Widget _buildRecoveryProgress(TierInfo league) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.warning,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '복구 중',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '이전 티어로 복구하려면 ${LeagueService.recoveryProblems - league.problemsSolvedSinceDemotion}개 문제를 더 풀어야 합니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: league.problemsSolvedSinceDemotion /
                LeagueService.recoveryProblems,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(AppColors.success),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${league.problemsSolvedSinceDemotion}/${LeagueService.recoveryProblems} 문제 완료',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  /// 활동 상태
  Widget _buildActivityStatus(TierInfo league) {
    final daysSinceLastActive =
        DateTime.now().difference(league.lastActiveDate).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '활동 상태',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            '마지막 활동',
            daysSinceLastActive == 0
                ? '오늘'
                : '$daysSinceLastActive일 전',
          ),
          _buildStatusRow(
            '연속 비활동',
            '${league.consecutiveInactiveDays}일',
          ),
        ],
      ),
    );
  }

  /// 포인트 정보
  Widget _buildPointsInfo(TierInfo league) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '포인트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${league.points} 포인트',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  /// 상태 행
  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  /// 티어 진행 상황
  Widget _buildTierProgression() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '티어 체계',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...TierLevel.values.reversed.map((tier) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    _getTierIcon(tier),
                    color: _getTierColor(tier),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tier.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
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

  /// 시스템 설명
  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '리그 티어 시스템',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('📉 강등 조건', '7일 이상 비활동 시 자동 강등'),
          _buildInfoItem('📈 복구 방법', '10문제 풀면 이전 티어로 복구'),
          _buildInfoItem('⭐ 포인트', '문제를 풀면 포인트 획득'),
          _buildInfoItem('🏆 승급', '높은 포인트로 상위 티어 도전'),
        ],
      ),
    );
  }

  /// 정보 항목
  Widget _buildInfoItem(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 티어별 색상
  Color _getTierColor(TierLevel tier) {
    switch (tier) {
      case TierLevel.bronze:
        return const Color(0xFFCD7F32);
      case TierLevel.silver:
        return const Color(0xFFC0C0C0);
      case TierLevel.gold:
        return const Color(0xFFFFD700);
      case TierLevel.platinum:
        return const Color(0xFFE5E4E2);
      case TierLevel.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  /// 티어별 아이콘
  IconData _getTierIcon(TierLevel tier) {
    switch (tier) {
      case TierLevel.bronze:
        return Icons.workspace_premium;
      case TierLevel.silver:
        return Icons.military_tech;
      case TierLevel.gold:
        return Icons.emoji_events;
      case TierLevel.platinum:
        return Icons.diamond;
      case TierLevel.diamond:
        return Icons.stars;
    }
  }
}
