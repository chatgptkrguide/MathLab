import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/achievement_model.dart';
import '../../services/admin_image_service.dart';
import '../infrastructure/firebase_providers.dart';

/// Provides an AdminImageService instance
final adminImageServiceProvider = Provider<AdminImageService>((ref) {
  return AdminImageService();
});

/// Fetches all achievements from Firestore
final adminAchievementsProvider =
    FutureProvider<List<AchievementModel>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  final snapshot = await firestore
      .collection('achievements')
      .orderBy('category')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return AchievementModel.fromJson(data);
  }).toList();
});

/// Notifier for admin achievement CRUD operations
class AdminAchievementNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final AdminImageService _imageService;

  AdminAchievementNotifier(this._firestore, this._imageService)
      : super(const AsyncValue.data(null));

  /// Create a new achievement, returns the document ID
  Future<String> createAchievement(AchievementModel achievement) async {
    state = const AsyncValue.loading();
    try {
      final data = achievement.toJson();
      data.remove('id');
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('achievements').add(data);
      AppLogger.info('Achievement created: ${docRef.id}',
          tag: 'AdminAchievement');
      state = const AsyncValue.data(null);
      return docRef.id;
    } catch (e, st) {
      AppLogger.error('Failed to create achievement',
          tag: 'AdminAchievement', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update an existing achievement
  Future<void> updateAchievement(
      String id, AchievementModel achievement) async {
    state = const AsyncValue.loading();
    try {
      final data = achievement.toJson();
      data.remove('id');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('achievements').doc(id).update(data);
      AppLogger.info('Achievement updated: $id', tag: 'AdminAchievement');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to update achievement',
          tag: 'AdminAchievement', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete an achievement and its icon image
  Future<void> deleteAchievement(String id, String iconUrl) async {
    state = const AsyncValue.loading();
    try {
      // Delete icon image from Storage
      if (iconUrl.isNotEmpty) {
        await _imageService.deleteAllImages('achievements/$id');
      }

      // Delete Firestore document
      await _firestore.collection('achievements').doc(id).delete();
      AppLogger.info('Achievement deleted: $id', tag: 'AdminAchievement');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to delete achievement',
          tag: 'AdminAchievement', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminAchievementNotifierProvider =
    StateNotifierProvider<AdminAchievementNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.read(firestoreProvider);
  final imageService = ref.read(adminImageServiceProvider);
  return AdminAchievementNotifier(firestore, imageService);
});
