import '../models/subscription.dart';
import '../models/premium_tier.dart';
import '../models/subscription_status.dart';
import '../models/user.dart';
import '../repositories/subscription_repository.dart';

/// 구독 비즈니스 로직 서비스
///
/// Repository와 상호작용하며, 구독 관련 비즈니스 규칙을 처리합니다.
/// 예: 중복 구독 방지, 체험 자격 검증, 구독 업그레이드/다운그레이드 등
class SubscriptionService {
  final SubscriptionRepository _repository;

  SubscriptionService({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository();

  // ========================================
  // 구독 조회 (READ)
  // ========================================

  /// 사용자의 현재 구독 정보 조회
  Future<Subscription?> getUserSubscription(String userId) async {
    return await _repository.getSubscription(userId);
  }

  /// 사용자의 구독 정보 실시간 스트림
  Stream<Subscription?> watchUserSubscription(String userId) {
    return _repository.subscriptionStream(userId);
  }

  /// 사용자가 프리미엄 활성 상태인지 확인
  ///
  /// 구독이 있고, 상태가 사용 가능하며, 만료되지 않았는지 검증합니다.
  Future<bool> isPremiumActive(String userId) async {
    final subscription = await getUserSubscription(userId);
    if (subscription == null) return false;
    return subscription.isActive;
  }

  /// 사용자의 현재 프리미엄 등급 조회
  Future<PremiumTier> getUserPremiumTier(String userId) async {
    final subscription = await getUserSubscription(userId);
    if (subscription == null || !subscription.isActive) {
      return PremiumTier.free;
    }
    return subscription.tier;
  }

  // ========================================
  // 무료 체험 (FREE TRIAL)
  // ========================================

  /// 무료 체험 시작 가능 여부 확인
  ///
  /// 조건:
  /// 1. 기존 구독이 없어야 함
  /// 2. User의 hasHadTrial이 false여야 함
  Future<bool> canStartTrial(User user) async {
    // 이미 체험을 사용했다면 불가
    if (user.hasHadTrial) return false;

    // 현재 활성 구독이 있다면 불가
    final subscription = await getUserSubscription(user.id);
    if (subscription != null && subscription.isActive) return false;

    return true;
  }

  /// 무료 체험 시작
  ///
  /// 7일 무료 체험 구독을 생성합니다.
  /// User의 hasHadTrial 플래그는 별도로 업데이트해야 합니다.
  Future<Subscription> startFreeTrial(String userId, String platform) async {
    // 기존 구독 확인
    final existingSubscription = await getUserSubscription(userId);
    if (existingSubscription != null && existingSubscription.isActive) {
      throw Exception('이미 활성 구독이 있습니다');
    }

    // 무료 체험 생성
    return await _repository.startTrial(userId, platform);
  }

  // ========================================
  // 구독 구매/갱신 (PURCHASE/RENEWAL)
  // ========================================

  /// 새 구독 시작 (첫 결제)
  ///
  /// 새로운 유료 구독을 시작합니다.
  Future<Subscription> startNewSubscription({
    required String userId,
    required PremiumTier tier,
    required String transactionId,
    required String platform,
  }) async {
    if (tier == PremiumTier.free) {
      throw Exception('무료 등급으로는 구독을 시작할 수 없습니다');
    }

    final now = DateTime.now();
    DateTime? expiryDate;

    // 만료일 계산
    if (tier == PremiumTier.monthly) {
      expiryDate = now.add(const Duration(days: 30));
    } else if (tier == PremiumTier.yearly) {
      expiryDate = now.add(const Duration(days: 365));
    }
    // lifetime은 null (만료 없음)

    final subscription = Subscription(
      id: '', // Firestore에서 생성
      userId: userId,
      tier: tier,
      status: SubscriptionStatus.active,
      startDate: now,
      expiryDate: expiryDate,
      transactionId: transactionId,
      platform: platform,
      autoRenew: true,
      cancelledAt: null,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createSubscription(subscription);
  }

  /// 구독 갱신 (자동 갱신 또는 수동 재구매)
  ///
  /// 기존 구독을 갱신하거나, 만료된 구독을 재활성화합니다.
  Future<void> renewSubscription({
    required String subscriptionId,
    required PremiumTier tier,
    required String transactionId,
  }) async {
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('구독을 찾을 수 없습니다');
    }

    DateTime newExpiryDate;
    final now = DateTime.now();

    // 만료일 계산
    if (tier == PremiumTier.monthly) {
      // 현재 시각 또는 기존 만료일 중 더 미래 시점 기준으로 30일 추가
      final baseDate = subscription.expiryDate != null &&
              subscription.expiryDate!.isAfter(now)
          ? subscription.expiryDate!
          : now;
      newExpiryDate = baseDate.add(const Duration(days: 30));
    } else if (tier == PremiumTier.yearly) {
      final baseDate = subscription.expiryDate != null &&
              subscription.expiryDate!.isAfter(now)
          ? subscription.expiryDate!
          : now;
      newExpiryDate = baseDate.add(const Duration(days: 365));
    } else {
      // lifetime으로 업그레이드
      await _repository.renewSubscription(
        subscriptionId,
        tier,
        DateTime(2099, 12, 31), // 평생 구독은 먼 미래 날짜
        transactionId,
      );
      return;
    }

    await _repository.renewSubscription(
      subscriptionId,
      tier,
      newExpiryDate,
      transactionId,
    );
  }

  // ========================================
  // 구독 변경 (UPGRADE/DOWNGRADE)
  // ========================================

  /// 구독 업그레이드 (월간 → 연간 or 평생)
  ///
  /// 기존 구독을 더 높은 등급으로 업그레이드합니다.
  /// 비례 배분(proration) 계산은 InAppPurchaseService에서 처리됩니다.
  Future<void> upgradeSubscription({
    required String subscriptionId,
    required PremiumTier newTier,
    required String transactionId,
  }) async {
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('구독을 찾을 수 없습니다');
    }

    if (!subscription.isActive) {
      throw Exception('활성 구독만 업그레이드할 수 있습니다');
    }

    // 업그레이드 검증
    if (_isDowngrade(subscription.tier, newTier)) {
      throw Exception('더 낮은 등급으로는 변경할 수 없습니다');
    }

    // 새로운 만료일 계산
    final now = DateTime.now();
    DateTime? newExpiryDate;

    if (newTier == PremiumTier.lifetime) {
      newExpiryDate = null; // 평생 구독은 만료일 없음
    } else if (newTier == PremiumTier.yearly) {
      newExpiryDate = now.add(const Duration(days: 365));
    } else if (newTier == PremiumTier.monthly) {
      newExpiryDate = now.add(const Duration(days: 30));
    }

    // 구독 업데이트
    final updatedSubscription = subscription.copyWith(
      tier: newTier,
      expiryDate: newExpiryDate,
      transactionId: transactionId,
      updatedAt: now,
    );

    await _repository.updateSubscription(updatedSubscription);
  }

  /// 등급 비교: downgrade인지 확인
  bool _isDowngrade(PremiumTier currentTier, PremiumTier newTier) {
    const tierOrder = {
      PremiumTier.free: 0,
      PremiumTier.monthly: 1,
      PremiumTier.yearly: 2,
      PremiumTier.lifetime: 3,
    };

    return tierOrder[newTier]! < tierOrder[currentTier]!;
  }

  // ========================================
  // 구독 취소 및 복원 (CANCEL/RESTORE)
  // ========================================

  /// 구독 취소
  ///
  /// 자동 갱신을 중단하고 구독을 취소 상태로 변경합니다.
  /// 기간 종료까지는 프리미엄 기능을 계속 사용할 수 있습니다.
  Future<void> cancelSubscription(String subscriptionId) async {
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('구독을 찾을 수 없습니다');
    }

    if (!subscription.isActive) {
      throw Exception('활성 구독만 취소할 수 있습니다');
    }

    await _repository.cancelSubscription(subscriptionId);
  }

