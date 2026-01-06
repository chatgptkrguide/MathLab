import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../../data/providers/subscription/premium_providers.dart';

/// 프리미엄 뱃지 위젯
///
/// 프리미엄 사용자 프로필, 아바타, 이름 옆에 표시되는 뱃지입니다.
/// 무료 체험 중인 사용자에게는 표시되지 않습니다.
///
/// 사용 예시:
/// ```dart
/// Row(
///   children: [
///     Text('사용자 이름'),
///     PremiumBadge(size: PremiumBadgeSize.small),
///   ],
/// )
/// ```
class PremiumBadge extends ConsumerWidget {
  /// 뱃지 크기
  final PremiumBadgeSize size;

  /// 뱃지 스타일
  final PremiumBadgeStyle style;

  /// 애니메이션 활성화 여부
  final bool animate;

  /// 툴팁 표시 여부
  final bool showTooltip;

  const PremiumBadge({
    super.key,
    this.size = PremiumBadgeSize.medium,
    this.style = PremiumBadgeStyle.iconOnly,
    this.animate = true,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowBadge = ref.watch(shouldShowPremiumBadgeProvider);

    // 무료 사용자 또는 체험 중인 사용자는 뱃지를 표시하지 않음
    if (!shouldShowBadge) {
      return const SizedBox.shrink();
    }

    final badge = _buildBadge();

    // 툴팁 표시
    if (showTooltip) {
      return Tooltip(
        message: '프리미엄 회원',
        child: badge,
      );
    }

    return badge;
  }

  /// 뱃지 빌드
  Widget _buildBadge() {
    final dimensions = _getBadgeDimensions();

    switch (style) {
      case PremiumBadgeStyle.iconOnly:
        return _buildIconOnlyBadge(dimensions);

      case PremiumBadgeStyle.iconWithText:
        return _buildIconWithTextBadge(dimensions);

      case PremiumBadgeStyle.textOnly:
        return _buildTextOnlyBadge(dimensions);

      case PremiumBadgeStyle.crown:
        return _buildCrownBadge(dimensions);
    }
  }

  /// 아이콘만 있는 뱃지
  Widget _buildIconOnlyBadge(_BadgeDimensions dimensions) {
    return Container(
      width: dimensions.size,
      height: dimensions.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.premiumGradient,
        ),
        shape: BoxShape.circle,
        boxShadow: animate
            ? [
                BoxShadow(
                  color: AppColors.premiumGold.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.workspace_premium,
        color: Colors.white,
        size: dimensions.iconSize,
      ),
    );
  }

  /// 아이콘 + 텍스트 뱃지
  Widget _buildIconWithTextBadge(_BadgeDimensions dimensions) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.padding,
        vertical: dimensions.padding / 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.premiumGradient,
        ),
        borderRadius: BorderRadius.circular(dimensions.size / 2),
        boxShadow: animate
            ? [
                BoxShadow(
                  color: AppColors.premiumGold.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: dimensions.iconSize,
          ),
          SizedBox(width: dimensions.spacing),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions.fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 텍스트만 있는 뱃지
  Widget _buildTextOnlyBadge(_BadgeDimensions dimensions) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.padding,
        vertical: dimensions.padding / 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.premiumGradient,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'PREMIUM',
        style: TextStyle(
          color: Colors.white,
          fontSize: dimensions.fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  /// 왕관 스타일 뱃지
  Widget _buildCrownBadge(_BadgeDimensions dimensions) {
    return Container(
      width: dimensions.size,
      height: dimensions.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.goldGradient,
        ),
        shape: BoxShape.circle,
        boxShadow: animate
            ? [
                BoxShadow(
                  color: AppColors.premiumGold.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: dimensions.iconSize,
      ),
    );
  }

  /// 뱃지 크기 계산
  _BadgeDimensions _getBadgeDimensions() {
    switch (size) {
      case PremiumBadgeSize.small:
        return const _BadgeDimensions(
          size: 16,
          iconSize: 12,
          fontSize: 8,
          padding: 4,
          spacing: 2,
        );

      case PremiumBadgeSize.medium:
        return const _BadgeDimensions(
          size: 24,
          iconSize: 16,
          fontSize: 10,
          padding: 6,
          spacing: 4,
        );

      case PremiumBadgeSize.large:
        return const _BadgeDimensions(
          size: 32,
          iconSize: 20,
          fontSize: 12,
          padding: 8,
          spacing: 6,
        );
    }
  }
}

/// 뱃지 크기
enum PremiumBadgeSize {
  small,
  medium,
  large,
}

/// 뱃지 스타일
enum PremiumBadgeStyle {
  /// 아이콘만
  iconOnly,

  /// 아이콘 + 텍스트
  iconWithText,

  /// 텍스트만
  textOnly,

  /// 왕관 스타일
  crown,
}

/// 뱃지 크기 정보
class _BadgeDimensions {
  final double size;
  final double iconSize;
  final double fontSize;
  final double padding;
  final double spacing;

  const _BadgeDimensions({
    required this.size,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    required this.spacing,
  });
}

/// 애니메이션 프리미엄 뱃지
///
/// 반짝이는 애니메이션 효과가 있는 프리미엄 뱃지입니다.
class AnimatedPremiumBadge extends StatefulWidget {
  final PremiumBadgeSize size;
  final PremiumBadgeStyle style;

  const AnimatedPremiumBadge({
    super.key,
    this.size = PremiumBadgeSize.medium,
    this.style = PremiumBadgeStyle.iconOnly,
  });

  @override
  State<AnimatedPremiumBadge> createState() => _AnimatedPremiumBadgeState();
}

class _AnimatedPremiumBadgeState extends State<AnimatedPremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: PremiumBadge(
        size: widget.size,
        style: widget.style,
        animate: true,
      ),
    );
  }
}

