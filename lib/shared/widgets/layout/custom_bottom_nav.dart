import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

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
        height: 75 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 피그마 디자인 순서: 홈, 학습, 오답, 프로필, 학습이력
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
            icon: Icons.error_outline,
            label: '오답',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person,
            label: '프로필',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.history_edu,
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
      // 홈 탭 - GoMath 스타일 원형 버튼
      return Expanded(
        child: Center(
          child: GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                    ? AppColors.mathButtonGradient
                    : [
                        AppColors.mathButtonBlue.withValues(alpha: 0.7),
                        AppColors.mathButtonBlue.withValues(alpha: 0.6),
                      ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mathButtonBlue.withValues(alpha: isSelected ? 0.4 : 0.25),
                    blurRadius: isSelected ? 12 : 8,
                    offset: Offset(0, isSelected ? 6 : 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.1 : 1.0,
                  child: Icon(
                    icon,
                    color: AppColors.surface,
                    size: 26, // 약간 작게 조정
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
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label${isSelected ? ' 선택됨' : ''}',
        onTap: () => onTap(index),
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque, // 전체 영역 터치 가능
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48), // 접근성을 위한 최소 터치 영역
          padding: const EdgeInsets.symmetric(
            horizontal: 4.0, // 패딩 줄임
            vertical: 6.0,   // 패딩 줄임
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? _getSelectedIcon(icon) : icon,
                  color: isSelected ? AppColors.mathButtonBlue : AppColors.textSecondary.withOpacity(0.6),
                  size: 24, // 아이콘 크기 조정
                ),
              ),
              const SizedBox(height: 4), // 간격 조정
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.mathButtonBlue : AppColors.textSecondary.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11, // 폰트 크기 조정
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  IconData _getSelectedIcon(IconData defaultIcon) {
    // 선택된 상태일 때 filled 아이콘으로 변경
    switch (defaultIcon) {
      case Icons.home:
        return Icons.home;
      case Icons.school:
        return Icons.school;
      case Icons.leaderboard:
        return Icons.leaderboard;
      case Icons.error_outline:
        return Icons.error;
      case Icons.person:
        return Icons.person;
      case Icons.history_edu:
        return Icons.history_edu;
      default:
        return defaultIcon;
    }
  }
}