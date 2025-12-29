import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription/subscription.dart';
import '../../models/subscription/premium_tier.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/subscription_service.dart';
import '../../services/in_app_purchase_service.dart';
import '../infrastructure/firebase_providers.dart';

// ========================================
// Repository & Service Providers
// ========================================

/// Subscription Repository Provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

/// Subscription Service Provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionService(repository: repository);
});

/// In-App Purchase Service Provider
final inAppPurchaseServiceProvider = Provider<InAppPurchaseService>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return InAppPurchaseService(subscriptionService: subscriptionService);
});

// ========================================
// Subscription Data Providers
// ========================================

/// 현재 사용자의 구독 정보 스트림
///
/// 로그인한 사용자의 실시간 구독 정보를 제공합니다.
/// 로그인하지 않은 경우 null을 반환합니다.
final userSubscriptionProvider = StreamProvider<Subscription?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }

  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.watchUserSubscription(user.uid);
});

/// 현재 사용자의 구독 정보 (동기)
///
/// 비동기 데이터를 동기적으로 접근할 수 있습니다.
/// AsyncValue를 처리하는 것이 번거로울 때 사용합니다.
final currentSubscriptionProvider = Provider<Subscription?>((ref) {
  final subscriptionAsync = ref.watch(userSubscriptionProvider);
  return subscriptionAsync.asData?.value;
});

// ========================================
// Premium Status Providers
// ========================================

/// 프리미엄 활성 상태 확인
///
/// 사용자가 현재 프리미엄 구독을 가지고 있는지 확인합니다.
/// 무료 체험 중이거나, 유료 구독 중이면 true를 반환합니다.
final isPremiumActiveProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return false;
  return subscription.isActive;
});

/// 프리미엄 등급 조회
///
/// 사용자의 현재 프리미엄 등급을 반환합니다.
/// 구독이 없거나 만료된 경우 PremiumTier.free를 반환합니다.
final premiumTierProvider = Provider<PremiumTier>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null || !subscription.isActive) {
    return PremiumTier.free;
  }
  return subscription.tier;
});

/// 무료 체험 가능 여부
///
/// 사용자가 무료 체험을 시작할 수 있는지 확인합니다.
/// 조건:
/// 1. 이전에 체험을 사용한 적이 없어야 함
/// 2. 현재 활성 구독이 없어야 함
final canStartTrialProvider = Provider<bool>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final subscription = ref.watch(currentSubscriptionProvider);

  // 유저 프로필이 로드되지 않았으면 false
  if (userProfile.asData?.value == null) return false;

  final user = userProfile.asData!.value!;

  // 이미 체험을 사용했다면 false
  if (user.hasHadTrial) return false;

  // 현재 활성 구독이 있다면 false
  if (subscription != null && subscription.isActive) return false;

  return true;
});

/// 체험 중인지 확인
final isOnTrialProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return false;
  return subscription.isTrial;
});

/// 구독 취소 상태 확인
final isSubscriptionCancelledProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return false;
  return subscription.isCancelled;
});

/// 구독 만료 예정 확인 (7일 이내)
final isExpiringSoonProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return false;
  return subscription.isExpiringSoon;
});

// ========================================
// Subscription Details Providers
// ========================================

/// 남은 일수
final subscriptionDaysRemainingProvider = Provider<int>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return 0;
  return subscription.daysRemaining;
});

/// 남은 시간 텍스트 (UI 표시용)
final subscriptionRemainingTextProvider = Provider<String>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return '구독 없음';
  return subscription.remainingTimeText;
});

/// 자동 갱신 설정 여부
final isAutoRenewEnabledProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return false;
  return subscription.autoRenew;
});

/// 구독 시작일
final subscriptionStartDateProvider = Provider<DateTime?>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription?.startDate;
});

/// 구독 만료일
final subscriptionExpiryDateProvider = Provider<DateTime?>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription?.expiryDate;
});

// ========================================
// In-App Purchase Providers
// ========================================

/// IAP 초기화 상태
///
/// 인앱 구매 시스템이 초기화되었는지 확인합니다.
final iapInitializedProvider = StateProvider<bool>((ref) => false);

