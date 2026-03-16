// 🏅 Achievement Screen
//
// Displays user's achievements and progress

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/achievement_model.dart';
import '../../data/providers/achievement/achievement_provider.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../shared/widgets/loading_overlay.dart';
import 'achievement_card.dart';

class AchievementScreen extends ConsumerStatefulWidget {
  const AchievementScreen({super.key});

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final firebaseUser = authState.firebaseUser;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    final achievementState = ref.watch(achievementProvider(firebaseUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('업적'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '달성률: ${(achievementState.getCompletionPercentage() * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${achievementState.unlockedAchievements.length} / ${achievementState.achievements.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: achievementState.getCompletionPercentage(),
                      backgroundColor: Colors.grey[300],
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '획득한 업적'),
                  Tab(text: '미획득 업적'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          // Tab view
          Expanded(
            child: achievementState.isLoading
                ? const LoadingOverlay(message: '업적을 불러오는 중...')
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementList(
                        achievementState.unlockedAchievements,
                        achievementState,
                      ),
                      _buildAchievementList(
                        achievementState.lockedAchievements,
                        achievementState,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('전체'),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = null;
              });
              final fu = ref.read(authProvider).firebaseUser;
              if (fu != null) {
                ref.read(achievementProvider(fu.uid).notifier).filterByCategory(null);
              }
            },
          ),
          const SizedBox(width: 8),
          ...AchievementCategory.values.map((category) {
            final icon = _getCategoryIcon(category);
            final label = _getCategoryLabel(category);
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text('$icon $label'),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                  final fu = ref.read(authProvider).firebaseUser;
                  if (fu != null) {
                    ref.read(achievementProvider(fu.uid).notifier)
                        .filterByCategory(selected ? category : null);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementList(
    List<AchievementModel> achievements,
    AchievementState state,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '업적이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final fu = ref.read(authProvider).firebaseUser;
        if (fu != null) {
          await ref.read(achievementProvider(fu.uid).notifier).loadAchievements();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final progress = state.getProgress(achievement.id);
          return AchievementCard(
            achievement: achievement,
            progress: progress,
          );
        },
      ),
    );
  }

  String _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.general:
        return '🎯';
      case AchievementCategory.streak:
        return '🔥';
      case AchievementCategory.mastery:
        return '🎓';
      case AchievementCategory.social:
        return '👥';
      case AchievementCategory.speed:
        return '⚡';
      case AchievementCategory.perfectionist:
        return '💯';
      case AchievementCategory.explorer:
        return '🗺️';
    }
  }

  String _getCategoryLabel(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.general:
        return '일반';
      case AchievementCategory.streak:
        return '연속';
      case AchievementCategory.mastery:
        return '숙련';
      case AchievementCategory.social:
        return '소셜';
      case AchievementCategory.speed:
        return '스피드';
      case AchievementCategory.perfectionist:
        return '완벽주의';
      case AchievementCategory.explorer:
        return '탐험가';
    }
  }
}
