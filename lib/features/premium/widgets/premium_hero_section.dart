import 'package:flutter/material.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 프리미엄 업그레이드 히어로 섹션
class PremiumHeroSection extends StatelessWidget {
  const PremiumHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // 프리미엄 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // 타이틀
          Text(
            '프리미엄으로 업그레이드',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 서브타이틀
          Text(
            '무제한 학습과 모든 프리미엄 기능을\n지금 바로 사용해보세요!',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
