// Problem Completion Screen
//
// Shown after all problems are completed.
// Displays stars, stats, and saves progress.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/problem/problem_session_model.dart';
import '../../data/providers/lesson/lesson_progress_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(userProvider);
      if (user == null) return;

      await ref
          .read(lessonProgressProvider(user.id).notifier)
          .completeLesson(
            lessonId: widget.lessonId,
            correctAnswers: widget.session.correctCount,
            totalQuestions: widget.session.problems.length,
            xpEarned: widget.session.score,
          );

      await ref.read(userProvider.notifier).addXp(widget.session.score);
      await ref.read(userProvider.notifier).updateStreak();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: AppDimensions.iconMedium,
                          height: AppDimensions.iconMedium,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.mathGreen),
                          ),
                        )
                      : Text(
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
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
            ),
          ),
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
