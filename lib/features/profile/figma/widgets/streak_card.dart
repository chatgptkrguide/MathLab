import 'package:flutter/material.dart';
import '../../../../data/models/user/user.dart';
import '../../../../shared/constants/app_colors.dart';

/// 연속 학습 스트릭 카드 위젯
class StreakCard extends StatelessWidget {
  final User? user;

  const StreakCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final streakDays = user?.streakDays ?? 6;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 불 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 32)),
            ),
          ),

          const SizedBox(width: 16),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '연속 학습 이력',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '수학을 꾸준한 학습이 가장 중요해요!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 원형 진행 표시
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                // 배경 원
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // 진행 원 (오렌지색)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircularProgressIndicator(
                    value: streakDays / 10, // 10일 기준
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.mathOrange,
                    ),
                  ),
                ),
                // 숫자
                Center(
                  child: Text(
                    '$streakDays',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
