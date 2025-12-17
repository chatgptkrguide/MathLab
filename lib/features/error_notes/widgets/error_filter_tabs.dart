import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';

/// 오답 노트 필터 탭 위젯
///
/// 오답 노트를 복습 횟수별로 필터링하는 탭
/// - errors_screen과 wrong_answer_screen에서 공통 사용
/// - GoMath flat style 디자인
/// - 탭: 전체, 미복습, 1회, 2회+
class ErrorFilterTabs extends StatelessWidget {
  final TabController controller;
  final List<String> filterTabs;
  final VoidCallback? onTabChanged;

  const ErrorFilterTabs({
    super.key,
    required this.controller,
    this.filterTabs = const ['전체', '미복습', '1회', '2회+'],
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.spacingM,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXS),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
        tabs: filterTabs.map((tab) => Tab(height: 40, text: tab)).toList(),
        labelColor: AppColors.mathBlue,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        indicatorPadding: const EdgeInsets.all(0),
        onTap: (_) {
          onTabChanged?.call();
        },
      ),
    );
  }
}
