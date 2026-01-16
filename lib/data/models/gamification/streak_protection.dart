import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/base_model.dart';

/// Streak 보호 시스템 (Duolingo 스타일)
/// Streak Freeze 및 Streak Repair 기능
class StreakProtection implements BaseModel {
  @override
  final String id;

  /// 사용자 ID
  final String userId;

  /// 남은 Streak Freeze 개수 (최대 2개까지 보유 가능)
  final int freezeCount;

  /// 마지막 Streak Repair 사용 날짜
  final DateTime? lastRepairDate;

  /// 프리미엄 구독 여부 (자동 보호 기능)
  final bool hasPremiumProtection;

  /// Streak Freeze 마지막 획득 날짜
  final DateTime? lastFreezeEarnedDate;

  /// 생성 시간
  final DateTime createdAt;

  /// 마지막 업데이트 시간
  final DateTime lastUpdated;

  const StreakProtection({
    required this.id,
    required this.userId,
    this.freezeCount = 0,
    this.lastRepairDate,
    this.hasPremiumProtection = false,
    this.lastFreezeEarnedDate,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// 신규 사용자용 기본 생성
  factory StreakProtection.create(String userId) {
    final now = DateTime.now();
    return StreakProtection(
      id: userId,
      userId: userId,
      freezeCount: 1, // 기본 1개 제공
      createdAt: now,
      lastUpdated: now,
    );
  }

  /// JSON에서 생성
  factory StreakProtection.fromJson(Map<String, dynamic> json) {
    return StreakProtection(
      id: json['id'] as String,
      userId: json['userId'] as String,
      freezeCount: json['freezeCount'] as int? ?? 0,
      lastRepairDate: json['lastRepairDate'] != null
          ? DateTime.parse(json['lastRepairDate'] as String)
          : null,
      hasPremiumProtection: json['hasPremiumProtection'] as bool? ?? false,
      lastFreezeEarnedDate: json['lastFreezeEarnedDate'] != null
          ? DateTime.parse(json['lastFreezeEarnedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// JSON으로 변환
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'freezeCount': freezeCount,
      'lastRepairDate': lastRepairDate?.toIso8601String(),
      'hasPremiumProtection': hasPremiumProtection,
      'lastFreezeEarnedDate': lastFreezeEarnedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Firestore 형식으로 변환
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'freezeCount': freezeCount,
      'lastRepairDate':
          lastRepairDate != null ? Timestamp.fromDate(lastRepairDate!) : null,
      'hasPremiumProtection': hasPremiumProtection,
      'lastFreezeEarnedDate': lastFreezeEarnedDate != null
          ? Timestamp.fromDate(lastFreezeEarnedDate!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Firestore 문서에서 생성
  factory StreakProtection.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return StreakProtection(
      id: doc.id,
      userId: data['userId'] as String,
      freezeCount: data['freezeCount'] as int? ?? 0,
      lastRepairDate: data['lastRepairDate'] != null
          ? (data['lastRepairDate'] as Timestamp).toDate()
          : null,
      hasPremiumProtection: data['hasPremiumProtection'] as bool? ?? false,
      lastFreezeEarnedDate: data['lastFreezeEarnedDate'] != null
          ? (data['lastFreezeEarnedDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// 복사 (업데이트용)
  StreakProtection copyWith({
    String? id,
    String? userId,
    int? freezeCount,
    DateTime? lastRepairDate,
    bool? hasPremiumProtection,
    DateTime? lastFreezeEarnedDate,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return StreakProtection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      freezeCount: freezeCount ?? this.freezeCount,
      lastRepairDate: lastRepairDate ?? this.lastRepairDate,
      hasPremiumProtection: hasPremiumProtection ?? this.hasPremiumProtection,
      lastFreezeEarnedDate: lastFreezeEarnedDate ?? this.lastFreezeEarnedDate,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Streak Freeze 사용 가능 여부
  bool get hasFreeze => freezeCount > 0;

  /// Streak Repair 사용 가능 여부 (7일 쿨다운)
  bool canRepairStreak() {
    if (lastRepairDate == null) return true;

    final daysSinceLastRepair =
        DateTime.now().difference(lastRepairDate!).inDays;
    return daysSinceLastRepair >= 7;
  }

  /// 다음 Repair 가능 날짜
  DateTime? get nextRepairAvailableDate {
    if (lastRepairDate == null) return null;
    return lastRepairDate!.add(const Duration(days: 7));
  }

  /// Freeze 최대 보유 가능 개수
  static const int maxFreezeCount = 2;

  /// Freeze를 더 획득할 수 있는지 확인
  bool get canEarnMoreFreeze => freezeCount < maxFreezeCount;

  /// Freeze 비용 (광고 시청 또는 In-App Purchase)
  static const int freezeCostGems = 0; // 광고 시청으로 획득 가능
  static const int repairCostGems = 100; // 복구는 유료
}

/// Streak 복구 방법
enum StreakRepairMethod {
  /// 광고 시청
  watchAd,

  /// 젬(Gem) 사용
  useGems,

  /// 프리미엄 구독 (자동)
  premiumAuto,
}

/// Streak Freeze 획득 방법
enum StreakFreezeEarnMethod {
  /// 7일 연속 학습 달성
  sevenDayStreak,

  /// 광고 시청
  watchAd,

  /// 프리미엄 구독 혜택
  premiumBenefit,

  /// 이벤트 보상
  eventReward,
}
