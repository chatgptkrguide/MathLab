import 'package:flutter/material.dart';
import '../constants/figma_colors.dart';

/// Figma 디자인 통일 상단 바
/// 모든 페이지에서 일관된 디자인 유지
class FigmaTopBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final bool showSettings;
  final VoidCallback? onSettingsPressed;

  // 확장된 헤더 옵션
  final String? userName;
  final int? streakDays;
  final int? gems;
  final String? userLevel;
  final bool showExpandedHeader;

  const FigmaTopBar({
    super.key,
    this.title = '',
    this.showBackButton = false,
    this.onBackPressed,
    this.trailing,
    this.showSettings = false,
    this.onSettingsPressed,
    this.userName,
    this.streakDays,
    this.gems,
    this.userLevel,
    this.showExpandedHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showExpandedHeader) {
      return _buildExpandedHeader(context);
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: FigmaColors.profileTopBarGradient,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽: 뒤로가기 또는 메뉴
          SizedBox(
            width: 40,
            height: 40,
            child: showBackButton
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    padding: EdgeInsets.zero,
                  ),
          ),

          // 중앙: 제목 또는 로고
          Expanded(
            child: Center(
              child: title.isNotEmpty
                  ? Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GoMATH',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
            ),
          ),

          // 오른쪽: GoMATH 로고 또는 설정 또는 trailing
          SizedBox(
            width: 120,
            height: 40,
            child: trailing ??
                (showSettings
                    ? IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: onSettingsPressed ?? () {},
                        padding: EdgeInsets.zero,
                      )
                    : Image.asset(
                        'assets/icons/gomath_logo.png',
                        height: 44,
                        fit: BoxFit.contain,
                      )),
          ),
        ],
      ),
    );
  }

  /// 확장된 헤더 (이름, 불, 보석, 레벨 포함)
  Widget _buildExpandedHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: FigmaColors.profileTopBarGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 첫 번째 줄: 메뉴 + 인사말/이름 + 연속일
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 메뉴 버튼
              IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),

              // 중앙: 인사말 및 이름
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '안녕하세요!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName != null ? '$userName의 수학 학습' : '수학 학습',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽: 연속일 (불 아이콘)
              if (streakDays != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$streakDays',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 두 번째 줄: 보석, 레벨
          Row(
            children: [
              // 보석
              if (gems != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '💎',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$gems',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              if (gems != null && userLevel != null) const SizedBox(width: 12),

              // 레벨
              if (userLevel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '⭐',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        userLevel!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
