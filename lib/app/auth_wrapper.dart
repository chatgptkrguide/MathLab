import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_screen.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/user_provider.dart';
import '../data/providers/sync_manager_provider.dart';
import '../data/providers/fcm_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // SyncManager 초기화 상태 감지
    final syncManagerInitialized = ref.watch(syncManagerInitializedProvider);

    // FCM 서비스 초기화 상태 감지
    final fcmServiceInitialized = ref.watch(fcmServiceInitializedProvider);

    // 계정이 변경되었는지 확인하고 UserProvider 업데이트
    if (authState.currentAccount != null &&
        authState.currentAccount!.id != _lastAccountId) {
      _lastAccountId = authState.currentAccount!.id;
      // 비동기 작업을 안전하게 실행
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // 1. UserProvider 로드
        await ref.read(userProvider.notifier).loadUserByAccount(_lastAccountId!);

        // 2. SyncManager 초기화 완료 후 실시간 동기화 시작
        syncManagerInitialized.whenData((initialized) {
          if (initialized) {
            final syncActions = ref.read(syncActionsProvider);
            syncActions.startRealtimeSync().then((_) {
              Logger.info('실시간 동기화 시작 완료: $_lastAccountId', tag: 'AuthWrapper');

              // 3. 초기 동기화 실행 (Firebase → 로컬)
              syncActions.initialSync().then((_) {
                Logger.info('초기 동기화 완료: $_lastAccountId', tag: 'AuthWrapper');
              }).catchError((error) {
                Logger.error('초기 동기화 실패', error: error, tag: 'AuthWrapper');
              });
            }).catchError((error) {
              Logger.error('실시간 동기화 시작 실패', error: error, tag: 'AuthWrapper');
            });
          }
        });

        // 4. FCM 서비스 초기화 완료 후 토픽 구독
        fcmServiceInitialized.whenData((initialized) {
          if (initialized) {
            final fcmService = ref.read(fcmServiceProvider);

            // 사용자별 토픽 구독
            fcmService.subscribeToTopic('user_$_lastAccountId').then((_) {
              Logger.info('사용자 토픽 구독 완료: user_$_lastAccountId', tag: 'AuthWrapper');
            }).catchError((error) {
              Logger.error('사용자 토픽 구독 실패', error: error, tag: 'AuthWrapper');
            });

            // 전체 알림 토픽 구독
            fcmService.subscribeToTopic('all_users').then((_) {
              Logger.info('전체 사용자 토픽 구독 완료', tag: 'AuthWrapper');
            }).catchError((error) {
              Logger.error('전체 사용자 토픽 구독 실패', error: error, tag: 'AuthWrapper');
            });
          }
        });
      });
    }

    // 항상 로그인 화면 먼저 표시
    // 로딩 중이거나 인증되지 않은 상태
    if (authState.isLoading || !authState.isAuthenticated || authState.currentAccount == null) {
      return const AuthScreen();
    }

    // 인증된 상태 - 메인 앱으로
    return const MainNavigation();
  }
}