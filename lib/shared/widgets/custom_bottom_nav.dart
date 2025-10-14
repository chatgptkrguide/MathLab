import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 커스텀 하단 네비게이션 바
/// 새 디자인에 맞게 홈 탭이 둥근 원형으로 구현
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
        top: AppDimensions.paddingL,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF5F5F5)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          // 홈을 중앙에 특별 배치
          _buildNavItem(
            index: 0,
            icon: Icons.home,
            label: '홈',
            isSpecial: true,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.history,
            label: '이력',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.person,
            label: '프로필',
          ),
        ],
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
      // 홈 탭 - 깔끔한 현대적 디자인
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
                    ? [
                        const Color(0xFF6C63FF),
                        const Color(0xFF5A52E5),
                      ]
                    : [
                        const Color(0xFF8B85FF),
                        const Color(0xFF7B74F0),
                      ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(isSelected ? 0.4 : 0.25),
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
                    color: Colors.white,
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
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque, // 전체 영역 터치 가능
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 4.0, // 패딩 줄임
            vertical: 8.0,   // 패딩 줄임
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(6.0), // 패딩 줄임
                  decoration: isSelected
                      ? BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        )
                      : null,
                  child: Icon(
                    isSelected ? _getSelectedIcon(icon) : icon,
                    color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                    size: 20, // 아이콘 크기 고정
                  ),
                ),
              ),
              const SizedBox(height: 2), // 간격 줄임
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 10, // 폰트 크기 줄임
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
        return Icons.home;
      case Icons.school:
        return Icons.school;
      case Icons.error_outline:
        return Icons.error;
      case Icons.history:
        return Icons.history;
      case Icons.person:
        return Icons.person;
      default:
        return defaultIcon;
    }
  }
}