import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../shared/constants/app_colors.dart';
import '../shared/themes/app_theme.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'auth_wrapper.dart';
import 'splash_screen.dart';

/// MathLab 앱의 메인 위젯
class MathLabApp extends StatelessWidget {
  const MathLabApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            systemNavigationBarColor: AppColors.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child!,
        );
      },

      // 스플래시 화면에서 온보딩 여부 체크
      home: const SplashScreen(),

      // 라우팅 설정
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const AuthWrapper(),
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