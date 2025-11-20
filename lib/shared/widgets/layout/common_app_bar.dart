import 'package:flutter/material.dart';

/// 모든 페이지에서 사용하는 공통 상단 바
/// 디자인 일관성을 위해 통일된 스타일 제공
class CommonAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // 좌측 버튼 (뒤로가기 or 커스텀 leading)
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else if (leading != null)
              leading!
            else
              const SizedBox(width: 28),

            const Spacer(),

            // 중앙 타이틀
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const Spacer(),

            // 우측 액션 버튼들
            if (actions != null)
              ...actions!
            else
              const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}
