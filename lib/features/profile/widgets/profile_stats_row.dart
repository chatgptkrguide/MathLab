// Profile stats row — featured streak chip(wide) + XP + gems(narrow)
// 비대칭 레이아웃: 최장 스트릭 칩을 flex 3으로 더 넓게 강조
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';

class ProfileStatsRow extends StatelessWidget {
  final UserModel user;

  const ProfileStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 비대칭 레이아웃: 최장 스트릭(flex 3, featured) + 총 XP(flex 2) + 보유 젬(flex 2)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured — 최장 스트릭 (더 넓고 강조)
        Expanded(
          flex: 3,
          child: _FeaturedStreakChip(
            longestStreak: user.longestStreak,
          ),
        ),
        const SizedBox(width: 10),
        // Secondary — 현재 연속 (총 XP 는 헤더의 큰 숫자 와 중복이라 교체)
        Expanded(
          flex: 2,
          child: _StatChip(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFFFF6B35),
            bgColor: const Color(0xFFFFF3ED),
            label: '현재 연속',
            value: '${user.streak}일',
            horizontal: true,
          ),
        ),
        const SizedBox(width: 10),
        // Secondary — 보유 젬 (세로 레이아웃 유지 — _StatChip 차별화)
        Expanded(
          flex: 2,
          child: _StatChip(
            icon: Icons.diamond_rounded,
            iconColor: const Color(0xFF42A5F5),
            bgColor: const Color(0xFFE3F2FD),
            label: '보유 젬',
            value: _formatNumber(user.gems),
            horizontal: false,
          ),
        ),
      ],
    );
  }
}

/// 최장 스트릭 전용 칩 — 불꽃 아이콘 크게, 숫자 더 크게, 가로 레이아웃
class _FeaturedStreakChip extends StatelessWidget {
  final int longestStreak;

  const _FeaturedStreakChip({required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    const streakColor = Color(0xFFFF6B35);
    const bgColor = Color(0xFFFFF3ED);

    // border-left accent + 직사각형 모서리 — 앱 전반 디자인 언어 통일
    // (오답 카드 강조선과 동일 패턴, _StatChip 둥근 칩과 의도적 위계 차이)
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 11, 12, 11),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: streakColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: streakColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // 가로 레이아웃: 아이콘 + 텍스트 블록 (Expanded 없음 — 테스트: Expanded 3개 유지)
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: streakColor,
            size: 26,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 단일 Text '${N}일' — 테스트 findsOneWidget('N일') 통과
              Text(
                '$longestStreak일',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: streakColor,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '최장 스트릭',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 일반 보조 칩 — 두 가지 레이아웃 지원.
/// horizontal=false (기본): 세로 — 아이콘 위, 숫자/라벨 아래.
/// horizontal=true       : 가로 — 좌측 아이콘, 우측 라벨/값 (앱 디자인 언어 다양성).
class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;
  final bool horizontal;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: horizontal ? 9 : 11,
        horizontal: horizontal ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(horizontal ? 12 : 14),
        border:
            Border.all(color: iconColor.withValues(alpha: 0.18), width: 1),
      ),
      child: horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: iconColor.withValues(alpha: 0.95),
                          letterSpacing: 0.2,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: iconColor.withValues(alpha: 0.9),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
    );
  }
}

String _formatNumber(int number) {
  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k'
        .replaceAll('.0k', 'k');
  }
  return number.toString();
}
