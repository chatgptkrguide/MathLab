import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../shared/themes/app_theme.dart';
import '../data/providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import 'main_navigation.dart';

/// MathLab 앱의 메인 위젯
class MathLabApp extends ConsumerWidget {
  const MathLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MathLab',
      debugShowCheckedModeBanner: false,

      // 테마 설정
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // 현재는 라이트 모드만 지원

      // 시스템 UI 설정
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child!,
        );
      },

      // 인증 상태에 따라 화면 표시
      home: const AuthWrapper(),

      // 라우팅 설정 (향후 확장용)
      routes: {
        '/home': (context) => const MainNavigation(),
      },

      // 글로벌 설정
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 스크롤 동작 설정
      scrollBehavior: const MaterialScrollBehavior(),
    );
  }
}

/// 인증 상태에 따라 적절한 화면을 보여주는 래퍼 위젯
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 로딩 중일 때는 스플래시 화면 표시
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 인증 상태에 따라 적절한 화면 반환
    if (authState.isAuthenticated) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }
}