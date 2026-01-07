import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/utils/logger.dart';

/// 충돌 해결 전략 열거형
enum ResolutionStrategy {
  lastWriteWins, // 최신 타임스탬프 기준 덮어쓰기
  merge, // 필드별 병합
  clientWins, // 클라이언트 우선
  serverWins, // 서버 우선
  custom, // 커스텀 로직
}

/// 충돌 해결 메타데이터
class ConflictMetadata {
  final DateTime localTimestamp;
  final DateTime serverTimestamp;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;

  ConflictMetadata({
    required this.localTimestamp,
    required this.serverTimestamp,
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
  });

  /// 충돌 여부 확인
  bool get hasConflict => localTimestamp != serverTimestamp;

  /// 최신 데이터 확인
  bool get isLocalNewer => localTimestamp.isAfter(serverTimestamp);
}

/// 데이터 충돌 해결 서비스
///
/// 오프라인/온라인 동기화 시 발생하는 데이터 충돌을 해결하는 서비스
/// Last-Write-Wins (LWW) 전략을 기본으로 사용하며, 중요한 필드는 병합 전략 적용
class ConflictResolutionService {
  static const String _tag = 'ConflictResolution';

  /// 사용자 데이터 충돌 해결
  Map<String, dynamic> resolveUserConflict(ConflictMetadata conflict) {
    Logger.info(
      '사용자 데이터 충돌 해결 시작: ${conflict.entityId}',
      tag: _tag,
    );

    // 기본 전략: Last-Write-Wins
    if (conflict.isLocalNewer) {
      Logger.info('로컬 데이터가 더 최신 - 로컬 데이터 유지', tag: _tag);
      return conflict.localData;
    }

    // 서버 데이터가 더 최신이지만, 중요한 필드는 병합
    final merged = Map<String, dynamic>.from(conflict.serverData);

    // 게임 진행 데이터는 더 큰 값을 유지 (XP, 레벨, 스트릭 등)
    _mergeGameProgress(merged, conflict.localData, conflict.serverData);

    // 학습 진행도는 병합
    _mergeLearningProgress(merged, conflict.localData, conflict.serverData);

    // 프리미엄 상태는 서버 우선 (결제 정보)
    _mergePremiumStatus(merged, conflict.serverData);

    // 타임스탬프 업데이트
    merged['updatedAt'] = FieldValue.serverTimestamp();
    merged['lastSyncAt'] = FieldValue.serverTimestamp();

    Logger.info('충돌 해결 완료 - 병합된 데이터 반환', tag: _tag);
    return merged;
  }

  /// 게임 진행 데이터 병합 (더 큰 값 유지)
  void _mergeGameProgress(
    Map<String, dynamic> target,
    Map<String, dynamic> local,
    Map<String, dynamic> server,
  ) {
    // XP는 더 큰 값 유지
    if (local['totalXP'] != null && server['totalXP'] != null) {
      final localXP = local['totalXP'] as int;
      final serverXP = server['totalXP'] as int;
      target['totalXP'] = localXP > serverXP ? localXP : serverXP;
      Logger.debug(
          'XP 병합: local=$localXP, server=$serverXP, merged=${target['totalXP']}',
          tag: _tag);
    }

    // 레벨은 더 큰 값 유지
    if (local['level'] != null && server['level'] != null) {
      final localLevel = local['level'] as int;
      final serverLevel = server['level'] as int;
      target['level'] = localLevel > serverLevel ? localLevel : serverLevel;
    }

    // 스트릭은 더 큰 값 유지
    if (local['streak'] != null && server['streak'] != null) {
      final localStreak = local['streak'] as int;
      final serverStreak = server['streak'] as int;
      target['streak'] =
          localStreak > serverStreak ? localStreak : serverStreak;
    }

    // 일일 XP는 날짜 확인 후 병합
    _mergeDailyXP(target, local, server);
  }

