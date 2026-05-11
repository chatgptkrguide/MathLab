import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/shop_item_model.dart';
import '../../data/providers/gamification/shop_provider.dart';
import '../../data/providers/user/user_provider.dart';
import '../../shared/constants/app_colors.dart';
import 'widgets/shop_header.dart';
import 'widgets/shop_item_card.dart';
import 'widgets/shop_purchase_dialog.dart';
import 'widgets/shop_section_label.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final gems = user?.gems ?? 0;
    final isHeartsFull = user?.hasFullHearts == true;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          ShopHeader(gems: gems),

          // Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Hearts section
                  const ShopSectionLabel(title: '하트'),
                  const SizedBox(height: 10),
                  _itemCard(
                    context,
                    ref,
                    ShopItem.allItems[0], // heart refill
                    gems,
                    isHeartsFull: isHeartsFull,
                    isFeatured: true,
                  ),
                  const SizedBox(height: 10),
                  _itemCard(
                    context,
                    ref,
                    ShopItem.allItems[1], // heart single
                    gems,
                    isHeartsFull: isHeartsFull,
                  ),

                  const SizedBox(height: 28),

                  // Streak section
                  const ShopSectionLabel(title: '스트릭 보호'),
                  const SizedBox(height: 10),
                  _itemCard(
                    context,
                    ref,
                    ShopItem.allItems[2], // streak freeze
                    gems,
                    isHeartsFull: isHeartsFull,
                  ),

                  const SizedBox(height: 28),

                  // Booster section
                  const ShopSectionLabel(title: '부스터'),
                  const SizedBox(height: 10),
                  _itemCard(
                    context,
                    ref,
                    ShopItem.allItems[3], // xp boost (disabled)
                    gems,
                    isHeartsFull: isHeartsFull,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(
    BuildContext context,
    WidgetRef ref,
    ShopItem item,
    int currentGems, {
    required bool isHeartsFull,
    bool isFeatured = false,
  }) {
    return ShopItemCard(
      item: item,
      currentGems: currentGems,
      isHeartsFull: isHeartsFull,
      isFeatured: isFeatured,
      onTap: () => showShopPurchaseDialog(
        context: context,
        item: item,
        currentGems: currentGems,
        onPurchase: () => ref.read(shopProvider.notifier).purchaseItem(item),
      ),
    );
  }
}
