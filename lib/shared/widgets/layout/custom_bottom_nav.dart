import 'package:flutter/material.dart';
import '../../constants/figma_colors.dart';

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
    return Semantics(
      container: true,
      label: '하단 네비게이션',
      child: Container(
        height: 68 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          left: 1,
          right: 1,
          top: 4,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [Color(0xFF58CC02), Color(0xFF4CAF02)]
                      : [
                          FigmaColors.skyBlue.withValues(alpha: 0.85),
                          FigmaColors.skyBlue.withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: FigmaColors.skyBlue
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
                    size: 24,
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
              // 상단 인디케이터
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2.5,
                width: isSelected ? 28 : 0,
                decoration: BoxDecoration(
                  color: FigmaColors.skyBlue,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected
                      ? FigmaColors.skyBlue
                      : Colors.grey.withValues(alpha: 0.5),
                  size: isSelected ? 25 : 23,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? FigmaColors.skyBlue
                        : Colors.grey.withValues(alpha: 0.6),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: isSelected ? 10.5 : 9.5,
                    height: 1.1,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
