import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

/// 학습 캘린더 사이드 메뉴 (피그마 03 디자인 기반)
class LearningCalendarDrawer extends StatefulWidget {
  const LearningCalendarDrawer({super.key});

  @override
  State<LearningCalendarDrawer> createState() => _LearningCalendarDrawerState();
}

class _LearningCalendarDrawerState extends State<LearningCalendarDrawer> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 학습한 날짜 (예시 데이터 - 피그마처럼 13~18일)
  final Set<DateTime> _studiedDays = {
    DateTime(2024, 11, 13),
    DateTime(2024, 11, 14),
    DateTime(2024, 11, 15),
    DateTime(2024, 11, 16),
    DateTime(2024, 11, 17),
    DateTime(2024, 11, 18),
  };

  final int _challengeDoneDays = 6;
  final int _remainingDays = 10;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 챌린지 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '챌린지',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChallengeCard(
                            icon: '🔥',
                            title: 'Challenge Done',
                            value: '$_challengeDoneDays Days',
                            color: const Color(0xFFFFF5F5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildChallengeCard(
                            icon: '📅',
                            title: 'Remaining',
                            value: '$_remainingDays Days',
                            color: const Color(0xFFF5F9FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 캘린더 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'December 2022',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'VIEW',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.mathBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCalendar(),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// 챌린지 카드 (피그마 디자인)
  Widget _buildChallengeCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// 캘린더 (피그마 디자인 - 간단한 그리드)
  Widget _buildCalendar() {
    // December 2022 캘린더 데이터
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<int?> days = [
      null, null, null, 1, 2, 3, 4,  // 첫 주
      5, 6, 7, 8, 9, 10, 11,         // 둘째 주
      12, 13, 14, 15, 16, 17, 18,    // 셋째 주 (13-18 학습함)
      19, 20, 21, 22, 23, 24, 25,    // 넷째 주
      26, 27, 28, 29, 30, 31, null,  // 다섯째 주
    ];

    return Column(
      children: [
        // 요일 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => SizedBox(
            width: 40,
            child: Center(
              child: Text(
                day,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),

        // 날짜 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) {
              return const SizedBox.shrink();
            }

            // 학습한 날짜 체크 (13-18)
            final isStudied = day >= 13 && day <= 18;

            return Container(
              decoration: BoxDecoration(
                color: isStudied
                    ? const Color(0xFF6BA4D8)  // 피그마의 파란색
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isStudied ? Colors.white : AppColors.textPrimary,
                    fontWeight: isStudied ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
