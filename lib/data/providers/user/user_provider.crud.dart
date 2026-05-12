// 👤 User provider — CRUD operations
//
// part of user_provider.dart. Owns loadUser / createUser / createGuestUser /
// updateProfile / deleteUser / clearUser.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'user_provider.dart';

extension UserCrud on User {
  /// Load user from Firestore
  Future<void> loadUser(String uid) async {
    try {
      AppLogger.info('Loading user data', tag: 'User', data: {'uid': uid});

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        AppLogger.warning('User document not found, creating new user', tag: 'User');
        // Create new user document if it doesn't exist
        await createUser(uid);
        return;
      }

      state = UserModel.fromFirestore(doc);
      AppLogger.info('User data loaded successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to load user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '사용자 정보를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Create new user in Firestore
  Future<void> createUser(
    String uid, {
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider provider = AuthProvider.email,
    bool isEmailVerified = false,
  }) async {
    try {
      AppLogger.info('Creating new user', tag: 'User', data: {'uid': uid});

      final user = UserModel.fromFirebase(
        uid: uid,
        provider: provider,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isEmailVerified: isEmailVerified,
      );

      await _firestore.collection('users').doc(uid).set(user.toFirestore());

      state = user;
      AppLogger.info('User created successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to create user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '사용자 정보를 생성하는데 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Create guest user
  Future<void> createGuestUser(String uid) async {
    try {
      AppLogger.info('Creating guest user', tag: 'User', data: {'uid': uid});

      final user = UserModel.guest(uid);

      await _firestore.collection('users').doc(uid).set(user.toFirestore());

      state = user;
      AppLogger.info('Guest user created successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to create guest user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '게스트 사용자 생성에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? currentGrade,
  }) async {
    if (state == null) {
      throw const DataException(message: '사용자 정보가 없습니다');
    }

    try {
      AppLogger.info('Updating user profile', tag: 'User');

      final updatedUser = state!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        currentGrade: currentGrade,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updatedUser.toFirestore());

      state = updatedUser;
      AppLogger.info('User profile updated successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to update profile', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '프로필 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete user data from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      AppLogger.info('Deleting user data', tag: 'User', data: {'uid': uid});

      await _firestore.collection('users').doc(uid).delete();

      state = null;
      AppLogger.info('User data deleted successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to delete user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '사용자 데이터 삭제에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Clear user state
  void clearUser() {
    state = null;
    AppLogger.info('User state cleared', tag: 'User');
  }
}
