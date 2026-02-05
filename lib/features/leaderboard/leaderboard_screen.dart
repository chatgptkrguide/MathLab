import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/layout/responsive_wrapper.dart';
import '../../data/models/models.dart';
import '../../data/providers/gamification/leaderboard_provider.dart';
import '../../data/providers/user/user_provider.dart';
import 'widgets/widgets.dart';

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
    final user = ref.watch(userProvider);
    final leaderboardState = ref.watch(leaderboardProvider(user?.id));

    // 선택된 기간에 맞는 리더보드 데이터 가져오기
    final entries = _getEntriesForPeriod(leaderboardState, _selectedPeriod);
    final currentUserEntry = _getCurrentUserEntryForPeriod(entries);

    return Scaffold(
      backgroundColor: AppColors.mathBlue, // GoMath blue
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Column(
            children: [
              const LeaderboardHeader(),
              LeaderboardPeriodTabs(tabController: _tabController),
              const SizedBox(height: AppDimensions.spacingL),
              if (currentUserEntry != null)
                LeaderboardCurrentUserRank(entry: currentUserEntry),
              const SizedBox(height: AppDimensions.spacingL),
              Expanded(
                child: LeaderboardList(entries: entries),
              ),
            ],
          ),
        ),
      ),
    );
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
