import 'package:flutter/material.dart';
import '../../../shared/constants/game_constants.dart';
import '../../../data/models/models.dart';
import '../../profile/figma/profile_detail_screen.dart';

/// 홈 화면 상단 섹션
///
/// 포함 내용:
/// - 사용자 인사말 ("안녕하세요, {이름}님!")
/// - 학습 상태 메시지
/// - 스트릭 배지 (클릭 시 프로필 상세 화면 이동)
class HomeTopSection extends StatelessWidget {
  final User? user;

  const HomeTopSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white.withValues(alpha: 0.8),
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
                    builder: (context) => const ProfileDetailScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.orange.shade50.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/icons/streak_fire.png',
                        width: 22,
                        height: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user?.streakDays ?? GameConstants.defaultStreakDays}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
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
}
