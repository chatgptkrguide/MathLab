import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/gamification/heart_provider.dart';
import '../constants/constants.dart';

/// 하트 표시 위젯
class HeartWidget extends ConsumerWidget {
  /// 크기 (기본: 24)
  final double size;

  /// 색상 (기본: 빨간색)
  final Color? color;

  /// 타이머 표시 여부
  final bool showTimer;

  const HeartWidget({
    super.key,
    this.size = 24,
    this.color,
    this.showTimer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heartConfig = ref.watch(heartProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 하트 아이콘들
        ...List.generate(heartConfig.maxHearts, (index) {
          final isFilled = index < heartConfig.currentHearts;

          return Padding(
            padding: EdgeInsets.only(
                right: index < heartConfig.maxHearts - 1 ? 4 : 0),
            child: _buildHeart(isFilled),
          );
        }),

        // 타이머 표시
        if (showTimer && heartConfig.isRecovering) ...[
          const SizedBox(width: 8),
          _buildTimer(heartConfig.secondsUntilNextHeart ?? 0),
        ],
      ],
    );
  }

  Widget _buildHeart(bool isFilled) {
    return Icon(
      isFilled ? Icons.favorite : Icons.favorite_border,
      size: size,
      color: isFilled ? (color ?? AppColors.mathRed) : Colors.grey.shade400,
    );
  }

  Widget _buildTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mathRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$minutes:${remainingSeconds.toString().padLeft(2, '0')}',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.mathRed,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 하트 상세 정보 위젯 (하트 부족 시 표시)
class HeartInfoDialog extends ConsumerWidget {
  const HeartInfoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heartConfig = ref.watch(heartProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 하트 아이콘
            Icon(
              Icons.favorite,
              size: 64,
              color: AppColors.mathRed,
            ),
            const SizedBox(height: 16),

            // 제목
            Text(
              '하트가 부족해요!',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              heartConfig.isEmpty
                  ? '하트가 모두 소진되었어요.\n잠시 후 다시 시도하거나 하트를 구매하세요.'
                  : '문제를 틀리면 하트가 감소해요.\n하트가 0이 되면 더 이상 학습할 수 없어요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 하트 복구 정보
            if (heartConfig.isRecovering) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mathBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '다음 하트 복구',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        HeartWidget(showTimer: true, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 복구 진행률
                    LinearProgressIndicator(
                      value: heartConfig.recoveryProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.mathBlue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                    ),
                    child: const Text('닫기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: 하트 구매 화면으로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mathRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusL),
                      ),
                    ),
                    child: const Text(
                      '하트 구매',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 하트 없음 알림 표시
void showNoHeartsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const HeartInfoDialog(),
  );
}
