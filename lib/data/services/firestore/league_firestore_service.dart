import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/utils/logger.dart';
import '../../models/gamification/league.dart';

/// 리그 관련 Firestore 서비스
///
/// 역할:
/// - 리그 CRUD
/// - 리그 참가자 관리
/// - 리그 순위 관리
/// - 리그 종료 처리
class LeagueFirestoreService {
  final FirebaseFirestore _firestore;

  LeagueFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== 리그 조회 ====================

  /// 현재 리그 조회
  Future<League?> getCurrentLeague(String leagueId) async {
    try {
      Logger.info('Firestore에서 리그 조회: $leagueId', tag: 'LeagueFirestoreService');

      final doc = await _firestore.collection('leagues').doc(leagueId).get();

      if (!doc.exists) {
        Logger.warning('리그를 찾을 수 없음: $leagueId', tag: 'LeagueFirestoreService');
        return null;
      }

      return League.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error(
        '리그 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueFirestoreService',
      );
      throw Exception('리그 조회 실패: $e');
    }
  }

  /// 리그 실시간 감지
  Stream<League?> watchLeague(String leagueId) {
    try {
      return _firestore
          .collection('leagues')
          .doc(leagueId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) return null;
        return League.fromFirestore(snapshot);
      });
    } catch (e, stackTrace) {
      Logger.error(
        '리그 스트림 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueFirestoreService',
      );
      return Stream.value(null);
    }
  }

  // ==================== 리그 생성 ====================

  /// 리그 생성
  Future<void> createLeague(League league) async {
    try {
      Logger.info('리그 생성: ${league.id}', tag: 'LeagueFirestoreService');

      await _firestore
          .collection('leagues')
          .doc(league.id)
          .set(league.toFirestore());

      Logger.info('리그 생성 완료', tag: 'LeagueFirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueFirestoreService',
      );
      throw Exception('리그 생성 실패: $e');
    }
  }

  // ==================== 리그 참가자 관리 ====================

  /// 리그 참가자 업데이트 (트랜잭션 사용)
  Future<void> updateLeagueParticipant(
    String leagueId,
    String userId,
    Map<String, dynamic> participantData,
  ) async {
    try {
      Logger.info('리그 참가자 업데이트: $leagueId, $userId', tag: 'LeagueFirestoreService');

      final leagueRef = _firestore.collection('leagues').doc(leagueId);

      await _firestore.runTransaction((transaction) async {
        final leagueDoc = await transaction.get(leagueRef);

        if (!leagueDoc.exists) {
          throw Exception('리그를 찾을 수 없습니다: $leagueId');
        }

        final data = leagueDoc.data()!;
        final participants = List<Map<String, dynamic>>.from(
          data['participants'] as List? ?? [],
        );

        // 기존 참가자 찾기
        final existingIndex = participants.indexWhere(
          (p) => p['userId'] == userId,
        );

        if (existingIndex >= 0) {
          // 기존 참가자 업데이트
          participants[existingIndex] = {
            ...participants[existingIndex],
            ...participantData,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          };
        } else {
          // 새 참가자 추가
          participants.add({
            'userId': userId,
            ...participantData,
            'joinedAt': Timestamp.fromDate(DateTime.now()),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }

        // 순위 재계산 (XP 기준 내림차순)
        participants.sort((a, b) {
          final aXp = a['xp'] as int? ?? 0;
          final bXp = b['xp'] as int? ?? 0;
          return bXp.compareTo(aXp);
        });

        // 순위 업데이트
        for (int i = 0; i < participants.length; i++) {
          participants[i]['rank'] = i + 1;
        }

        // Firestore 업데이트
        transaction.update(leagueRef, {
          'participants': participants,
          'participantCount': participants.length,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      Logger.info('리그 참가자 업데이트 완료', tag: 'LeagueFirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 참가자 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueFirestoreService',
      );
      throw Exception('리그 참가자 업데이트 실패: $e');
    }
  }

  /// 사용자를 리그에 할당
  Future<void> assignUserToLeague(String userId, String leagueId) async {
    try {
      Logger.info('사용자를 리그에 할당: $userId → $leagueId', tag: 'LeagueFirestoreService');

      await _firestore.collection('users').doc(userId).update({
        'currentLeagueId': leagueId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      Logger.info('사용자 리그 할당 완료', tag: 'LeagueFirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 리그 할당 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueFirestoreService',
      );
      throw Exception('사용자 리그 할당 실패: $e');
    }
  }

  // ==================== 리그 종료 ====================

  /// 리그 종료 처리
  Future<void> finalizeLeague(String leagueId) async {
    try {
      Logger.info('리그 종료 처리: $leagueId', tag: 'LeagueFirestoreService');

      final leagueRef = _firestore.collection('leagues').doc(leagueId);

      await _firestore.runTransaction((transaction) async {
        final leagueDoc = await transaction.get(leagueRef);

        if (!leagueDoc.exists) {
          throw Exception('리그를 찾을 수 없습니다: $leagueId');
        }

        final data = leagueDoc.data()!;
        final participants = List<Map<String, dynamic>>.from(
          data['participants'] as List? ?? [],
        );

        // 최종 순위 확정
        participants.sort((a, b) {
          final aXp = a['xp'] as int? ?? 0;
          final bXp = b['xp'] as int? ?? 0;
          return bXp.compareTo(aXp);
        });

        for (int i = 0; i < participants.length; i++) {
          participants[i]['finalRank'] = i + 1;
        }

        // 리그 종료 상태 업데이트
        transaction.update(leagueRef, {
          'participants': participants,
          'status': 'completed',
          'endedAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      Logger.info('리그 종료 처리 완료', tag: 'LeagueFirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 종료 처리 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LeagueFirestoreService',
      );
      throw Exception('리그 종료 처리 실패: $e');
    }
  }
}
