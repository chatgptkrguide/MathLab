// 📚 Curriculum Provider
//
// Manages curriculum data with Firestore integration and offline fallback.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/lesson/curriculum_data.dart';
import '../../models/lesson/unit_model.dart';
import '../infrastructure/firebase_providers.dart';

/// 커리큘럼 유닛 데이터 Provider (Firestore + 오프라인 폴백)
final curriculumProvider =
    FutureProvider<List<UnitModel>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  try {
    final snapshot = await firestore
        .collection('units')
        .orderBy('order')
        .get();

    if (snapshot.docs.isEmpty) {
      AppLogger.info(
        'Firestore에 커리큘럼 없음, 샘플 데이터 사용',
        tag: 'Curriculum',
      );
      return CurriculumData.getSampleUnits();
    }

    final units = <UnitModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      // 서브컬렉션에서 레슨 로드
      final lessonsSnapshot = await firestore
          .collection('units')
          .doc(doc.id)
          .collection('lessons')
          .orderBy('order')
          .get();

      data['lessons'] = lessonsSnapshot.docs.map((lessonDoc) {
        final lessonData = lessonDoc.data();
        lessonData['id'] = lessonDoc.id;
        return lessonData;
      }).toList();

      units.add(UnitModel.fromJson(data));
    }

    AppLogger.info(
      '${units.length}개 유닛 로드 (총 ${units.fold<int>(0, (s, u) => s + u.lessonCount)}개 레슨)',
      tag: 'Curriculum',
    );
    return units;
  } catch (e, stackTrace) {
    AppErrorHandler.handle(e, stackTrace);
    AppLogger.warning(
      'Firestore 커리큘럼 로드 실패, 샘플 데이터 사용',
      tag: 'Curriculum',
    );
    return CurriculumData.getSampleUnits();
  }
});

/// 커리큘럼 시드 데이터 업로드 유틸리티
class CurriculumSeeder {
  static Future<void> seedCurriculum(FirebaseFirestore firestore) async {
    final units = CurriculumData.getSampleUnits();

    for (final unit in units) {
      final unitData = unit.toJson();
      // 레슨은 서브컬렉션으로 저장하므로 제거
      unitData.remove('lessons');
      unitData['createdAt'] = FieldValue.serverTimestamp();

      await firestore.collection('units').doc(unit.id).set(unitData);

      // 레슨을 서브컬렉션으로 저장
      final batch = firestore.batch();
      for (var i = 0; i < unit.lessons.length; i++) {
        final lesson = unit.lessons[i];
        final lessonData = lesson.toJson();
        lessonData['createdAt'] = FieldValue.serverTimestamp();

        batch.set(
          firestore
              .collection('units')
              .doc(unit.id)
              .collection('lessons')
              .doc(lesson.id),
          lessonData,
        );
      }
      await batch.commit();
    }

    AppLogger.info('커리큘럼 시드 데이터 업로드 완료', tag: 'CurriculumSeeder');
  }
}
