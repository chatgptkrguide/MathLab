import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 하단 네비게이션 바
/// 5탭: 학습(0), 오답(1), 홈(2, 가운데 강조), 프로필(3), 팀(4)
class CustomBottomNavigation extends StatelessWidget {
  /// 코치마크에서 참조할 GlobalKey
  static final bottomNavKey = GlobalKey(debugLabel: 'bottomNav');

  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Semantics(
      container: true,
      label: '하단 네비게이션',
      child: Container(
        key: bottomNavKey,
        height: 60 + bottomPadding,
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: 0,
          bottom: bottomPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFEEEEEE),
              width: 0.2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 28,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.school_rounded,
              label: '학습',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.star_border_rounded,
              label: '오답',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.home_rounded,
              label: '홈',
              isSpecial: true,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: '프로필',
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.groups_rounded,
              label: '팀',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isSpecial = false,
  }) {
    final isSelected = currentIndex == index;

    if (isSpecial) {
      return Expanded(
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.nodeActive,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8925CF)
                          .withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isSelected ? 24 : 22,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.nodeActive
                      : AppColors.textLight,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 10,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.mathBlue
                    : AppColors.textLight,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF030204)
                      : AppColors.textLight,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 10,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
