// Shop item card — displays a purchasable item with icon, name, description, and gem price.
import 'package:flutter/material.dart';

import '../../../data/models/shop_item_model.dart';
import '../../../shared/constants/app_colors.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final int currentGems;
  final bool isHeartsFull;
  final bool isFeatured;
  final VoidCallback onTap;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.currentGems,
    required this.isHeartsFull,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = currentGems >= item.gemCost && item.isEnabled;

    // Disable heart items when hearts are full
    final isDisabled = !item.isEnabled ||
        (item.type == ShopItemType.heartRefill && isHeartsFull) ||
        (item.type == ShopItemType.heartSingle && isHeartsFull);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
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
                    style: const TextStyle(
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
}
