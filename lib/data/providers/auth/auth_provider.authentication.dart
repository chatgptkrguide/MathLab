// 🔐 Auth provider — authentication flows
//
// part of auth_provider.dart. Owns email/Google/Apple/Kakao/Guest sign-in & sign-up
// implementations and provider-specific helper methods (nonce, sha256, Kakao logout).

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'auth_provider.dart';

extension AuthAuthentication on Auth {
  // ========================================
  // Email/Password Authentication
  // ========================================

  /// Register new user with email and password
  Future<bool> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting email signup', tag: 'Auth');

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
      AppLogger.info('Starting email signin', tag: 'Auth');

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
      AppLogger.info('=== GOOGLE SIGNIN START ===', tag: 'Auth');

      final gsi = _getGoogleSignIn();
      AppLogger.info('GoogleSignIn instance created, calling signIn()...', tag: 'Auth');

      // Trigger the Google Sign-In flow
      final googleUser = await gsi.signIn();

      AppLogger.info('GoogleSignIn.signIn() returned: ${googleUser?.email ?? "NULL"}', tag: 'Auth');

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
  // Apple Authentication
  // ========================================

  /// Generate a random nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// SHA256 hash of a string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting Apple signin', tag: 'Auth');

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw const AuthException(
          message: 'Apple 로그인에 실패했습니다',
          type: AuthErrorType.unknown,
        );
      }

      // Apple only provides name on first sign-in, update display name if available
      if (appleCredential.givenName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
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

      AppLogger.info('Apple signin successful', tag: 'Auth');
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      AppLogger.error('Apple signin canceled or failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: e.code == AuthorizationErrorCode.canceled
            ? null
            : 'Apple 로그인에 실패했습니다',
      );
      return false;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Apple signin failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Apple signin failed', tag: 'Auth', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Apple 로그인 중 오류가 발생했습니다',
      );
      return false;
    }
  }

  // ========================================
  // Kakao Authentication (개발 단계)
  // ========================================
  // ⚠️ 개발용 구현: Firebase Custom Token 서버 없이 Email/Password로 연동
  //    프로덕션에서는 반드시 Cloud Functions에서 Custom Token 발급하도록 교체
  //    참고: https://firebase.google.com/docs/auth/admin/create-custom-tokens

  /// Sign in with Kakao (개발 단계)
  Future<bool> signInWithKakao() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Starting Kakao signin', tag: 'Auth');

      // 1. Kakao 로그인 (KakaoTalk 앱 우선, 실패 시 카카오 계정)
      kakao.OAuthToken kakaoToken;
      final talkInstalled = await kakao.isKakaoTalkInstalled();
      if (talkInstalled) {
        try {
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          AppLogger.warning(
            'KakaoTalk login failed, falling back to account',
            tag: 'Auth',
            error: e,
          );
          kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
      AppLogger.info('Kakao OAuth token acquired (expires: ${kakaoToken.expiresAt})', tag: 'Auth');

      // 2. Kakao user 정보 조회
      final kakaoUser = await kakao.UserApi.instance.me();
      final kakaoId = kakaoUser.id.toString();
      final email = kakaoUser.kakaoAccount?.email ?? '$kakaoId@mathlab.kakao.local';
      final nickname = kakaoUser.kakaoAccount?.profile?.nickname ?? '카카오 사용자';

      // 3. 개발 단계: deterministic password 로 Firebase Email/Password 인증
      final password = _sha256ofString('kakao_dev_$kakaoId');

      auth.UserCredential userCredential;
      try {
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // 최초 로그인 — 자동 가입
          userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (userCredential.user != null && nickname.isNotEmpty) {
            await userCredential.user!.updateDisplayName(nickname);
          }
        } else {
          rethrow;
        }
      }

      if (userCredential.user == null) {
        throw const AuthException(
          message: 'Kakao 로그인에 실패했습니다',
          type: AuthErrorType.unknown,
        );
      }

      // 4. 토큰 저장
      final idToken = await userCredential.user!.getIdToken();
      if (idToken != null) {
        await _storage.saveAuthToken(idToken);
      }

      // 5. 사용자 데이터 로드
      await ref.read(userProvider.notifier).loadUser(userCredential.user!.uid);

      // 6. 상태 업데이트
      state = state.copyWith(
        firebaseUser: userCredential.user,
        isAuthenticated: true,
        isLoading: false,
      );

      AppLogger.info('Kakao signin successful', tag: 'Auth');
      return true;
    } on kakao.KakaoAuthException catch (e) {
      AppLogger.error('Kakao auth failed', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Kakao 로그인에 실패했습니다',
      );
      return false;
    } on kakao.KakaoClientException catch (e) {
      // 사용자가 Kakao 로그인 화면 취소한 경우
      AppLogger.info('Kakao signin canceled or client error: ${e.reason}', tag: 'Auth');
      state = state.copyWith(isLoading: false);
      return false;
    } on auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth failed after Kakao', tag: 'Auth', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e.code),
      );
      return false;
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

  /// Safe Kakao logout (실패 무시)
  Future<void> _safeKakaoLogout() async {
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {
      // 로그인 안 된 상태 등은 무시
    }
  }
}
