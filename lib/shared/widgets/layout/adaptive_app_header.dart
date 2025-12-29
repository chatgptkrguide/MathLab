import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../../data/providers/user/user_provider.dart';

/// 모든 탭에서 사용할 수 있는 적응형 앱 헤더
///
/// 다양한 헤더 스타일을 지원하며, 필요에 따라 커스터마이징 가능
class AdaptiveAppHeader extends ConsumerWidget {
  /// 헤더 제목
  final String? title;

  /// 배경 색상 (단일색)
  final Color? backgroundColor;

  /// 배경 그라디언트 (단일색보다 우선)
  final List<Color>? gradientColors;

  /// 그라디언트 방향
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  /// 좌측 위젯 (뒤로가기, 메뉴 등)
  final Widget? leading;

  /// 우측 위젯들 (설정, 메시지 등)
  final List<Widget>? actions;

  /// 하단 추가 정보 위젯 (통계바, 사용자 정보 등)
  final Widget? bottomInfo;

  /// 사용자 통계 표시 여부
  final bool showUserStats;

  /// 하단 모서리 둥글게 처리 (프로필용)
  final BorderRadius? borderRadius;

  /// 패딩
  final EdgeInsetsGeometry? padding;

  /// 그림자 표시 여부
  final bool showShadow;

  /// 제목 스타일 커스터마이징
  final TextStyle? titleStyle;

  /// 제목 정렬 (기본값: center)
  final MainAxisAlignment titleAlignment;

  const AdaptiveAppHeader({
    super.key,
    this.title,
    this.backgroundColor,
    this.gradientColors,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
    this.leading,
    this.actions,
    this.bottomInfo,
    this.showUserStats = false,
    this.borderRadius,
    this.padding,
    this.showShadow = false,
    this.titleStyle,
    this.titleAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradientColors != null
            ? LinearGradient(
                begin: gradientBegin,
                end: gradientEnd,
                colors: gradientColors!,
              )
            : null,
        borderRadius: borderRadius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.mathBlue).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 바 (제목 + 버튼)
          _buildTopBar(context),

          // 사용자 통계 표시
          if (showUserStats) ...[
            const SizedBox(height: 12),
            _buildUserStats(user),
          ],

          // 커스텀 하단 정보
          if (bottomInfo != null) ...[
            const SizedBox(height: 12),
            bottomInfo!,
          ],
        ],
      ),
    );
  }

  /// 상단 바 (제목 + 좌우 버튼)
  Widget _buildTopBar(BuildContext context) {
    // 제목이 없고 leading/actions만 있는 경우
    if (title == null && (leading != null || actions != null)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading! else const SizedBox(width: 48),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      );
    }

    // 제목이 있는 경우
    return Row(
      mainAxisAlignment: titleAlignment,
      children: [
        // 좌측 버튼
        if (leading != null)
          leading!
        else if (titleAlignment == MainAxisAlignment.spaceBetween)
          const SizedBox(width: 48), // 대칭을 위한 빈 공간

        // 제목
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: titleStyle ??
                  AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.headerText,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
              textAlign: titleAlignment == MainAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
            ),
          ),

        // 우측 버튼들
        if (actions != null) ...actions!,
      ],
    );
  }

  /// 사용자 통계 바 (FigmaUserInfoBar 대체)
  Widget _buildUserStats(user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 스트릭
          _buildStatItem(
            icon: Icons.local_fire_department,
            value: '${user?.streakDays ?? 0}',
            color: AppColors.mathOrange,
          ),

          // XP
          _buildStatItem(
            icon: Icons.star,
            value: '${user?.xp ?? 0}',
            color: AppColors.mathYellow,
          ),

          // 레벨
          _buildStatItem(
            icon: Icons.emoji_events,
            value: 'Lv${user?.level ?? 1}',
            color: AppColors.mathGold,
          ),
        ],
      ),
    );
  }

  /// 통계 항목
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.headerText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
