// Problem Content Widget
//
// Displays the question text, images, and unlocked hints.

import 'package:flutter/material.dart';
import '../../../data/models/problem/problem_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/math/math_renderer.dart';
import '../../../shared/widgets/zoomable_image_viewer.dart';

class ProblemQuestionCard extends StatelessWidget {
  final ProblemModel problem;

  const ProblemQuestionCard({
    super.key,
    required this.problem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MathRichText(
          text: problem.question,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3D4543),
            height: 1.6,
          ),
          mathFontSize: 20.0,
        ),
        if (problem.allImages.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacing16),
          ProblemImageGallery(
            imageUrls: problem.allImages,
            problemId: problem.id,
          ),
        ],
      ],
    );
  }
}

/// Shows unlocked hints for the current problem
class UnlockedHintsSection extends StatelessWidget {
  final List<String> hints;
  final Set<int> unlockedIndices;

  const UnlockedHintsSection({
    super.key,
    required this.hints,
    required this.unlockedIndices,
  });

  @override
  Widget build(BuildContext context) {
    if (hints.isEmpty || unlockedIndices.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedUnlocked = unlockedIndices.toList()..sort();

    return Column(
      children: sortedUnlocked.map((index) {
        if (index >= hints.length) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
          child: _HintCard(hint: hints[index], hintNumber: index + 1),
        );
      }).toList(),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String hint;
  final int hintNumber;

  const _HintCard({required this.hint, required this.hintNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mathOrange.withValues(alpha: 0.12),
            AppColors.mathOrange.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: AppColors.mathOrange.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: AppColors.mathOrange.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.iconLarge,
            height: AppDimensions.iconLarge,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mathOrange, Color(0xFFE67E22)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.mathOrange.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$hintNumber',
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '힌트 $hintNumber',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mathOrange,
                  ),
                ),
                const SizedBox(height: 6),
                MathRichText(
                  text: hint,
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5,
                  ),
                  mathFontSize: 16.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