/// 사용 가능한 구독 상품 목록
///
/// App Store/Play Store에서 가져온 상품 정보입니다.
final availableProductsProvider = StateProvider((ref) {
  final iapService = ref.watch(inAppPurchaseServiceProvider);
  return iapService.availableProducts;
});

/// 구매 진행 중 상태
final isPurchaseInProgressProvider = StateProvider<bool>((ref) => false);

// ========================================
// Feature Gate Providers
// ========================================

/// 프리미엄 전용 기능 사용 가능 여부
///
/// 각 기능별로 사용 가능 여부를 체크합니다.
/// 프리미엄 사용자만 접근할 수 있는 기능을 제어합니다.

/// 무제한 하트 사용 가능
final unlimitedHeartsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

/// 오프라인 모드 사용 가능
final offlineModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

/// 광고 제거
final adFreeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

/// 고급 통계 접근
final advancedStatsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

/// 우선 지원
final prioritySupportEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

/// 프리미엄 배지 표시
final premiumBadgeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

/// 커스텀 테마 사용 가능
final customThemesEnabledProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumActiveProvider);
});

// ========================================
// UI Helper Providers
// ========================================

/// 프리미엄 뱃지 표시 여부
///
/// UI에서 프리미엄 뱃지를 표시할지 결정합니다.
final shouldShowPremiumBadgeProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null || !subscription.isActive) return false;

  // 무료 체험 중에는 뱃지 표시 안 함
  if (subscription.isTrial) return false;

  return true;
});

/// 업그레이드 프롬프트 표시 여부
///
/// 무료 사용자에게 업그레이드 안내를 표시할지 결정합니다.
final shouldShowUpgradePromptProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumActiveProvider);
  final isOnTrial = ref.watch(isOnTrialProvider);

  // 프리미엄 사용자나 체험 중인 사용자에게는 표시 안 함
  if (isPremium && !isOnTrial) return false;

  return true;
});

/// 구독 만료 경고 표시 여부
///
/// 만료 7일 전부터 경고를 표시합니다.
final shouldShowExpiryWarningProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumActiveProvider);
  final isExpiringSoon = ref.watch(isExpiringSoonProvider);

  return isPremium && isExpiringSoon;
});

/// 구독 갱신 안내 표시 여부
///
/// 취소된 구독이지만 아직 기간이 남아있는 경우 갱신 안내를 표시합니다.
final shouldShowRenewalPromptProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  if (subscription == null) return false;

  // 취소되었지만 아직 사용 가능한 구독
  return subscription.isCancelled && subscription.isActive;
});

/// 프리미엄 상태 요약 텍스트
///
/// UI에 표시할 간단한 상태 텍스트를 반환합니다.
/// 예: "프리미엄 (평생)", "무료 체험 중 (3일 남음)", "무료 플랜"
final premiumStatusTextProvider = Provider<String>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);

  if (subscription == null || !subscription.isActive) {
    return '무료 플랜';
  }

  if (subscription.isTrial) {
    final daysLeft = subscription.daysRemaining;
    return '무료 체험 중 ($daysLeft일 남음)';
  }

  switch (subscription.tier) {
    case PremiumTier.lifetime:
      return '프리미엄 (평생)';
    case PremiumTier.yearly:
      return '프리미엄 (연간)';
    case PremiumTier.monthly:
      return '프리미엄 (월간)';
    default:
      return '무료 플랜';
  }
});

// ========================================
// Analytics & Metrics Providers
// ========================================

/// 전체 활성 구독 수 (관리자용)
final activeSubscriptionCountProvider = FutureProvider<int>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getActiveSubscriptionCount();
});

/// 등급별 구독 수 (관리자용)
final subscriptionCountsByTierProvider =
    FutureProvider<Map<PremiumTier, int>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getSubscriptionCountsByTier();
});

/// 플랫폼별 구독 수 (관리자용)
final subscriptionCountsByPlatformProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getSubscriptionCountsByPlatform();
});

/// 월간 반복 수익 (관리자용)
final monthlyRecurringRevenueProvider = FutureProvider<int>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.calculateMonthlyRecurringRevenue();
});
