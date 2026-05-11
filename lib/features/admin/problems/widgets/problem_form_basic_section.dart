// Problem form basic section — lesson selector, question with LaTeX preview,
// type/difficulty pickers, points, correct answer, and explanation fields.
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../data/models/lesson/lesson_model.dart';
import '../../../../data/models/lesson/unit_model.dart';
import '../../../../data/models/problem/problem_model.dart';
import '../../../../shared/constants/constants.dart';

class ProblemFormBasicSection extends StatelessWidget {
  /// Pre-built lesson selector widget — the host screen renders this from its
  /// `AsyncValue<List<UnitModel>>` so this widget stays Riverpod-free.
  final Widget lessonSelector;

  final TextEditingController questionController;
  final bool showLatexPreview;
  final VoidCallback onToggleLatexPreview;
  final ValueChanged<String> onQuestionChanged;

  final ProblemType selectedType;
  final ValueChanged<ProblemType> onTypeChanged;

  final ProblemDifficulty selectedDifficulty;
  final ValueChanged<ProblemDifficulty> onDifficultyChanged;

  final TextEditingController pointsController;

  const ProblemFormBasicSection({
    super.key,
    required this.lessonSelector,
    required this.questionController,
    required this.showLatexPreview,
    required this.onToggleLatexPreview,
    required this.onQuestionChanged,
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.pointsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lesson selector
        lessonSelector,
        const SizedBox(height: AppDimensions.spacing16),

        // Question
        problemFormSectionLabel('질문 (LaTeX 지원)'),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: questionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: r'예: $x^2 + 2x + 1 = 0$의 근은?',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                showLatexPreview ? Icons.visibility_off : Icons.visibility,
                color: AppColors.mathBlue,
              ),
              onPressed: onToggleLatexPreview,
            ),
          ),
          validator: (v) => v == null || v.isEmpty ? '질문을 입력하세요' : null,
          onChanged: onQuestionChanged,
        ),
        if (showLatexPreview) ...[
          const SizedBox(height: AppDimensions.spacing8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacing12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: _buildLatexPreview(questionController.text),
          ),
        ],
        const SizedBox(height: AppDimensions.spacing16),

        // Type & Difficulty
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  problemFormSectionLabel('문제 유형'),
                  const SizedBox(height: AppDimensions.spacing4),
                  DropdownButtonFormField<ProblemType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12, vertical: 10),
                    ),
                    items: ProblemType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(_typeLabel(t),
                                  style: AppTextStyles.bodyMedium),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      onTypeChanged(v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  problemFormSectionLabel('난이도'),
                  const SizedBox(height: AppDimensions.spacing4),
                  DropdownButtonFormField<ProblemDifficulty>(
                    initialValue: selectedDifficulty,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12, vertical: 10),
                    ),
                    items: ProblemDifficulty.values
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(_difficultyLabel(d),
                                  style: AppTextStyles.bodyMedium),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      onDifficultyChanged(v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),

        // Points
        problemFormSectionLabel('포인트'),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: pointsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return '포인트를 입력하세요';
            if (int.tryParse(v) == null) return '숫자를 입력하세요';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLatexPreview(String text) {
    // Simple LaTeX extraction: look for $...$
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\$(.+?)\$');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        ));
      }
      // Add LaTeX as widget span
      parts.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          match.group(1)!,
          textStyle: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      ));
    }

    if (parts.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary),
      );
    }

    return RichText(text: TextSpan(children: parts));
  }

  String _typeLabel(ProblemType type) {
    switch (type) {
      case ProblemType.multipleChoice:
        return '객관식';
      case ProblemType.trueFalse:
        return 'O/X';
      case ProblemType.fillInBlank:
        return '빈칸 채우기';
      case ProblemType.matching:
        return '매칭';
      case ProblemType.shortAnswer:
        return '단답형';
      case ProblemType.dragAndDrop:
        return '드래그 앤 드롭';
    }
  }

  String _difficultyLabel(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return '쉬움';
      case ProblemDifficulty.medium:
        return '보통';
      case ProblemDifficulty.hard:
        return '어려움';
      case ProblemDifficulty.expert:
        return '전문가';
    }
  }
}

/// Builds the lesson dropdown selector from a flat list of units/lessons.
/// Kept at top-level so the host screen can build it from inside the
/// AsyncValue.when() branch and pass it into [ProblemFormBasicSection].
class ProblemFormLessonSelector extends StatelessWidget {
  final List<UnitModel> units;
  final String? selectedLessonId;
  final ValueChanged<String?> onChanged;

  const ProblemFormLessonSelector({
    super.key,
    required this.units,
    required this.selectedLessonId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Flatten all lessons with unit info
    final allLessons = <MapEntry<UnitModel, LessonModel>>[];
    for (final unit in units) {
      for (final lesson in unit.lessons) {
        allLessons.add(MapEntry(unit, lesson));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        problemFormSectionLabel('레슨'),
        const SizedBox(height: AppDimensions.spacing4),
        DropdownButtonFormField<String>(
          initialValue: selectedLessonId,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12, vertical: 10),
          ),
          items: allLessons
              .map((entry) => DropdownMenuItem(
                    value: entry.value.id,
                    child: Text(
                      '${entry.key.emoji} ${entry.key.title} > ${entry.value.title}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null || v.isEmpty ? '레슨을 선택하세요' : null,
        ),
      ],
    );
  }
}

/// Renders the "정답" and "해설" fields that appear after the options list in
/// the form layout. Kept as a sibling widget so the host screen can preserve
/// the original section ordering (options between basic-section and answers).
class ProblemFormAnswerSection extends StatelessWidget {
  final TextEditingController correctAnswerController;
  final TextEditingController explanationController;

  const ProblemFormAnswerSection({
    super.key,
    required this.correctAnswerController,
    required this.explanationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        problemFormSectionLabel('정답'),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: correctAnswerController,
          decoration: const InputDecoration(
            hintText: '정답을 입력하세요',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          validator: (v) => v == null || v.isEmpty ? '정답을 입력하세요' : null,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        problemFormSectionLabel('해설 (선택)'),
        const SizedBox(height: AppDimensions.spacing4),
        TextFormField(
          controller: explanationController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: '문제 해설을 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// Shared section label used across the problem-form widgets.
Widget problemFormSectionLabel(String text) {
  return Text(
    text,
    style: AppTextStyles.titleSmall,
  );
}
