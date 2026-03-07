// 📝 Problem Provider
//
// Manages problem data with Firestore integration and offline fallback.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/problem/problem_model.dart';
import '../../models/problem/sample_problems.dart';
import '../infrastructure/firebase_providers.dart';

/// 레슨별 문제 데이터 Provider (Firestore + 오프라인 폴백)
final problemsForLessonProvider =
    FutureProvider.family<List<ProblemModel>, String>((ref, lessonId) async {
  final firestore = ref.read(firestoreProvider);

  try {
    final snapshot = await firestore
        .collection('problems')
        .where('lessonId', isEqualTo: lessonId)
        .orderBy('createdAt')
        .get();

    if (snapshot.docs.isEmpty) {
      // Firestore에 데이터가 없으면 샘플 데이터로 폴백
      AppLogger.info(
        'Firestore에 문제 없음, 샘플 데이터 사용: $lessonId',
        tag: 'Problem',
      );
      return SampleProblems.getProblemsForLesson(lessonId);
    }

    final problems = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ProblemModel.fromJson(data);
    }).toList();

    AppLogger.info(
      '${problems.length}개 문제 로드: $lessonId',
      tag: 'Problem',
    );
    return problems;
  } catch (e, stackTrace) {
    // 네트워크 오류 등 → 샘플 데이터로 폴백
    AppErrorHandler.handle(e, stackTrace);
    AppLogger.warning(
      'Firestore 문제 로드 실패, 샘플 데이터 사용: $lessonId',
      tag: 'Problem',
    );
    return SampleProblems.getProblemsForLesson(lessonId);
  }
});

/// 문제 시드 데이터 업로드 유틸리티
class ProblemSeeder {
  static Future<void> seedProblems(FirebaseFirestore firestore) async {
    final lessonIds = ['lesson_1_1', 'lesson_1_2', 'lesson_1_3'];
    final batch = firestore.batch();

    for (final lessonId in lessonIds) {
      final problems = SampleProblems.getProblemsForLesson(lessonId);
      for (var i = 0; i < problems.length; i++) {
        final problem = problems[i];
        final data = problem.toJson();
        data['order'] = i;
        data['createdAt'] = FieldValue.serverTimestamp();

        batch.set(
          firestore.collection('problems').doc(problem.id),
          data,
        );
      }
    }

    await batch.commit();
    AppLogger.info('시드 데이터 업로드 완료', tag: 'ProblemSeeder');
  }
}
