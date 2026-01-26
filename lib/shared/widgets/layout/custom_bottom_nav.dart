import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 커스텀 하단 네비게이션 바
/// 새 디자인에 맞게 홈 탭이 둥근 원형으로 구현
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
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 새로운 순서: 홈, 학습, 리그(가운데), 오답, 프로필
            _buildNavItem(
              index: 0,
              icon: Icons.home,
              label: '홈',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.school,
              label: '학습',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.emoji_events,
              label: '리그',
              isSpecial: true, // 리그 탭을 특별하게 표시 (게이미피케이션 강조)
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.error_outline,
              label: '오답',
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person,
              label: '프로필',
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
      // 홈 탭 - GoMath 스타일 원형 버튼
      return Expanded(
        child: Center(
          child: GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [Color(0xFF58CC02), Color(0xFF4CAF02)]
                      : [
                          AppColors.mathButtonBlue.withValues(alpha: 0.75),
                          AppColors.mathButtonBlue.withValues(alpha: 0.65),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mathButtonBlue
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
                    color: AppColors.surface,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 일반 네비게이션 아이템 (플렉서블 디자인으로 오버플로우 방지)
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: 4.0,
              vertical: 4.0,
            ),
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
                    color: AppColors.mathButtonBlue,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? _getSelectedIcon(icon) : icon,
                    color: isSelected
                        ? AppColors.mathButtonBlue
                        : AppColors.textSecondary.withValues(alpha: 0.65),
                    size: isSelected ? 25 : 23,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.mathButtonBlue
                          : AppColors.textSecondary.withValues(alpha: 0.75),
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

  IconData _getSelectedIcon(IconData defaultIcon) {
    // 선택된 상태일 때 filled 아이콘으로 변경
    switch (defaultIcon) {
      case Icons.home:
        return Icons.home_rounded;
      case Icons.school:
        return Icons.school_rounded;
      case Icons.leaderboard:
        return Icons.leaderboard_rounded;
      case Icons.error_outline:
        return Icons.error_rounded;
      case Icons.person:
        return Icons.person_rounded;
      case Icons.emoji_events:
        return Icons.emoji_events_rounded;
      case Icons.history_edu:
        return Icons.history_edu_rounded;
      default:
        return defaultIcon;
    }
  }
}
