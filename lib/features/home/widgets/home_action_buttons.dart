import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 피그마 홈 화면 하단 CTA 3개: 과제 확인, AI 튜터, 멤버 채팅
class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.assignment_rounded,
              label: '과제 및\n주간테스트',
              sublabel: '확인 & 제출',
              color: AppColors.tealGreen,
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: _ActionButton(
              icon: Icons.smart_toy_rounded,
              label: 'AI 튜터에게',
              sublabel: '물어보세요',
              color: AppColors.royalBlue,
              onTap: () {},
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: _ActionButton(
              icon: Icons.chat_rounded,
              label: '멤버들',
              sublabel: '채팅하기',
              color: AppColors.mathPurple,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing16,
          horizontal: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconMedium),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(height: AppDimensions.spacing2),
              Text(
                sublabel!,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
