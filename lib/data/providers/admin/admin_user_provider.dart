import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../models/user/user_model.dart';
import '../infrastructure/firebase_providers.dart';

const _pageSize = 30;

/// Manages paginated user list for admin
class AdminUserListNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final FirebaseFirestore _firestore;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  AdminUserListNotifier(this._firestore) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  bool get hasMore => _hasMore;

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    _lastDocument = null;
    _hasMore = true;

    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .get();

      final users =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      _hasMore = snapshot.docs.length >= _pageSize;
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      AppLogger.info('Admin: ${users.length} users loaded (initial)',
          tag: 'AdminUser');
      state = AsyncValue.data(users);
    } catch (e, st) {
      AppLogger.error('Failed to load users', tag: 'AdminUser', error: e);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _lastDocument == null) return;
    final currentUsers = state.valueOrNull ?? [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      final newUsers =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      _hasMore = snapshot.docs.length >= _pageSize;
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      AppLogger.info('Admin: ${newUsers.length} more users loaded',
          tag: 'AdminUser');
      state = AsyncValue.data([...currentUsers, ...newUsers]);
    } catch (e) {
      AppLogger.error('Failed to load more users', tag: 'AdminUser', error: e);
      // Keep existing data, just show error via SnackBar
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final adminUserListProvider = StateNotifierProvider<AdminUserListNotifier,
    AsyncValue<List<UserModel>>>((ref) {
  final firestore = ref.read(firestoreProvider);
  return AdminUserListNotifier(firestore);
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
