// 💎 Premium Subscription Providers
//
// Firestore-based premium subscription state management,
// trial management, and subscription status checking.
// In-App Purchase (Google Play / App Store) integration via IapService.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/subscription/premium_tier.dart';
import '../../services/iap_service.dart';
import '../infrastructure/firebase_providers.dart';
// user_provider not directly imported; user UID comes via currentUserProvider

// ========================================
// Subscription State
// ========================================

/// Premium subscription state
class PremiumState {
  final bool isPremium;
  final PremiumTier tier;
  final DateTime? expiresAt;
  final DateTime? trialStartedAt;
  final bool isLoading;

  const PremiumState({
    this.isPremium = false,
    this.tier = PremiumTier.free,
    this.expiresAt,
    this.trialStartedAt,
    this.isLoading = true,
  });

  /// Whether the subscription is currently active (not expired)
  bool get isActive {
    if (!isPremium) return false;
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }

  /// Whether the user has never started a trial
  bool get canStartTrial => trialStartedAt == null;

  /// Whether the user is on a trial (started trial and it hasn't expired)
  bool get isOnTrial {
    if (trialStartedAt == null) return false;
    if (expiresAt == null) return false;
    return isActive;
  }

  /// Days remaining until expiration
  int get daysRemaining {
    if (expiresAt == null) return 0;
    final diff = expiresAt!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  PremiumState copyWith({
    bool? isPremium,
    PremiumTier? tier,
    DateTime? expiresAt,
    DateTime? trialStartedAt,
    bool? isLoading,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      tier: tier ?? this.tier,
      expiresAt: expiresAt ?? this.expiresAt,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ========================================
// Subscription Service
// ========================================

/// Firestore-based subscription service
class SubscriptionService {
  final FirebaseFirestore _firestore;

  SubscriptionService(this._firestore);

  /// Get the user document reference
  DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  /// Start a 7-day free trial
  Future<void> startFreeTrial(String userId, String platform) async {
    try {
      AppLogger.info('Starting free trial', tag: 'Premium', data: {
        'userId': userId,
        'platform': platform,
      });

      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 7));

      await _userDoc(userId).update({
        'isPremium': true,
        'premiumTier': PremiumTier.monthly.name,
        'premiumExpiresAt': Timestamp.fromDate(trialEnd),
        'trialStartedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      AppLogger.info('Free trial started successfully', tag: 'Premium', data: {
        'expiresAt': trialEnd.toIso8601String(),
      });
    } catch (e, st) {
      AppLogger.error('Failed to start free trial',
          tag: 'Premium', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Check subscription status from Firestore
  Future<PremiumState> checkSubscriptionStatus(String userId) async {
    try {
      AppLogger.info('Checking subscription status', tag: 'Premium');

      final doc = await _userDoc(userId).get();
      if (!doc.exists) {
        return const PremiumState(isLoading: false);
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return const PremiumState(isLoading: false);
      }

      final isPremium = data['isPremium'] as bool? ?? false;
      final tierStr = data['premiumTier'] as String?;
      final expiresAtTs = data['premiumExpiresAt'] as Timestamp?;
      final trialStartedAtTs = data['trialStartedAt'] as Timestamp?;

      PremiumTier tier = PremiumTier.free;
      if (tierStr != null) {
        tier = PremiumTier.values.firstWhere(
          (t) => t.name == tierStr,
          orElse: () => PremiumTier.free,
        );
      }

      final expiresAt = expiresAtTs?.toDate();
      final trialStartedAt = trialStartedAtTs?.toDate();

      // Auto-deactivate if expired
      if (isPremium && expiresAt != null && expiresAt.isBefore(DateTime.now())) {
        await _userDoc(userId).update({
          'isPremium': false,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });

        return PremiumState(
          isPremium: false,
          tier: tier,
          expiresAt: expiresAt,
          trialStartedAt: trialStartedAt,
          isLoading: false,
        );
      }

      return PremiumState(
        isPremium: isPremium,
        tier: tier,
        expiresAt: expiresAt,
        trialStartedAt: trialStartedAt,
        isLoading: false,
      );
    } catch (e, st) {
      AppLogger.error('Failed to check subscription status',
          tag: 'Premium', error: e, stackTrace: st);
      return const PremiumState(isLoading: false);
    }
  }

  /// Cancel subscription (sets isPremium to false)
  Future<void> cancelSubscription(String userId) async {
    try {
      AppLogger.info('Cancelling subscription', tag: 'Premium');

      await _userDoc(userId).update({
        'isPremium': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      AppLogger.info('Subscription cancelled successfully', tag: 'Premium');
    } catch (e, st) {
      AppLogger.error('Failed to cancel subscription',
          tag: 'Premium', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Check if user can start a trial (never tried before)
  Future<bool> canStartTrial(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists) return true;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return true;

      return data['trialStartedAt'] == null;
    } catch (e, st) {
      AppLogger.error('Failed to check trial eligibility',
          tag: 'Premium', error: e, stackTrace: st);
      return false;
    }
  }

  /// Activate a paid subscription
  Future<void> activateSubscription(String userId, PremiumTier tier) async {
    try {
      AppLogger.info('Activating subscription', tag: 'Premium', data: {
        'tier': tier.name,
      });

      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: tier.durationDays));

      await _userDoc(userId).update({
        'isPremium': true,
        'premiumTier': tier.name,
        'premiumExpiresAt': Timestamp.fromDate(expiresAt),
        'updatedAt': Timestamp.fromDate(now),
      });

      AppLogger.info('Subscription activated', tag: 'Premium');
    } catch (e, st) {
      AppLogger.error('Failed to activate subscription',
          tag: 'Premium', error: e, stackTrace: st);
      rethrow;
    }
  }
}

// ========================================
// In-App Purchase Service (Store Integration)
// ========================================

/// In-app purchase service with real store integration
///
/// IapService를 래핑하여 구매 결과를 Firestore에 반영합니다.
/// - 스토어 상품이 로드된 경우: 실제 IAP 결제 흐름
/// - 스토어 상품이 없는 경우 (개발/테스트): Firestore 직접 활성화 폴백
class InAppPurchaseService {
  final SubscriptionService _subscriptionService;
  final IapService _iapService;

  InAppPurchaseService(this._subscriptionService, this._iapService);

  /// IAP 서비스 접근 (UI에서 상품 정보 표시용)
  IapService get iapService => _iapService;

  /// Purchase subscription via store or fallback
  Future<void> purchaseSubscription({
    required String userId,
    required PremiumTier tier,
    required void Function(bool success, String? error) onComplete,
  }) async {
    try {
      // IAP 서비스가 사용 가능하고 상품이 로드된 경우 실제 결제
      if (_iapService.isAvailable && _iapService.products.isNotEmpty) {
        final product = _iapService.getProductForTier(tier);

        if (product != null) {
          // 구매 결과 콜백 설정
          _iapService.onPurchaseResult = (success, productId, error) {
            if (success && productId != null) {
              // 구매 성공 -> Firestore에 구독 활성화
              _subscriptionService
                  .activateSubscription(userId, tier)
                  .then((_) => onComplete(true, null))
                  .catchError((e) => onComplete(false, e.toString()));
            } else {
              onComplete(false, error ?? 'Purchase failed');
            }
          };

          // 스토어 결제 흐름 시작
          final initiated = await _iapService.purchaseProduct(product);
          if (!initiated) {
            onComplete(false, 'Failed to initiate purchase');
          }
          // 결과는 onPurchaseResult 콜백으로 전달됨
          return;
        }

        AppLogger.warning(
          'Product not found for tier ${tier.name}, falling back to direct activation',
          tag: 'IAP',
        );
      }

      // 폴백: Firestore 직접 활성화 (개발/테스트 환경)
      AppLogger.info(
        'Using fallback direct activation for tier ${tier.name}',
        tag: 'IAP',
      );
      await _subscriptionService.activateSubscription(userId, tier);
      onComplete(true, null);
    } catch (e) {
      onComplete(false, e.toString());
    }
  }

  /// Restore purchases from store
  Future<void> restorePurchases({
    required String userId,
    required void Function(bool success, String? error) onComplete,
  }) async {
    try {
      if (_iapService.isAvailable) {
        // 구매 복원 결과 콜백 설정
        _iapService.onPurchaseResult = (success, productId, error) {
          if (success && productId != null) {
            // 복원 성공 -> productId로 tier 판별하여 Firestore 업데이트
            final tier = _tierFromProductId(productId);
            _subscriptionService
                .activateSubscription(userId, tier)
                .then((_) => onComplete(true, null))
                .catchError((e) => onComplete(false, e.toString()));
          } else {
            onComplete(false, error ?? 'Restore failed');
          }
        };

        await _iapService.restorePurchases();
        // 결과는 onPurchaseResult 콜백으로 전달됨
        return;
      }

      // 폴백: Firestore에서 기존 구독 상태 확인
      final status =
          await _subscriptionService.checkSubscriptionStatus(userId);
      onComplete(status.isActive, null);
    } catch (e) {
      onComplete(false, e.toString());
    }
  }

  /// Product ID에서 PremiumTier 판별
  PremiumTier _tierFromProductId(String productId) {
    switch (productId) {
      case IapService.monthlyProductId:
        return PremiumTier.monthly;
      case IapService.yearlyProductId:
        return PremiumTier.yearly;
      default:
        return PremiumTier.monthly;
    }
  }
}

// ========================================
// Providers
// ========================================

/// IapService provider (싱글톤, 앱 시작 시 초기화)
final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService();
  // 비동기 초기화는 앱 시작 시 별도 호출 필요
  ref.onDispose(() => service.dispose());
  return service;
});

/// IapService 초기화 상태 provider
final iapInitializationProvider = FutureProvider<void>((ref) async {
  final iapService = ref.watch(iapServiceProvider);
  await iapService.initialize();
});

/// Subscription service provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SubscriptionService(firestore);
});

/// Premium state provider (loads and caches subscription status)
final premiumStateProvider =
    StateNotifierProvider<PremiumStateNotifier, PremiumState>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  return PremiumStateNotifier(service, currentUser?.uid);
});

