import 'package:flutter/material.dart';

/// 반응형 레이아웃 래퍼
/// 화면 크기에 따라 최대 너비를 제한하여 태블릿/웹에서도
/// 적절한 레이아웃을 유지합니다
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      ),
    );
  }
}
