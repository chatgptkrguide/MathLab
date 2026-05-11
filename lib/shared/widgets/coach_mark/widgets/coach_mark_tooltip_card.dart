// Coach mark tooltip card — white rounded card with title, description, and nav buttons.
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class CoachMarkTooltipCard extends StatelessWidget {
  final String title;
  final String description;
  final bool showPrevious;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final BoxConstraints? constraints;

  const CoachMarkTooltipCard({
    super.key,
    required this.title,
    required this.description,
    required this.showPrevious,
    required this.isLastStep,
    required this.onNext,
    required this.onPrevious,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showPrevious)
                GestureDetector(
                  onTap: onPrevious,
                  child: Text(
                    '이전',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mathBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLastStep ? '완료' : '다음',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
