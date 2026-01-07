import 'package:flutter/material.dart';
import '../../constants/duolingo_styles.dart';

/// 듀오링고 스타일 3D 카드 위젯
///
/// 3D 그림자, 그라디언트, 상단 하이라이트를 포함한 재사용 가능한 카드 컴포넌트
class DuolingoCard extends StatelessWidget {
  /// 카드 내부 콘텐츠
  final Widget child;

  /// 카드 색상 테마
  final DuolingoCardTheme theme;

  /// 카드 패딩
  final EdgeInsets? padding;

  /// 클릭 이벤트 핸들러
  final VoidCallback? onTap;

  /// 카드 border radius (기본값: 16)
  final double? borderRadius;

  /// 카드 외부 여백
  final EdgeInsets? margin;

  const DuolingoCard({
    super.key,
    required this.child,
    this.theme = DuolingoCardTheme.blue,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? DuolingoStyles.cardBorderRadius;
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
          vertical: DuolingoStyles.cardPaddingVertical,
          horizontal: DuolingoStyles.cardPaddingHorizontal,
        );

    Widget cardContent = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        boxShadow: _getBoxShadow(),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: _getGradient(),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          border: Border.all(
            color: _getBorderColor(),
            width: DuolingoStyles.cardBorderWidth,
          ),
        ),
        child: Stack(
          children: [
            // 상단 하이라이트
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: DuolingoStyles.highlightHeight,
                decoration: DuolingoStyles.topHighlight,
              ),
            ),
            // 카드 내용
            child,
          ],
        ),
      ),
    );

    // 클릭 가능한 경우 GestureDetector로 래핑
    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    // 마진 적용
    if (margin != null) {
      cardContent = Padding(
        padding: margin!,
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// 테마에 따른 그림자 반환
  List<BoxShadow> _getBoxShadow() {
    switch (theme) {
      case DuolingoCardTheme.green:
        return DuolingoStyles.greenShadow;
      case DuolingoCardTheme.blue:
        return DuolingoStyles.blueShadow;
      case DuolingoCardTheme.white:
        return DuolingoStyles.whiteShadow;
    }
  }

  /// 테마에 따른 그라디언트 반환
  Gradient _getGradient() {
    switch (theme) {
      case DuolingoCardTheme.green:
        return DuolingoStyles.greenBackgroundGradient;
      case DuolingoCardTheme.blue:
        return DuolingoStyles.blueBackgroundGradient;
      case DuolingoCardTheme.white:
        return DuolingoStyles.whiteGradient;
    }
  }

  /// 테마에 따른 border 색상 반환
  Color _getBorderColor() {
    switch (theme) {
      case DuolingoCardTheme.green:
        return DuolingoStyles.duolingoGreenBorder;
      case DuolingoCardTheme.blue:
        return DuolingoStyles.duoBlueBorder;
      case DuolingoCardTheme.white:
        return Colors.grey.shade200;
    }
  }
}

/// 듀오링고 카드 테마 타입
enum DuolingoCardTheme {
  /// 그린 테마 (듀오링고 메인 컬러)
  green,

  /// 블루 테마
  blue,

  /// 화이트 테마
  white,
}
