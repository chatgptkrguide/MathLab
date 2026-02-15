import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/lesson/lesson_model.dart';
import '../infrastructure/firebase_providers.dart';

/// Fetches lessons for a specific unit
final adminLessonsProvider =
    FutureProvider.family<List<LessonModel>, String>((ref, unitId) async {
  final firestore = ref.read(firestoreProvider);

  final snapshot = await firestore
      .collection('units')
      .doc(unitId)
      .collection('lessons')
      .orderBy('order')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return LessonModel.fromJson(data);
  }).toList();
});

/// Notifier for admin lesson CRUD operations
class AdminLessonNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  AdminLessonNotifier(this._firestore) : super(const AsyncValue.data(null));

  /// Create a new lesson in a unit
  Future<String> createLesson(String unitId, LessonModel lesson) async {
    state = const AsyncValue.loading();
    try {
      final data = lesson.toJson();
      data.remove('id');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection('units')
          .doc(unitId)
          .collection('lessons')
          .add(data);

      AppLogger.info('Lesson created: ${docRef.id} in unit $unitId',
          tag: 'AdminLesson');
      state = const AsyncValue.data(null);
      return docRef.id;
    } catch (e, st) {
      AppLogger.error('Failed to create lesson', tag: 'AdminLesson', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update an existing lesson
  Future<void> updateLesson(
      String unitId, String lessonId, LessonModel lesson) async {
    state = const AsyncValue.loading();
    try {
      final data = lesson.toJson();
      data.remove('id');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('units')
          .doc(unitId)
          .collection('lessons')
          .doc(lessonId)
          .update(data);

      AppLogger.info('Lesson updated: $lessonId', tag: 'AdminLesson');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to update lesson', tag: 'AdminLesson', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a lesson and cascade delete associated problems
  Future<void> deleteLesson(String unitId, String lessonId) async {
    state = const AsyncValue.loading();
    try {
      // Delete the lesson
      await _firestore
          .collection('units')
          .doc(unitId)
          .collection('lessons')
          .doc(lessonId)
          .delete();

      // Delete associated problems (chunked to stay under 500-doc batch limit)
      final problemsSnapshot = await _firestore
          .collection('problems')
          .where('lessonId', isEqualTo: lessonId)
          .get();

      if (problemsSnapshot.docs.isNotEmpty) {
        final refs = problemsSnapshot.docs.map((d) => d.reference).toList();
        const chunkSize = 499;
        for (var i = 0; i < refs.length; i += chunkSize) {
          final chunk = refs.sublist(
              i, i + chunkSize > refs.length ? refs.length : i + chunkSize);
          final batch = _firestore.batch();
          for (final ref in chunk) {
            batch.delete(ref);
          }
          await batch.commit();
        }
      }

      AppLogger.info(
        'Lesson deleted: $lessonId (${problemsSnapshot.docs.length} problems cascaded)',
        tag: 'AdminLesson',
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete lesson', tag: 'AdminLesson', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reorder lessons within a unit
  Future<void> reorderLessons(String unitId, List<LessonModel> lessons) async {
    state = const AsyncValue.loading();
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < lessons.length; i++) {
        batch.update(
          _firestore
              .collection('units')
              .doc(unitId)
              .collection('lessons')
              .doc(lessons[i].id),
          {'order': i, 'updatedAt': FieldValue.serverTimestamp()},
        );
      }
      await batch.commit();
      AppLogger.info(
          'Lessons reordered in unit $unitId (${lessons.length})',
          tag: 'AdminLesson');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to reorder lessons',
          tag: 'AdminLesson', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminLessonNotifierProvider =
    StateNotifierProvider<AdminLessonNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return AdminLessonNotifier(firestore);
});
