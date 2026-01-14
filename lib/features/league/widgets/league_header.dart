import 'package:flutter/material.dart';
import '../../../data/models/gamification/league.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 리그 헤더 위젯
///
/// 리그 티어, 순위, 남은 시간, 승급/강등 상태를 표시
/// - Duolingo 스타일 그라디언트 카드
/// - 티어별 색상 및 아이콘
/// - 승급/강등 배지 포함
class LeagueHeader extends StatelessWidget {
  final League league;
  final int? currentUserRank;
  final bool canPromote;
  final bool isRelegationZone;

  const LeagueHeader({
    super.key,
    required this.league,
    this.currentUserRank,
    required this.canPromote,
    required this.isRelegationZone,
  });

  @override
  Widget build(BuildContext context) {
    final timeLeft = league.weekEndDate.difference(DateTime.now());
    final daysLeft = timeLeft.inDays;
    final hoursLeft = timeLeft.inHours % 24;
    final minutesLeft = timeLeft.inMinutes % 60;

    // 시간 문자열 생성
    String timeString = '';
    if (daysLeft > 0) {
      timeString = '$daysLeft일 $hoursLeft시간';
    } else if (hoursLeft > 0) {
      timeString = '$hoursLeft시간 $minutesLeft분';
    } else {
      timeString = '$minutesLeft분';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(league.tier.color),
            Color(league.tier.color).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(league.tier.color).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 데코레이션
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 리그 아이콘 & 이름
                Column(
                  children: [
                    // 큰 티어 아이콘
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          league.tier.iconPath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              league.tier.iconEmoji,
                              style: const TextStyle(fontSize: 56),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 리그 이름
                    Text(
                      league.tier.displayName,
                      style: AppTextStyles.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 타이머
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$timeString 후 승급/강등',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 현재 순위 카드
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '내 순위',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.mathYellow.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppColors.mathYellow,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${currentUserRank ?? '-'}위',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 승급/강등 상태 배지
                if (canPromote || isRelegationZone) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canPromote
                            ? AppColors.greenGradient
                            : [AppColors.mathRed, AppColors.mathRedDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (canPromote
                                  ? AppColors.mathGreen
                                  : AppColors.mathRed)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          canPromote ? Icons.arrow_upward : Icons.warning,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          canPromote ? '승급 가능!' : '강등 위험',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
