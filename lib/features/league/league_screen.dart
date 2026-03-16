// 🏆 League Screen
//
// Displays league standings and competition

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/user/user_provider.dart';
import '../../data/providers/league/league_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import 'widgets/league_header.dart';
import 'widgets/leaderboard_list.dart';
import 'widgets/league_info_card.dart';
import 'widgets/league_timer.dart';
import 'league_history_screen.dart';
import '../lessons/lessons_screen.dart';

class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeague();
    });
  }

  void _loadLeague() {
    final user = ref.read(userProvider);
    if (user != null) {
      ref.read(leagueProvider(user.uid).notifier).loadUserLeague();
    }
  }

  Future<void> _onRefresh() async {
    final user = ref.read(userProvider);
    if (user != null) {
      await ref.read(leagueProvider(user.uid).notifier).loadUserLeague();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('리그'),
        ),
        body: const Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    final leagueState = ref.watch(leagueProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '리그',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LeagueHistoryScreen(),
                ),
              );
            },
            tooltip: '리그 히스토리',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showLeagueInfo(context);
            },
            tooltip: '리그 정보',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: leagueState.isLoading && leagueState.userLeagueStatus == null
            ? const Center(child: CircularProgressIndicator())
            : leagueState.error != null &&
                    leagueState.userLeagueStatus == null
                ? _buildErrorState(leagueState.error!)
                : leagueState.userLeagueStatus == null
                    ? _buildEmptyState()
                    : _buildLeagueContent(leagueState, user.uid),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '리그 정보를 불러올 수 없습니다',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLeague,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 리그에 참여하지 않았습니다',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '첫 레슨을 완료하면 자동으로 리그에 배정됩니다',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LessonsScreenFigma(),
                ),
              );
            },
            child: const Text('학습 시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueContent(LeagueState state, String userId) {
    final status = state.userLeagueStatus!;

    return CustomScrollView(
      slivers: [
        // League Header
        SliverToBoxAdapter(
          child: LeagueHeader(status: status),
        ),

        // League Timer — tighter to header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: LeagueTimer(endDate: status.league.endDate),
          ),
        ),

        // League Info Card — more breathing room
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: LeagueInfoCard(status: status),
          ),
        ),

        // Leaderboard Section Header — asymmetric spacing
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '순위표',
                  style: AppTextStyles.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(leagueProvider(userId).notifier).refreshLeaderboard();
                  },
                  tooltip: '새로고침',
                ),
              ],
            ),
          ),
        ),

        // Leaderboard List
        LeaderboardList(
          entries: state.leaderboard,
          promotionCount: status.league.promotionCount,
          relegationCount: status.league.relegationCount,
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 28),
        ),
      ],
    );
  }

  void _showLeagueInfo(BuildContext context) {
    final user = ref.read(userProvider);
    if (user == null) return;
    
    final status = ref.read(leagueProvider(user.uid)).userLeagueStatus;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '리그 시스템 안내',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                '리그란?',
                '매주 경쟁하는 그룹입니다. XP를 많이 획득할수록 순위가 올라갑니다.',
              ),
              _buildInfoSection(
                '승급과 강등',
                '상위 ${status?.league.promotionCount ?? 5}명은 다음 주에 상위 리그로 승급하고, '
                '하위 ${status?.league.relegationCount ?? 5}명은 하위 리그로 강등됩니다.',
              ),
              _buildInfoSection(
                '티어',
                '브론즈 → 실버 → 골드 → 다이아몬드 → 마스터 순으로 티어가 있습니다.',
              ),
              _buildInfoSection(
                '보상',
                '리그 종료 시 순위에 따라 보상을 받을 수 있습니다.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
