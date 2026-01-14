import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// 공통 앱 헤더 위젯
///
/// 앱 전체에서 사용되는 통일된 헤더 디자인
/// - 그라데이션 배경
/// - 둥근 하단 모서리
/// - 다양한 레이아웃 옵션 지원
class CommonAppHeader extends StatelessWidget {
  /// 헤더 제목
  final String title;

  /// 우측에 표시할 액션 위젯들
  final List<Widget>? actions;

  /// 좌측에 표시할 위젯 (일반적으로 뒤로가기 또는 메뉴 버튼)
  final Widget? leading;

  /// 제목을 중앙에 배치할지 여부 (기본값: true)
  final bool centerTitle;

  /// 아이콘을 제목 앞에 표시
  final IconData? icon;

  /// 아이콘 색상
  final Color? iconColor;

  /// 아이콘 크기
  final double iconSize;

  const CommonAppHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.icon,
    this.iconColor,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.headerBlueGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (centerTitle) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const Spacer(),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.mathYellow,
              size: iconSize,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.headerText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...[
            const Spacer(),
            ...actions!,
          ] else if (leading != null)
            const SizedBox(width: 48), // 대칭을 위한 빈 공간
        ],
      );
    }

    // centerTitle이 false인 경우
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leading != null) leading!,
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? AppColors.mathYellow,
                  size: iconSize,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.headerText,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (actions != null) ...actions! else const SizedBox(width: 48),
      ],
    );
  }
}

/// 메뉴 버튼이 있는 공통 헤더
///
/// 좌측에 메뉴 아이콘이 있고 중앙에 제목이 있는 헤더
class CommonAppHeaderWithMenu extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;

  const CommonAppHeaderWithMenu({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.icon,
    this.iconColor,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return CommonAppHeader(
      title: title,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: AppColors.headerText,
          size: 28,
        ),
        onPressed: onMenuPressed ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('메뉴 기능 준비 중입니다'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

/// 뒤로가기 버튼이 있는 공통 헤더
///
/// 좌측에 뒤로가기 버튼이 있고 중앙에 제목이 있는 헤더
class CommonAppHeaderWithBack extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;

  const CommonAppHeaderWithBack({
    super.key,
    required this.title,
    this.onBackPressed,
    this.icon,
    this.iconColor,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return CommonAppHeader(
      title: title,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.headerText,
          size: 28,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