/// 프리미엄 상태 인디케이터
///
/// 프리미엄 상태를 텍스트로 표시하는 위젯입니다.
class PremiumStatusIndicator extends ConsumerWidget {
  /// 인디케이터 스타일
  final PremiumStatusIndicatorStyle style;

  const PremiumStatusIndicator({
    super.key,
    this.style = PremiumStatusIndicatorStyle.compact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumActive = ref.watch(isPremiumActiveProvider);
    final premiumStatusText = ref.watch(premiumStatusTextProvider);
    final isOnTrial = ref.watch(isOnTrialProvider);

    if (!isPremiumActive) {
      return const SizedBox.shrink();
    }

    switch (style) {
      case PremiumStatusIndicatorStyle.compact:
        return _buildCompactIndicator(premiumStatusText, isOnTrial);

      case PremiumStatusIndicatorStyle.detailed:
        return _buildDetailedIndicator(premiumStatusText, isOnTrial, ref);
    }
  }

  /// 간결한 인디케이터
  Widget _buildCompactIndicator(String statusText, bool isOnTrial) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnTrial
              ? [AppColors.mathYellow, AppColors.mathOrange]
              : AppColors.premiumGradient,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnTrial ? Icons.star : Icons.workspace_premium,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 상세한 인디케이터
  Widget _buildDetailedIndicator(
    String statusText,
    bool isOnTrial,
    WidgetRef ref,
  ) {
    final daysRemaining = ref.watch(subscriptionDaysRemainingProvider);
    final remainingText = ref.watch(subscriptionRemainingTextProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnTrial
              ? [AppColors.mathYellow, AppColors.mathOrange]
              : AppColors.premiumGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnTrial ? Icons.star : Icons.workspace_premium,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusText,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (daysRemaining > 0) ...[
            const SizedBox(height: 8),
            Text(
              remainingText,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 프리미엄 상태 인디케이터 스타일
enum PremiumStatusIndicatorStyle {
  /// 간결한 스타일 (한 줄)
  compact,

  /// 상세한 스타일 (여러 줄)
  detailed,
}
