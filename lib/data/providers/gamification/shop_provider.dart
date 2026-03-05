import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/shop_item_model.dart';
import '../user/user_provider.dart';
import '../../../core/utils/app_logger.dart';

enum ShopStatus { idle, purchasing, success, error }

class ShopState {
  final ShopStatus status;
  final String? message;

  const ShopState({this.status = ShopStatus.idle, this.message});

  ShopState copyWith({ShopStatus? status, String? message}) {
    return ShopState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref ref;

  ShopNotifier(this.ref) : super(const ShopState());

  Future<bool> purchaseItem(ShopItem item) async {
    if (!item.isEnabled) return false;

    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);
    if (user == null) return false;

    if (user.gems < item.gemCost) {
      state = const ShopState(
        status: ShopStatus.error,
        message: 'Not enough gems',
      );
      return false;
    }

    state = const ShopState(status: ShopStatus.purchasing);

    try {
      final spent = await userNotifier.spendGems(item.gemCost);
      if (!spent) {
        state = const ShopState(
          status: ShopStatus.error,
          message: 'Failed to spend gems',
        );
        return false;
      }

      switch (item.type) {
        case ShopItemType.heartRefill:
          await userNotifier.refillHearts();
          break;

        case ShopItemType.heartSingle:
          final currentHearts = ref.read(userProvider)?.hearts ?? 0;
          final maxHearts = ref.read(userProvider)?.maxHearts ?? 5;
          if (currentHearts < maxHearts) {
            await userNotifier.updateHearts(currentHearts + 1);
          }
          break;

        case ShopItemType.streakFreeze:
          await _addStreakFreeze(user.uid);
          break;

        case ShopItemType.xpBoost:
          break;
      }

      state = const ShopState(status: ShopStatus.success);
      AppLogger.info('Purchase successful', tag: 'Shop', data: {'item': item.id});
      return true;
    } catch (e, st) {
      AppLogger.error('Purchase failed', tag: 'Shop', error: e, stackTrace: st);
      state = const ShopState(
        status: ShopStatus.error,
        message: 'Purchase failed',
      );
      return false;
    }
  }

  Future<void> _addStreakFreeze(String uid) async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final newFreezes = user.streakFreezes + 1;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'streakFreezes': newFreezes,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Update local state via userProvider reload
    await ref.read(userProvider.notifier).loadUser(uid);
  }

  void resetStatus() {
    state = const ShopState();
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});
