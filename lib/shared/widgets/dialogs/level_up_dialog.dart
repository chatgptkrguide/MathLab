import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 레벨업 축하 다이얼로그
/// 화려한 애니메이션과 축하 효과
class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final int totalXP;
  final VoidCallback? onClose;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.totalXP,
    this.onClose,
  });

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required int totalXP,
    VoidCallback? onClose,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.cardShadow.withValues(alpha: 0.87),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LevelUpDialog(
          newLevel: newLevel,
          totalXP: totalXP,
          onClose: onClose,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 바운스 + 스케일 애니메이션
        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late ConfettiController _confettiController;

  late Animation<double> _starScale;
  late Animation<double> _pulse;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    // 별 애니메이션
    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.5),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOut,
    ));

    // 펄스 애니메이션
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 회전 애니메이션
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _rotate = Tween<double>(begin: 0.0, end: 1.0).animate(_rotateController);

    // 컨페티 컨트롤러
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // 애니메이션 시작
    _starController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _starController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 컨페티 효과 (왼쪽)
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 0, // 오른쪽으로
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              AppColors.mathYellow,
              AppColors.mathOrange,
              AppColors.mathTeal,
              AppColors.mathBlue,
            ],
          ),
        ),
        // 컨페티 효과 (오른쪽)
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14, // 왼쪽으로
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              AppColors.mathYellow,
              AppColors.mathOrange,
              AppColors.mathTeal,
              AppColors.mathBlue,
            ],
          ),
        ),
        // 메인 다이얼로그
        Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXXXL),
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 회전하는 장식
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotate.value * 2 * 3.14159,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: AppColors.mathYellowGradient,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // 레벨 업 텍스트
                  Text(
                    'Level Up!',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathBlue,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  // 별 아이콘 + 레벨
                  AnimatedBuilder(
                    animation: _starController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _starScale.value,
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: AppColors.mathYellowGradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mathYellow.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.stars,
                                color: AppColors.surface,
                                size: 48,
                              ),
                              Text(
                                '${widget.newLevel}',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),
                  // 축하 메시지
                  Text(
                    '축하합니다! 레벨 ${widget.newLevel}에 도달했습니다!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  // 총 XP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mathTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.diamond_outlined,
                          color: AppColors.mathTeal,
                          size: 24,
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          '총 ${widget.totalXP} XP',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.mathTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  // 보상 표시
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '레벨 보상',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '하트 완전 회복',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXL),
                  // 계속하기 버튼
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulse.value,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onClose?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingXL,
                              vertical: AppDimensions.paddingL,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.mathButtonGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mathButtonBlue.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              '계속하기',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
