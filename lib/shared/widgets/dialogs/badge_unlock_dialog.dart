import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../../data/models/models.dart';
import 'package:confetti/confetti.dart';

/// 뱃지 언락 애니메이션 다이얼로그
///
/// 업적 달성 시 표시되는 축하 다이얼로그
/// 아름다운 애니메이션과 함께 뱃지 정보를 표시합니다.
class BadgeUnlockDialog extends StatefulWidget {
  /// 언락된 업적
  final Achievement achievement;

  /// 닫기 콜백
  final VoidCallback onClose;

  const BadgeUnlockDialog({
    super.key,
    required this.achievement,
    required this.onClose,
  });

  @override
  State<BadgeUnlockDialog> createState() => _BadgeUnlockDialogState();

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<void> show(
    BuildContext context,
    Achievement achievement,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BadgeUnlockDialog(
        achievement: achievement,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _BadgeUnlockDialogState extends State<BadgeUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _backdropController;
  late AnimationController _badgeController;
  late AnimationController _contentController;
  late ConfettiController _confettiController;

  late Animation<double> _backdropAnimation;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _badgeRotateAnimation;
  late Animation<double> _badgeGlowAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // 배경 애니메이션 (0-300ms)
    _backdropController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _backdropAnimation = CurvedAnimation(
      parent: _backdropController,
      curve: Curves.easeOut,
    );

    // 뱃지 애니메이션 (300-900ms)
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _badgeScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    ));

    _badgeRotateAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOut,
    ));

    // 뱃지 반짝임 애니메이션 (무한 반복)
    _badgeGlowAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeInOut,
    ));

    // 컨텐츠 애니메이션 (600-1000ms)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // Confetti 컨트롤러
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  void _startAnimations() async {
    // 순차 애니메이션
    await _backdropController.forward();
    await Future.delayed(const Duration(milliseconds: 100));

    // 뱃지와 confetti 동시 시작
    _badgeController.forward();
    _confettiController.play();

    await Future.delayed(const Duration(milliseconds: 300));
    await _contentController.forward();

    // 뱃지 반짝임 반복
    _badgeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backdropController.dispose();
    _badgeController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 희귀도별 색상 (GoMath)
  Color get _rarityColor {
    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return AppColors.textSecondary; // Gray (GoMath)
      case AchievementRarity.uncommon:
        return AppColors.successGreen; // Green (GoMath)
      case AchievementRarity.rare:
        return AppColors.mathBlue; // Blue (GoMath)
      case AchievementRarity.epic:
        return AppColors.mathPurple; // Purple (GoMath)
      case AchievementRarity.legendary:
        return AppColors.mathYellow; // Gold (GoMath)
    }
  }

  /// 희귀도 텍스트
  String get _rarityText {
    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.uncommon:
        return '고급';
      case AchievementRarity.rare:
        return '희귀';
      case AchievementRarity.epic:
        return '영웅';
      case AchievementRarity.legendary:
        return '전설';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 반투명 배경
        FadeTransition(
          opacity: _backdropAnimation,
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),

        // 메인 컨텐츠
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 뱃지 아이콘
                _buildBadgeIcon(),
                const SizedBox(height: AppDimensions.spacingXXL),

                // 컨텐츠 영역
                _buildContent(),
              ],
            ),
          ),
        ),

        // Confetti 효과
        _buildConfetti(),
      ],
    );
  }

  /// 뱃지 아이콘 애니메이션
  Widget _buildBadgeIcon() {
    return ScaleTransition(
      scale: _badgeScaleAnimation,
      child: RotationTransition(
        turns: _badgeRotateAnimation,
        child: AnimatedBuilder(
          animation: _badgeGlowAnimation,
          builder: (context, child) {
            return Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _rarityColor.withValues(alpha: 0.3 * _badgeGlowAnimation.value),
                    _rarityColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _rarityColor,
                        _rarityColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _rarityColor.withValues(alpha: 0.5 * _badgeGlowAnimation.value),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.achievement.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 컨텐츠 영역
  Widget _buildContent() {
    return FadeTransition(
      opacity: _contentFadeAnimation,
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
              // 축하 메시지
              Text(
                '🎉 업적 달성!',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _rarityColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // 희귀도 뱃지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _rarityColor,
                      _rarityColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Text(
                  _rarityText,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // 업적 제목
              Text(
                widget.achievement.title,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // 업적 설명
              Text(
                widget.achievement.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingXL),

              // XP 보상
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.mathBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: AppColors.mathBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🔶',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      '+${widget.achievement.xpReward} XP',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.mathBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXXL),

              // 확인 버튼
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingL,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _rarityColor,
                        _rarityColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: _rarityColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '확인',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Confetti 효과
  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 3.14 / 2, // 위에서 아래로
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 30,
        gravity: 0.3,
        colors: [
          _rarityColor,
          AppColors.mathTeal,
          AppColors.mathButtonBlue,
          AppColors.successGreen,
          AppColors.mathYellow, // Gold (GoMath)
        ],
      ),
    );
  }
}
