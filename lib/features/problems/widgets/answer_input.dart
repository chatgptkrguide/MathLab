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
        return _buildAnswerOptions(context);

      case ProblemType.shortAnswer:
      case ProblemType.fillInBlank:
        return _buildFillInBlankInput();

      case ProblemType.matching:
      case ProblemType.dragAndDrop:
        return _buildDragAndDropInput();
    }
  }

  Widget _buildAnswerOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: problem.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswer == option;
        final isThisCorrect = option == problem.correctAnswer;

        Color backgroundColor = Colors.white;
        Color borderColor = const Color(0xFFE0E4E3);
        double borderWidth = 1.5;
        Color textColor = const Color(0xFF3D4543);
        IconData? trailingIcon;
        Color? trailingIconColor;

        // Option label (A, B, C, D)
        final optionLabel = String.fromCharCode(65 + index);

        if (isAnswerChecked) {
          if (isThisCorrect) {
            backgroundColor = AppColors.mathGreen.withValues(alpha: 0.1);
            borderColor = AppColors.mathGreen;
            borderWidth = 2.5;
            textColor = AppColors.mathGreen;
            trailingIcon = Icons.check_circle_rounded;
            trailingIconColor = AppColors.mathGreen;
          } else if (isSelected && !isCorrect) {
            backgroundColor = AppColors.mathRed.withValues(alpha: 0.1);
            borderColor = AppColors.mathRed;
            borderWidth = 2.5;
            textColor = AppColors.mathRed;
            trailingIcon = Icons.cancel_rounded;
            trailingIconColor = AppColors.mathRed;
          } else {
            backgroundColor = Colors.white.withValues(alpha: 0.6);
            textColor = const Color(0xFFAAAAAA);
            borderColor = const Color(0xFFEEEEEE);
          }
        } else if (isSelected) {
          backgroundColor = const Color(0xFFEDF4FC);
          borderColor = const Color(0xFF61A1D8);
          borderWidth = 2.5;
          textColor = const Color(0xFF2C5F8A);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => onSelectAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Row(
                children: [
                  // Option label circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected && !isAnswerChecked
                          ? const Color(0xFF61A1D8)
                          : isAnswerChecked && isThisCorrect
                              ? AppColors.mathGreen
                              : isAnswerChecked && isSelected && !isCorrect
                                  ? AppColors.mathRed
                                  : const Color(0xFFF0F0F0),
                    ),
                    child: Center(
                      child: Text(
                        optionLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: (isSelected && !isAnswerChecked) ||
                                  (isAnswerChecked && (isThisCorrect || (isSelected && !isCorrect)))
                              ? Colors.white
                              : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MathRichText(
                      text: option,
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        fontWeight:
                            isSelected || (isAnswerChecked && isThisCorrect)
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color: textColor,
                        fontSize: 16,
                      ),
                      mathFontSize: 18.0,
                      mathColor: textColor,
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(trailingIcon, color: trailingIconColor, size: 22),
                ],
              ),
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
