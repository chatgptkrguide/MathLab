/// 💡 Hint Dialog
///
/// Shows available hints with unlock functionality

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hint_model.dart';
import '../../data/providers/hint/hint_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HintDialog extends ConsumerWidget {
  final String problemId;

  const HintDialog({
    super.key,
    required this.problemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintState = ref.watch(hintProvider(problemId));
    final userState = ref.watch(userProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '힌트',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!hintState.allHintsUnlocked) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${hintState.unlockedHints.length}/${hintState.hints.length} 잠금 해제',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: hintState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hintState.error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              hintState.error!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : hintState.hints.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '이 문제에는 힌트가 없습니다',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: hintState.hints.length,
                              itemBuilder: (context, index) {
                                final hint = hintState.hints[index];
                                final isUnlocked =
                                    ref.read(hintProvider(problemId).notifier).isHintUnlocked(hint.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildHintCard(
                                    context,
                                    ref,
                                    hint,
                                    isUnlocked,
                                    userState.user?.xp ?? 0,
                                    userState.user?.gems ?? 0,
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard(
    BuildContext context,
    WidgetRef ref,
    HintModel hint,
    bool isUnlocked,
    int userXP,
    int userGems,
  ) {
    final canAfford = hint.requiresGems
        ? userGems >= hint.gemCost!
        : userXP >= hint.xpCost;

    return Card(
      elevation: isUnlocked ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnlocked
            ? BorderSide(color: Colors.green.shade200, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Level and cost
            Row(
              children: [
                Text(
                  hint.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hint.levelDescription,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isUnlocked) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hint.requiresGems
                          ? Colors.purple.shade100
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hint.requiresGems ? Icons.diamond : Icons.star,
                          size: 16,
                          color: hint.requiresGems
                              ? Colors.purple.shade700
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hint.requiresGems
                              ? '${hint.gemCost}'
                              : '${hint.xpCost} XP',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: hint.requiresGems
                                ? Colors.purple.shade700
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Content
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hint.content,
                  style: AppTextStyles.bodyMedium,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '힌트를 잠금 해제하세요',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Unlock button
            if (!isUnlocked) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canAfford
                      ? () async {
                          final success = await ref
                              .read(hintProvider(problemId).notifier)
                              .unlockHint(hint);

                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('힌트를 잠금 해제했습니다'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ref.read(hintProvider(problemId)).error ??
                                        '힌트 잠금 해제에 실패했습니다',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  icon: Icon(
                    hint.requiresGems ? Icons.diamond : Icons.lock_open,
                    size: 18,
                  ),
                  label: Text(
                    hint.requiresGems
                        ? '${hint.gemCost} 젬으로 잠금 해제'
                        : '${hint.xpCost} XP로 잠금 해제',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canAfford ? AppColors.primary : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(height: 8),
                Text(
                  hint.requiresGems
                      ? '젬이 부족합니다 (${userGems}/${hint.gemCost})'
                      : 'XP가 부족합니다 ($userXP/${hint.xpCost})',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
