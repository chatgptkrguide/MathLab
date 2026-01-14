import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/headers/common_app_header.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';

/// 업적 달성 데이터 모델
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int currentProgress;
  final int targetProgress;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentProgress,
    required this.targetProgress,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercentage => currentProgress / targetProgress;
}

/// 업적 화면
///
/// 사용자가 달성할 수 있는 다양한 업적을 표시하고 진행 상황을 추적합니다.
/// - 학습 업적 (문제 풀이, 스트릭 등)
/// - 소셜 업적 (친구 추가, 리그 순위 등)
/// - 특별 업적 (이벤트, 도전 과제 등)
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() =>
      _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 샘플 업적 데이터
  final List<Achievement> _learningAchievements = [
    Achievement(
      id: 'first_problem',
      title: '첫 걸음',
      description: '첫 번째 문제 풀기',
      icon: Icons.celebration,
      currentProgress: 1,
      targetProgress: 1,
      xpReward: 10,
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Achievement(
      id: 'problem_solver_10',
      title: '문제 해결사',
      description: '10개의 문제 풀기',
      icon: Icons.psychology,
      currentProgress: 7,
      targetProgress: 10,
      xpReward: 50,
    ),
    Achievement(
      id: 'problem_solver_50',
      title: '실력자',
      description: '50개의 문제 풀기',
      icon: Icons.military_tech,
      currentProgress: 7,
      targetProgress: 50,
      xpReward: 200,
    ),
    Achievement(
      id: 'streak_3',
      title: '꾸준함',
      description: '3일 연속 학습하기',
      icon: Icons.local_fire_department,
      currentProgress: 2,
      targetProgress: 3,
      xpReward: 30,
    ),
    Achievement(
      id: 'streak_7',
      title: '일주일 연속',
      description: '7일 연속 학습하기',
      icon: Icons.whatshot,
      currentProgress: 2,
      targetProgress: 7,
      xpReward: 100,
    ),
    Achievement(
      id: 'perfect_score',
      title: '완벽한 실력',
      description: '레슨 하나를 100% 정답으로 완료하기',
      icon: Icons.stars,
      currentProgress: 0,
      targetProgress: 1,
      xpReward: 150,
    ),
  ];

  final List<Achievement> _socialAchievements = [
    Achievement(
      id: 'first_friend',
      title: '친구 만들기',
      description: '첫 번째 친구 추가하기',
      icon: Icons.person_add,
      currentProgress: 0,
      targetProgress: 1,
      xpReward: 20,
    ),
    Achievement(
      id: 'friend_5',
      title: '인기쟁이',
      description: '5명의 친구 추가하기',
      icon: Icons.people,
      currentProgress: 0,
      targetProgress: 5,
      xpReward: 100,
    ),
    Achievement(
      id: 'league_top10',
      title: '상위권 진입',
      description: '리그에서 상위 10위 안에 들기',
      icon: Icons.emoji_events,
      currentProgress: 0,
      targetProgress: 1,
      xpReward: 200,
    ),
    Achievement(
      id: 'league_champion',
      title: '리그 챔피언',
      description: '리그에서 1위 달성하기',
      icon: Icons.workspace_premium,
      currentProgress: 0,
      targetProgress: 1,
      xpReward: 500,
    ),
  ];

  final List<Achievement> _specialAchievements = [
    Achievement(
      id: 'daily_challenge_3',
      title: '도전자',
      description: '일일 챌린지 3회 완료하기',
      icon: Icons.flash_on,
      currentProgress: 1,
      targetProgress: 3,
      xpReward: 100,
    ),
    Achievement(
      id: 'daily_challenge_30',
      title: '챌린지 마스터',
      description: '일일 챌린지 30회 완료하기',
      icon: Icons.bolt,
      currentProgress: 1,
      targetProgress: 30,
      xpReward: 1000,
    ),
    Achievement(
      id: 'night_owl',
      title: '올빼미',
      description: '밤 11시 이후에 학습하기',
      icon: Icons.nightlight,
      currentProgress: 0,
      targetProgress: 1,
      xpReward: 50,
    ),
    Achievement(
      id: 'early_bird',
      title: '아침형 인간',
      description: '오전 6시 전에 학습하기',
      icon: Icons.wb_sunny,
      currentProgress: 0,
      targetProgress: 1,
      xpReward: 50,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: const CommonAppHeaderWithBack(
        title: '업적',
        icon: Icons.emoji_events,
        iconColor: AppColors.mathYellow,
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsList(_learningAchievements),
                _buildAchievementsList(_socialAchievements),
                _buildAchievementsList(_specialAchievements),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 헤더
  Widget _buildStatsHeader() {
    final allAchievements = [
      ..._learningAchievements,
      ..._socialAchievements,
      ..._specialAchievements,
    ];
    final unlockedCount =
        allAchievements.where((a) => a.isUnlocked).length;
    final totalCount = allAchievements.length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerBlueGradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '달성한 업적',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unlockedCount / $totalCount',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${((unlockedCount / totalCount) * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 탭 바
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: '학습'),
          Tab(text: '소셜'),
          Tab(text: '특별'),
        ],
      ),
    );
  }

  /// 업적 목록
  Widget _buildAchievementsList(List<Achievement> achievements) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  /// 업적 카드
  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? AppColors.mathYellow.withValues(alpha: 0.1)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                size: 32,
                color: achievement.isUnlocked
                    ? AppColors.mathYellow
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: achievement.isUnlocked
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '달성',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 진행 바 또는 완료 정보
                  if (achievement.isUnlocked)
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          size: 16,
                          color: AppColors.mathYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.xpReward} XP',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mathYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${achievement.currentProgress} / ${achievement.targetProgress}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(achievement.progressPercentage * 100).toStringAsFixed(0)}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: achievement.progressPercentage,
                            minHeight: 6,
                            backgroundColor: AppColors.primaryLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
