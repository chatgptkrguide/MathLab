import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/layout/adaptive_app_header.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/providers/admin/admin_achievement_provider.dart';
import 'admin_achievement_form_screen.dart';

class AdminAchievementListScreen extends ConsumerStatefulWidget {
  const AdminAchievementListScreen({super.key});

  @override
  ConsumerState<AdminAchievementListScreen> createState() =>
      _AdminAchievementListScreenState();
}

class _AdminAchievementListScreenState
    extends ConsumerState<AdminAchievementListScreen> {
  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(adminAchievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdaptiveAppHeader(
              title: '업적 관리',
              gradientColors: AppColors.adminGradient,
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
            ),
            Expanded(
              child: achievementsAsync.when(
                data: (achievements) => achievements.isEmpty
                    ? _buildEmptyState()
                    : _buildAchievementList(achievements),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('오류: $e',
                      style: const TextStyle(color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(null),
        backgroundColor: AppColors.mathGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminAchievementsProvider);
      },
      child: ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 64, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text(
                  '업적이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '+ 버튼을 눌러 새 업적을 추가하세요',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<AchievementModel> achievements) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminAchievementsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _AdminAchievementCard(
            achievement: achievement,
            onEdit: () => _navigateToForm(achievement),
            onDelete: () => _confirmDelete(achievement),
          );
        },
      ),
    );
  }

  Future<void> _navigateToForm(AchievementModel? achievement) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAchievementFormScreen(achievement: achievement),
      ),
    );
    if (result == true) {
      ref.invalidate(adminAchievementsProvider);
    }
  }

  Future<void> _confirmDelete(AchievementModel achievement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('업적 삭제'),
        content: Text('이 업적을 삭제하시겠습니까?\n\n"${achievement.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.mathRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(adminAchievementNotifierProvider.notifier)
            .deleteAchievement(achievement.id, achievement.iconUrl);
        ref.invalidate(adminAchievementsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('업적이 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }
}

class _AdminAchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminAchievementCard({
    required this.achievement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Name row
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(achievement.rarityColor)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      achievement.categoryIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Chips row
              Row(
                children: [
                  _buildChip(
                    _categoryLabel(achievement.category),
                    AppColors.mathBlue,
                  ),
                  const SizedBox(width: 6),
                  _buildChip(
                    achievement.rarityLabel,
                    Color(achievement.rarityColor),
                  ),
                  const SizedBox(width: 6),
                  _buildChip(
                    _criteriaTypeLabel(achievement.criteria.type),
                    AppColors.mathOrange,
                  ),
                  const SizedBox(width: 6),
                  _buildChip(
                    '목표: ${achievement.criteria.targetValue}',
                    AppColors.mathPurple,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.mathBlue,
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.mathRed,
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _categoryLabel(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.general:
        return '일반';
      case AchievementCategory.streak:
        return '연속학습';
      case AchievementCategory.mastery:
        return '숙달';
      case AchievementCategory.social:
        return '소셜';
      case AchievementCategory.speed:
        return '속도';
      case AchievementCategory.perfectionist:
        return '완벽주의';
      case AchievementCategory.explorer:
        return '탐험가';
    }
  }

  String _criteriaTypeLabel(AchievementType type) {
    switch (type) {
      case AchievementType.totalXP:
        return '총 XP';
      case AchievementType.streak:
        return '연속학습';
      case AchievementType.lessonsCompleted:
        return '레슨 완료';
      case AchievementType.perfectScore:
        return '만점';
      case AchievementType.fastSolver:
        return '빠른 풀이';
      case AchievementType.accuracy:
        return '정확도';
      case AchievementType.problemsSolved:
        return '문제 풀기';
      case AchievementType.leagueRank:
        return '리그 순위';
      case AchievementType.helpfulStudent:
        return '도움';
    }
  }
}
