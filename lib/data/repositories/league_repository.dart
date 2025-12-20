import 'base_repository.dart';
import '../models/league.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../../shared/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 리그 Repository
///
/// 역할:
/// - 주간 리그 데이터 CRUD
/// - 로컬 + Firebase 동기화
/// - 실시간 순위 업데이트
/// - 티어별 리그 매칭
class LeagueRepository extends BaseRepository<League> {
  LeagueRepository({
    required LocalStorageService localStorageService,
    required FirestoreService firestoreService,
  }) : super(
          localStorageService: localStorageService,
          firestoreService: firestoreService,
        );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== 로컬 스토리지 ====================

  @override
  Future<League?> getFromLocal(String storageKey) async {
    try {
      final json = await localStorageService.loadMap(storageKey);

      if (json == null || json.isEmpty) {
        Logger.debug('로컬에 리그 데이터 없음: $storageKey', tag: 'LeagueRepository');
        return null;
      }

      return League.fromJson(json);
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 리그 데이터 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToLocal(String storageKey, League data) async {
    try {
      await localStorageService.saveMap(storageKey, data.toJson());
      Logger.debug('로컬에 리그 데이터 저장 완료: $storageKey', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 리그 데이터 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      throw Exception('로컬 리그 데이터 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromLocal(String storageKey) async {
    try {
      await localStorageService.remove(storageKey);
      Logger.debug('로컬 리그 데이터 삭제 완료: $storageKey', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 리그 데이터 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
    }
  }

  // ==================== Firebase ====================

  @override
  Future<League?> getFromFirebase([String? userId]) async {
    try {
      // 현재 주차의 리그 조회
      final now = DateTime.now();
      final weekStart = _getWeekStartDate(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final leagueSnapshot = await _firestore
          .collection('leagues')
          .where('weekStartDate', isEqualTo: Timestamp.fromDate(weekStart))
          .where('weekEndDate', isEqualTo: Timestamp.fromDate(weekEnd))
          .limit(1)
          .get();

      if (leagueSnapshot.docs.isEmpty) {
        Logger.debug('Firestore에 현재 주차 리그 없음', tag: 'LeagueRepository');
        return null;
      }

      final leagueDoc = leagueSnapshot.docs.first;
      final leagueId = leagueDoc.id;

      // 참가자 정보 조회
      final participantsSnapshot = await _firestore
          .collection('leagues')
          .doc(leagueId)
          .collection('participants')
          .orderBy('weeklyXp', descending: true)
          .get();

      final participants = participantsSnapshot.docs
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final data = doc.data();
            return LeagueParticipant.fromJson({
              ...data,
              'rank': index + 1, // 순위는 정렬 순서대로
            });
          })
          .toList();

      final leagueData = leagueDoc.data();
      final league = League(
        tier: LeagueTier.values.firstWhere(
          (t) => t.toString() == leagueData['tier'],
          orElse: () => LeagueTier.bronze,
        ),
        participants: participants,
        weekStartDate: (leagueData['weekStartDate'] as Timestamp).toDate(),
        weekEndDate: (leagueData['weekEndDate'] as Timestamp).toDate(),
      );

      Logger.debug('Firestore에서 리그 조회 완료: ${participants.length}명 참가', tag: 'LeagueRepository');
      return league;
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 리그 데이터 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToFirebase(String userId, League data) async {
    try {
      final leagueId = _generateLeagueId(data.weekStartDate, data.tier);

      // 리그 기본 정보 저장
      await _firestore.collection('leagues').doc(leagueId).set({
        'tier': data.tier.toString(),
        'weekStartDate': Timestamp.fromDate(data.weekStartDate),
        'weekEndDate': Timestamp.fromDate(data.weekEndDate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 참가자 정보 저장 (배치)
      final batch = _firestore.batch();

      for (final participant in data.participants) {
        final participantRef = _firestore
            .collection('leagues')
            .doc(leagueId)
            .collection('participants')
            .doc(participant.userId);

        batch.set(participantRef, participant.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      Logger.debug('Firestore에 리그 데이터 저장 완료: ${data.participants.length}명', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 리그 데이터 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      throw Exception('Firebase 리그 데이터 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromFirebase(String userId) async {
    try {
      // 사용자가 참여한 모든 리그에서 참가자 정보 삭제
      final leaguesSnapshot = await _firestore.collection('leagues').get();

      final batch = _firestore.batch();
      for (final leagueDoc in leaguesSnapshot.docs) {
        final participantRef = leagueDoc.reference.collection('participants').doc(userId);
        batch.delete(participantRef);
      }

      await batch.commit();
      Logger.debug('Firestore 리그 참가자 정보 삭제 완료: $userId', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 리그 데이터 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
    }
  }

  // ==================== 충돌 해결 ====================

  @override
  Future<League?> mergeData(League local, League remote) async {
    // 리그 데이터는 Firebase를 우선 (서버 데이터가 항상 최신)
    Logger.debug('리그 데이터 충돌 해결: remote 우선', tag: 'LeagueRepository');
    return remote;
  }

  // ==================== 추가 메서드 ====================

  /// 실시간 리그 순위 감지
  Stream<League?> watchCurrentLeague([String? userId]) {
    try {
      final now = DateTime.now();
      final weekStart = _getWeekStartDate(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      return _firestore
          .collection('leagues')
          .where('weekStartDate', isEqualTo: Timestamp.fromDate(weekStart))
          .where('weekEndDate', isEqualTo: Timestamp.fromDate(weekEnd))
          .limit(1)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) return null;

        final leagueDoc = snapshot.docs.first;
        final leagueId = leagueDoc.id;

        // 참가자 실시간 조회
        final participantsSnapshot = await _firestore
            .collection('leagues')
            .doc(leagueId)
            .collection('participants')
            .orderBy('weeklyXp', descending: true)
            .get();

        final participants = participantsSnapshot.docs
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final doc = entry.value;
              final data = doc.data();
              return LeagueParticipant.fromJson({
                ...data,
                'rank': index + 1,
              });
            })
            .toList();

        final leagueData = leagueDoc.data();
        return League(
          tier: LeagueTier.values.firstWhere(
            (t) => t.toString() == leagueData['tier'],
            orElse: () => LeagueTier.bronze,
          ),
          participants: participants,
          weekStartDate: (leagueData['weekStartDate'] as Timestamp).toDate(),
          weekEndDate: (leagueData['weekEndDate'] as Timestamp).toDate(),
        );
      });
    } catch (e, stackTrace) {
      Logger.error(
        '리그 실시간 감지 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      return Stream.value(null);
    }
  }

  /// 사용자 XP 업데이트 (리그 순위 반영)
  Future<void> updateUserXP({
    required String userId,
    required int weeklyXp,
    LeagueTier tier = LeagueTier.bronze,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = _getWeekStartDate(now);
      final leagueId = _generateLeagueId(weekStart, tier);

      await _firestore
          .collection('leagues')
          .doc(leagueId)
          .collection('participants')
          .doc(userId)
          .update({
        'weeklyXp': weeklyXp,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('사용자 주간 XP 업데이트: $userId = $weeklyXp', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 XP 업데이트 실패: $userId',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      throw Exception('사용자 XP 업데이트 실패: $e');
    }
  }

  /// 리그 참가 (새 주차 시작 시)
  Future<void> joinLeague({
    required String userId,
    required String userName,
    required String? avatarUrl,
    LeagueTier tier = LeagueTier.bronze,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = _getWeekStartDate(now);
      final weekEnd = weekStart.add(const Duration(days: 7));
      final leagueId = _generateLeagueId(weekStart, tier);

      // 리그 기본 정보 생성
      await _firestore.collection('leagues').doc(leagueId).set({
        'tier': tier.toString(),
        'weekStartDate': Timestamp.fromDate(weekStart),
        'weekEndDate': Timestamp.fromDate(weekEnd),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 참가자 정보 저장
      await _firestore
          .collection('leagues')
          .doc(leagueId)
          .collection('participants')
          .doc(userId)
          .set({
        'userId': userId,
        'userName': userName,
        'weeklyXp': 0,
        'avatarUrl': avatarUrl,
        'badges': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('리그 참가 완료: $userId → $tier', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 참가 실패: $userId',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
      throw Exception('리그 참가 실패: $e');
    }
  }

  /// 뱃지 추가
  Future<void> addBadge({
    required String userId,
    required LeagueBadge badge,
    LeagueTier tier = LeagueTier.bronze,
  }) async {
    try {
      final now = DateTime.now();
      final weekStart = _getWeekStartDate(now);
      final leagueId = _generateLeagueId(weekStart, tier);

      await _firestore
          .collection('leagues')
          .doc(leagueId)
          .collection('participants')
          .doc(userId)
          .update({
        'badges': FieldValue.arrayUnion([badge.toString()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('뱃지 추가 완료: $userId → $badge', tag: 'LeagueRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '뱃지 추가 실패: $userId',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueRepository',
      );
    }
  }

  // ==================== 헬퍼 메서드 ====================

  /// 주차 시작일 계산 (월요일 00:00 기준)
  DateTime _getWeekStartDate(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    final daysToMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToMonday));
  }

  /// 리그 ID 생성
  String _generateLeagueId(DateTime weekStart, LeagueTier tier) {
    final dateStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    return '${tier.toString().split('.').last}_$dateStr';
  }
}
