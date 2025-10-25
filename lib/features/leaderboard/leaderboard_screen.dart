import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../shared/widgets/animations/fade_in_widget.dart';
import '../../data/models/models.dart';
import '../../data/providers/leaderboard_provider.dart';

/// 리더보드 화면
/// 주간/월간/전체 순위를 표시합니다
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.weekly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      _selectedPeriod = LeaderboardPeriod.values[_tabController.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);

    // 선택된 기간에 맞는 리더보드 데이터 가져오기
    final entries = _getEntriesForPeriod(leaderboardState, _selectedPeriod);
    final currentUserEntry = _getCurrentUserEntryForPeriod(entries);

    return Scaffold(
      backgroundColor: AppColors.mathBlue, // GoMath blue
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodTabs(),
              const SizedBox(height: AppDimensions.spacingL),
              if (currentUserEntry != null)
                _buildCurrentUserRank(currentUserEntry),
              const SizedBox(height: AppDimensions.spacingL),
              Expanded(
                child: _buildLeaderboardList(entries),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🏆',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Text(
            '리더보드',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 기간 선택 탭 - Duolingo flat style
  Widget _buildPeriodTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXS),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.surface, // Duolingo flat white
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        labelColor: AppColors.mathBlue, // GoMath blue text when selected
        unselectedLabelColor: AppColors.surface,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        tabs: LeaderboardPeriod.values
            .map((period) => Tab(
                  height: 40,
                  text: period.displayName,
                ))
            .toList(),
      ),
    );
  }

  /// 현재 사용자 순위 표시 - Duolingo flat style with 3D shadow (개선: 애니메이션 추가)
  Widget _buildCurrentUserRank(LeaderboardEntry entry) {
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          tween: Tween(begin: 0.9, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // GoMath 3D solid shadow
                  Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    bottom: -6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.duolingoGreenDark, // Darker green (successGreen 20% darker)
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Main container
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen, // GoMath green
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.duolingoGreenDark, // Darker green
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 순위
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                            border: Border.all(
                              color: AppColors.duolingoGreenDark, // Darker green
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.rank}',
                              style: const TextStyle(
                                color: AppColors.successGreen, // GoMath green
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // 사용자 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '나의 순위',
                                style: TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.userName,
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        // XP
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${entry.xp} XP',
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lv.${entry.level}',
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
          },
        ),
      ),
    );
  }

  /// 리더보드 목록
  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isTopThree = entry.rank <= 3;

          return FadeInWidget(
            delay: Duration(milliseconds: 50 * index),
            child: _buildLeaderboardCard(entry, isTopThree),
          );
        },
      ),
    );
  }

  /// 리더보드 카드 - Duolingo flat style (Fixed: Flexible instead of Expanded)
  Widget _buildLeaderboardCard(LeaderboardEntry entry, bool isTopThree) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.highlightGreen // Light green highlight (successGreen 80% lighter)
            : AppColors.surface,
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.successGreen // GoMath green border for current user
              : AppColors.borderLight, // Light gray border
          width: entry.isCurrentUser ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: entry.isCurrentUser
                ? AppColors.successGreen.withValues(alpha: 0.15)
                : AppColors.borderLight.withValues(alpha: 0.1),
            blurRadius: entry.isCurrentUser ? 8 : 4,
            offset: Offset(0, entry.isCurrentUser ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 순위
          _buildRankBadge(entry),
          const SizedBox(width: AppDimensions.spacingM),
          // 사용자 정보
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min, // FIX: Prevent unbounded height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen, // GoMath green
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '나',
                          style: TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      entry.grade,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.${entry.level}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.mathRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.streakDays}일',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp}',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTopThree
                      ? _getRankColor(entry.rank)
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 순위 배지 - Duolingo flat style
  Widget _buildRankBadge(LeaderboardEntry entry) {
    final medal = entry.medalEmoji;

    if (medal != null) {
      // Top 3는 메달 표시 with flat color and border
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _getRankColor(entry.rank), // Flat color
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: _getDarkerRankColor(entry.rank),
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            medal,
            style: const TextStyle(fontSize: 26),
          ),
        ),
      );
    }

    // 나머지는 순위 숫자 with GoMath style
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.background, // Light gray
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${entry.rank}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 순위별 색상 (GoMath)
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.mathYellow; // 금 (GoMath)
      case 2:
        return AppColors.levelSilver; // 은 (표준 메달 색상)
      case 3:
        return AppColors.levelBronze; // 동 (표준 메달 색상)
      default:
        return AppColors.textSecondary;
    }
  }

  /// 순위별 어두운 색상 (테두리용)
  Color _getDarkerRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.levelGoldDark; // Darker gold (mathYellow 20% darker)
      case 2:
        return AppColors.levelSilverDark; // Darker silver (표준 메달 색상)
      case 3:
        return AppColors.levelBronzeDark; // Darker bronze (표준 메달 색상)
      default:
        return AppColors.borderLight;
    }
  }

  /// 기간별 리더보드 엔트리 가져오기
  List<LeaderboardEntry> _getEntriesForPeriod(
    LeaderboardState state,
    LeaderboardPeriod period,
  ) {
    switch (period) {
      case LeaderboardPeriod.weekly:
        return state.weeklyEntries;
      case LeaderboardPeriod.monthly:
        return state.monthlyEntries;
      case LeaderboardPeriod.allTime:
        return state.allTimeEntries;
    }
  }

  /// 현재 사용자 엔트리 찾기
  LeaderboardEntry? _getCurrentUserEntryForPeriod(
    List<LeaderboardEntry> entries,
  ) {
    try {
      return entries.firstWhere((entry) => entry.isCurrentUser);
    } catch (e) {
      return null;
    }
  }
}
