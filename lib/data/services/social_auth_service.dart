import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../shared/utils/logger.dart';

/// 소셜 로그인 서비스
/// Google, Kakao, Apple 로그인 통합 관리
class SocialAuthService {
  // Singleton 패턴
  static final SocialAuthService _instance = SocialAuthService._internal();
  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  /// Google Sign-In 인스턴스 (lazy initialization)
  GoogleSignIn? _googleSignIn;

  /// Google 로그인 초기화 여부
  bool _isGoogleInitialized = false;

  /// Kakao 로그인 초기화 여부
  bool _isKakaoInitialized = false;

  /// Google 로그인 초기화
  Future<void> initializeGoogle() async {
    if (_isGoogleInitialized) return;

    try {
      // Google Sign-In을 lazy 초기화
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      _isGoogleInitialized = true;
      Logger.info('Google 로그인 초기화 완료', tag: 'SocialAuth');
    } catch (e, stackTrace) {
      Logger.error(
        'Google 로그인 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
      // 초기화 실패 시에도 계속 진행
      _isGoogleInitialized = false;
    }
  }

  /// Kakao 로그인 초기화
  ///
  /// Kakao Native App Key는 환경변수나 설정 파일에서 불러와야 함
  /// 현재는 예시로 하드코딩되어 있음 (실제 사용 시 변경 필요)
  Future<void> initializeKakao({required String nativeAppKey}) async {
    if (_isKakaoInitialized) return;

    try {
      KakaoSdk.init(
        nativeAppKey: nativeAppKey,
        javaScriptAppKey: null, // 웹에서 사용할 경우 필요
      );

      _isKakaoInitialized = true;
      Logger.info('Kakao 로그인 초기화 완료', tag: 'SocialAuth');
    } catch (e, stackTrace) {
      Logger.error(
        'Kakao 로그인 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
    }
  }

  // ==================== Google 로그인 ====================

  /// Google 로그인
  Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      if (_googleSignIn == null || !_isGoogleInitialized) {
        await initializeGoogle();
        if (_googleSignIn == null) {
          throw Exception('Google 로그인을 초기화할 수 없습니다');
        }
      }

      Logger.info('Google 로그인 시작', tag: 'SocialAuth');

      // Google 계정 선택 화면 표시 (타임아웃: 60초)
      final GoogleSignInAccount? googleUser =
          await _googleSignIn!.signIn().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          Logger.warning('Google 로그인 타임아웃', tag: 'SocialAuth');
          throw TimeoutException('Google 로그인 시간이 초과되었습니다');
        },
      );

      if (googleUser == null) {
        Logger.info('Google 로그인 취소됨', tag: 'SocialAuth');
        return null; // 사용자가 로그인 취소
      }

