import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription/subscription.dart';
import '../models/subscription/premium_tier.dart';
import '../models/subscription/subscription_status.dart';

/// 구독 정보 저장소
///
/// Firestore의 subscriptions 컬렉션과 상호작용하여
/// 사용자의 구독 데이터를 CRUD 합니다.
class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  /// Firestore 인스턴스를 주입받아 Repository 생성
  SubscriptionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Subscriptions 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _subscriptionsCollection =>
      _firestore.collection('subscriptions');

  // ========================================
  // READ Operations (조회)
  // ========================================

  /// 특정 사용자의 구독 정보 조회
  ///
  /// userId를 기준으로 subscriptions 컬렉션에서 구독 정보를 찾습니다.
  /// 구독이 없으면 null을 반환합니다.
  Future<Subscription?> getSubscription(String userId) async {
    try {
      // userId로 구독 문서 쿼리 (userId는 유니크해야 함)
      final querySnapshot = await _subscriptionsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return Subscription.fromFirestore(doc);
    } catch (e) {
      throw Exception('구독 정보 조회 실패: $e');
    }
  }

  /// 특정 구독 ID로 구독 정보 조회
  ///
  /// Firestore document ID를 사용하여 구독 정보를 직접 조회합니다.
  Future<Subscription?> getSubscriptionById(String subscriptionId) async {
    try {
      final doc = await _subscriptionsCollection.doc(subscriptionId).get();

      if (!doc.exists) {
        return null;
      }

      return Subscription.fromFirestore(doc);
    } catch (e) {
      throw Exception('구독 정보 조회 실패 (ID: $subscriptionId): $e');
    }
  }

  /// 사용자의 구독 정보를 실시간으로 스트리밍
  ///
  /// userId를 기준으로 구독 정보 변경사항을 실시간으로 받습니다.
  /// UI에서 StreamProvider로 사용하기 적합합니다.
  Stream<Subscription?> subscriptionStream(String userId) {
    try {
      return _subscriptionsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        return Subscription.fromFirestore(snapshot.docs.first);
      });
    } catch (e) {
      throw Exception('구독 정보 스트리밍 실패: $e');
    }
  }

  // ========================================
  // CREATE Operations (생성)
  // ========================================

  /// 새로운 구독 생성
  ///
  /// 새 구독을 Firestore에 저장합니다.
  /// 중복 체크는 Service 계층에서 수행되어야 합니다.
  Future<Subscription> createSubscription(Subscription subscription) async {
    try {
      // Firestore에 저장
      final docRef =
          await _subscriptionsCollection.add(subscription.toFirestore());

      // 생성된 문서 ID를 포함한 Subscription 객체 반환
      return subscription.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('구독 생성 실패: $e');
    }
  }

  /// 무료 체험 구독 시작
  ///
  /// 7일 무료 체험 구독을 생성합니다.
  Future<Subscription> startTrial(String userId, String platform) async {
    final now = DateTime.now();
    final expiryDate = now.add(const Duration(days: 7));

    final subscription = Subscription(
      id: '', // Firestore에서 생성될 ID
      userId: userId,
      tier: PremiumTier.monthly, // 체험은 월간 플랜 기준
      status: SubscriptionStatus.trial,
      startDate: now,
      expiryDate: expiryDate,
      transactionId: null,
      platform: platform,
      autoRenew: false, // 체험은 자동 갱신 안 함
      cancelledAt: null,
      createdAt: now,
      updatedAt: now,
    );

    return createSubscription(subscription);
  }

  // ========================================
  // UPDATE Operations (수정)
  // ========================================

  /// 기존 구독 정보 업데이트
  ///
  /// Subscription 객체의 모든 필드를 Firestore에 업데이트합니다.
  /// updatedAt은 자동으로 현재 시각으로 설정됩니다.
  Future<void> updateSubscription(Subscription subscription) async {
    try {
      if (subscription.id.isEmpty) {
        throw Exception('구독 ID가 필요합니다');
      }

      await _subscriptionsCollection
          .doc(subscription.id)
          .update(subscription.toFirestore());
    } catch (e) {
      throw Exception('구독 정보 업데이트 실패: $e');
    }
  }

  /// 구독 상태만 업데이트
  ///
  /// 구독 상태만 변경하는 경우 사용합니다.
  Future<void> updateSubscriptionStatus(
    String subscriptionId,
    SubscriptionStatus status,
  ) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).update({
        'status': status.value,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('구독 상태 업데이트 실패: $e');
    }
  }

  /// 구독 취소 (즉시 만료는 아님, 기간 종료까지 사용 가능)
  ///
  /// 구독을 취소 상태로 변경하고, 취소 시각을 기록합니다.
  /// 자동 갱신도 비활성화합니다.
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).update({
        'status': SubscriptionStatus.cancelled.value,
        'autoRenew': false,
        'cancelledAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('구독 취소 실패: $e');
    }
  }

  /// 구독 갱신
  ///
  /// 구독 만료일을 연장하고 상태를 활성으로 변경합니다.
  /// transactionId는 결제 영수증 ID입니다.
  Future<void> renewSubscription(
    String subscriptionId,
    PremiumTier tier,
    DateTime newExpiryDate,
    String transactionId,
  ) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).update({
        'tier': tier.value,
        'status': SubscriptionStatus.active.value,
        'expiryDate': Timestamp.fromDate(newExpiryDate),
        'transactionId': transactionId,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('구독 갱신 실패: $e');
    }
  }

  /// 자동 갱신 설정 변경
  ///
  /// 자동 갱신 on/off를 토글합니다.
  Future<void> setAutoRenew(String subscriptionId, bool autoRenew) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).update({
        'autoRenew': autoRenew,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('자동 갱신 설정 실패: $e');
    }
  }

  // ========================================
  // DELETE Operations (삭제)
  // ========================================

  /// 구독 삭제 (실제 사용 시 주의!)
  ///
  /// 구독 정보를 Firestore에서 완전히 삭제합니다.
  /// 일반적으로는 상태 변경(expired)으로 처리하고, 삭제는 하지 않는 것이 좋습니다.
  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).delete();
    } catch (e) {
      throw Exception('구독 삭제 실패: $e');
    }
  }

  /// 사용자의 구독 삭제 (userId 기준)
  ///
  /// 특정 사용자의 모든 구독을 삭제합니다.
  /// 테스트 환경에서만 사용하세요!
  Future<void> deleteUserSubscriptions(String userId) async {
    try {
      final querySnapshot = await _subscriptionsCollection
          .where('userId', isEqualTo: userId)
          .get();

      // Batch 작업으로 모든 문서 삭제
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('사용자 구독 삭제 실패: $e');
    }
  }

  // ========================================
  // 배치 만료 처리 (Batch Operations)
  // ========================================

  /// 만료된 구독 찾기
  ///
  /// 현재 시각 기준으로 만료된 구독을 조회합니다.
  /// Cloud Function에서 사용할 수 있습니다.
  Future<List<Subscription>> getExpiredSubscriptions() async {
    try {
      final now = Timestamp.now();
      final querySnapshot = await _subscriptionsCollection
          .where('status', isEqualTo: SubscriptionStatus.active.value)
          .where('expiryDate', isLessThan: now)
          .get();

      return querySnapshot.docs
          .map((doc) => Subscription.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('만료 구독 조회 실패: $e');
    }
  }

  /// 만료 예정 구독 찾기 (7일 이내)
  ///
  /// 곧 만료될 구독을 찾아서 알림을 보낼 수 있습니다.
  Future<List<Subscription>> getExpiringSoonSubscriptions() async {
    try {
      final now = DateTime.now();
      final sevenDaysLater = now.add(const Duration(days: 7));

      final querySnapshot = await _subscriptionsCollection
          .where('status', isEqualTo: SubscriptionStatus.active.value)
          .where('expiryDate', isLessThan: Timestamp.fromDate(sevenDaysLater))
          .where('expiryDate', isGreaterThan: Timestamp.now())
          .get();

      return querySnapshot.docs
          .map((doc) => Subscription.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('만료 예정 구독 조회 실패: $e');
    }
  }

  /// 배치로 만료된 구독 상태 업데이트
  ///
  /// 여러 구독의 상태를 한 번에 expired로 변경합니다.
  Future<void> batchUpdateExpiredSubscriptions(
      List<String> subscriptionIds) async {
    try {
      final batch = _firestore.batch();

      for (final id in subscriptionIds) {
        final docRef = _subscriptionsCollection.doc(id);
        batch.update(docRef, {
          'status': SubscriptionStatus.expired.value,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('배치 만료 처리 실패: $e');
    }
  }

  // ========================================
  // 통계 및 분석 (Analytics)
  // ========================================

  /// 전체 활성 구독 수 조회
  Future<int> getActiveSubscriptionCount() async {
    try {
      final querySnapshot = await _subscriptionsCollection
          .where('status', isEqualTo: SubscriptionStatus.active.value)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('활성 구독 수 조회 실패: $e');
    }
  }

  /// 특정 등급의 구독 수 조회
  Future<int> getSubscriptionCountByTier(PremiumTier tier) async {
    try {
      final querySnapshot = await _subscriptionsCollection
          .where('tier', isEqualTo: tier.value)
          .where('status', isEqualTo: SubscriptionStatus.active.value)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('${tier.displayName} 구독 수 조회 실패: $e');
    }
  }

  /// 플랫폼별 구독 수 조회
  Future<Map<String, int>> getSubscriptionCountByPlatform() async {
    try {
      final iosCount = await _subscriptionsCollection
          .where('platform', isEqualTo: 'ios')
          .where('status', isEqualTo: SubscriptionStatus.active.value)
          .count()
          .get();

      final androidCount = await _subscriptionsCollection
          .where('platform', isEqualTo: 'android')
          .where('status', isEqualTo: SubscriptionStatus.active.value)
          .count()
          .get();

      return {
        'ios': iosCount.count ?? 0,
        'android': androidCount.count ?? 0,
      };
    } catch (e) {
      throw Exception('플랫폼별 구독 수 조회 실패: $e');
    }
  }
}
