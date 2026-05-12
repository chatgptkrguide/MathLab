// 🔐 Authentication Provider
//
// Manages authentication state and operations using Firebase Auth, Google Sign-In, and Kakao SDK.
// Integrates with SecureStorage for token management and UserProvider for user data.
//
// This file owns the class definition, fields, build(), and shared private helpers.
// Method implementations are split across part files for readability:
//   * auth_provider.authentication.dart — sign in/up flows per provider
//   * auth_provider.session.dart       — signOut / deleteAccount / session validation
//   * auth_provider.credentials.dart   — password / email change & profile sync
// Splitting is done via Dart `part` so that private fields/methods remain accessible.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/user/user_model.dart';
import '../../services/onboarding_profile_storage.dart';
import '../user/user_provider.dart';

part 'auth_provider.g.dart';
part 'auth_provider.authentication.dart';
part 'auth_provider.session.dart';
part 'auth_provider.credentials.dart';

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
  GoogleSignIn? _googleSignIn;

  GoogleSignIn _getGoogleSignIn() {
    // Android: google-services.json에서 web client ID를 자동 감지
    // serverClientId를 지정하지 않으면 google-services.json의 type=3 client를 사용
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email'],
    );
    return _googleSignIn!;
  }
  final SecureStorageService _storage = SecureStorageService();

  @override
  AuthState build() {
    // Check if user is already authenticated
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      // AuthWrapper handles loadUser to avoid race conditions
      return AuthState(
        firebaseUser: currentUser,
        isAuthenticated: true,
      );
    }

    return const AuthState(isAuthenticated: false);
  }

  // ========================================
  // Shared Helpers (used across all part files)
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
