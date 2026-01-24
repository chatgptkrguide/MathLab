import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../data/models/models.dart';

/// 리더보드 기간 선택 탭 위젯 (Duolingo flat style)
class LeaderboardPeriodTabs extends StatelessWidget {
  final TabController tabController;

  const LeaderboardPeriodTabs({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppColors.surface, // Duolingo flat white
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.surface.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: EdgeInsets.zero,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.mathBlue, // GoMath blue text when selected
        unselectedLabelColor: AppColors.surface,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: LeaderboardPeriod.values
            .map((period) => Tab(
                  height: 44,
                  text: period.displayName,
                ))
            .toList(),
      ),
    );
  }
}
