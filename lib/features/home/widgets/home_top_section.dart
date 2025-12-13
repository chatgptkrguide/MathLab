import 'package:flutter/material.dart';
import '../../../shared/constants/game_constants.dart';
import '../../../data/models/models.dart';
import '../../profile/figma/profile_detail_screen_v3_new.dart';

/// 홈 화면 상단 섹션
///
/// 포함 내용:
/// - 사용자 인사말 ("안녕하세요, {이름}님!")
/// - 학습 상태 메시지
/// - 스트릭 배지 (클릭 시 프로필 상세 화면 이동)
class HomeTopSection extends StatelessWidget {
  final UserAccount? user;

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
                    Image.asset(
                      'assets/icons/streak_fire.png',
                      width: 20,
                      height: 20,
                    ),
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
}