      // 인증 정보 가져오기 (타임아웃: 30초)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          Logger.warning('Google 인증 정보 가져오기 타임아웃', tag: 'SocialAuth');
          throw TimeoutException('Google 인증 정보를 가져오는 시간이 초과되었습니다');
        },
      );

      // Access Token 또는 ID Token이 없으면 에러
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        Logger.error(
          'Google 인증 토큰이 없습니다',
          tag: 'SocialAuth',
        );
        throw Exception('Google 인증에 실패했습니다. 다시 시도해주세요.');
      }

      Logger.info(
        'Google 로그인 성공: ${googleUser.email}',
        tag: 'SocialAuth',
      );

      return SocialAuthResult(
        provider: SocialAuthProvider.google,
        userId: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ?? googleUser.email,
        photoUrl: googleUser.photoUrl,
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } on TimeoutException catch (e) {
      Logger.error(
        'Google 로그인 타임아웃',
        error: e,
        tag: 'SocialAuth',
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Google 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );

      // 사용자 친화적 에러 메시지
      if (e.toString().contains('network')) {
        throw Exception('네트워크 연결을 확인해주세요');
      } else if (e.toString().contains('PlatformException')) {
        throw Exception('Google 로그인 설정에 문제가 있습니다. SHA-1 인증서를 확인해주세요.');
      }

      rethrow;
    }
  }

  /// Google 로그아웃
  Future<void> signOutGoogle() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
        Logger.info('Google 로그아웃 완료', tag: 'SocialAuth');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Google 로그아웃 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
    }
  }

  /// Google 계정 연결 해제
  Future<void> disconnectGoogle() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.disconnect();
        Logger.info('Google 계정 연결 해제 완료', tag: 'SocialAuth');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Google 계정 연결 해제 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
    }
  }

  /// 현재 Google 로그인 상태 확인
  Future<bool> isGoogleSignedIn() async {
    if (_googleSignIn == null) return false;
    return await _googleSignIn!.isSignedIn();
  }

  // ==================== Kakao 로그인 ====================

  /// Kakao 로그인
  Future<SocialAuthResult?> signInWithKakao() async {
    try {
      Logger.info('Kakao 로그인 시작', tag: 'SocialAuth');

      OAuthToken token;

      // 카카오톡 앱 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인
          token = await UserApi.instance.loginWithKakaoTalk();
          Logger.debug('카카오톡 앱으로 로그인', tag: 'SocialAuth');
        } catch (e) {
          // 사용자가 취소하거나 카카오톡 앱 실행 실패 시 웹으로 시도
          Logger.warning('카카오톡 로그인 실패, 웹으로 시도', tag: 'SocialAuth');
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡 미설치 시 웹으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
        Logger.debug('카카오 계정으로 로그인', tag: 'SocialAuth');
      }

      // 사용자 정보 가져오기
      final User user = await UserApi.instance.me();

      Logger.info(
        'Kakao 로그인 성공: ${user.kakaoAccount?.email ?? user.id}',
        tag: 'SocialAuth',
      );

      return SocialAuthResult(
        provider: SocialAuthProvider.kakao,
        userId: user.id.toString(),
        email: user.kakaoAccount?.email ?? '',
        displayName: user.kakaoAccount?.profile?.nickname ?? '카카오 사용자',
        photoUrl: user.kakaoAccount?.profile?.profileImageUrl,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Kakao 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
      return null;
    }
  }

  /// Kakao 로그아웃
  Future<void> signOutKakao() async {
    try {
      await UserApi.instance.logout();
      Logger.info('Kakao 로그아웃 완료', tag: 'SocialAuth');
    } catch (e, stackTrace) {
      Logger.error(
        'Kakao 로그아웃 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
    }
  }

  /// Kakao 연결 끊기 (회원 탈퇴)
  Future<void> unlinkKakao() async {
    try {
      await UserApi.instance.unlink();
      Logger.info('Kakao 연결 끊기 완료', tag: 'SocialAuth');
    } catch (e, stackTrace) {
      Logger.error(
        'Kakao 연결 끊기 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
    }
  }

  // ==================== Apple 로그인 ====================

  /// Apple 로그인 (iOS만 지원)
  Future<SocialAuthResult?> signInWithApple() async {
    try {
      Logger.info('Apple 로그인 시작', tag: 'SocialAuth');

      // Apple 로그인 가능 여부 확인
      if (!await SignInWithApple.isAvailable()) {
        Logger.warning('Apple 로그인을 사용할 수 없습니다', tag: 'SocialAuth');
        return null;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      Logger.info(
        'Apple 로그인 성공: ${credential.email ?? credential.userIdentifier}',
        tag: 'SocialAuth',
      );

      // Apple은 첫 로그인 시에만 이메일과 이름을 제공함
      String displayName = 'Apple 사용자';
      if (credential.givenName != null || credential.familyName != null) {
        displayName =
            '${credential.familyName ?? ''} ${credential.givenName ?? ''}'
                .trim();
      }

      return SocialAuthResult(
        provider: SocialAuthProvider.apple,
        userId: credential.userIdentifier ?? '',
        email: credential.email ?? '',
        displayName: displayName,
        photoUrl: null, // Apple은 프로필 사진 제공 안 함
        accessToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Apple 로그인 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'SocialAuth',
      );
      return null;
    }
  }

  // ==================== 유틸리티 메서드 ====================

  /// 통합 로그아웃 (모든 소셜 로그인)
  Future<void> signOutAll() async {
    await Future.wait([
      signOutGoogle(),
      signOutKakao(),
    ]);
    Logger.info('모든 소셜 로그인 로그아웃 완료', tag: 'SocialAuth');
  }

  /// Apple 로그인 가능 여부 (iOS 13+ 필수)
  Future<bool> isAppleSignInAvailable() async {
    return await SignInWithApple.isAvailable();
  }
}

// ==================== 모델 클래스 ====================

/// 소셜 로그인 프로바이더
enum SocialAuthProvider {
  google,
  kakao,
  apple,
}

/// 소셜 로그인 결과
class SocialAuthResult {
  final SocialAuthProvider provider;
  final String userId;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final String? authorizationCode;

  const SocialAuthResult({
    required this.provider,
    required this.userId,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.authorizationCode,
  });

  /// 프로바이더 이름
  String get providerName {
    switch (provider) {
      case SocialAuthProvider.google:
        return 'Google';
      case SocialAuthProvider.kakao:
        return 'Kakao';
      case SocialAuthProvider.apple:
        return 'Apple';
    }
  }

  /// 프로바이더 아이콘
  String get providerIcon {
    switch (provider) {
      case SocialAuthProvider.google:
        return '🔵'; // Google 아이콘
      case SocialAuthProvider.kakao:
        return '💛'; // Kakao 아이콘
      case SocialAuthProvider.apple:
        return '🍎'; // Apple 아이콘
    }
  }

  @override
  String toString() =>
      'SocialAuthResult{provider: $providerName, email: $email, name: $displayName}';
}
