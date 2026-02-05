// 🔐 Authentication Provider
//
// Manages authentication state and operations using Firebase Auth, Google Sign-In, and Kakao SDK.
// Integrates with SecureStorage for token management and UserProvider for user data.

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/user/user_model.dart';
import '../../services/temp_profile_storage.dart';
import '../user/user_provider.dart';

part 'auth_provider.g.dart';

/// Authentication state model
class AuthState {
  final auth.User? firebaseUser;
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.firebaseUser,
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  /// 현재 계정 (Firebase User)
  auth.User? get currentAccount => firebaseUser;

  /// 게스트 여부
  bool get isGuest => user?.isGuest ?? (firebaseUser?.isAnonymous ?? false);

  AuthState copyWith({
    auth.User? firebaseUser,
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SecureStorageService _storage = SecureStorageService();

  @override
  AuthState build() {
    // Check if user is already authenticated
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      // Load user data from UserProvider
      ref.read(userProvider.notifier).loadUser(currentUser.uid);

      return AuthState(
        firebaseUser: currentUser,
        isAuthenticated: true,
      );
    }

    return const AuthState(isAuthenticated: false);
  }

  // ========================================
  // Email/Password Authentication
  // ========================================

  /// Register new user with email and password
  Future<bool> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting email signup', tag: 'Auth', data: {'email': email});

      // Create user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(
          message: '계정 생성에 실패했습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Send email verification
      await credential.user!.sendEmailVerification();
      AppLogger.info('Email verification sent', tag: 'Auth');

      // Save auth token
      final token = await credential.user!.getIdToken();
      if (token != null) {
        await _storage.saveAuthToken(token);
      }

      // Update state
      state = state.copyWith(
        firebaseUser: credential.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Email signup successful', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Email signup failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Email signup failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '회원가입 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting email signin', tag: 'Auth', data: {'email': email});

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(
          message: '로그인에 실패했습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Save auth token
      final token = await credential.user!.getIdToken();
      if (token != null) {
        await _storage.saveAuthToken(token);
      }

      // Load user data
      await ref.read(userProvider.notifier).loadUser(credential.user!.uid);

      // Update state
      state = state.copyWith(
        firebaseUser: credential.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Email signin successful', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Email signin failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Email signin failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  // ========================================
  // Google Authentication
  // ========================================

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting Google signin', tag: 'Auth');

      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        AppLogger.info('Google signin canceled by user', tag: 'Auth');
        state = state.copyWith(isLoading: false);
        return false;
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException(
          message: 'Google 로그인에 실패했습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Save auth token
      final token = await userCredential.user!.getIdToken();
      if (token != null) {
        await _storage.saveAuthToken(token);
      }

      // Load or create user data
      await ref.read(userProvider.notifier).loadUser(userCredential.user!.uid);

      // Update state
      state = state.copyWith(
        firebaseUser: userCredential.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Google signin successful', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Google signin failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Google signin failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Google 로그인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  // ========================================
  // Kakao Authentication
  // ========================================

  /// Sign in with Kakao
  Future<bool> signInWithKakao() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Kakao signin temporarily disabled', tag: 'Auth');

      // Temporarily disabled due to SDK compatibility issues
      // TODO: Re-enable when SDK is updated
      // bool isKakaoTalkAvailable = await kakao.isKakaoTalkInstalled();
      // kakao.OAuthToken token;
      // if (isKakaoTalkAvailable) {
      //   token = await kakao.UserApi.instance.loginWithKakaoTalk();
      // } else {
      //   token = await kakao.UserApi.instance.loginWithKakaoAccount();
      // }
      // final kakaoUser = await kakao.UserApi.instance.me();

      // TODO: Backend Integration Required
      // You need to implement a backend endpoint that:
      // 1. Receives the Kakao access token
      // 2. Validates it with Kakao servers
      // 3. Creates or retrieves the user in your system
      // 4. Generates a custom Firebase token
      // 5. Returns the Firebase token
      //
      // Example backend call:
      // final response = await http.post(
      //   Uri.parse('${EnvConfig.apiBaseUrl}/auth/kakao'),
      //   body: {'accessToken': token.accessToken},
      // );
      // final firebaseToken = response.data['firebaseToken'];

      // For now, throw an error to indicate backend integration is needed
      throw const AuthException(
        message: 'Kakao 로그인은 백엔드 연동이 필요합니다',
        type: AuthErrorType.unknown,
      );

      // Once backend is ready, uncomment and use this code:
      /*
      // Sign in to Firebase with custom token from backend
      final userCredential = await _firebaseAuth.signInWithCustomToken(firebaseToken);

      if (userCredential.user == null) {
        throw const AuthException(
          message: 'Kakao 로그인에 실패했습니다',
          code: AuthErrorCode.loginFailed,
        );
      }

      // Save auth token
      final idToken = await userCredential.user!.getIdToken();
      if (idToken != null) {
        await _storage.saveAuthToken(idToken);
      }

      // Load or create user data
      await ref.read(userProvider.notifier).loadUser(userCredential.user!.uid);

      // Update state
      state = state.copyWith(
        firebaseUser: userCredential.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Kakao signin successful', tag: 'Auth');
      return true;
      */
    } catch (e, st) {
      AppLogger.error('Kakao signin failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Kakao 로그인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  // ========================================
  // Guest Authentication
  // ========================================

  /// Sign in as guest (anonymous)
  Future<bool> signInAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting guest signin', tag: 'Auth');

      final credential = await _firebaseAuth.signInAnonymously();

      if (credential.user == null) {
        throw const AuthException(
          message: '게스트 로그인에 실패했습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Create guest user data
      await ref.read(userProvider.notifier).createGuestUser(credential.user!.uid);

      // Update state
      state = state.copyWith(
        firebaseUser: credential.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Guest signin successful', tag: 'Auth');
      return true;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Guest signin failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Guest signin failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: '게스트 로그인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

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
  // Session Management
  // ========================================

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      AppLogger.info('Starting signout', tag: 'Auth');

      // Sign out from all providers
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        // Kakao logout is handled automatically when Firebase signs out
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

  // ========================================
  // Error Handling
  // ========================================

  /// Convert Firebase Auth error codes to Korean messages
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다';
      case 'operation-not-allowed':
        return '허용되지 않은 작업입니다';
      case 'weak-password':
        return '비밀번호가 너무 약합니다 (최소 6자)';
      case 'user-disabled':
        return '비활성화된 계정입니다';
      case 'user-not-found':
        return '존재하지 않는 계정입니다';
      case 'wrong-password':
        return '잘못된 비밀번호입니다';
      case 'invalid-credential':
        return '인증 정보가 올바르지 않습니다';
      case 'account-exists-with-different-credential':
        return '다른 인증 방법으로 가입된 계정입니다';
      case 'requires-recent-login':
        return '최근에 로그인하지 않았습니다. 다시 로그인해주세요';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요';
      default:
        return '인증 중 오류가 발생했습니다';
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
