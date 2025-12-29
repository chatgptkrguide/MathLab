import 'package:cloud_firestore/cloud_firestore.dart';
import 'premium_tier.dart';
import 'subscription_status.dart';

/// 구독 정보 모델
///
/// 사용자의 프리미엄 구독 상태와 결제 정보를 관리합니다.
class Subscription {
  /// 구독 ID (Firestore document ID)
  final String id;

  /// 사용자 ID (Firebase Auth UID)
  final String userId;

  /// 구독 등급 (free/monthly/yearly/lifetime)
  final PremiumTier tier;

  /// 구독 상태 (active/expired/cancelled/trial/paused)
  final SubscriptionStatus status;

  /// 구독 시작일
  final DateTime startDate;

  /// 구독 만료일 (평생 구독의 경우 null)
  final DateTime? expiryDate;

  /// 거래 ID (Apple/Google Play 영수증 ID)
  final String? transactionId;

  /// 플랫폼 (ios/android/web)
  final String platform;

  /// 자동 갱신 여부
  final bool autoRenew;

  /// 구독 취소 시각 (취소되지 않았으면 null)
  final DateTime? cancelledAt;

  /// 생성 시각
  final DateTime createdAt;

  /// 수정 시각
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.expiryDate,
    this.transactionId,
    required this.platform,
    this.autoRenew = true,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // ========================================
  // Helper Methods (계산 메서드)
  // ========================================

  /// 현재 활성 상태인지 확인
  ///
  /// 활성 조건:
  /// 1. status가 사용 가능한 상태 (active/trial/cancelled)
  /// 2. 만료되지 않음
  bool get isActive => status.isUsable && !isExpired;

  /// 만료되었는지 확인
  ///
  /// - 평생 구독 (lifetime)은 절대 만료되지 않음
  /// - 만료일이 없으면 만료되지 않은 것으로 간주
  /// - 현재 시각이 만료일을 지났으면 만료
  bool get isExpired {
    if (tier == PremiumTier.lifetime) return false;
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// 체험 중인지 확인
  bool get isTrial => status == SubscriptionStatus.trial;

  /// 취소되었는지 확인 (기간까지는 사용 가능)
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  /// 일시 정지 상태인지 확인
  bool get isPaused => status == SubscriptionStatus.paused;

  /// 남은 일수 계산
  ///
  /// - 평생 구독: -1 반환
  /// - 만료일 없음: -1 반환
  /// - 만료일 있음: 남은 일수 반환 (음수면 이미 만료)
  int get daysRemaining {
    if (tier == PremiumTier.lifetime) return -1;
    if (expiryDate == null) return -1;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// 남은 시간을 읽기 쉬운 형태로 반환
  ///
  /// 예: "3일 남음", "2개월 남음", "평생"
  String get remainingTimeText {
    if (tier == PremiumTier.lifetime) return '평생';
    if (expiryDate == null) return '알 수 없음';

    final days = daysRemaining;
    if (days < 0) return '만료됨';
    if (days == 0) return '오늘 만료';
    if (days == 1) return '1일 남음';
    if (days < 30) return '$days일 남음';
    if (days < 365) {
      final months = (days / 30).floor();
      return '$months개월 남음';
    }
    final years = (days / 365).floor();
    return '$years년 남음';
  }

  /// 곧 만료 예정인지 확인 (7일 이내)
  bool get isExpiringSoon {
    if (tier == PremiumTier.lifetime) return false;
    final days = daysRemaining;
    return days >= 0 && days <= 7;
  }

  // ========================================
  // JSON Serialization (JSON 직렬화)
  // ========================================

  /// JSON으로부터 Subscription 객체 생성
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: PremiumTier.fromString(json['tier'] as String),
      status: SubscriptionStatus.fromString(json['status'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
      platform: json['platform'] as String,
      autoRenew: json['autoRenew'] as bool? ?? true,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Subscription 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.value,
      'status': status.value,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'transactionId': transactionId,
      'platform': platform,
      'autoRenew': autoRenew,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ========================================
  // Firestore Serialization (Firestore 직렬화)
  // ========================================

  /// Firestore DocumentSnapshot으로부터 Subscription 객체 생성
  factory Subscription.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Subscription(
      id: doc.id,
      userId: data['userId'] as String,
      tier: PremiumTier.fromString(data['tier'] as String? ?? 'free'),
      status:
          SubscriptionStatus.fromString(data['status'] as String? ?? 'expired'),
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      transactionId: data['transactionId'] as String?,
      platform: data['platform'] as String? ?? 'unknown',
      autoRenew: data['autoRenew'] as bool? ?? true,
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Subscription 객체를 Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tier': tier.value,
      'status': status.value,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'transactionId': transactionId,
      'platform': platform,
      'autoRenew': autoRenew,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.now(), // 항상 현재 시각으로 업데이트
    };
  }

  // ========================================
  // Copy With (불변 객체 복사)
  // ========================================

  /// Subscription 객체 복사 (일부 값 변경)
  Subscription copyWith({
    String? id,
    String? userId,
    PremiumTier? tier,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? expiryDate,
    String? transactionId,
    String? platform,
    bool? autoRenew,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      transactionId: transactionId ?? this.transactionId,
      platform: platform ?? this.platform,
      autoRenew: autoRenew ?? this.autoRenew,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ========================================
  // Utility Methods
  // ========================================

  @override
  String toString() {
    return 'Subscription{id: $id, userId: $userId, tier: ${tier.displayName}, status: ${status.displayName}, isActive: $isActive, daysRemaining: $daysRemaining}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
