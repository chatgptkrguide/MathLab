import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 사용자 정보 섹션
class UserInfoSection extends StatelessWidget {
  final dynamic user;

  const UserInfoSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.mathBlueGradient,
        ),
      ),
      child: Column(
        children: [
          // 아바타
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: const Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 이름
          Text(
            user?.name ?? 'Guest',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // 이메일
          Text(
            user?.email ?? 'guest@gomath.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
