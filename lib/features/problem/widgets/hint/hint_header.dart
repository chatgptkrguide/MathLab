import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';

/// 힌트 헤더 위젯 (전구 아이콘 + 진행률 바 + XP 표시)
class HintHeader extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Animation<double> glowAnimation;
  final int unlockedCount;
  final int totalHints;
  final int userXP;
  final bool isExpanded;
  final VoidCallback onToggle;

  const HintHeader({
    super.key,
    required this.pulseAnimation,
    required this.glowAnimation,
    required this.unlockedCount,
    required this.totalHints,
    required this.userXP,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.mathOrange.withValues(alpha: 0.12),
              AppColors.mathOrange.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isExpanded ? 0 : 20),
            bottomRight: Radius.circular(isExpanded ? 0 : 20),
          ),
          border: Border.all(
            color: AppColors.mathOrange.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // 전구 아이콘 - 펄스 애니메이션 + 글로우
            Stack(
              alignment: Alignment.center,
              children: [
                // 글로우 효과
                AnimatedBuilder(
                  animation: glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 56 + (glowAnimation.value * 8),
                      height: 56 + (glowAnimation.value * 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mathOrange
                                .withValues(alpha: glowAnimation.value * 0.4),
                            blurRadius: 20 + (glowAnimation.value * 10),
                            spreadRadius: glowAnimation.value * 4,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // 메인 아이콘
                ScaleTransition(
                  scale: pulseAnimation,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.mathOrange,
                          Color(0xFFE67E22),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.mathOrangeDark,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mathOrange.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: AppColors.surface,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // 힌트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '힌트',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 진행률 바
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                AppColors.borderLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: unlockedCount / totalHints,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.mathOrange,
                                    AppColors.mathOrange
                                        .withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$unlockedCount/$totalHints',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // XP 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mathOrange.withValues(alpha: 0.15),
                    AppColors.mathOrange.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.mathOrange.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.diamond,
                    color: AppColors.mathOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$userXP',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathOrange,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 펼침/접기 아이콘
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mathOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.mathOrange,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
