// 📚 Curriculum Provider
//
// 커리큘럼 메타데이터 (단원·레슨 제목, 과목, 순서) 는 정적 콘텐츠라
// `CurriculumData` 코드 상수를 단일 진실로 사용한다.
//
// Firestore 의 `units` 컬렉션에 과거에 시드된 영문 라벨이 남아 있어
// 화면에 "arithmetic" 등이 노출되는 문제가 있었음 (2026-05). 코드 측
// 데이터가 항상 최신·한글이므로 Firestore 폴백을 제거하고 코드를 우선시.
//
// 진도/통계 등 사용자별 동적 데이터는 별도 provider (lesson_progress 등) 에서
// Firestore 와 동기화.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/lesson/curriculum_data.dart';
import '../../models/lesson/unit_model.dart';

final curriculumProvider = FutureProvider<List<UnitModel>>((ref) async {
  final units = CurriculumData.getSampleUnits();
  AppLogger.info(
    '커리큘럼 ${units.length}개 유닛 / ${units.fold<int>(0, (s, u) => s + u.lessonCount)}개 레슨 (코드 단일 진실)',
    tag: 'Curriculum',
  );
  return units;
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
