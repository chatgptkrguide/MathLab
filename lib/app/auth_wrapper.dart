import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_screen.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/user_provider.dart';
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

    // 계정이 변경되었는지 확인하고 UserProvider 업데이트
    if (authState.currentAccount != null &&
        authState.currentAccount!.id != _lastAccountId) {
      _lastAccountId = authState.currentAccount!.id;
      // 비동기 작업을 안전하게 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProvider.notifier).loadUserByAccount(_lastAccountId!);
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