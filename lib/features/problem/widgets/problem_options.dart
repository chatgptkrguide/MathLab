import 'package:flutter/material.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../data/models/models.dart';
import 'problem_option_button.dart';

/// 객관식 문제 선택지 위젯
///
/// 포함 내용:
/// - 선택지 버튼 리스트
/// - 선택 상태 표시
/// - 정답/오답 표시 (제출 후)
/// - Fade-in 애니메이션
class ProblemOptions extends StatelessWidget {
  /// 표시할 문제
  final Problem problem;

  /// 현재 선택된 답안 인덱스
  final int? selectedIndex;

  /// 답안 제출 여부
  final bool isAnswerSubmitted;

  /// 선택 콜백
  final Function(int) onSelect;

  /// 펄스 애니메이션 표시할 인덱스 (더블 클릭용)
  final int? pulsingIndex;

  const ProblemOptions({
    super.key,
    required this.problem,
    this.selectedIndex,
    this.isAnswerSubmitted = false,
    required this.onSelect,
    this.pulsingIndex,
  });

  @override
  Widget build(BuildContext context) {
    // 선택지가 없으면 빈 위젯 반환
    if (problem.choices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(
        problem.choices.length,
        (index) {
          // answer가 int인 경우 정답 인덱스로 사용
          final correctAnswerIndex =
              problem.answer is int ? problem.answer as int : -1;
          final isCorrectAnswer = correctAnswerIndex == index;

          return FadeInWidget(
            delay: Duration(milliseconds: 100 * index),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              child: ProblemOptionButton(
                optionText: problem.choices[index],
                index: index,
                selectedIndex: selectedIndex,
                isAnswerSubmitted: isAnswerSubmitted,
                isCorrectAnswer: isCorrectAnswer,
                onTap: () => onSelect(index),
                isPulsing: pulsingIndex == index,
              ),
            ),
          );
        },
      ),
    );
  }
}
