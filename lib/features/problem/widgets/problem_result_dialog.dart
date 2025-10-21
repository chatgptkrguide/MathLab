import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../data/models/models.dart';
import 'package:confetti/confetti.dart';

/// 문제 풀이 결과 다이얼로그
///
/// 레슨의 모든 문제를 풀고 나면 표시되는 결과 화면입니다.
/// 총 정답률, 획득 XP, 업적 등을 표시합니다.
class ProblemResultDialog extends StatefulWidget {
  /// 레슨 제목
  final String lessonTitle;

  /// 문제 결과 목록
  final List<ProblemResult> results;

  /// 총 획득 XP
  final int totalXPEarned;

  /// 완료 버튼 콜백
  final VoidCallback onComplete;

  /// 다시 풀기 버튼 콜백
  final VoidCallback onRetry;

  const ProblemResultDialog({
    super.key,
    required this.lessonTitle,
    required this.results,
    required this.totalXPEarned,
    required this.onComplete,
    required this.onRetry,
  });

  @override
  State<ProblemResultDialog> createState() => _ProblemResultDialogState();
}

class _ProblemResultDialogState extends State<ProblemResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();

    // 높은 점수일 경우 축하 효과
    if (_accuracyPercentage >= 80) {
      _confettiController.play();
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 정답 개수
  int get _correctCount =>
      widget.results.where((r) => r.isCorrect).length;

  /// 총 문제 수
  int get _totalCount => widget.results.length;

  /// 정답률 (퍼센트)
  int get _accuracyPercentage =>
      ((_correctCount / _totalCount) * 100).round();

  /// 평가 등급
  String get _grade {
    if (_accuracyPercentage >= 90) return 'S';
    if (_accuracyPercentage >= 80) return 'A';
    if (_accuracyPercentage >= 70) return 'B';
    if (_accuracyPercentage >= 60) return 'C';
    return 'D';
  }

  /// 평가 색상
  Color get _gradeColor {
    if (_accuracyPercentage >= 90) return const Color(0xFFFFD700); // Gold
    if (_accuracyPercentage >= 80) return AppColors.successGreen;
    if (_accuracyPercentage >= 70) return AppColors.mathTeal;
    if (_accuracyPercentage >= 60) return AppColors.warningYellow;
    return AppColors.errorRed;
  }

  /// 평가 메시지
  String get _message {
    if (_accuracyPercentage >= 90) return '완벽해요! 🌟';
    if (_accuracyPercentage >= 80) return '훌륭해요! 👏';
    if (_accuracyPercentage >= 70) return '잘했어요! 👍';
    if (_accuracyPercentage >= 60) return '괜찮아요! 💪';
    return '조금 더 연습해봐요! 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 오버레이
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
        // 결과 다이얼로그
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXL,
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이틀
                  Text(
                    widget.lessonTitle,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    '레슨 완료!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // 평가 등급
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _gradeColor,
                          _gradeColor.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gradeColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _grade,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // 평가 메시지
                  Text(
                    _message,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // 통계
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        '정답률',
                        '$_accuracyPercentage%',
                        '📊',
                      ),
                      _buildStatItem(
                        '정답',
                        '$_correctCount/$_totalCount',
                        '✅',
                      ),
                      _buildStatItem(
                        '획득 XP',
                        '+${widget.totalXPEarned}',
                        '🔶',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // 문제별 결과
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '문제별 결과',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        ...List.generate(
                          widget.results.length,
                          (index) => _buildProblemResultItem(
                            index + 1,
                            widget.results[index],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // 버튼들
                  Row(
                    children: [
                      // 다시 풀기 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onRetry,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingL,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL),
                              border: Border.all(
                                color: AppColors.mathTeal,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: AppColors.mathTeal,
                                ),
                                const SizedBox(width: AppDimensions.spacingS),
                                Text(
                                  '다시 풀기',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.mathTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      // 완료 버튼
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: widget.onComplete,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.paddingL,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.mathButtonGradient,
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mathButtonBlue
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: AppDimensions.spacingS),
                                Text(
                                  '완료',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Confetti 효과
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // 위에서 아래로
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
            colors: const [
              AppColors.mathTeal,
              AppColors.mathButtonBlue,
              AppColors.successGreen,
              Color(0xFFFFD700),
            ],
          ),
        ),
      ],
    );
  }

  /// 통계 항목 위젯
  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 문제별 결과 항목
  Widget _buildProblemResultItem(int number, ProblemResult result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        children: [
          // 문제 번호
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: result.isCorrect
                  ? AppColors.successGreen.withValues(alpha: 0.1)
                  : AppColors.errorRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTextStyles.bodySmall.copyWith(
                  color: result.isCorrect
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          // 결과 아이콘
          Icon(
            result.isCorrect ? Icons.check_circle : Icons.cancel,
            color: result.isCorrect
                ? AppColors.successGreen
                : AppColors.errorRed,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          // XP
          if (result.isCorrect) ...[
            Text(
              '+${result.xpEarned} XP',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          // 소요 시간
          Text(
            '${result.timeSpentSeconds}초',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
