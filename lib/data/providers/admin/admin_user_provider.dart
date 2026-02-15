import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/user/user_model.dart';
import '../infrastructure/firebase_providers.dart';

/// Fetches all users ordered by creation date (newest first), limited to 100
final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final firestore = ref.read(firestoreProvider);

  try {
    final snapshot = await firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  } catch (e) {
    AppLogger.error('Failed to load users', tag: 'AdminUser', error: e);
    rethrow;
  }
});

/// Notifier for admin user management operations
class AdminUserNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  AdminUserNotifier(this._firestore) : super(const AsyncValue.data(null));

  /// Update the role of a user
  Future<void> updateUserRole(String uid, String newRole) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('User role updated: $uid -> $newRole', tag: 'AdminUser');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error('Failed to update user role',
          tag: 'AdminUser', error: e);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final adminUserNotifierProvider =
    StateNotifierProvider<AdminUserNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return AdminUserNotifier(firestore);
});
