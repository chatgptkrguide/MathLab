// 🔐 Auth provider — credential & profile management
//
// part of auth_provider.dart. Owns password reset, password change, email change,
// and applyTempProfileToAccount.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'auth_provider.dart';

extension AuthCredentials on Auth {
  // ========================================
  // Profile Management
  // ========================================

  /// Apply temporary profile data to the user account in Firestore
  Future<void> applyTempProfileToAccount(TempProfileData profileData) async {
    try {
      AppLogger.info('Applying temp profile to account', tag: 'Auth');

      await ref.read(userProvider.notifier).updateProfile(
            displayName: profileData.name,
          );

      AppLogger.info('Temp profile applied successfully', tag: 'Auth');
    } catch (e, st) {
      AppLogger.error('Failed to apply temp profile', tag: 'Auth', error: e, stackTrace: st);
    }
  }

  // ========================================
  // Password & Email Management
  // ========================================

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Sending password reset email', tag: 'Auth');

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      state = state.copyWith(isLoading: false);
      AppLogger.info('Password reset email sent', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Password reset failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  /// Change password (requires current password for re-authentication)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting password change', tag: 'Auth');

      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException(
          message: '로그인된 사용자가 없습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Re-authenticate user with current password
      final credential = auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      state = state.copyWith(isLoading: false);
      AppLogger.info('Password changed successfully', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Password change failed', tag: 'Auth', error: e);

      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = '현재 비밀번호가 올바르지 않습니다';
      } else if (e.code == 'weak-password') {
        errorMessage = '새 비밀번호가 너무 약합니다 (최소 6자)';
      } else {
        errorMessage = _getFirebaseAuthErrorMessage(e.code);
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Password change failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '비밀번호 변경 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  /// Change email (sends verification to new email)
  Future<bool> changeEmail(String newEmail, String currentPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting email change', tag: 'Auth');

      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException(
          message: '로그인된 사용자가 없습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Re-authenticate user with current password
      final credential = auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Send verification email to new address
      await user.verifyBeforeUpdateEmail(newEmail);

      state = state.copyWith(isLoading: false);
      AppLogger.info('Email verification sent to new address', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Email change failed', tag: 'Auth', error: e);

      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = '비밀번호가 올바르지 않습니다';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 이메일입니다';
      } else if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일 형식입니다';
      } else {
        errorMessage = _getFirebaseAuthErrorMessage(e.code);
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Email change failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '이메일 변경 중 오류가 발생했습니다',
      );
      return false;
    }
  }
}
