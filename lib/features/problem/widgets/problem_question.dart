import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../shared/widgets/math/math_text.dart';
import '../../../data/models/models.dart';

/// 문제 질문 표시 위젯
///
/// 포함 내용:
/// - 카테고리 뱃지 (유형 아이콘, 카테고리명, 학년, XP)
/// - 문제 텍스트 (MathText 사용)
/// - 문제 이미지 (옵션)
class ProblemQuestion extends StatelessWidget {
  /// 표시할 문제
  final Problem problem;

  /// 카테고리 뱃지 표시 여부
  final bool showCategoryBadge;

  const ProblemQuestion({
    super.key,
    required this.problem,
    this.showCategoryBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 뱃지
        if (showCategoryBadge) ...[
          _buildCategoryBadge(),
          const SizedBox(height: 20),
        ],

        // 문제 텍스트
        _buildQuestionText(),

        // 문제 이미지 (있는 경우)
        if (problem.imageUrl != null) ...[
          const SizedBox(height: 20),
          _buildQuestionImage(),
        ],
      ],
    );
  }

  /// 카테고리 뱃지
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.mathBlue, // GoMath 파란색
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mathBlue.withOpacity(0.7), // 어두운 파란색 테두리
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 유형 아이콘
          Text(
            problem.typeIcon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),

          // 카테고리명
          Text(
            problem.category,
            style: const TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          // 학년 정보
          if (problem.grade != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                problem.grade!,
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],

          // XP 보상
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.mathYellow, // GoMath 노란색
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${problem.xpReward} XP',
              style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 문제 텍스트
  Widget _buildQuestionText() {
    return FadeInWidget(
      child: MathText(
        problem.question,
        style: AppTextStyles.headlineMedium.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        fontSize: 24,
      ),
    );
  }

  /// 문제 이미지
  Widget _buildQuestionImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        problem.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
