import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// 헤더에서 사용되는 아이콘 버튼 (뒤로가기, 메뉴, 설정 등)
///
/// 모든 탭의 헤더 버튼 스타일을 통일하기 위한 공통 위젯
class HeaderIconButton extends StatelessWidget {
  /// 아이콘
  final IconData icon;

  /// 탭 콜백
  final VoidCallback onPressed;

  /// 배경 색상 (기본값: 반투명 흰색)
  final Color? backgroundColor;

  /// 테두리 표시 여부 (기본값: true)
  final bool showBorder;

  /// 아이콘 색상 (기본값: 흰색)
  final Color? iconColor;

  /// 아이콘 크기 (기본값: 24)
  final double iconSize;

  /// 패딩 (기본값: 8)
  final double padding;

  /// 접근성 레이블
  final String? semanticLabel;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.showBorder = true,
    this.iconColor,
    this.iconSize = 24,
    this.padding = 8,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.headerButtonBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: showBorder
                ? Border.all(
                    color: AppColors.headerButtonBorder,
                    width: 1.5,
                  )
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.headerText,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