  /// 일일 XP 병합 (같은 날짜면 더 큰 값, 다른 날짜면 최신 날짜 기준)
  void _mergeDailyXP(
    Map<String, dynamic> target,
    Map<String, dynamic> local,
    Map<String, dynamic> server,
  ) {
    final localDailyXP = local['dailyXP'] as int?;
    final serverDailyXP = server['dailyXP'] as int?;
    final localResetDate = (local['lastXPResetDate'] as Timestamp?)?.toDate();
    final serverResetDate = (server['lastXPResetDate'] as Timestamp?)?.toDate();

    if (localDailyXP != null &&
        serverDailyXP != null &&
        localResetDate != null &&
        serverResetDate != null) {
      // 같은 날짜면 더 큰 값 유지
      if (_isSameDay(localResetDate, serverResetDate)) {
        target['dailyXP'] =
            localDailyXP > serverDailyXP ? localDailyXP : serverDailyXP;
        target['lastXPResetDate'] = Timestamp.fromDate(localResetDate);
        Logger.debug(
          '일일 XP 병합 (같은 날): local=$localDailyXP, server=$serverDailyXP, merged=${target['dailyXP']}',
          tag: _tag,
        );
      } else if (localResetDate.isAfter(serverResetDate)) {
        // 로컬이 더 최신 날짜
        target['dailyXP'] = localDailyXP;
        target['lastXPResetDate'] = Timestamp.fromDate(localResetDate);
        Logger.debug('일일 XP - 로컬 날짜가 더 최신', tag: _tag);
      } else {
        // 서버가 더 최신 날짜
        target['dailyXP'] = serverDailyXP;
        target['lastXPResetDate'] = Timestamp.fromDate(serverResetDate);
        Logger.debug('일일 XP - 서버 날짜가 더 최신', tag: _tag);
      }
    }
  }

  /// 학습 진행도 병합 (누적 방식)
  void _mergeLearningProgress(
    Map<String, dynamic> target,
    Map<String, dynamic> local,
    Map<String, dynamic> server,
  ) {
    // 완료된 레슨 병합 (중복 제거)
    final localLessons = (local['completedLessons'] as List<dynamic>?) ?? [];
    final serverLessons = (server['completedLessons'] as List<dynamic>?) ?? [];
    final mergedLessons = {...localLessons, ...serverLessons}.toList();
    target['completedLessons'] = mergedLessons;

    Logger.debug(
      '레슨 병합: local=${localLessons.length}, server=${serverLessons.length}, merged=${mergedLessons.length}',
      tag: _tag,
    );

    // 잠금 해제된 기능 병합
    final localUnlocked = (local['unlockedFeatures'] as List<dynamic>?) ?? [];
    final serverUnlocked = (server['unlockedFeatures'] as List<dynamic>?) ?? [];
    final mergedUnlocked = {...localUnlocked, ...serverUnlocked}.toList();
    target['unlockedFeatures'] = mergedUnlocked;
  }

  /// 프리미엄 상태 병합 (서버 우선 - 결제 정보는 서버가 신뢰할 수 있는 소스)
  void _mergePremiumStatus(
    Map<String, dynamic> target,
    Map<String, dynamic> server,
  ) {
    target['isPremium'] = server['isPremium'] ?? false;
    target['premiumTier'] = server['premiumTier'];
    target['premiumExpiryDate'] = server['premiumExpiryDate'];
    target['hasHadTrial'] = server['hasHadTrial'] ?? false;

    Logger.debug(
      '프리미엄 상태 - 서버 데이터 사용: isPremium=${target['isPremium']}',
      tag: _tag,
    );
  }

  /// 오답 노트 충돌 해결
  Map<String, dynamic> resolveWrongAnswerConflict(ConflictMetadata conflict) {
    Logger.info(
      '오답 노트 충돌 해결: ${conflict.entityId}',
      tag: _tag,
    );

    // 오답 노트는 누적 데이터이므로 병합
    final merged = Map<String, dynamic>.from(conflict.serverData);

    // 복습 횟수는 더 큰 값 유지
    final localReviewCount = conflict.localData['reviewCount'] as int? ?? 0;
    final serverReviewCount = conflict.serverData['reviewCount'] as int? ?? 0;
    merged['reviewCount'] = localReviewCount > serverReviewCount
        ? localReviewCount
        : serverReviewCount;

    // 마지막 복습 시간은 더 최신 시간 유지
    final localLastReview =
        (conflict.localData['lastReviewedAt'] as Timestamp?)?.toDate();
    final serverLastReview =
        (conflict.serverData['lastReviewedAt'] as Timestamp?)?.toDate();

    if (localLastReview != null && serverLastReview != null) {
      merged['lastReviewedAt'] = Timestamp.fromDate(
          localLastReview.isAfter(serverLastReview)
              ? localLastReview
              : serverLastReview);
    }

    // 마스터 여부는 OR 연산 (한 번이라도 마스터하면 마스터)
    merged['isMastered'] = (conflict.localData['isMastered'] ?? false) ||
        (conflict.serverData['isMastered'] ?? false);

    merged['updatedAt'] = FieldValue.serverTimestamp();

    return merged;
  }

