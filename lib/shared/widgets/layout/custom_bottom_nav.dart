import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 피그마 디자인 하단 네비게이션 바
/// 5탭: 학습(0), 오답(1), Home(2, 가운데 강조), 프로필(3), 학습이력(4)
class CustomBottomNavigation extends StatelessWidget {
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
        height: 68 + bottomPadding,
        padding: EdgeInsets.only(
          left: 1,
          right: 1,
          top: 4,
          bottom: bottomPadding + 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: AppColors.borderLight,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
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
              icon: Icons.error_outline_rounded,
              label: '오답',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.home_rounded,
              label: 'Home',
              isSpecial: true,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: '프로필',
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.history_rounded,
              label: '학습이력',
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
        child: Center(
          child: GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [AppColors.mathGreen, AppColors.mathGreenDark]
                      : [
                          AppColors.skyBlue.withValues(alpha: 0.85),
                          AppColors.skyBlue.withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.skyBlue
                        .withValues(alpha: isSelected ? 0.35 : 0.2),
                    blurRadius: isSelected ? 10 : 6,
                    offset: Offset(0, isSelected ? 4 : 3),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.05 : 1.0,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isSelected ? 26 : 24,
                  ),
                ),
              ),
            ),
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
              // Pill-shaped background indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.skyBlue.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.skyBlue
                      : AppColors.textTertiary,
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.skyBlue
                        : AppColors.textTertiary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: isSelected ? 12 : 11,
                    height: 1.1,
                    letterSpacing: 0.2,
                  ),
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
