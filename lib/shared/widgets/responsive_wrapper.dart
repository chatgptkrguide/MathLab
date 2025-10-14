import 'package:flutter/material.dart';

/// 반응형 래퍼 위젯
/// 모든 화면에서 오버플로우를 방지하기 위한 유틸리티 위젯
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool enableScroll;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.padding,
    this.enableScroll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;
    final isVerySmallScreen = screenSize.height < 400;

    Widget content = child;

    // 작은 화면에서는 자동으로 스크롤 가능하게 만들기
    if (enableScroll && (isSmallScreen || isVerySmallScreen)) {
      content = SingleChildScrollView(
        child: content,
        physics: const BouncingScrollPhysics(),
      );
    }

    // 패딩 적용
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    return content;
  }
}

/// 안전한 Column 위젯
/// 오버플로우를 방지하는 Column
class SafeColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeColumn({
    Key? key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면이 작으면 스크롤 가능한 컬럼으로 변환
    if (screenHeight < 600) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// 안전한 Row 위젯
/// 오버플로우를 방지하는 Row
class SafeRow extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeRow({
    Key? key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 화면이 좁으면 Column으로 변환
    if (screenWidth < 400) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: children.map((child) {
          if (child is Expanded || child is Flexible) {
            return child;
          }
          return child;
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// 반응형 텍스트 위젯
/// 화면 크기에 따라 텍스트 크기와 maxLines 자동 조절
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLinesLarge;
  final int? maxLinesSmall;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLinesLarge,
    this.maxLinesSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: isSmallScreen
          ? (maxLinesSmall ?? 2)
          : (maxLinesLarge ?? 3),
    );
  }
}