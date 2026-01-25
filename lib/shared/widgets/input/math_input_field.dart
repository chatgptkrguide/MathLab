/// 🔢 Math Input Field
///
/// Custom text field for entering mathematical answers.
/// Supports numbers, basic operators, and optional validation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Math-specific text input field
class MathInputField extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextEditingController? controller;

  const MathInputField({
    super.key,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.maxLength,
    this.controller,
  });

  @override
  State<MathInputField> createState() => _MathInputFieldState();
}

class _MathInputFieldState extends State<MathInputField> {
  late TextEditingController _controller;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _isControllerInternal = true;
    }
  }

  @override
  void dispose() {
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      textAlign: TextAlign.center,
      style: AppTextStyles.heading2.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText ?? '답을 입력하세요',
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.mathBlue,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        counterText: '', // Hide character counter
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}

/// Math keyboard with common operators
class MathKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onDone;

  const MathKeyboard({
    super.key,
    required this.controller,
    this.onDone,
  });

  void _insertText(String text) {
    final currentValue = controller.text;
    final selection = controller.selection;

    if (selection.isValid) {
      final newText = currentValue.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + text.length,
        ),
      );
    } else {
      controller.text = currentValue + text;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  void _backspace() {
    final currentValue = controller.text;
    final selection = controller.selection;

    if (selection.isValid && selection.start > 0) {
      final newText = currentValue.replaceRange(
        selection.start - 1,
        selection.start,
        '',
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start - 1,
        ),
      );
    }
  }

  void _clear() {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Number row 1: 7 8 9
          Row(
            children: [
              _buildKey('7'),
              const SizedBox(width: 8),
              _buildKey('8'),
              const SizedBox(width: 8),
              _buildKey('9'),
              const SizedBox(width: 8),
              _buildOperatorKey('+'),
            ],
          ),
          const SizedBox(height: 8),

          // Number row 2: 4 5 6
          Row(
            children: [
              _buildKey('4'),
              const SizedBox(width: 8),
              _buildKey('5'),
              const SizedBox(width: 8),
              _buildKey('6'),
              const SizedBox(width: 8),
              _buildOperatorKey('-'),
            ],
          ),
          const SizedBox(height: 8),

          // Number row 3: 1 2 3
          Row(
            children: [
              _buildKey('1'),
              const SizedBox(width: 8),
              _buildKey('2'),
              const SizedBox(width: 8),
              _buildKey('3'),
              const SizedBox(width: 8),
              _buildOperatorKey('×'),
            ],
          ),
          const SizedBox(height: 8),

          // Bottom row: 0 . ÷ and special keys
          Row(
            children: [
              _buildKey('0'),
              const SizedBox(width: 8),
              _buildKey('.'),
              const SizedBox(width: 8),
              _buildOperatorKey('÷'),
              const SizedBox(width: 8),
              _buildActionKey(
                icon: Icons.backspace,
                onPressed: _backspace,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Action row
          Row(
            children: [
              Expanded(
                child: _buildWideActionKey(
                  label: '지우기',
                  onPressed: _clear,
                  color: AppColors.mathRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWideActionKey(
                  label: '완료',
                  onPressed: onDone,
                  color: AppColors.mathGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String text) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.2,
        child: ElevatedButton(
          onPressed: () => _insertText(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorKey(String text) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.2,
        child: ElevatedButton(
          onPressed: () => _insertText(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mathBlue.withOpacity(0.1),
            foregroundColor: AppColors.mathBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.mathBlue,
                width: 1,
              ),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            text,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
              color: AppColors.mathBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.2,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.borderLight,
            foregroundColor: AppColors.textSecondary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }

  Widget _buildWideActionKey({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}
