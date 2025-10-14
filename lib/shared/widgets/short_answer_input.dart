import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 주관식 답안 입력 위젯
/// 듀오링고 스타일의 아름다운 입력 필드
class ShortAnswerInput extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? initialValue;
  final bool isEnabled;
  final bool showResult;
  final bool isCorrect;
  final String? correctAnswer;
  final TextInputType keyboardType;

  const ShortAnswerInput({
    Key? key,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.initialValue,
    this.isEnabled = true,
    this.showResult = false,
    this.isCorrect = false,
    this.correctAnswer,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<ShortAnswerInput> createState() => _ShortAnswerInputState();
}

class _ShortAnswerInputState extends State<ShortAnswerInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShortAnswerInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showResult && !oldWidget.showResult && !widget.isCorrect) {
      // 틀렸을 때 흔들기 애니메이션
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.borderLight;
    Color backgroundColor = AppColors.surface;
    Widget? suffixIcon;

    if (widget.showResult) {
      if (widget.isCorrect) {
        borderColor = AppColors.duolingoGreen;
        backgroundColor = AppColors.duolingoGreen.withOpacity(0.1);
        suffixIcon = const Icon(
          Icons.check_circle,
          color: AppColors.duolingoGreen,
        );
      } else {
        borderColor = AppColors.duolingoRed;
        backgroundColor = AppColors.duolingoRed.withOpacity(0.1);
        suffixIcon = const Icon(
          Icons.cancel,
          color: AppColors.duolingoRed,
        );
      }
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double shakeOffset = 0;
        if (widget.showResult && !widget.isCorrect) {
          shakeOffset = _shakeAnimation.value * 10 *
                       (1 - _shakeAnimation.value) *
                       (1 - ((_animationController.value * 4) % 1 > 0.5 ? 1 : -1));
        }

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                    boxShadow: widget.showResult && widget.isCorrect
                        ? [
                            BoxShadow(
                              color: AppColors.duolingoGreen.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.isEnabled && !widget.showResult,
                    keyboardType: widget.keyboardType,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.showResult
                          ? (widget.isCorrect ? AppColors.duolingoGreen : AppColors.duolingoRed)
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
                      suffixIcon: suffixIcon,
                    ),
                    onSubmitted: widget.onSubmitted,
                    inputFormatters: _getInputFormatters(),
                  ),
                ),
                if (widget.showResult && !widget.isCorrect && widget.correctAnswer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingS),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.duolingoBlue,
                          size: 16,
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          '정답: ${widget.correctAnswer}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.duolingoBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.keyboardType) {
      case TextInputType.number:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\-\+\.\,\/]')), // 숫자, 사칙연산, 소수점, 분수
        ];
      default:
        return [
          LengthLimitingTextInputFormatter(50), // 최대 50자
        ];
    }
  }
}

/// 수학 키보드 (주관식 문제용)
class MathKeyboard extends StatelessWidget {
  final ValueChanged<String>? onKeyPressed;
  final VoidCallback? onClear;
  final VoidCallback? onBackspace;

  const MathKeyboard({
    Key? key,
    this.onKeyPressed,
    this.onClear,
    this.onBackspace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 숫자 키패드
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildKey('+'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
              _buildKey('-'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
              _buildKey('×'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              _buildKey('.'),
              _buildKey('0'),
              _buildBackspaceKey(),
              _buildKey('÷'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              _buildKey('('),
              _buildKey(')'),
              _buildKey('/'),
              _buildClearKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () => onKeyPressed?.call(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: Text(
            key,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: onBackspace,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.duolingoOrange.withOpacity(0.1),
            foregroundColor: AppColors.duolingoOrange,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: const Icon(Icons.backspace_outlined),
        ),
      ),
    );
  }

  Widget _buildClearKey() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: onClear,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.duolingoRed.withOpacity(0.1),
            foregroundColor: AppColors.duolingoRed,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: const Text('C'),
        ),
      ),
    );
  }
}