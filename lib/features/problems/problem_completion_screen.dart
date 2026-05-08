// Problem Completion Screen
//
// Shown after all problems are completed.
// Displays stars, stats, and saves progress.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../core/utils/app_logger.dart';

class ProblemCompletionScreen extends ConsumerStatefulWidget {
  final ProblemSessionModel session;
  final String lessonTitle;
  final String lessonId;

  const ProblemCompletionScreen({
    super.key,
    required this.session,
    required this.lessonTitle,
    required this.lessonId,
  });

  @override
  ConsumerState<ProblemCompletionScreen> createState() =>
      _ProblemCompletionScreenState();
}

class _ProblemCompletionScreenState
    extends ConsumerState<ProblemCompletionScreen> {
  @override
  void initState() {
    super.initState();
    // 보상 영속화는 fire-and-forget. 사용자는 이미 받은 점수/별을
    // 클라이언트 상태로 즉시 보고, "계속하기"도 바로 누를 수 있다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_saveProgress());
    });
  }

  Future<void> _saveProgress() async {
    final user = ref.read(userProvider);
    if (user == null) return;

    // 3개 호출을 병렬로 실행 → Firestore RTT 3회 → 1회로 단축.
    // 서로 의존성 없음 (lessonProgress / users 문서 / studyDates 분리).
    try {
      await Future.wait([
        ref.read(lessonProgressProvider(user.uid).notifier).completeLesson(
              lessonId: widget.lessonId,
              correctAnswers: widget.session.correctCount,
              totalQuestions: widget.session.problems.length,
              xpEarned: widget.session.score,
            ),
        ref.read(userProvider.notifier).addXp(widget.session.score),
        ref.read(userProvider.notifier).updateStreak(),
      ]);
    } catch (e, st) {
      AppLogger.error(
        '레슨 완료 영속화 실패',
        tag: 'ProblemCompletion',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '보상 저장에 실패했어요. 잠시 후 다시 시도해 주세요.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '다시 시도',
            textColor: Colors.white,
            onPressed: () => unawaited(_saveProgress()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mathGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing32),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppDimensions.spacing32),
                      const Icon(
                        Icons.celebration,
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppDimensions.spacing24),
                      Text(
                        '레슨 완료!',
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      Text(
                        widget.lessonTitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacing48),

                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacing8),
                            child: Icon(
                              index < widget.session.starsEarned
                                  ? Icons.star
                                  : Icons.star_border,
                              size: AppDimensions.iconXLarge,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacing48),

                      // Stats
                      _buildStatCard(
                          '정답률',
                          '${(widget.session.accuracy * 100).toStringAsFixed(0)}%'),
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildStatCard('점수', '${widget.session.score}점'),
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildStatCard('남은 하트', '${widget.session.hearts}/5'),
                      const SizedBox(height: AppDimensions.spacing32),
                    ],
                  ),
                ),
              ),

              // Continue button — saving 진행 여부와 무관하게 항상 활성화.
              // 보상은 백그라운드에서 영속화되므로 UX 차단할 이유 없음.
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '계속하기',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.mathGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
