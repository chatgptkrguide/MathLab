import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../../data/providers/subscription/premium_providers.dart';
import '../../../features/premium/premium_upgrade_screen.dart';

/// 프리미엄 기능 게이트 위젯
///
/// 무료 사용자에게는 잠금 상태로 표시하고,
/// 프리미엄 사용자에게는 정상적으로 표시합니다.
///
/// 사용 예시:
/// ```dart
/// FeatureGateWidget(
///   child: Text('프리미엄 전용 콘텐츠'),
/// )
/// ```
class FeatureGateWidget extends ConsumerWidget {
  /// 프리미엄 전용 콘텐츠
  final Widget child;

  /// 잠금 스타일
  final FeatureGateLockStyle lockStyle;

  /// 잠금 메시지 (null이면 기본 메시지 사용)
  final String? lockMessage;

  /// 잠금 아이콘 (null이면 기본 아이콘 사용)
  final IconData? lockIcon;

  /// 업그레이드 화면으로 이동할지 여부
  final bool navigateOnTap;

  const FeatureGateWidget({
    super.key,
    required this.child,
    this.lockStyle = FeatureGateLockStyle.blur,
    this.lockMessage,
    this.lockIcon,
    this.navigateOnTap = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumActive = ref.watch(isPremiumActiveProvider);

    // 프리미엄 사용자는 그대로 표시
    if (isPremiumActive) {
      return child;
    }

    // 무료 사용자는 잠금 상태로 표시
    return _buildLockedView(context);
  }

  /// 잠금 상태 뷰
  Widget _buildLockedView(BuildContext context) {
    return GestureDetector(
      onTap: navigateOnTap ? () => _handleUpgradeNavigation(context) : null,
      child: Stack(
        children: [
          // 원본 콘텐츠 (블러 처리 또는 그레이스케일)
          _buildContentWithEffect(),

          // 잠금 오버레이
          _buildLockOverlay(context),
        ],
      ),
    );
  }

  /// 효과가 적용된 콘텐츠
  Widget _buildContentWithEffect() {
    switch (lockStyle) {
      case FeatureGateLockStyle.blur:
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: child,
        );

      case FeatureGateLockStyle.grayscale:
        return ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: child,
        );

      case FeatureGateLockStyle.dimmed:
        return Opacity(
          opacity: 0.3,
          child: child,
        );

      case FeatureGateLockStyle.none:
        return child;
    }
  }

  /// 잠금 오버레이
  Widget _buildLockOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 잠금 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.premiumGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  lockIcon ?? Icons.lock,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              // 잠금 메시지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lockMessage ?? '프리미엄 전용 기능',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.premiumGold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (navigateOnTap) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '탭하여 업그레이드',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 업그레이드 화면으로 이동
  void _handleUpgradeNavigation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PremiumUpgradeScreen(),
      ),
    );
  }
}

/// 잠금 스타일
enum FeatureGateLockStyle {
  /// 블러 효과
  blur,

  /// 그레이스케일
  grayscale,

  /// 어두워짐
  dimmed,

  /// 효과 없음 (오버레이만)
  none,
}

/// 프리미엄 기능 게이트 버튼
///
/// 버튼 스타일의 프리미엄 게이트입니다.
/// 무료 사용자에게는 잠금 아이콘과 함께 표시됩니다.
class FeatureGateButton extends ConsumerWidget {
  /// 버튼 텍스트
  final String text;

  /// 버튼 아이콘 (선택사항)
  final IconData? icon;

  /// 활성화 시 콜백
  final VoidCallback? onPressed;

  /// 버튼 스타일
  final ButtonStyle? style;

  const FeatureGateButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumActive = ref.watch(isPremiumActiveProvider);

    if (isPremiumActive) {
      // 프리미엄 사용자: 정상 버튼
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: style,
      );
    }

    // 무료 사용자: 잠금 버튼
    return ElevatedButton.icon(
      onPressed: () => _handleUpgradeNavigation(context),
      icon: const Icon(Icons.lock),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.premiumGold,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'PRO',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.premiumGold.withValues(alpha: 0.2),
            foregroundColor: AppColors.premiumGold,
          ),
    );
  }

  void _handleUpgradeNavigation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PremiumUpgradeScreen(),
      ),
    );
  }
}

/// 프리미엄 기능 게이트 리스트 타일
///
/// ListTile 스타일의 프리미엄 게이트입니다.
class FeatureGateListTile extends ConsumerWidget {
  /// 타이틀
  final Widget title;

  /// 서브타이틀 (선택사항)
  final Widget? subtitle;

  /// 리딩 아이콘 (선택사항)
  final Widget? leading;

  /// 탭 콜백 (프리미엄 사용자만 호출됨)
  final VoidCallback? onTap;

  const FeatureGateListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumActive = ref.watch(isPremiumActiveProvider);

    return ListTile(
      leading: leading,
      title: Row(
        children: [
          Expanded(child: title),
          if (!isPremiumActive) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.lock,
              size: 16,
              color: AppColors.premiumGold,
            ),
          ],
        ],
      ),
      subtitle: subtitle,
      trailing: !isPremiumActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.premiumGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'PRO',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: isPremiumActive ? onTap : () => _handleUpgradeNavigation(context),
    );
  }

  void _handleUpgradeNavigation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PremiumUpgradeScreen(),
      ),
    );
  }
}
