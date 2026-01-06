import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../data/models/models.dart';

/// 문제 풀이 제어 버튼 위젯
///
/// 포함 내용:
/// - 제출 버튼 (주관식, 제출 전)
/// - 다음 문제 버튼 (제출 후)
/// - 결과 확인 버튼 (마지막 문제)
/// - Duolingo 스타일 3D 그림자
class ProblemControls extends StatelessWidget {
  /// 문제 정보
  final Problem problem;

  /// 현재 문제 인덱스
  final int currentProblemIndex;

  /// 전체 문제 수
  final int totalProblems;

  /// 답안 선택 여부
  final bool isAnswerSelected;

  /// 답안 제출 여부
  final bool isAnswerSubmitted;

  /// 정답 여부
  final bool isCorrect;

  /// 사용자 입력 (주관식)
  final String? userInput;

  /// 제출 콜백
  final VoidCallback? onSubmit;

  /// 다음 문제 콜백
  final VoidCallback? onNext;

  /// 결과 확인 콜백
  final VoidCallback? onShowResults;

  const ProblemControls({
    super.key,
    required this.problem,
    required this.currentProblemIndex,
    required this.totalProblems,
    this.isAnswerSelected = false,
    this.isAnswerSubmitted = false,
    this.isCorrect = false,
    this.userInput,
    this.onSubmit,
    this.onNext,
    this.onShowResults,
  });

  bool get _isLastProblem => currentProblemIndex >= totalProblems - 1;

  @override
  Widget build(BuildContext context) {
    // 객관식이고 제출 전이면 버튼 숨김 (더블 클릭으로 자동 제출)
    if (problem.type == ProblemType.multipleChoice && !isAnswerSubmitted) {
      return const SizedBox.shrink();
    }

    final enabled = _getButtonAction() != null;
    final buttonColor = _getButtonColor();
    final darkerColor = _getDarkerButtonColor();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Duolingo 3D solid shadow
            if (enabled)
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                bottom: -6,
                child: Container(
                  decoration: BoxDecoration(
                    color: darkerColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            // Main button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _getButtonAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.borderLight,
                ),
                child: Text(
                  _getButtonText(),
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    // 답 제출 후에는 다음 문제 또는 결과 확인
    if (isAnswerSubmitted) {
      // 2문제 완료하면 결과 확인
      if (currentProblemIndex >= 1 || _isLastProblem) {
        return onShowResults;
      }
      return onNext;
    }

    // 객관식: 제출 버튼 없음 (더블 클릭으로 자동 제출)
    if (problem.type == ProblemType.multipleChoice) {
      return null;
    }

    // 주관식/계산: 입력이 있을 때만 제출 버튼 활성화
    if (problem.type == ProblemType.shortAnswer ||
        problem.type == ProblemType.calculation) {
      return (userInput != null && userInput!.isNotEmpty) ? onSubmit : null;
    }

    return null;
  }

  Color _getButtonColor() {
    if (isAnswerSubmitted) {
      return isCorrect ? AppColors.successGreen : AppColors.mathButtonBlue;
    }

    // 주관식: 입력이 있으면 활성화
    if (problem.type == ProblemType.shortAnswer ||
        problem.type == ProblemType.calculation) {
      return (userInput == null || userInput!.isEmpty)
          ? AppColors.borderLight
          : AppColors.successGreen;
    }

    // 객관식: 선택이 있으면 활성화
    if (!isAnswerSelected) {
      return AppColors.borderLight;
    }
    return AppColors.successGreen;
  }

  Color _getDarkerButtonColor() {
    if (isAnswerSubmitted) {
      return isCorrect
          ? AppColors.successGreen.withOpacity(0.8)
          : AppColors.mathButtonBlueDark;
    }
    return AppColors.successGreen.withOpacity(0.8);
  }

  String _getButtonText() {
    if (!isAnswerSubmitted) {
      return '제출';
    }
    // 2문제 완료하면 결과 확인
    if (currentProblemIndex >= 1 || _isLastProblem) {
      return '결과 확인';
    }
    return '다음 문제';
  }
}
