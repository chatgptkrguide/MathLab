import 'base_repository.dart';
import '../models/learning/lesson.dart';
import '../../shared/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 레슨 Repository
///
/// 역할:
/// - 레슨 데이터 CRUD
/// - 로컬 + Firebase 동기화
/// - 학년별/카테고리별 레슨 조회
/// - 레슨 잠금/해제 관리
class LessonRepository extends BaseRepository<List<Lesson>> {
  LessonRepository({
    required super.localStorageService,
    required super.firestoreService,
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== 로컬 스토리지 ====================

  @override
  Future<List<Lesson>?> getFromLocal(String storageKey) async {
    try {
      final json = await localStorageService.loadMap(storageKey);

      if (json == null || json.isEmpty || json['lessons'] == null) {
        Logger.debug('로컬에 레슨 데이터 없음: $storageKey', tag: 'LessonRepository');
        return null;
      }

      final lessonsList = json['lessons'] as List;
      return lessonsList
          .map((lessonJson) => Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 레슨 데이터 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToLocal(String storageKey, List<Lesson> data) async {
    try {
      await localStorageService.saveMap(storageKey, {
        'lessons': data.map((lesson) => lesson.toJson()).toList(),
      });
      Logger.debug('로컬에 레슨 ${data.length}개 저장 완료: $storageKey', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 레슨 데이터 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      throw Exception('로컬 레슨 데이터 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromLocal(String storageKey) async {
    try {
      await localStorageService.remove(storageKey);
      Logger.debug('로컬 레슨 데이터 삭제 완료: $storageKey', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '로컬 레슨 데이터 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
    }
  }

  // ==================== Firebase ====================

  @override
  Future<List<Lesson>?> getFromFirebase(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('lessons')
          .orderBy('order')
          .get();

      if (querySnapshot.docs.isEmpty) {
        Logger.debug('Firestore에 레슨 데이터 없음', tag: 'LessonRepository');
        return null;
      }

      final lessons = querySnapshot.docs
          .map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      Logger.debug('Firestore에서 ${lessons.length}개 레슨 조회 완료', tag: 'LessonRepository');
      return lessons;
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 레슨 데이터 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      return null;
    }
  }

  @override
  Future<void> saveToFirebase(String userId, List<Lesson> data) async {
    try {
      final batch = _firestore.batch();

      for (final lesson in data) {
        final docRef = _firestore.collection('lessons').doc(lesson.id);
        batch.set(docRef, lesson.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      Logger.debug('Firestore에 레슨 ${data.length}개 저장 완료', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 레슨 데이터 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      throw Exception('Firebase 레슨 데이터 저장 실패: $e');
    }
  }

  @override
  Future<void> deleteFromFirebase(String userId) async {
    try {
      final querySnapshot = await _firestore.collection('lessons').get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      Logger.debug('Firestore 레슨 데이터 삭제 완료', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 레슨 데이터 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
    }
  }

  // ==================== 충돌 해결 ====================

  @override
  Future<List<Lesson>?> mergeData(List<Lesson> local, List<Lesson> remote) async {
    // 레슨 데이터는 주로 읽기 전용이므로 Firebase를 우선
    // 하지만 사용자의 진행률 데이터(completedProblems, isUnlocked)는 로컬 우선
    Logger.debug('레슨 데이터 충돌 해결 시작', tag: 'LessonRepository');

    final mergedLessons = <Lesson>[];
    final localMap = {for (var lesson in local) lesson.id: lesson};
    final remoteMap = {for (var lesson in remote) lesson.id: lesson};

    // 모든 레슨 ID 수집
    final allIds = {...localMap.keys, ...remoteMap.keys};

    for (final id in allIds) {
      final localLesson = localMap[id];
      final remoteLesson = remoteMap[id];

      if (localLesson != null && remoteLesson != null) {
        // 둘 다 있으면 병합: 기본 정보는 Firebase, 진행률은 로컬 우선
        mergedLessons.add(remoteLesson.copyWith(
          completedProblems: localLesson.completedProblems,
          isUnlocked: localLesson.isUnlocked,
          completedAt: localLesson.completedAt,
        ));
      } else if (remoteLesson != null) {
        // Firebase에만 있으면 그대로 사용
        mergedLessons.add(remoteLesson);
      } else if (localLesson != null) {
        // 로컬에만 있으면 로컬 사용 (특이 케이스)
        mergedLessons.add(localLesson);
      }
    }

    mergedLessons.sort((a, b) => a.order.compareTo(b.order));
    Logger.debug('레슨 데이터 병합 완료: ${mergedLessons.length}개', tag: 'LessonRepository');
    return mergedLessons;
  }

  // ==================== 추가 메서드 ====================

  /// 레슨 실시간 감지 (Firebase Stream)
  Stream<List<Lesson>> watchLessons() {
    try {
      return _firestore
          .collection('lessons')
          .orderBy('order')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      });
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 실시간 감지 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      return Stream.value([]);
    }
  }

  /// 학년별 레슨 조회 (Firebase)
  Future<List<Lesson>> getLessonsByGrade(String grade) async {
    try {
      final querySnapshot = await _firestore
          .collection('lessons')
          .where('grade', isEqualTo: grade)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '학년별 레슨 조회 실패: $grade',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      return [];
    }
  }

  /// 카테고리별 레슨 조회 (Firebase)
  Future<List<Lesson>> getLessonsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('lessons')
          .where('category', isEqualTo: category)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '카테고리별 레슨 조회 실패: $category',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      return [];
    }
  }

  /// 특정 레슨 조회
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final doc = await _firestore.collection('lessons').doc(lessonId).get();

      if (!doc.exists) {
        Logger.warning('레슨을 찾을 수 없음: $lessonId', tag: 'LessonRepository');
        return null;
      }

      return Lesson.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 조회 실패: $lessonId',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      return null;
    }
  }

  /// 레슨 진행률 업데이트 (단일 레슨)
  Future<void> updateLessonProgress({
    required String lessonId,
    required int completedProblems,
    bool? isUnlocked,
    DateTime? completedAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'completedProblems': completedProblems,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isUnlocked != null) {
        updateData['isUnlocked'] = isUnlocked;
      }

      if (completedAt != null) {
        updateData['completedAt'] = completedAt.toIso8601String();
      }

      await _firestore.collection('lessons').doc(lessonId).update(updateData);
      Logger.info('레슨 진행률 업데이트 완료: $lessonId', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 진행률 업데이트 실패: $lessonId',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      throw Exception('레슨 진행률 업데이트 실패: $e');
    }
  }

  /// 레슨 잠금 해제
  Future<void> unlockLesson(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'isUnlocked': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Logger.info('레슨 잠금 해제 완료: $lessonId', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 잠금 해제 실패: $lessonId',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      throw Exception('레슨 잠금 해제 실패: $e');
    }
  }

  /// 레슨 초기화 (관리자용)
  Future<void> resetAllLessons() async {
    try {
      final querySnapshot = await _firestore.collection('lessons').get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'completedProblems': 0,
          'isUnlocked': false,
          'completedAt': null,
        });
      }

      // 첫 번째 레슨만 잠금 해제
      if (querySnapshot.docs.isNotEmpty) {
        final firstLesson = querySnapshot.docs
            .map((doc) => MapEntry(doc.id, doc.data()['order'] as int))
            .reduce((a, b) => a.value < b.value ? a : b);

        batch.update(
          _firestore.collection('lessons').doc(firstLesson.key),
          {'isUnlocked': true},
        );
      }

      await batch.commit();
      Logger.info('모든 레슨 초기화 완료', tag: 'LessonRepository');
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonRepository',
      );
      throw Exception('레슨 초기화 실패: $e');
    }
  }
}
