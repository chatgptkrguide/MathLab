import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/figma_colors.dart';
import '../../../data/providers/user_provider.dart';
import '../../settings/settings_screen.dart';
import '../edit_profile_screen.dart';

/// Figma 디자인 "05 Extra/프로필" 페이지 100% 재현
/// 레퍼런스: assets/images/figma_05_extra_reference.png
///
/// 화면 구성:
/// - Top Bar: 뒤로가기 + "프로필" + 설정
/// - Profile Card: 아바타 + 이름 + 핸들 + Edit Profile + 레벨 진행바
/// - Stats Row: 팔로잉 / XP / 팔로잉
/// - Streak Card: 연속 학습 이력 + 원형 진행 링
/// - Tabs: 대수 | 공통수학 1 | 공통수학 2
/// - Task Count: 12 Task
/// - Badges: 3개 뱃지 카드
/// - Your Statistics: 6개 통계 그리드
/// - Premium Banner: 업그레이드 유도
class ProfileScreenV2 extends ConsumerStatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  ConsumerState<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends ConsumerState<ProfileScreenV2> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 확장된 상단 바 (프로필 정보 포함)
          _buildExpandedTopBar(user),

          // 스크롤 가능한 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 통계 행 (팔로잉, XP, 팔로잉)
                  _buildStatsRow(user),

                  const SizedBox(height: 20),

                  // 연속 학습 카드 2개 (Challenge Done + Remaining)
                  _buildStreakCards(user),

                  const SizedBox(height: 24),

                  // 캘린더 섹션
                  _buildCalendarSection(),

                  const SizedBox(height: 100), // 네비게이션 바 공간
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 확장된 상단 바 (프로필 정보 통합)
  Widget _buildExpandedTopBar(user) {
    final userName = user?.name ?? 'Guest';
    final isGuest = user?.email == 'guest@gomath.com';
    final userHandle = isGuest
        ? '@guest'
        : '@${userName.toLowerCase().replaceAll(' ', '')}';

    return Container(
      decoration: const BoxDecoration(
        gradient: FigmaColors.profileTopBarGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 상단 네비게이션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),

                  // 제목
                  const Text(
                    '프로필',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // 설정 버튼
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 프로필 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  // 아바타
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC759), Color(0xFFFFB74D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '👤',
                        style: TextStyle(fontSize: 42),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 이름 + 핸들 + 레벨
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userHandle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 레벨 배지
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.military_tech_rounded,
                                    color: Color(0xFFFFD93D),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'H Lv${user?.level ?? 1}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${((user?.levelProgress ?? 0.5) * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Edit Profile 버튼
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 행 (3개 통계) - 개선된 디자인
  Widget _buildStatsRow(user) {
    return Row(
      children: [
        _buildStatItem('팔로워', '${user?.followers ?? 1820}', const Color(0xFF3B82F6)),
        const SizedBox(width: 16),
        _buildStatItem('XP', '${user?.xp ?? 12695}', const Color(0xFFFFC759)),
        const SizedBox(width: 16),
        _buildStatItem('팔로잉', '${user?.following ?? 284}', const Color(0xFFFF6B9D)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 연속 학습 카드 2개 (Challenge Done + Remaining)
  Widget _buildStreakCards(user) {
    return Row(
      children: [
        // Challenge Done 카드
        Expanded(
          child: _buildStreakCardItem(
            icon: '✅',
            title: 'Challenge Done',
            value: 12,
            total: 20,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 16),
        // Challenge Remaining 카드
        Expanded(
          child: _buildStreakCardItem(
            icon: '⏳',
            title: 'Remaining',
            value: 8,
            total: 20,
            color: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCardItem({
    required String icon,
    required String title,
    required int value,
    required int total,
    required Color color,
  }) {
    final progress = value / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 제목
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // 진행바
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 숫자
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                ' / $total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 캘린더 섹션 (학습 이력 시각화)
  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        const Text(
          '학습 이력',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 16),

        // 캘린더 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 월 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Text(
                    '2024년 11월',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 요일 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['일', '월', '화', '수', '목', '금', '토']
                    .map((day) => SizedBox(
                          width: 40,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 12),

              // 날짜 그리드 (샘플 데이터)
              _buildCalendarGrid(),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.grey[200]!, '학습 안함'),
            const SizedBox(width: 16),
            _buildLegendItem(const Color(0xFF4CAF50), '학습 완료'),
            const SizedBox(width: 16),
            _buildLegendItem(const Color(0xFFFF9800), '부분 완료'),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    // 샘플 데이터: 30일간의 학습 이력
    final days = List.generate(30, (index) => index + 1);
    final studyStatus = [
      // 0: 안함, 1: 완료, 2: 부분완료
      1, 1, 0, 1, 1, 1, 2, // 1주차
      0, 1, 1, 1, 2, 1, 1, // 2주차
      1, 0, 1, 1, 1, 1, 0, // 3주차
      1, 1, 2, 1, 1, 1, 1, // 4주차
      0, 1, 1, // 5주차 (일부)
    ];

    return Column(
      children: List.generate(5, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final dateIndex = weekIndex * 7 + dayIndex;
              if (dateIndex >= days.length) {
                return const SizedBox(width: 40);
              }

              final status = studyStatus[dateIndex];
              Color bgColor;
              if (status == 1) {
                bgColor = const Color(0xFF4CAF50);
              } else if (status == 2) {
                bgColor = const Color(0xFFFF9800);
              } else {
                bgColor = Colors.grey[200]!;
              }

              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    days[dateIndex].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: status == 0 ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
