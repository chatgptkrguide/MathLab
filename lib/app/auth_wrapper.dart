import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_screen.dart';
import '../shared/widgets/indicators/loading_widgets.dart';
import '../shared/constants/app_colors.dart';
import '../data/providers/auth_provider.dart';
import 'main_navigation.dart';

/// 인증 상태에 따라 적절한 화면을 보여주는 래퍼
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 로딩 중
    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.mathBlue, // GoMath blue
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.mathBlueGradient, // GoMath gradient
            ),
          ),
          child: const Center(
            child: DuolingoLoadingIndicator(
              message: 'MathLab을 시작하는 중...',
              size: 100,
            ),
          ),
        ),
      );
    }

    // 인증되지 않은 상태 또는 계정이 없는 경우
    if (!authState.isAuthenticated || authState.currentAccount == null) {
      return const AuthScreen();
    }

    // 인증된 상태 - 메인 앱으로
    return const MainNavigation();
  }
}