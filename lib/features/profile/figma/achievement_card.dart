// 🏅 Achievement Card Widget
//
// Displays individual achievement with progress

import 'package:flutter/material.dart';
import '../../../data/models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final UserAchievementModel? progress;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = progress?.isUnlocked ?? false;
    final progressPercentage =
        progress?.getProgressPercentage(achievement.criteria.targetValue) ?? 0.0;
    final isCloseToUnlocking =
        progress?.isCloseToUnlocking(achievement.criteria.targetValue) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: () {
          _showAchievementDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildIcon(isUnlocked),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and rarity
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? null : Colors.grey,
                                ),
                          ),
                        ),
                        _buildRarityBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUnlocked ? null : Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar (for locked achievements)
                    if (!isUnlocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Colors.grey[300],
                              color: isCloseToUnlocking ? Colors.orange : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progressPercentage * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress?.currentProgress ?? 0} / ${achievement.criteria.targetValue}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    // Unlocked date
                    if (isUnlocked && progress?.unlockedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '획득: ${_formatDate(progress!.unlockedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    // Rewards
                    if (achievement.rewards.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildRewards(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isUnlocked) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isUnlocked
            ? Color(achievement.rarityColor).withValues(alpha: 0.2)
            : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isUnlocked
            ? Icon(
                Icons.emoji_events,
                size: 32,
                color: Color(achievement.rarityColor),
              )
            : Icon(
                Icons.lock_outline,
                size: 32,
                color: Colors.grey[600],
              ),
      ),
    );
  }

  Widget _buildRarityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(achievement.rarityColor).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        achievement.rarityLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(achievement.rarityColor),
        ),
      ),
    );
  }

  Widget _buildRewards() {
    final rewards = achievement.rewards;
    final rewardWidgets = <Widget>[];

    if (rewards.containsKey('xp')) {
      rewardWidgets.add(
        _buildRewardChip(
          '⭐ +${rewards['xp']} XP',
          Colors.amber,
        ),
      );
    }

    if (rewards.containsKey('gems')) {
      rewardWidgets.add(
        _buildRewardChip(
          '💎 +${rewards['gems']} 젬',
          Colors.blue,
        ),
      );
    }

    if (rewards.containsKey('title')) {
      rewardWidgets.add(
        _buildRewardChip(
          '🏷️ ${rewards['title']}',
          Colors.purple,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: rewardWidgets,
    );
  }

  Widget _buildRewardChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Color(achievement.rarityColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(achievement.name),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            Text(
              '카테고리: ${achievement.categoryIcon}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '등급: ${achievement.rarityLabel}',
              style: TextStyle(
                color: Color(achievement.rarityColor),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '조건: ${_getCriteriaDescription()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  String _getCriteriaDescription() {
    final type = achievement.criteria.type;
    final targetValue = achievement.criteria.targetValue;

    switch (type) {
      case AchievementType.totalXP:
        return '총 $targetValue XP 획득';
      case AchievementType.streak:
        return '$targetValue일 연속 학습';
      case AchievementType.lessonsCompleted:
        return '$targetValue개 레슨 완료';
      case AchievementType.perfectScore:
        return '$targetValue번 만점 획득';
      case AchievementType.fastSolver:
        return '$targetValue번 빠른 풀이';
      case AchievementType.accuracy:
        return '정확도 $targetValue% 달성';
      case AchievementType.problemsSolved:
        return '$targetValue개 문제 풀이';
      case AchievementType.leagueRank:
        return '리그 $targetValue위 달성';
      case AchievementType.helpfulStudent:
        return '$targetValue번 도움 제공';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
