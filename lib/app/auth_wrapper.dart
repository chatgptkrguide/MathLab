import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_screen.dart';
import '../features/profile/onboarding_profile_setup_screen.dart';
import '../data/providers/auth/auth_provider.dart';
import '../data/providers/user/user_provider.dart';
// import '../data/providers/infrastructure/sync_manager_provider.dart'; // TODO: Create provider file
import '../data/providers/communication/fcm_provider.dart';
import '../shared/utils/logger.dart';
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
    _lastAccountId = currentUserId;

    try {
      // 1. UserProvider 로드
      await ref.read(userProvider.notifier).loadUser(currentUserId);
      Logger.info('사용자 정보 로드 완료: $currentUserId', tag: 'AuthWrapper');

      // 2. TODO: ProblemProvider 초기화 (문제 데이터 로드) - Provider 파일 생성 필요
      // ref.read(problemProvider);
      // Logger.info('문제 데이터 로드 시작', tag: 'AuthWrapper');

      // 3. TODO: SyncManager 초기화 - Provider 파일 생성 필요
      // final syncManagerInitialized = await ref.read(syncManagerInitializedProvider.future);
      // if (syncManagerInitialized) {
      //   final syncActions = ref.read(syncActionsProvider);
      //   try {
      //     await syncActions.startRealtimeSync();
      //     Logger.info('실시간 동기화 시작 완료: $currentAccountId', tag: 'AuthWrapper');
      //     await syncActions.initialSync();
      //     Logger.info('초기 동기화 완료: $currentAccountId', tag: 'AuthWrapper');
      //   } catch (e) {
      //     Logger.error('동기화 실패', error: e, tag: 'AuthWrapper');
      //   }
      // }

      // 4. FCM 서비스 초기화 확인 및 토픽 구독
      final fcmServiceInitialized = await ref.read(fcmServiceInitializedProvider.future);
      if (fcmServiceInitialized) {
        final fcmService = ref.read(fcmServiceProvider);
        try {
          await fcmService.subscribeToTopic('user_$currentUserId');
          Logger.info('사용자 토픽 구독 완료: user_$currentUserId', tag: 'AuthWrapper');
          await fcmService.subscribeToTopic('all_users');
          Logger.info('전체 사용자 토픽 구독 완료', tag: 'AuthWrapper');
        } catch (e) {
          Logger.error('FCM 토픽 구독 실패', error: e, tag: 'AuthWrapper');
        }
      }

      Logger.info('FCM 푸시 알림 서비스 활성화됨', tag: 'AuthWrapper');
    } catch (e) {
      Logger.error('초기화 실패', error: e, tag: 'AuthWrapper');
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
      return const AuthScreen();
    }

    // 인증되었지만 사용자 정보가 없는 경우 (로딩 중)
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 프로필이 완성되지 않은 경우 프로필 설정 화면으로
    if (!user.isProfileComplete) {
      Logger.info('프로필 미완성, 프로필 설정 화면으로 이동', tag: 'AuthWrapper');
      return const OnboardingProfileSetupScreen();
    }

    // 인증된 상태이고 프로필도 완성된 경우 - 메인 앱으로
    return const MainNavigation();
  }
}
