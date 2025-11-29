import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/figma_colors.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/game_constants.dart';
import '../lessons/figma/lessons_screen_figma.dart';
import '../daily_reward/daily_reward_screen.dart';
import '../profile/figma/profile_detail_screen_v3_new.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../problems/problem_solving_screen.dart';
import '../messages/messages_screen.dart';
import '../friends/friends_screen.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/navigation_provider.dart';
import '../../data/providers/message_provider.dart';
import '../../data/providers/friend_provider.dart';
import '../../data/services/korean_math_curriculum.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/cards/daily_goal_card.dart';
import '../../shared/widgets/indicators/circular_progress_ring.dart';
import '../../shared/utils/level_badge_mapper.dart';

/// Figma 디자인 "00 home" 화면 100% 재현
/// 레퍼런스: assets/images/figma_home_reference.png
class HomeScreenFigma extends ConsumerWidget {
  const HomeScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: FigmaColors.homeGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 통합 헤더 (다른 페이지와 동일한 디자인)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.headerBlueGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // 대칭을 위한 빈 공간
                  Expanded(
                    child: Text(
                      '홈',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.headerText,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadCount = ref.watch(unreadMessageCountProvider);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.mail_outline, color: AppColors.headerText, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MessagesScreen(),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.mathRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 상단: "안녕하세요!" + 스트릭
                    _buildTopSection(context, user),

              const SizedBox(height: 24),

              // 중앙: 로봇 캐릭터 + 진행률 링
              _buildRobotSection(context),

              const SizedBox(height: 32),

              // 오늘의 목표 카드
              _buildTodayGoalCard(context),

              const SizedBox(height: 20),

              // 학습 시작하기 버튼
              _buildStartButton(context),

              const SizedBox(height: 24),

              // 하단 스탯 카드들 (XP, 레벨, 연속)
              _buildStatsCards(context, user),

              const SizedBox(height: 24),

              // 친구 활동 섹션
              _buildFriendsActivity(context),

              const SizedBox(height: 20),

              // 학년 선택 카드
              _buildLanguageCards(context),

              const SizedBox(height: 20),

              // 데일리 챌린지 배너
              _buildDailyChallengeB(context),

              const SizedBox(height: 100), // 네비게이션 바 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단: "안녕하세요!" + 메시지 + 스트릭
  Widget _buildTopSection(BuildContext context, user) {
    // 사용자 이름 표시 (게스트인 경우 기본값)
    final userName = user?.name ?? 'Guest';
    final isGuest = user?.email == 'guest@gomath.com';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 안녕하세요!
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? '안녕하세요!' : '안녕하세요, $userName님!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isGuest ? '게스트로 학습 중' : '$userName의 수학 학습',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // 스트릭 배지 (클릭하면 프로필 상세 화면으로)
          Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileDetailScreenV3New(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/streak_fire.png', width: 20, height: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${user?.streakDays ?? GameConstants.defaultStreakDays}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// 중앙: 로봇 캐릭터 + 진행률 링 (Figma 디자인)
  Widget _buildRobotSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Image.asset(
                  'assets/icons/robot_character.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('🤖', style: TextStyle(fontSize: 24));
                  },
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '안녕! 나는 GoMath 로봇이야. 오늘도 열심히 공부하자! 💪',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4A90E2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Figma 원형 진행률 링
            const CircularProgressRing(
              progress: 0.8,
              centerText: '80%',
              subtitle: '완료',
              size: 280,
              strokeWidth: 16,
            ),

            // 로봇 캐릭터 (중앙에 오버레이)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/robot_character.png',
                  width: 180,
                  height: 180,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/icons/character_design.png',
                      width: 180,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          '🤖',
                          style: TextStyle(fontSize: 100),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 오늘의 목표 카드 (Figma 디자인)
  Widget _buildTodayGoalCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          // 레슨 선택 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LessonsScreenFigma(),
            ),
          );
        },
        child: const DailyGoalCard(
          icon: '📚',
          title: '오늘의 목표',
          progress: 0.8,
          current: 80,
          total: 100,
        ),
      ),
    );
  }

  /// 학습 시작하기 버튼
  Widget _buildStartButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0000FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 레슨 선택 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LessonsScreenFigma(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  '학습 시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 스탯 카드들 (XP, 레벨, 연속)
  Widget _buildStatsCards(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // XP 카드 - 프로필 상세 화면으로 이동
          _buildStatCard(
            'assets/icons/xp_icon.png',
            'XP',
            '${user?.xp ?? 549}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // 레벨 카드 - 리더보드 화면으로 이동
          _buildStatCard(
            LevelBadgeMapper.getBadgeImagePath(user?.level ?? 1),
            '레벨',
            'H Lv${user?.level ?? 1}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // 연속 카드 - 프로필 상세 화면으로 이동
          _buildStatCard(
            'assets/icons/streak_fire.png',
            '연속',
            '${user?.streakDays ?? GameConstants.defaultStreakDays}일',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String? iconPath, String label, String value, {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                iconPath != null
                    ? Image.asset(
                        iconPath,
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/icons/gomath_logo_small.png',
                            width: 36,
                            height: 36,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFFFB74D));
                            },
                          );
                        },
                      )
                    : Image.asset(
                        'assets/icons/gomath_logo_small.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.emoji_events, size: 36, color: Color(0xFFFFB74D));
                        },
                      ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 학년/단원 선택 버튼들 (두 개 버튼 + 화살표)
  Widget _buildLanguageCards(BuildContext context) {
    final user = ProviderScope.containerOf(context).read(userProvider);
    final currentGrade = user?.currentGrade ?? '중1';

    // 현재 선택된 단원 (임시로 첫 번째 단원)
    final lessons = KoreanMathCurriculum.getLessonsByGrade(currentGrade);
    final selectedLesson = lessons.isNotEmpty ? lessons[0] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 왼쪽: 학년 선택 버튼
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showGradeSelectionModal(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '학년',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentGrade,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 가운데: 화살표
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.arrow_forward,
              size: 24,
              color: Color(0xFF4A90E2),
            ),
          ),

          // 오른쪽: 단원 선택 버튼
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLessonSelectionModal(context, currentGrade),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '단원',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedLesson != null
                          ? selectedLesson.title.length > 8
                            ? '${selectedLesson.title.substring(0, 8)}...'
                            : selectedLesson.title
                          : '단원 선택',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 학년 선택 모달 표시
  void _showGradeSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 제목
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '학년을 선택하세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // 학년 목록
            ...['중1', '중2', '중3', '고1', '고2', '고3'].map((grade) {
              final gradeInfo = _getGradeInfo(grade);
              return _buildGradeOption(context, grade, gradeInfo['emoji']!, gradeInfo['fullName']!);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 학년 정보 반환
  Map<String, String> _getGradeInfo(String grade) {
    final info = {
      '중1': {'emoji': '📚', 'fullName': '중학교 1학년'},
      '중2': {'emoji': '📖', 'fullName': '중학교 2학년'},
      '중3': {'emoji': '📕', 'fullName': '중학교 3학년'},
      '고1': {'emoji': '📘', 'fullName': '고등학교 1학년'},
      '고2': {'emoji': '📙', 'fullName': '고등학교 2학년'},
      '고3': {'emoji': '📗', 'fullName': '고등학교 3학년'},
    };
    return info[grade] ?? {'emoji': '📚', 'fullName': grade};
  }

  /// 학년 옵션 아이템
  Widget _buildGradeOption(BuildContext context, String grade, String emoji, String fullName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // 학년 업데이트
          ProviderScope.containerOf(context).read(userProvider.notifier).updateGrade(grade);
          // 단원 선택 모달 표시
          Future.delayed(const Duration(milliseconds: GameConstants.normalAnimationMs), () {
            _showLessonSelectionModal(context, grade);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 단원 선택 모달 표시
  void _showLessonSelectionModal(BuildContext context, String grade) {
    final lessons = KoreanMathCurriculum.getLessonsByGrade(grade);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 제목
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '$grade 단원을 선택하세요',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // 단원 목록 (스크롤 가능)
            Expanded(
              child: ListView.builder(
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildLessonOption(context, lesson);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 단원 옵션 아이템
  Widget _buildLessonOption(BuildContext context, Lesson lesson) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          // 학습 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemSolvingScreen(
                lessonId: lesson.id,
                lessonTitle: lesson.title,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    lesson.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 친구 활동 섹션
  Widget _buildFriendsActivity(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final friends = ref.watch(friendsProvider);
        final acceptedFriends = friends
            .where((f) => f.status == FriendRequestStatus.accepted)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '친구 활동',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (acceptedFriends.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${acceptedFriends.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FriendsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '전체 보기',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 친구 목록 (수평 스크롤)
            if (acceptedFriends.isEmpty)
              _buildEmptyFriendsState(context)
            else
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: acceptedFriends.length,
                  itemBuilder: (context, index) {
                    final friend = acceptedFriends[index];
                    return _buildFriendCard(friend);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// 친구가 없을 때 표시
  Widget _buildEmptyFriendsState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '친구와 함께 학습하세요!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '친구를 추가하고 함께 수학 실력을 키워보세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      '추가',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 친구 카드
  Widget _buildFriendCard(Friend friend) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아바타
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 이름
            Text(
              friend.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            // 레벨 배지
            Image.asset(
              LevelBadgeMapper.getBadgeImagePath(friend.level),
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                // 배지 이미지 로드 실패 시 텍스트로 폴백
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, size: 12, color: AppColors.mathGold),
                    const SizedBox(width: 3),
                    Text(
                      'Lv.${friend.level}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 데일리 챌린지 배너
  Widget _buildDailyChallengeB(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DailyRewardScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '데일리 챌린지',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '오늘의 챌린지 미션을 완료해 보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '데일리 챌린지 미션',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 챌린지 이미지
              const Text('🎬', style: TextStyle(fontSize: 60)),
            ],
          ),
        ),
      ),
    );
  }
}
