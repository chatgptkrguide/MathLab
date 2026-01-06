import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/assessment/level_skip_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../shared/widgets/math/math_text.dart';
import '../problem/widgets/problem_option_button.dart';

/// 레벨 스킵 테스트 화면
class LevelSkipTestScreen extends ConsumerStatefulWidget {
  final String testId;

  const LevelSkipTestScreen({
    super.key,
    required this.testId,
  });

  @override
  ConsumerState<LevelSkipTestScreen> createState() =>
      _LevelSkipTestScreenState();
}

class _LevelSkipTestScreenState extends ConsumerState<LevelSkipTestScreen> {
  int? _selectedAnswerIndex;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final testAsync = ref.watch(skipTestNotifierProvider(widget.testId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: testAsync.when(
          data: (test) {
            if (test == null) {
              return _buildError('테스트를 찾을 수 없습니다');
            }

            if (test.isCompleted) {
              // 테스트 완료 시 결과 화면으로 이동
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LevelSkipResultScreen(test: test),
                  ),
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            final currentProblem = test.currentProblem;
            if (currentProblem == null) {
              return _buildError('문제를 불러올 수 없습니다');
            }

            return Column(
              children: [
                // 헤더
                AdaptiveAppHeader(
                  title: '레벨 스킵 테스트 - ${test.lessonTitle}',
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _showCancelDialog(test),
                  ),
                ),

                // 진행률 표시
                _buildProgressBar(test),

                // 문제 영역
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 문제 번호 및 정확도
                        _buildInfoRow(test),
                        const SizedBox(height: 24),

                        // 문제 내용
                        _buildQuestionCard(currentProblem),
                        const SizedBox(height: 24),

                        // 선택지
                        _buildChoices(currentProblem),
                        const SizedBox(height: 32),

                        // 제출 버튼
                        _buildSubmitButton(test),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildError(error.toString()),
        ),
      ),
    );
  }

  /// 진행률 바
  Widget _buildProgressBar(LevelSkipTest test) {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: test.progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// 정보 행 (문제 번호 및 정확도)
  Widget _buildInfoRow(LevelSkipTest test) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '문제 ${test.currentProblemIndex + 1} / ${test.totalProblems}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: test.currentAccuracy >= test.requiredAccuracy
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '정확도: ${test.currentAccuracy}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: test.currentAccuracy >= test.requiredAccuracy
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  /// 문제 카드
  Widget _buildQuestionCard(Problem problem) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (problem.title.isNotEmpty) ...[
            Text(
              problem.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          MathText(
            problem.question,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 선택지 목록
  Widget _buildChoices(Problem problem) {
    return Column(
      children: List.generate(
        problem.choices.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProblemOptionButton(
            optionText: problem.choices[index],
            index: index,
            selectedIndex: _selectedAnswerIndex,
            isCorrectAnswer: false,
            isAnswerSubmitted: false,
            onTap: () {
              setState(() {
                _selectedAnswerIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  /// 제출 버튼
  Widget _buildSubmitButton(LevelSkipTest test) {
    final canSubmit = _selectedAnswerIndex != null && !_isSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitAnswer(test) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '제출',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// 답안 제출
  Future<void> _submitAnswer(LevelSkipTest test) async {
    if (_selectedAnswerIndex == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(skipTestNotifierProvider(widget.testId).notifier);
      await notifier.submitAnswer(_selectedAnswerIndex!);

      // 다음 문제로 이동 준비
      setState(() {
        _selectedAnswerIndex = null;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('답안 제출 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 취소 다이얼로그
  void _showCancelDialog(LevelSkipTest test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트 취소'),
        content: const Text('정말로 테스트를 취소하시겠습니까?\n진행 상황은 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              final actions = ref.read(skipTestActionsProvider);
              actions.cancelTest(test.id);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 테스트 화면 닫기
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 에러 화면
  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }
}

/// 레벨 스킵 결과 화면
class LevelSkipResultScreen extends ConsumerWidget {
  final LevelSkipTest test;

  const LevelSkipResultScreen({
    super.key,
    required this.test,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPassed = test.isPassed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AdaptiveAppHeader(
              title: '테스트 결과',
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // 결과 아이콘
                    Icon(
                      isPassed ? Icons.check_circle : Icons.cancel,
                      size: 120,
                      color: isPassed ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(height: 24),

                    // 결과 텍스트
                    Text(
                      isPassed ? '축하합니다!' : '아쉽습니다',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      isPassed
                          ? '레벨 스킵 테스트를 통과했습니다!'
                          : '조금 더 연습이 필요합니다',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // 통계 카드
                    _buildStatCard(test),
                    const SizedBox(height: 32),

                    // XP 획득 (통과 시에만)
                    if (isPassed) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.accentCyan.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '+${test.xpReward} XP',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isPassed ? '레슨으로 돌아가기' : '다시 도전하기',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatCard(LevelSkipTest test) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow('정답률', '${test.finalAccuracy}%'),
          const Divider(height: 32),
          _buildStatRow('맞춘 문제', '${test.correctAnswers} / ${test.totalProblems}'),
          const Divider(height: 32),
          _buildStatRow('통과 기준', '${test.requiredAccuracy}%'),
          if (test.durationInSeconds != null) ...[
            const Divider(height: 32),
            _buildStatRow('소요 시간', _formatDuration(test.durationInSeconds!)),
          ],
        ],
      ),
    );
  }

  /// 통계 행
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 시간 포맷팅
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes분 $remainingSeconds초';
  }
}
