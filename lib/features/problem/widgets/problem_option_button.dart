import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

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

  /// 버튼의 현재 상태를 기반으로 한 색상
  Color get _backgroundColor {
    if (!widget.isAnswerSubmitted) {
      // 답변 제출 전
      return _isSelected ? AppColors.mathTeal : Colors.white;
    } else {
      // 답변 제출 후
      if (_isSelected) {
        return widget.isCorrectAnswer
            ? AppColors.successGreen
            : AppColors.errorRed;
      } else if (widget.isCorrectAnswer) {
        // 정답 표시
        return AppColors.successGreen.withValues(alpha: 0.3);
      } else {
        return Colors.white;
      }
    }
  }

  /// 테두리 색상
  Color get _borderColor {
    if (!widget.isAnswerSubmitted) {
      return _isSelected ? AppColors.mathTeal : AppColors.borderColor;
    } else {
      if (_isSelected) {
        return widget.isCorrectAnswer
            ? AppColors.successGreen
            : AppColors.errorRed;
      } else if (widget.isCorrectAnswer) {
        return AppColors.successGreen;
      } else {
        return AppColors.borderColor;
      }
    }
  }

  /// 텍스트 색상
  Color get _textColor {
    if (!widget.isAnswerSubmitted) {
      return _isSelected ? Colors.white : AppColors.textPrimary;
    } else {
      if (_isSelected || widget.isCorrectAnswer) {
        return Colors.white;
      } else {
        return AppColors.textPrimary;
      }
    }
  }

  /// 아이콘 위젯 (정답/오답 표시)
  Widget? get _icon {
    if (!widget.isAnswerSubmitted) return null;

    if (_isSelected) {
      // 사용자가 선택한 답
      return Icon(
        widget.isCorrectAnswer ? Icons.check_circle : Icons.cancel,
        color: Colors.white,
        size: 24,
      );
    } else if (widget.isCorrectAnswer) {
      // 정답 표시
      return const Icon(
        Icons.check_circle,
        color: Colors.white,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: _borderColor,
              width: 2,
            ),
            boxShadow: _isSelected && !widget.isAnswerSubmitted
                ? [
                    BoxShadow(
                      color: AppColors.mathTeal.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : widget.isAnswerSubmitted && _isSelected
                    ? [
                        BoxShadow(
                          color: (widget.isCorrectAnswer
                                  ? AppColors.successGreen
                                  : AppColors.errorRed)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
          ),
          child: Row(
            children: [
              // 선택지 번호
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _textColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + widget.index), // A, B, C, D
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              // 선택지 텍스트
              Expanded(
                child: Text(
                  widget.optionText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: _textColor,
                    fontWeight: _isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              // 정답/오답 아이콘
              if (_icon != null) ...[
                const SizedBox(width: AppDimensions.spacingM),
                _icon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
