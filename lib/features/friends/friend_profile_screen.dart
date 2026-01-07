import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../shared/widgets/indicators/circular_level_badge.dart';

/// 친구 프로필 상세 화면
class FriendProfileScreen extends ConsumerWidget {
  final Friend friend;

  const FriendProfileScreen({
    super.key,
    required this.friend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '친구 프로필',
              gradientColors: AppColors.headerBlueGradient,
            ),

            // 프로필 내용
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.spacingXL),

                    // 프로필 사진 및 기본 정보
                    _buildProfileHeader(),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // 레벨 및 XP 정보
                    _buildLevelInfo(),

                    const SizedBox(height: AppDimensions.spacingL),

                    // 학습 통계
                    _buildStatsSection(),

                    const SizedBox(height: AppDimensions.spacingL),

                    // 업적 및 배지
                    _buildAchievementsSection(),

                    const SizedBox(height: AppDimensions.spacingL),

                    // 최근 학습 기록
                    _buildRecentActivity(),

                    const SizedBox(height: AppDimensions.spacingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 헤더 (사진 + 이름)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        // 프로필 사진
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.accentCyan.withOpacity(0.3),
                AppColors.accentCyan.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.accentCyan,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              friend.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.accentCyan,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // 이름
        Text(
          friend.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingS),

        // 친구 상태
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.successGreen,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.successGreen,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                '친구',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 레벨 및 XP 정보
  Widget _buildLevelInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mathGold.withOpacity(0.1),
            AppColors.mathYellow.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(
          color: AppColors.mathGold.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // 레벨 뱃지
          CircularLevelBadge(
            level: friend.level,
          ),
          const SizedBox(width: AppDimensions.spacingL),

          // XP 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 20,
                      color: AppColors.mathGold,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      'Level ${friend.level}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 18,
                      color: AppColors.mathYellow,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      '${friend.xp} XP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 학습 통계 섹션
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Text(
            '학습 통계',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // 통계 카드들
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: '연속 학습',
                  value: '7일',
                  color: AppColors.streakOrange,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  label: '완료 문제',
                  value: '128개',
                  color: AppColors.mathGold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: '정답률',
                  value: '85%',
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  label: '학습 일수',
                  value: '45일',
                  color: AppColors.mathBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
      ),
    );
  }

  /// 업적 섹션
  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Text(
            '획득한 업적',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // 업적 뱃지들
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            children: [
              _buildAchievementBadge(
                icon: Icons.local_fire_department,
                label: '7일 연속',
                color: AppColors.streakOrange,
              ),
              _buildAchievementBadge(
                icon: Icons.star,
                label: '첫 100문제',
                color: AppColors.mathGold,
              ),
              _buildAchievementBadge(
                icon: Icons.workspace_premium,
                label: 'Level 5',
                color: AppColors.mathBlue,
              ),
              _buildAchievementBadge(
                icon: Icons.emoji_events,
                label: '완벽한 점수',
                color: AppColors.successGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 업적 뱃지
  Widget _buildAchievementBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppDimensions.spacingM),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 최근 학습 기록
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Text(
            '최근 학습 활동',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // 활동 아이템들
        _buildActivityItem(
          icon: Icons.check_circle,
          title: '방정식 마스터하기',
          subtitle: '10문제 중 9문제 정답',
          time: '2시간 전',
          color: AppColors.successGreen,
        ),
        _buildActivityItem(
          icon: Icons.emoji_events,
          title: '레벨 업!',
          subtitle: 'Level 4 → Level 5',
          time: '1일 전',
          color: AppColors.mathGold,
        ),
        _buildActivityItem(
          icon: Icons.local_fire_department,
          title: '7일 연속 학습 달성',
          subtitle: '대단해요! 계속 유지하세요',
          time: '3일 전',
          color: AppColors.streakOrange,
        ),
      ],
    );
  }

  /// 활동 아이템
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        bottom: AppDimensions.spacingM,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),

          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 시간
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
