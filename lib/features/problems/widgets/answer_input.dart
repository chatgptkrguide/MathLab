// Answer Input Widget
//
// Handles different answer input types:
// - Multiple choice options
// - Text input (fill in blank / short answer)
// - Drag and drop

import 'package:flutter/material.dart';
import '../../../data/models/problem/problem_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/math/math_renderer.dart';
import '../../../shared/widgets/input/math_input_field.dart';
import '../../../shared/widgets/input/drag_and_drop_widget.dart';

class AnswerInput extends StatelessWidget {
  final ProblemModel problem;
  final String? selectedAnswer;
  final bool isAnswerChecked;
  final bool isCorrect;
  final TextEditingController textController;
  final Map<String, String> dragDropPlacements;
  final ValueChanged<String> onSelectAnswer;
  final VoidCallback onCheckAnswer;
  final ValueChanged<Map<String, String>> onDragDropChanged;
  final Map<String, String> Function(String) parseDragDropAnswer;

  const AnswerInput({
    super.key,
    required this.problem,
    required this.selectedAnswer,
    required this.isAnswerChecked,
    required this.isCorrect,
    required this.textController,
    required this.dragDropPlacements,
    required this.onSelectAnswer,
    required this.onCheckAnswer,
    required this.onDragDropChanged,
    required this.parseDragDropAnswer,
  });

  @override
  Widget build(BuildContext context) {
    switch (problem.type) {
      case ProblemType.multipleChoice:
      case ProblemType.trueFalse:
        return _buildAnswerOptions();

      case ProblemType.shortAnswer:
      case ProblemType.fillInBlank:
        return _buildFillInBlankInput();

      case ProblemType.matching:
      case ProblemType.dragAndDrop:
        return _buildDragAndDropInput();
    }
  }

  Widget _buildAnswerOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: problem.options.map((option) {
        final isSelected = selectedAnswer == option;
        final isThisCorrect = option == problem.correctAnswer;

        Color backgroundColor = Colors.white;
        Color borderColor = const Color(0xFFE7EEEC);
        double borderWidth = 1.5;
        Color textColor = const Color(0xFF7E8381);
        IconData? trailingIcon;
        Color? trailingIconColor;

        if (isAnswerChecked) {
          if (isThisCorrect) {
            backgroundColor = AppColors.mathGreen.withValues(alpha: 0.1);
            borderColor = AppColors.mathGreen;
            borderWidth = 2.0;
            textColor = AppColors.mathGreen;
            trailingIcon = Icons.check_circle_rounded;
            trailingIconColor = AppColors.mathGreen;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.mathRed.withValues(alpha: 0.1);
            borderColor = AppColors.mathRed;
            borderWidth = 2.0;
            textColor = AppColors.mathRed;
            trailingIcon = Icons.cancel_rounded;
            trailingIconColor = AppColors.mathRed;
          }
        } else if (isSelected) {
          backgroundColor = const Color(0xFFF1F2F1);
          borderColor = const Color(0xFF61A1D8);
          borderWidth = 2.0;
          textColor = const Color(0xFF3D4543);
        }

        return GestureDetector(
          onTap: () => onSelectAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: MathRichText(
                    text: option,
                    textStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight:
                          isSelected || (isAnswerChecked && isThisCorrect)
                              ? FontWeight.w600
                              : FontWeight.w500,
                      color: textColor,
                      fontSize: 15,
                    ),
                    mathFontSize: 16.0,
                    mathColor: textColor,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 6),
                  Icon(trailingIcon, color: trailingIconColor, size: 20),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillInBlankInput() {
    return Column(
      children: [
        MathInputField(
          controller: textController,
          hintText: '답을 입력하세요',
          autofocus: true,
          onSubmitted: (_) {
            if (!isAnswerChecked && textController.text.trim().isNotEmpty) {
              onCheckAnswer();
            }
          },
        ),
        const SizedBox(height: AppDimensions.spacing16),
        MathKeyboard(
          controller: textController,
          onDone: () {
            if (!isAnswerChecked && textController.text.trim().isNotEmpty) {
              onCheckAnswer();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDragAndDropInput() {
    final items = problem.options.map((option) {
      return DraggableItem(
        id: option,
        content: option,
        isMath: true,
      );
    }).toList();

    final correctPlacements = parseDragDropAnswer(problem.correctAnswer);
    final dropZones = correctPlacements.keys.map((zoneId) {
      final zoneIndex = int.tryParse(zoneId.replaceAll('zone_', '')) ?? 1;
      return DropZone(
        id: zoneId,
        hint: '$zoneIndex번 위치에 드래그하세요',
      );
    }).toList();

    if (dropZones.isEmpty) {
      dropZones.add(const DropZone(
        id: 'zone_1',
        hint: '여기에 답을 드래그하세요',
      ));
    }

    return DragAndDropMathWidget(
      items: items,
      dropZones: dropZones,
      isEnabled: !isAnswerChecked,
      onChanged: onDragDropChanged,
    );
  }
}