/// Premium state notifier
class PremiumStateNotifier extends StateNotifier<PremiumState> {
  final SubscriptionService _service;
  final String? _userId;

  PremiumStateNotifier(this._service, this._userId)
      : super(const PremiumState()) {
    if (_userId != null) {
      _loadStatus();
    } else {
      state = const PremiumState(isLoading: false);
    }
  }

  Future<void> _loadStatus() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true);
    final status = await _service.checkSubscriptionStatus(_userId);
    state = status;
  }

  /// Refresh subscription status from Firestore
  Future<void> refresh() async => _loadStatus();

  /// Start a 7-day free trial
  Future<bool> startFreeTrial({String platform = 'unknown'}) async {
    if (_userId == null) return false;
    try {
      await _service.startFreeTrial(_userId, platform);
      await _loadStatus();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cancel the subscription
  Future<bool> cancelSubscription() async {
    if (_userId == null) return false;
    try {
      await _service.cancelSubscription(_userId);
      await _loadStatus();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Whether premium is currently active (convenience provider)
final isPremiumActiveProvider = Provider<bool>((ref) {
  return ref.watch(premiumStateProvider).isActive;
});

/// Whether the user can start a free trial (convenience provider)
final canStartTrialProvider = Provider<bool>((ref) {
  return ref.watch(premiumStateProvider).canStartTrial;
});

/// In-app purchase service provider (with real IAP integration)
final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  final iapService = ref.watch(iapServiceProvider);
  return InAppPurchaseService(subscriptionService, iapService);
});

/// IAP 상품 목록 provider (UI에서 스토어 가격 표시용)
final iapProductsProvider = Provider<List<dynamic>>((ref) {
  final iapService = ref.watch(iapServiceProvider);
  return iapService.products;
});
