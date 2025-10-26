import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../shared/utils/logger.dart';
import 'social_auth_service.dart';

/// Firebase Authentication 서비스
/// 소셜 로그인 결과를 Firebase와 통합
class FirebaseAuthService {
  // Singleton 패턴
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  /// Firebase Auth 인스턴스
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  /// 소셜 로그인 서비스
  final SocialAuthService _socialAuthService = SocialAuthService();

  /// 현재 로그인한 사용자
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// 로그인 상태 스트림
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// 사용자 로그인 여부
  bool get isSignedIn => currentUser != null;

  // ==================== Google 로그인 ====================

  /// Google 로그인 with Firebase
  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      Logger.info('Google Firebase 로그인 시작', tag: 'FirebaseAuth');

      // Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Logger.info('Google 로그인 취소됨', tag: 'FirebaseAuth');
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 인증 자격증명 생성
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      Logger.info(
        'Google Firebase 로그인 성공: ${userCredential.user?.email}',
        tag: 'FirebaseAuth',
      );

      return userCredential;
    } catch (e, stackTrace) {
      Logger.error(
        'Google Firebase 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
      return null;
    }
  }

  // ==================== Apple 로그인 ====================

  /// Apple 로그인 with Firebase
  Future<firebase_auth.UserCredential?> signInWithApple() async {
    try {
      Logger.info('Apple Firebase 로그인 시작', tag: 'FirebaseAuth');

      // Apple 로그인 가능 여부 확인
      if (!await SignInWithApple.isAvailable()) {
        Logger.warning('Apple 로그인을 사용할 수 없습니다', tag: 'FirebaseAuth');
        return null;
      }

      // Apple 인증 정보 가져오기
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase OAuthProvider 생성
      final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase로 로그인
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      Logger.info(
        'Apple Firebase 로그인 성공: ${userCredential.user?.email}',
        tag: 'FirebaseAuth',
      );

      return userCredential;
    } catch (e, stackTrace) {
      Logger.error(
        'Apple Firebase 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
      return null;
    }
  }

  // ==================== Kakao 로그인 ====================

  /// Kakao 로그인 (커스텀 토큰 방식)
  ///
  /// Kakao는 Firebase가 직접 지원하지 않으므로,
  /// 백엔드에서 커스텀 토큰을 생성해야 합니다.
  /// 현재는 소셜 로그인 결과만 반환합니다.
  Future<SocialAuthResult?> signInWithKakao() async {
    try {
      Logger.info('Kakao 로그인 시작 (Firebase 미지원)', tag: 'FirebaseAuth');

      // Kakao 소셜 로그인
      final socialResult = await _socialAuthService.signInWithKakao();

      if (socialResult == null) {
        Logger.info('Kakao 로그인 취소됨', tag: 'FirebaseAuth');
        return null;
      }

      // TODO: 백엔드에서 커스텀 토큰 생성 후 Firebase 로그인
      // final customToken = await _getCustomTokenFromBackend(socialResult);
      // await _firebaseAuth.signInWithCustomToken(customToken);

      Logger.warning(
        'Kakao는 Firebase 커스텀 토큰이 필요합니다. 백엔드 구현 필요.',
        tag: 'FirebaseAuth',
      );

      return socialResult;
    } catch (e, stackTrace) {
      Logger.error(
        'Kakao 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
      return null;
    }
  }

  // ==================== 이메일/비밀번호 로그인 ====================

  /// 이메일/비밀번호로 회원가입
  Future<firebase_auth.UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('이메일 회원가입 시작: $email', tag: 'FirebaseAuth');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Logger.info('이메일 회원가입 성공: $email', tag: 'FirebaseAuth');
      return userCredential;
    } catch (e, stackTrace) {
      Logger.error(
        '이메일 회원가입 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
      return null;
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<firebase_auth.UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('이메일 로그인 시작: $email', tag: 'FirebaseAuth');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Logger.info('이메일 로그인 성공: $email', tag: 'FirebaseAuth');
      return userCredential;
    } catch (e, stackTrace) {
      Logger.error(
        '이메일 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
      return null;
    }
  }

  // ==================== 로그아웃 및 계정 관리 ====================

  /// 로그아웃
  Future<void> signOut() async {
    try {
      Logger.info('Firebase 로그아웃 시작', tag: 'FirebaseAuth');

      // Firebase 로그아웃
      await _firebaseAuth.signOut();

      // 소셜 로그인도 로그아웃
      await _socialAuthService.signOutAll();

      Logger.info('Firebase 로그아웃 완료', tag: 'FirebaseAuth');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 로그아웃 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    try {
      Logger.info('Firebase 계정 삭제 시작', tag: 'FirebaseAuth');

      final user = currentUser;
      if (user == null) {
        Logger.warning('로그인된 사용자가 없습니다', tag: 'FirebaseAuth');
        return;
      }

      await user.delete();
      Logger.info('Firebase 계정 삭제 완료', tag: 'FirebaseAuth');
    } catch (e, stackTrace) {
      Logger.error(
        'Firebase 계정 삭제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.info('비밀번호 재설정 이메일 전송: $email', tag: 'FirebaseAuth');

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      Logger.info('비밀번호 재설정 이메일 전송 완료', tag: 'FirebaseAuth');
    } catch (e, stackTrace) {
      Logger.error(
        '비밀번호 재설정 이메일 전송 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
    }
  }

  /// 이메일 인증 메일 전송
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        Logger.warning('로그인된 사용자가 없습니다', tag: 'FirebaseAuth');
        return;
      }

      if (user.emailVerified) {
        Logger.info('이미 이메일 인증이 완료된 사용자입니다', tag: 'FirebaseAuth');
        return;
      }

      await user.sendEmailVerification();
      Logger.info('이메일 인증 메일 전송 완료', tag: 'FirebaseAuth');
    } catch (e, stackTrace) {
      Logger.error(
        '이메일 인증 메일 전송 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
    }
  }

  /// 사용자 프로필 업데이트
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        Logger.warning('로그인된 사용자가 없습니다', tag: 'FirebaseAuth');
        return;
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      Logger.info('사용자 프로필 업데이트 완료', tag: 'FirebaseAuth');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirebaseAuth',
      );
    }
  }

  // ==================== 유틸리티 메서드 ====================

  /// Firebase 에러 메시지를 사용자 친화적 메시지로 변환
  String getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return '등록되지 않은 이메일입니다.';
        case 'wrong-password':
          return '비밀번호가 올바르지 않습니다.';
        case 'invalid-email':
          return '이메일 형식이 올바르지 않습니다.';
        case 'user-disabled':
          return '비활성화된 계정입니다.';
        case 'email-already-in-use':
          return '이미 사용 중인 이메일입니다.';
        case 'weak-password':
          return '비밀번호가 너무 약합니다.';
        case 'operation-not-allowed':
          return '허용되지 않은 작업입니다.';
        case 'account-exists-with-different-credential':
          return '다른 로그인 방식으로 가입된 계정입니다.';
        default:
          return '로그인 중 오류가 발생했습니다: ${error.code}';
      }
    }
    return '알 수 없는 오류가 발생했습니다.';
  }
}
