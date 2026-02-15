import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/layout/adaptive_app_header.dart';
import '../../data/providers/admin/admin_stats_provider.dart';
import 'widgets/admin_stat_card.dart';
import 'widgets/admin_menu_card.dart';
import 'admin_problem_list_screen.dart';
import 'units/admin_unit_list_screen.dart';
import 'achievements/admin_achievement_list_screen.dart';
import 'users/admin_user_list_screen.dart';
import 'config/admin_config_screen.dart';

/// Admin gradient colors (purple to distinguish from user screens)
const _adminGradient = [Color(0xFF9C27B0), Color(0xFF7B1FA2)];

class AdminShellScreen extends ConsumerWidget {
  const AdminShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '관리자 패널',
              gradientColors: _adminGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              titleAlignment: MainAxisAlignment.spaceBetween,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.headerText, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.headerText, size: 24),
                onPressed: () => ref.invalidate(adminStatsProvider),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats section
                    const Text(
                      '통계',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    statsAsync.when(
                      data: (stats) => GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          AdminStatCard(
                            icon: Icons.people_outline,
                            label: '사용자',
                            count: stats.userCount,
                            color: AppColors.mathBlue,
                          ),
                          AdminStatCard(
                            icon: Icons.folder_outlined,
                            label: '유닛',
                            count: stats.unitCount,
                            color: AppColors.mathGreen,
                          ),
                          AdminStatCard(
                            icon: Icons.menu_book_outlined,
                            label: '레슨',
                            count: stats.lessonCount,
                            color: AppColors.mathOrange,
                          ),
                          AdminStatCard(
                            icon: Icons.quiz_outlined,
                            label: '문제',
                            count: stats.problemCount,
                            color: AppColors.mathPurple,
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text('통계 로드 실패: $e',
                            style: const TextStyle(color: AppColors.error)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu section
                    const Text(
                      '관리 메뉴',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        AdminMenuCard(
                          icon: Icons.folder_outlined,
                          title: '유닛 관리',
                          subtitle: '유닛 생성/수정/삭제',
                          color: AppColors.mathGreen,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AdminUnitListScreen()),
                          ),
                        ),
                        AdminMenuCard(
                          icon: Icons.quiz_outlined,
                          title: '문제 관리',
                          subtitle: '문제 생성/수정/삭제',
                          color: AppColors.mathPurple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AdminProblemListScreen()),
                          ),
                        ),
                        AdminMenuCard(
                          icon: Icons.emoji_events_outlined,
                          title: '업적 관리',
                          subtitle: '업적 생성/수정/삭제',
                          color: AppColors.mathOrange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AdminAchievementListScreen()),
                          ),
                        ),
                        AdminMenuCard(
                          icon: Icons.people_outline,
                          title: '사용자 관리',
                          subtitle: '사용자 조회/역할 변경',
                          color: AppColors.mathBlue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AdminUserListScreen()),
                          ),
                        ),
                        AdminMenuCard(
                          icon: Icons.settings_outlined,
                          title: '앱 설정',
                          subtitle: '앱 설정 관리',
                          color: AppColors.textSecondary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AdminConfigScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
