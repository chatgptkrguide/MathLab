// 💎 Premium Subscription Providers
//
// Providers for premium subscription state management,
// in-app purchases, and trial management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription/premium_tier.dart';

/// 구독 서비스
class SubscriptionService {
  /// 무료 체험 시작
  Future<void> startFreeTrial(String userId, String platform) async {
    // TODO: 실제 구독 서비스 API 연동
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 구독 상태 확인
  Future<bool> checkSubscriptionStatus(String userId) async {
    // TODO: 실제 구독 상태 확인 API 연동
    return false;
  }

  /// 구독 취소
  Future<void> cancelSubscription(String userId) async {
    // TODO: 실제 구독 취소 API 연동
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 무료 체험 가능 여부 확인
  Future<bool> canStartTrial(String userId) async {
    // TODO: 실제 체험 가능 여부 확인 API 연동
    return true;
  }
}

/// 인앱 구매 서비스
class InAppPurchaseService {
  /// 구독 구매
  Future<void> purchaseSubscription({
    required String userId,
    required PremiumTier tier,
    required void Function(bool success, String? error) onComplete,
  }) async {
    try {
      // TODO: 실제 인앱 구매 연동 (Google Play / App Store)
      await Future.delayed(const Duration(seconds: 1));

      onComplete(true, null);
    } catch (e) {
      onComplete(false, e.toString());
    }
  }

  /// 구매 복원
  Future<void> restorePurchases({
    required String userId,
    required void Function(bool success, String? error) onComplete,
  }) async {
    try {
      // TODO: 실제 구매 복원 연동
      await Future.delayed(const Duration(seconds: 1));

      onComplete(true, null);
    } catch (e) {
      onComplete(false, e.toString());
    }
  }
}

/// 구독 서비스 Provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// 프리미엄 활성 여부 Provider
final isPremiumActiveProvider = Provider<bool>((ref) {
  // TODO: 실제 구독 상태 확인 로직
  return false;
});

/// 무료 체험 가능 여부 Provider
final canStartTrialProvider = Provider<bool>((ref) {
  // TODO: 실제 체험 가능 여부 확인 로직
  return true;
});

/// 인앱 구매 서비스 Provider
final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((ref) {
  return InAppPurchaseService();
});
