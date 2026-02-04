// 인증 핸들러 Provider
//
// 인증 상태를 간편하게 접근할 수 있는 Provider입니다.
// friends_screen, achievement_screen 등에서 현재 사용자 정보를 얻는데 사용됩니다.

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// 인증 핸들러 상태
class AuthHandlerState {
  final AuthHandlerUser? user;
  final bool isAuthenticated;
  final bool isLoading;

  const AuthHandlerState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
  });
}

/// 인증 핸들러에서 사용하는 간소화된 사용자 모델
class AuthHandlerUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthHandlerUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Firebase User로부터 생성
  factory AuthHandlerUser.fromFirebaseUser(firebase_auth.User user) {
    return AuthHandlerUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}

/// 인증 핸들러 Provider
/// AuthProvider의 상태를 감시하여 간소화된 인증 상태를 제공합니다
final authHandlerProvider = Provider<AuthHandlerState>((ref) {
  final authState = ref.watch(authProvider);

  if (authState.isAuthenticated && authState.firebaseUser != null) {
    return AuthHandlerState(
      user: AuthHandlerUser.fromFirebaseUser(authState.firebaseUser!),
      isAuthenticated: true,
      isLoading: authState.isLoading,
    );
  }

  return AuthHandlerState(
    isAuthenticated: authState.isAuthenticated,
    isLoading: authState.isLoading,
  );
});
