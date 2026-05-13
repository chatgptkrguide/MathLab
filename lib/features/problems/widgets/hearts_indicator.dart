// Hearts Indicator Widget
//
// Displays animated hearts with explicit count + auto-recovery hint.
// 힌트 버튼은 답안 영역 위 InlineHintTrigger 로 별도 분리됨.

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';

class HeartsIndicator extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;
  final int previousHearts;
  final AnimationController heartAnimController;
  final Animation<double> heartScaleAnim;

  const HeartsIndicator({
    super.key,
    required this.currentHearts,
    this.maxHearts = 5,
    required this.previousHearts,
    required this.heartAnimController,
    required this.heartScaleAnim,
  });

  @override
  Widget build(BuildContext context) {
    final missing = (maxHearts - currentHearts).clamp(0, maxHearts);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hearts row + count badge — 힌트 버튼은 답안 영역 위 inline 으로
          // 분리됨 (problem_solving_screen 의 InlineHintTrigger).
          // 여기는 하트 표시에만 집중해서 좌측 정렬·여백 정리.
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...List.generate(
                maxHearts,
                (index) {
                  final isFilled = index < currentHearts;
                  final isLostHeart = !isFilled &&
                      index == currentHearts &&
                      currentHearts < previousHearts;

                  Widget heartIcon = Icon(
                    isFilled ? Icons.favorite : Icons.favorite_border,
                    color: isFilled
                        ? AppColors.mathRed
                        : AppColors.borderDark,
                    size: 22,
                  );

                  // glow 는 가장 최근에 획득한 하트 1개에만 — 네온 누적 방지.
                  final isMostRecentFilled =
                      isFilled && index == currentHearts - 1;
                  if (isMostRecentFilled) {
                    heartIcon = Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mathRed
                                .withValues(alpha: 0.18),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: heartIcon,
                    );
                  }

                  if (isLostHeart) {
                    heartIcon = AnimatedBuilder(
                      animation: heartAnimController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: heartScaleAnim.value,
                          child: Icon(
                            Icons.favorite_border,
                            color: Color.lerp(
                              AppColors.mathRed,
                              AppColors.borderDark,
                              heartAnimController.value,
                            ),
                            size: AppDimensions.iconMedium,
                          ),
                        );
                      },
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: heartIcon,
                  );
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mathRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$currentHearts/$maxHearts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mathRed,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          // 자동 회복 안내 — 하트가 부족할 때만 노출
          if (missing > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentHearts == 0
                        ? '30분 후 1개 자동 회복'
                        : '$missing개 부족 · 30분마다 1개 회복',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
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
