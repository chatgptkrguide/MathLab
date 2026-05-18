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

    // lessonProgress 는 별개 provider 라 병렬 OK. 단, addXp + updateStreak 는
    // 같은 userProvider state 를 mutate 하므로 직렬로 실행해야 한다.
    // (병렬 실행 시 둘 다 원본 state 를 동시에 읽고 각자 copyWith → 나중에 끝나는
    // 쪽이 먼저 끝난 쪽의 변경을 덮어써 XP 가 사라지는 race condition 발생.)
    try {
      await Future.wait([
        ref.read(lessonProgressProvider(user.uid).notifier).completeLesson(
              lessonId: widget.lessonId,
              correctAnswers: widget.session.correctCount,
              totalQuestions: widget.session.problems.length,
              xpEarned: widget.session.score,
            ),
        () async {
          await ref.read(userProvider.notifier).addXp(widget.session.score);
          await ref.read(userProvider.notifier).updateStreak();
        }(),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // === 상단 녹색 accent 헤더 ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mathGreen,
                    AppColors.mathGreen.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mathGreen.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration_rounded,
                      size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '레슨 완료!',
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lessonTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // === 본문 (흰 배경) ===
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  children: [
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
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 56,
                            color: index < widget.session.starsEarned
                                ? const Color(0xFFFFC800)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing32),

                    // Stats
                    _buildStatCard(
                        '정답률',
                        '${(widget.session.accuracy * 100).toStringAsFixed(0)}%',
                        AppColors.mathGreen,
                        Icons.check_circle_rounded),
                    const SizedBox(height: 12),
                    _buildStatCard('획득 점수', '${widget.session.score}점',
                        AppColors.mathYellow, Icons.bolt_rounded),
                    const SizedBox(height: 12),
                    _buildStatCard(
                        '남은 하트',
                        '${widget.session.hearts}/5',
                        AppColors.mathRed,
                        Icons.favorite_rounded),
                    const SizedBox(height: AppDimensions.spacing16),
                  ],
                ),
              ),
            ),

            // === Continue button ===
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mathGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '계속하기',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accent,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
