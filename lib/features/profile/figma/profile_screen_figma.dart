import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/figma_colors.dart';
import '../../../shared/figma_components/figma_top_bar.dart';
import '../../../shared/figma_components/figma_user_info_bar.dart';
import '../../../data/providers/user_provider.dart';
import 'profile_detail_screen_v3_new.dart';

/// Figma 디자인 "03" 프로필 페이지 100% 재현
/// 레퍼런스: assets/images/figma_03_profile_reference.png
///
/// 화면 구성:
/// - Top Bar: 뒤로가기 버튼 + 로고
/// - User Info Bar: 프로필 + 이름 + 스트릭 + XP + 레벨
/// - 챌린지 섹션: 완료/남은 일수 + 진행률
/// - 레벨 진행 바: H Lv1 50% 그라디언트
/// - 통계 카드: Challenge Done 6 Days + Remaining 10 Days
/// - 달력: December 2022 (13-18일 하이라이트)
class ProfileScreenFigma extends ConsumerWidget {
  const ProfileScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 상단 바 (뒤로가기 버튼 + 로고)
          const FigmaTopBar(
            title: '',
            showBackButton: true,
          ),

          // 사용자 정보 바 (탭하면 상세 프로필로 이동)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
            child: FigmaUserInfoBar(
              userName: user?.name ?? '소인수분해',
              streakDays: user?.streakDays ?? 6,
              xp: user?.xp ?? 549,
              level: 'HLv${user?.level ?? 1}',
            ),
          ),

          // 프로필 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 챌린지 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '챌린지',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '6/12',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 레벨 진행 바
                  _buildLevelProgress(),

                  const SizedBox(height: 24),

                  // 챌린지 통계 카드들
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          emoji: '🔥',
                          title: 'Challenge Done',
                          value: '6 Days',
                          backgroundColor: const Color(0xFFFFF5F5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          emoji: '📅',
                          title: 'Remaining',
                          value: '10 Days',
                          backgroundColor: const Color(0xFFF5F8FF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 달력 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'December 2022',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'VIEW',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A90E2),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 달력
                  _buildCalendar(),

                  const SizedBox(height: 100), // 네비게이션 바 공간
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 레벨 진행 바 (피그마 디자인 100% 재현)
  Widget _buildLevelProgress() {
    return Row(
      children: [
        // 레벨 뱃지 (빨간색 배경 + 트로피 아이콘)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F), // 진한 빨간색
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 레벨 텍스트 + 진행 바
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'H Lv1',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '50%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 그라디언트 진행 바 (핑크 → 주황 → 노랑)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF69B4), // 핑크
                            Color(0xFFFF8C69), // 코랄/주황
                            Color(0xFFFFB84D), // 골드/노랑
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 통계 카드 (피그마 디자인 100% 재현)
  Widget _buildStatCard({
    required String emoji,
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 이모지 아이콘
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          // 제목
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // 값
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  /// 달력 (피그마 디자인 100% 재현)
  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeekDayLabel('Mon'),
              _buildWeekDayLabel('Tue'),
              _buildWeekDayLabel('Wed'),
              _buildWeekDayLabel('Thu'),
              _buildWeekDayLabel('Fri'),
              _buildWeekDayLabel('Sat'),
              _buildWeekDayLabel('Sun'),
            ],
          ),

          const SizedBox(height: 12),

          // 날짜 그리드
          ..._buildCalendarRows(),
        ],
      ),
    );
  }

  Widget _buildWeekDayLabel(String day) {
    return SizedBox(
      width: 40,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  List<Widget> _buildCalendarRows() {
    // December 2022 달력 데이터 (피그마와 정확히 일치)
    final List<List<int?>> weeks = [
      [null, null, null, 1, 2, 3, 4],
      [5, 6, 7, 8, 9, 10, 11],
      [12, 13, 14, 15, 16, 17, 18], // 13-18일은 챌린지 완료
      [19, 20, 21, 22, 23, 24, 25],
      [26, 27, 28, 29, 30, 31, null],
    ];

    return weeks.map((week) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: week.map((day) {
            if (day == null) {
              return const SizedBox(width: 40, height: 40);
            }

            // 13-18일은 파란색으로 하이라이트
            final isCompleted = day >= 13 && day <= 18;

            return _buildCalendarDay(day, isCompleted);
          }).toList(),
        ),
      );
    }).toList();
  }

  Widget _buildCalendarDay(int day, bool isCompleted) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF4A90E2) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}
