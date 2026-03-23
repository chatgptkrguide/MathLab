import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/shop_item_model.dart';
import '../../data/providers/gamification/shop_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/widgets/effects/noise_texture.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final gems = user?.gems ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          _buildHeader(context, gems),

          // Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Hearts section
                  _buildSectionLabel('하트'),
                  const SizedBox(height: 10),
                  _buildItemCard(
                    context,
                    ref,
                    ShopItem.allItems[0], // heart refill
                    gems,
                    isFeatured: true,
                  ),
                  const SizedBox(height: 10),
                  _buildItemCard(
                    context,
                    ref,
                    ShopItem.allItems[1], // heart single
                    gems,
                  ),

                  const SizedBox(height: 28),

                  // Streak section
                  _buildSectionLabel('스트릭 보호'),
                  const SizedBox(height: 10),
                  _buildItemCard(
                    context,
                    ref,
                    ShopItem.allItems[2], // streak freeze
                    gems,
                  ),

                  const SizedBox(height: 28),

                  // Booster section
                  _buildSectionLabel('부스터'),
                  const SizedBox(height: 10),
                  _buildItemCard(
                    context,
                    ref,
                    ShopItem.allItems[3], // xp boost (disabled)
                    gems,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int gems) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 28,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B5CE7), Color(0xFF5A4BD6)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Top row: back button + title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    '상점',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Gem balance display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        color: Color(0xFFFFD54F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '보유 젬',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$gems',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(24),
            ),
            child: const NoiseTexture(opacity: 0.03, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF6B5CE7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    ShopItem item,
    int currentGems, {
    bool isFeatured = false,
  }) {
    final canAfford = currentGems >= item.gemCost && item.isEnabled;
    final user = ref.watch(userProvider);
    final isHeartsFull = user?.hasFullHearts == true;

    // Disable heart items when hearts are full
    final isDisabled = !item.isEnabled ||
        (item.type == ShopItemType.heartRefill && isHeartsFull) ||
        (item.type == ShopItemType.heartSingle && isHeartsFull);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () => _showPurchaseConfirmation(context, ref, item, currentGems),
      child: Container(
        padding: EdgeInsets.all(isFeatured ? 18 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isFeatured ? 18 : 14),
          border: isFeatured
              ? Border.all(color: item.color.withValues(alpha: 0.25), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isFeatured ? 0.06 : 0.03),
              blurRadius: isFeatured ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: isFeatured ? 52 : 44,
              height: isFeatured ? 52 : 44,
              decoration: BoxDecoration(
                color: isDisabled
                    ? AppColors.disabled.withValues(alpha: 0.15)
                    : item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(isFeatured ? 14 : 12),
              ),
              child: Icon(
                item.icon,
                color: isDisabled ? AppColors.disabled : item.color,
                size: isFeatured ? 26 : 22,
              ),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: isDisabled
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      fontSize: isFeatured ? 16 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDisabled && item.type != ShopItemType.xpBoost
                        ? (isHeartsFull ? '하트가 가득 찼습니다' : item.description)
                        : item.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Price button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDisabled
                    ? AppColors.disabled.withValues(alpha: 0.12)
                    : canAfford
                        ? const Color(0xFF6B5CE7)
                        : AppColors.disabled.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.diamond_rounded,
                    size: 14,
                    color: isDisabled || !canAfford
                        ? AppColors.disabled
                        : const Color(0xFFFFD54F),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.gemCost}',
                    style: TextStyle(
                      color: isDisabled || !canAfford
                          ? AppColors.disabled
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(
    BuildContext context,
    WidgetRef ref,
    ShopItem item,
    int currentGems,
  ) {
    if (currentGems < item.gemCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('젬이 부족합니다'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
        ),
        title: Text(
          '${item.name} 구매',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: item.color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond_rounded,
                  color: Color(0xFFFFB800),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.gemCost}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(잔액: $currentGems)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success =
                  await ref.read(shopProvider.notifier).purchaseItem(item);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '${item.name} 구매 완료!'
                          : '구매에 실패했습니다',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              '구매하기',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
