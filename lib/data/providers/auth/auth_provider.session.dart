// 🔐 Auth provider — session management
//
// part of auth_provider.dart. Owns signOut, deleteAccount, isSessionValid.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'auth_provider.dart';

extension AuthSession on Auth {
  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      AppLogger.info('Starting signout', tag: 'Auth');

      // Sign out from all providers
      await Future.wait([
        _firebaseAuth.signOut(),
        _getGoogleSignIn().signOut(),
        _safeKakaoLogout(),
      ]);

      // Clear secure storage
      await _storage.clearAll();

      // Clear user data
      ref.read(userProvider.notifier).clearUser();

      // Update state
      state = const AuthState(isAuthenticated: false);

      AppLogger.info('Signout successful', tag: 'Auth');
    } catch (e, st) {
      AppLogger.error('Signout failed', tag: 'Auth', error: e, stackTrace: st);
      throw AuthException(
        message: '로그아웃 중 오류가 발생했습니다',
        type: AuthErrorType.unknown,
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting account deletion', tag: 'Auth');

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: '로그인된 사용자가 없습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Delete user data from Firestore
      await ref.read(userProvider.notifier).deleteUser(user.uid);

      // Delete Firebase Auth account
      await user.delete();

      // Clear secure storage
      await _storage.clearAll();

      // Update state
      state = const AuthState(isAuthenticated: false);

      AppLogger.info('Account deletion successful', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Account deletion failed', tag: 'Auth', error: e);

      if (e.code == 'requires-recent-login') {
        state = state.copyWith(
          isLoading: false,
          error: '계정을 삭제하려면 다시 로그인해주세요',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: _getFirebaseAuthErrorMessage(e.code),
        );
      }
      return false;
    } catch (e, st) {
      AppLogger.error('Account deletion failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '계정 삭제 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  /// Check if session is still valid
  Future<bool> isSessionValid() async {
    try {
      final isExpired = await _storage.isSessionExpired();
      return !isExpired && _firebaseAuth.currentUser != null;
    } catch (e) {
      AppLogger.error('Session validation failed', tag: 'Auth', error: e);
      return false;
    }
  }
}