  /// 리그 데이터 충돌 해결
  Map<String, dynamic> resolveLeagueConflict(ConflictMetadata conflict) {
    Logger.info(
      '리그 데이터 충돌 해결: ${conflict.entityId}',
      tag: _tag,
    );

    // 리그 데이터는 서버 우선 (중앙 관리 데이터)
    Logger.info('리그 데이터는 서버 우선 정책 적용', tag: _tag);
    return conflict.serverData;
  }

  /// 일반 데이터 충돌 해결 (Last-Write-Wins)
  Map<String, dynamic> resolveGenericConflict(ConflictMetadata conflict) {
    Logger.info(
      '일반 데이터 충돌 해결 (LWW): ${conflict.entityType}/${conflict.entityId}',
      tag: _tag,
    );

    if (conflict.isLocalNewer) {
      Logger.info('로컬 데이터가 더 최신', tag: _tag);
      return conflict.localData;
    } else {
      Logger.info('서버 데이터가 더 최신', tag: _tag);
      return conflict.serverData;
    }
  }

  /// 충돌 해결 전략 선택
  Map<String, dynamic> resolveConflict(
    String entityType,
    String entityId,
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
  ) {
    // 타임스탬프 추출
    final localTimestamp = _extractTimestamp(localData);
    final serverTimestamp = _extractTimestamp(serverData);

    final conflict = ConflictMetadata(
      localTimestamp: localTimestamp,
      serverTimestamp: serverTimestamp,
      entityType: entityType,
      entityId: entityId,
      localData: localData,
      serverData: serverData,
    );

    // 충돌이 없으면 서버 데이터 반환
    if (!conflict.hasConflict) {
      Logger.debug('충돌 없음 - 서버 데이터 반환', tag: _tag);
      return serverData;
    }

    // 엔티티 타입별 충돌 해결
    switch (entityType.toLowerCase()) {
      case 'user':
      case 'users':
        return resolveUserConflict(conflict);
      case 'wronganswer':
      case 'wronganswers':
        return resolveWrongAnswerConflict(conflict);
      case 'league':
      case 'leagues':
        return resolveLeagueConflict(conflict);
      default:
        return resolveGenericConflict(conflict);
    }
  }

  /// 타임스탬프 추출
  DateTime _extractTimestamp(Map<String, dynamic> data) {
    // updatedAt 우선, 없으면 createdAt
    final updatedAt = data['updatedAt'];
    final createdAt = data['createdAt'];

    if (updatedAt != null) {
      if (updatedAt is Timestamp) {
        return updatedAt.toDate();
      } else if (updatedAt is DateTime) {
        return updatedAt;
      } else if (updatedAt is String) {
        return DateTime.parse(updatedAt);
      }
    }

    if (createdAt != null) {
      if (createdAt is Timestamp) {
        return createdAt.toDate();
      } else if (createdAt is DateTime) {
        return createdAt;
      } else if (createdAt is String) {
        return DateTime.parse(createdAt);
      }
    }

    // 타임스탬프가 없으면 현재 시간
    return DateTime.now();
  }

  /// 같은 날짜인지 확인 (UTC 기준)
  bool _isSameDay(DateTime date1, DateTime date2) {
    final utc1 = date1.toUtc();
    final utc2 = date2.toUtc();
    return utc1.year == utc2.year &&
        utc1.month == utc2.month &&
        utc1.day == utc2.day;
  }

  /// 충돌 통계 기록
  void recordConflict(
    String entityType,
    String entityId,
    ResolutionStrategy strategy,
    bool resolved,
  ) {
    Logger.info(
      '충돌 기록: $entityType/$entityId - 전략: $strategy, 해결: $resolved',
      tag: _tag,
    );

    // TODO: 충돌 통계를 Analytics에 전송하여 모니터링
    // 충돌이 자주 발생하는 패턴을 파악하여 개선
  }
}
