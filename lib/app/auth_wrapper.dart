// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_screen.dart';
import '../features/profile/onboarding_profile_setup_screen.dart';
import '../data/providers/auth/auth_provider.dart';
import '../data/providers/user/user_provider.dart';
import '../data/providers/communication/fcm_provider.dart';
import '../core/utils/app_logger.dart';
import '../shared/widgets/welcome_dialog.dart';
import 'main_navigation.dart';

/// 인증 상태에 따라 적절한 화면을 보여주는 래퍼
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  String? _lastAccountId;
  bool _isInitializing = false;
  bool _shouldShowWelcome = false;
  bool _hasInitError = false;

  @override
  void initState() {
    super.initState();
    // 초기화 작업은 initState에서 시작
    Future.microtask(() => _checkAndInitialize());
  }

  Future<void> _checkAndInitialize() async {
    if (_isInitializing) return;

    final authState = ref.read(authProvider);
    if (authState.firebaseUser == null) return;

    final currentUserId = authState.firebaseUser!.uid;
    if (currentUserId == _lastAccountId) return;

    _isInitializing = true;
    _hasInitError = false;
    final isNewLogin = _lastAccountId != null && _lastAccountId != currentUserId;
    _lastAccountId = currentUserId;

    try {
      // 1. UserProvider 로드
      await ref.read(userProvider.notifier).loadUser(currentUserId);
      AppLogger.info('사용자 정보 로드 완료: $currentUserId', tag: 'AuthWrapper');

      // Mark to show welcome dialog for new logins (not initial app launch with existing session)
      if (isNewLogin) {
        _shouldShowWelcome = true;
      }

      // TODO: SyncManager, ProblemProvider 초기화 (Phase 2)

      // 2. FCM 서비스 초기화 확인 및 토픽 구독 (타임아웃 적용)
      try {
        final fcmServiceInitialized = await ref
            .read(fcmServiceInitializedProvider.future)
            .timeout(const Duration(seconds: 10));
        if (fcmServiceInitialized) {
          final fcmService = ref.read(fcmServiceProvider);
          try {
            await fcmService.subscribeToTopic('user_$currentUserId');
            AppLogger.info('사용자 토픽 구독 완료: user_$currentUserId', tag: 'AuthWrapper');
            await fcmService.subscribeToTopic('all_users');
            AppLogger.info('전체 사용자 토픽 구독 완료', tag: 'AuthWrapper');
          } catch (e) {
            AppLogger.error('FCM 토픽 구독 실패', error: e, tag: 'AuthWrapper');
          }
        }
        AppLogger.info('FCM 푸시 알림 서비스 활성화됨', tag: 'AuthWrapper');
      } catch (e) {
        AppLogger.warning('FCM 초기화 타임아웃 또는 실패 (앱은 정상 작동)', tag: 'AuthWrapper');
      }
    } catch (e) {
      AppLogger.error('초기화 실패', error: e, tag: 'AuthWrapper');
      _hasInitError = true;
      if (mounted) setState(() {});
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);

    // 계정이 변경되었는지 확인
    if (authState.firebaseUser != null &&
        authState.firebaseUser!.uid != _lastAccountId &&
        !_isInitializing) {
      Future.microtask(() => _checkAndInitialize());
    }

    // 로딩 중이거나 인증되지 않은 상태
    if (authState.isLoading ||
        !authState.isAuthenticated ||
        authState.firebaseUser == null) {
      // Reset tracking on logout so next login triggers initialization
      if (!authState.isLoading && _lastAccountId != null) {
        _lastAccountId = null;
        _shouldShowWelcome = false;
      }
      return const AuthScreen();
    }

    // 인증되었지만 사용자 정보가 없는 경우
    if (user == null) {
      // 초기화 에러 발생 시 재시도 UI 표시
      if (_hasInitError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('사용자 정보를 불러올 수 없습니다'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _hasInitError = false;
                    _lastAccountId = null;
                    setState(() {});
                    Future.microtask(() => _checkAndInitialize());
                  },
                  child: const Text('다시 시도'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          ),
        );
      }
      // 정상 로딩 중
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show profile setup for incomplete profiles or guest users with default name
    if (!user.isProfileComplete ||
        (user.isGuest && user.displayName == '게스트')) {
      AppLogger.info('프로필 미완성, 프로필 설정 화면으로 이동', tag: 'AuthWrapper');
      return const OnboardingProfileSetupScreen();
    }
    // 인증된 상태이고 프로필도 완성된 경우 - 메인 앱으로
    // Show welcome dialog after login transition completes
    if (_shouldShowWelcome) {
      _shouldShowWelcome = false;
      final authMethod = (authState.isGuest) ? 'guest' : 'email';
      final currentContext = context;
      Future.microtask(() {
        if (mounted) {
          WelcomeDialog.show(
            currentContext,
            user: user,
            authMethod: authMethod,
          );
        }
      });
    }
    return const MainNavigation();
  }
}
