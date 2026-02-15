import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/problem/problem_model.dart';
import '../../services/problem_image_service.dart';
import '../infrastructure/firebase_providers.dart';

/// Provides a ProblemImageService instance
final problemImageServiceProvider = Provider<ProblemImageService>((ref) {
  return ProblemImageService();
});

/// Fetches problems filtered by lessonId (or all if null)
final adminProblemsProvider =
    FutureProvider.family<List<ProblemModel>, String?>((ref, lessonId) async {
  final firestore = ref.read(firestoreProvider);

  Query<Map<String, dynamic>> query = firestore.collection('problems');
  if (lessonId != null && lessonId.isNotEmpty) {
    query = query.where('lessonId', isEqualTo: lessonId);
  }

  final snapshot = await query.orderBy('lessonId').get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return ProblemModel.fromJson(data);
  }).toList();
});

/// Notifier for admin problem CRUD operations
class AdminProblemNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final ProblemImageService _imageService;

  AdminProblemNotifier(this._firestore, this._imageService)
      : super(const AsyncValue.data(null));

  /// Create a new problem, returns the document ID
  Future<String> createProblem(ProblemModel problem) async {
    state = const AsyncValue.loading();
    try {
      final data = problem.toJson();
      data.remove('id');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('problems').add(data);
      AppLogger.info('Problem created: ${docRef.id}', tag: 'AdminProblem');
      state = const AsyncValue.data(null);
      return docRef.id;
    } catch (e, st) {
      AppLogger.error('Failed to create problem', tag: 'AdminProblem', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update an existing problem
  Future<void> updateProblem(String id, ProblemModel problem) async {
    state = const AsyncValue.loading();
    try {
      final data = problem.toJson();
      data.remove('id');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('problems').doc(id).update(data);
      AppLogger.info('Problem updated: $id', tag: 'AdminProblem');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to update problem', tag: 'AdminProblem', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a problem and its images
  Future<void> deleteProblem(String id, List<String> imageUrls) async {
    state = const AsyncValue.loading();
    try {
      // Delete images from Storage
      if (imageUrls.isNotEmpty) {
        await _imageService.deleteAllImages(id);
      }

      // Delete Firestore document
      await _firestore.collection('problems').doc(id).delete();
      AppLogger.info('Problem deleted: $id', tag: 'AdminProblem');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete problem', tag: 'AdminProblem', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminProblemNotifierProvider =
    StateNotifierProvider<AdminProblemNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.read(firestoreProvider);
  final imageService = ref.read(problemImageServiceProvider);
  return AdminProblemNotifier(firestore, imageService);
});