  /// 구독 복원 (취소했던 구독 재활성화)
  ///
  /// 취소 상태의 구독을 다시 활성화합니다.
  Future<void> restoreSubscription(String subscriptionId) async {
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('구독을 찾을 수 없습니다');
    }

    if (subscription.status != SubscriptionStatus.cancelled) {
      throw Exception('취소된 구독만 복원할 수 있습니다');
    }

    if (subscription.isExpired) {
      throw Exception('이미 만료된 구독은 복원할 수 없습니다');
    }

    final updatedSubscription = subscription.copyWith(
      status: SubscriptionStatus.active,
      autoRenew: true,
      cancelledAt: null,
      updatedAt: DateTime.now(),
    );

    await _repository.updateSubscription(updatedSubscription);
  }

  /// 자동 갱신 설정 변경
  Future<void> setAutoRenew(String subscriptionId, bool autoRenew) async {
    await _repository.setAutoRenew(subscriptionId, autoRenew);
  }

  // ========================================
  // 구독 만료 처리 (EXPIRATION)
  // ========================================

  /// 만료된 구독 처리
  ///
  /// Cloud Function 또는 백그라운드 작업에서 실행됩니다.
  /// 만료 시각이 지난 활성 구독을 expired 상태로 변경합니다.
  Future<void> processExpiredSubscriptions() async {
    final expiredSubscriptions = await _repository.getExpiredSubscriptions();

    final subscriptionIds = expiredSubscriptions.map((s) => s.id).toList();

    if (subscriptionIds.isNotEmpty) {
      await _repository.batchUpdateExpiredSubscriptions(subscriptionIds);
    }
  }

  /// 만료 예정 알림 대상 구독 조회
  ///
  /// 7일 이내 만료 예정인 구독을 찾아서 푸시 알림을 보낼 수 있습니다.
  Future<List<Subscription>> getSubscriptionsExpiringSoon() async {
    return await _repository.getExpiringSoonSubscriptions();
  }

  // ========================================
  // 구독 검증 (VALIDATION)
  // ========================================

  /// 영수증 검증 (서버 사이드 검증 필요)
  ///
  /// 실제로는 백엔드 서버에서 Apple/Google 영수증을 검증해야 합니다.
  /// 클라이언트에서는 transactionId만 서버로 전송하고,
  /// 서버가 검증 후 Firestore를 업데이트합니다.
  ///
  /// 이 메서드는 간단한 로컬 검증만 수행합니다.
  Future<bool> validateSubscription(String subscriptionId) async {
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) return false;

    // 기본적인 검증
    // 1. 구독이 활성 상태인가?
    if (!subscription.isActive) return false;

    // 2. 만료되지 않았는가?
    if (subscription.isExpired) return false;

    // 3. transactionId가 있는가? (결제 영수증)
    if (subscription.tier != PremiumTier.free &&
        subscription.status != SubscriptionStatus.trial &&
        (subscription.transactionId == null ||
            subscription.transactionId!.isEmpty)) {
      return false;
    }

    return true;
  }

  /// 구독 무결성 검사
  ///
  /// 구독 데이터가 일관성 있는지 확인합니다.
  Future<bool> checkSubscriptionIntegrity(String subscriptionId) async {
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) return false;

    // 검증 규칙
    // 1. 평생 구독은 만료일이 없어야 함
    if (subscription.tier == PremiumTier.lifetime &&
        subscription.expiryDate != null) {
      return false;
    }

    // 2. 월간/연간 구독은 만료일이 있어야 함
    if ((subscription.tier == PremiumTier.monthly ||
            subscription.tier == PremiumTier.yearly) &&
        subscription.expiryDate == null) {
      return false;
    }

    // 3. 활성 상태는 만료되지 않아야 함
    if (subscription.status == SubscriptionStatus.active &&
        subscription.isExpired) {
      return false;
    }

    // 4. 취소 상태는 취소 시각이 있어야 함
    if (subscription.status == SubscriptionStatus.cancelled &&
        subscription.cancelledAt == null) {
      return false;
    }

    return true;
  }

  // ========================================
  // 통계 (ANALYTICS)
  // ========================================

  /// 전체 활성 구독 수
  Future<int> getActiveSubscriptionCount() async {
    return await _repository.getActiveSubscriptionCount();
  }

  /// 등급별 구독 수
  Future<Map<PremiumTier, int>> getSubscriptionCountsByTier() async {
    final monthly =
        await _repository.getSubscriptionCountByTier(PremiumTier.monthly);
    final yearly =
        await _repository.getSubscriptionCountByTier(PremiumTier.yearly);
    final lifetime =
        await _repository.getSubscriptionCountByTier(PremiumTier.lifetime);

    return {
      PremiumTier.monthly: monthly,
      PremiumTier.yearly: yearly,
      PremiumTier.lifetime: lifetime,
    };
  }

  /// 플랫폼별 구독 수
  Future<Map<String, int>> getSubscriptionCountsByPlatform() async {
    return await _repository.getSubscriptionCountByPlatform();
  }

  /// 월간 반복 수익(MRR) 계산
  ///
  /// 모든 활성 구독의 월간 환산 금액을 합산합니다.
  Future<int> calculateMonthlyRecurringRevenue() async {
    final tierCounts = await getSubscriptionCountsByTier();

    int mrr = 0;

    // 월간 구독: 전체 금액
    mrr += tierCounts[PremiumTier.monthly]! * PremiumTier.monthly.price;

    // 연간 구독: 월 단위로 환산
    mrr += tierCounts[PremiumTier.yearly]! *
        PremiumTier.yearly.monthlyEquivalentPrice;

    // 평생 구독: MRR 계산에서 제외하거나, 별도 처리
    // 여기서는 제외

    return mrr;
  }

  /// 연간 반복 수익(ARR) 계산
  Future<int> calculateAnnualRecurringRevenue() async {
    final mrr = await calculateMonthlyRecurringRevenue();
    return mrr * 12;
  }
}
