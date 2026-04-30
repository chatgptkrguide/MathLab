// Answer Feedback Widget
//
// Slide-up overlay showing correct/incorrect feedback with explanation.

import 'package:flutter/material.dart';
import '../../../data/models/problem/problem_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/utils/answer_validator.dart';
import '../../../shared/widgets/math/math_renderer.dart';

class AnswerFeedbackOverlay extends StatelessWidget {
  final ProblemModel problem;
  final bool isCorrect;
  final ValidationResult? validationResult;
  final AnimationController animationController;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onContinue;

  const AnswerFeedbackOverlay({
    super.key,
    required this.problem,
    required this.isCorrect,
    required this.validationResult,
    required this.animationController,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final result = validationResult;
    final isPartialCredit =
        result != null && result.score > 0 && result.score < 1.0;

    Color panelColor;
    Color accentColor;
    String title;
    IconData icon;

    if (isCorrect) {
      panelColor = AppColors.mathGreen;
      accentColor = AppColors.mathGreen;
      title = result?.feedback ?? '정답입니다!';
      icon = Icons.check_circle_rounded;
    } else if (isPartialCredit) {
      panelColor = AppColors.mathYellow;
      accentColor = AppColors.mathYellow;
      title = result.feedback ?? '거의 맞았어요!';
      icon = Icons.star_half_rounded;
    } else {
      panelColor = AppColors.mathRed;
      accentColor = AppColors.mathRed;
      title = result?.feedback ?? '틀렸습니다';
      icon = Icons.cancel_rounded;
    }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Semi-transparent background overlay
              GestureDetector(
                onTap: onContinue,
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.3 * fadeAnimation.value,
                  ),
                ),
              ),
              // Slide-up result panel from bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      // 불투명 흰색 배경으로 텍스트 가독성 확보.
                      // 정/오답은 상단 두꺼운 색상 띠 + 진한 그림자로 구분.
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radius24),
                        topRight: Radius.circular(AppDimensions.radius24),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: panelColor,
                          width: 5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: panelColor.withValues(alpha: 0.22),
                          blurRadius: 28,
                          offset: const Offset(0, -8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height * 0.75,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                AppDimensions.spacing24,
                                AppDimensions.spacing16,
                                AppDimensions.spacing24,
                                AppDimensions.spacing24,
                              ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            // Drag handle — 진한 톤으로 시인성 확보
                            Container(
                              width: AppDimensions.spacing40,
                              height: AppDimensions.spacing4,
                              decoration: BoxDecoration(
                                color: panelColor.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.spacing2),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacing16),
                            // Icon and title row
                            _buildTitleRow(
                                panelColor, icon, title, isPartialCredit,
                                result: result, accentColor: accentColor),
                            // Explanation
                            if (!isCorrect &&
                                problem.explanation != null) ...[
                              const SizedBox(
                                  height: AppDimensions.spacing16),
                              _buildExplanation(
                                  problem.explanation!, accentColor),
                            ],
                            // Validation hints
                            if (result?.hints != null &&
                                result!.hints!.isNotEmpty) ...[
                              const SizedBox(
                                  height: AppDimensions.spacing12),
                              _buildValidationHints(result.hints!),
                            ],
                            const SizedBox(height: AppDimensions.spacing20),
                            // Continue button — 상태 색 배경, 흰 글자
                            SizedBox(
                              width: double.infinity,
                              height: AppDimensions.buttonHeightLarge,
                              child: ElevatedButton(
                                onPressed: onContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: panelColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radius16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  '계속하기',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitleRow(
    Color panelColor,
    IconData icon,
    String title,
    bool isPartialCredit, {
    ValidationResult? result,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          width: AppDimensions.iconXLarge,
          height: AppDimensions.iconXLarge,
          decoration: BoxDecoration(
            color: panelColor.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: panelColor, size: 28),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: panelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPartialCredit && result != null)
                Text(
                  '${(result.score * 100).toStringAsFixed(0)}% 정확도',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: accentColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation(String explanation, Color accentColor) {
    // Split explanation at '=' for step-by-step display
    final steps = _splitAtEquals(explanation);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '설명',
            style: AppTextStyles.bodySmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (steps.length > 1)
            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value.trim();
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                child: MathRichText(
                  text: step,
                  textStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                    fontSize: 17,
                  ),
                  mathFontSize: 19.0,
                ),
              );
            })
          else
            MathRichText(
              text: explanation,
              textStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
                fontSize: 17,
              ),
              mathFontSize: 19.0,
            ),
        ],
      ),
    );
  }

  /// Split explanation at '=' or '→' signs for step-by-step display.
  /// Handles all formats: plain text, single $...$, multiple $...$, mixed.
  List<String> _splitAtEquals(String text) {
    final trimmed = text.trim();

    // Strip $ signs for splitting, then re-wrap
    var raw = trimmed.replaceAll('\$', '');

    // Manual split at '=' or '→' to keep delimiters separate
    final lines = <String>[];
    final buffer = StringBuffer();
    String? lastDelim;

    for (int i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (ch == '=' || ch == '→') {
        final part = buffer.toString().trim();
        if (part.isNotEmpty) {
          if (lastDelim != null) {
            lines.add('$lastDelim \$$part\$');
          } else {
            lines.add('\$$part\$');
          }
        }
        lastDelim = ch == '=' ? '=' : '→';
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    // Last part
    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      if (lastDelim != null) {
        lines.add('$lastDelim \$$remaining\$');
      } else {
        lines.add('\$$remaining\$');
      }
    }

    return lines.length > 1 ? lines : [text];
  }

  Widget _buildValidationHints(List<String> hints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.mathOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '힌트',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mathOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          ...hints.map((hint) => Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacing4),
                child: MathRichText(
                  text: hint,
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  mathFontSize: 16.0,
                ),
              )),
        ],
      ),
    );
  }
}
