import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/math/math_text.dart';

/// 문제 선택지 버튼
///
/// 선택 가능, 선택됨, 정답, 오답 등 다양한 상태를 지원하며
/// 부드러운 애니메이션과 시각적 피드백을 제공합니다.
class ProblemOptionButton extends StatefulWidget {
  /// 선택지 텍스트
  final String optionText;

  /// 선택지 인덱스 (0, 1, 2, 3)
  final int index;

  /// 현재 선택된 인덱스
  final int? selectedIndex;

  /// 정답 여부가 확인되었는지
  final bool isAnswerSubmitted;

  /// 이 선택지가 정답인지
  final bool isCorrectAnswer;

  /// 탭 콜백
  final VoidCallback onTap;

  const ProblemOptionButton({
    super.key,
    required this.optionText,
    required this.index,
    required this.selectedIndex,
    required this.isAnswerSubmitted,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  @override
  State<ProblemOptionButton> createState() => _ProblemOptionButtonState();
}

class _ProblemOptionButtonState extends State<ProblemOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// 현재 버튼이 선택되었는지
  bool get _isSelected => widget.selectedIndex == widget.index;

  /// 버튼의 현재 상태를 기반으로 한 색상 - GoMath flat style
  Color get _backgroundColor {
    if (!widget.isAnswerSubmitted) {
      // 답변 제출 전
      return _isSelected ? AppColors.mathBlue : AppColors.surface; // GoMath blue
    } else {
      // 답변 제출 후
      if (_isSelected) {
        return widget.isCorrectAnswer
            ? AppColors.successGreen // GoMath green
            : AppColors.mathRed; // GoMath red
      } else if (widget.isCorrectAnswer) {
        // 정답 표시 (연한 초록색)
        return AppColors.highlightGreen; // Light green (successGreen 80% lighter)
      } else {
        return AppColors.surface;
      }
    }
  }

  /// 테두리 색상 - GoMath style
  Color get _borderColor {
    if (!widget.isAnswerSubmitted) {
      return _isSelected ? AppColors.mathBlueDark : AppColors.borderLight; // GoMath darker blue
    } else {
      if (_isSelected) {
        return widget.isCorrectAnswer
            ? AppColors.duolingoGreenDark // Darker green (successGreen 20% darker)
            : AppColors.mathRedDark; // Darker red (mathRed 20% darker)
      } else if (widget.isCorrectAnswer) {
        return AppColors.successGreen; // GoMath green
      } else {
        return AppColors.borderLight;
      }
    }
  }

  /// 텍스트 색상 - GoMath style
  Color get _textColor {
    if (!widget.isAnswerSubmitted) {
      return _isSelected ? AppColors.surface : AppColors.textPrimary; // GoMath dark gray
    } else {
      if (_isSelected || widget.isCorrectAnswer) {
        return AppColors.surface;
      } else {
        return AppColors.textPrimary;
      }
    }
  }

  /// 3D 그림자 색상 - GoMath style
  Color get _getShadowColor {
    if (!widget.isAnswerSubmitted) {
      return _isSelected ? AppColors.mathBlueDark : AppColors.borderLight; // GoMath darker blue
    } else {
      if (_isSelected) {
        return widget.isCorrectAnswer
            ? AppColors.duolingoGreenDark // Darker green (successGreen 20% darker)
            : AppColors.mathRedDark; // Darker red (mathRed 20% darker)
      }
      return AppColors.borderLight;
    }
  }

  /// 아이콘 위젯 (정답/오답 표시)
  Widget? get _icon {
    if (!widget.isAnswerSubmitted) return null;

    if (_isSelected) {
      // 사용자가 선택한 답
      return Icon(
        widget.isCorrectAnswer ? Icons.check_circle : Icons.cancel,
        color: AppColors.surface,
        size: 24,
      );
    } else if (widget.isCorrectAnswer) {
      // 정답 표시
      return const Icon(
        Icons.check_circle,
        color: AppColors.surface,
        size: 24,
      );
    }
    return null;
  }

  void _handleTap() {
    if (!widget.isAnswerSubmitted) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Duolingo-style 3D solid shadow
            if (_isSelected && !widget.isAnswerSubmitted)
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                bottom: -4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: _getShadowColor, // getter - no parentheses
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            // Main button container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _borderColor,
                  width: 3,
                ),
              ),
              child: Row(
                children: [
                  // 선택지 번호 (A, B, C, D)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _textColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _textColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + widget.index), // A, B, C, D
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 선택지 텍스트
                  Expanded(
                    child: MathText(
                      widget.optionText,
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: _isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      fontSize: 16,
                      color: _textColor,
                    ),
                  ),
                  // 정답/오답 아이콘
                  if (_icon != null) ...[
                    const SizedBox(width: 12),
                    _icon!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
