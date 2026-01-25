/// 🚀 MathLab - Main Entry Point
///
/// Gamification-based math learning app powered by Flutter and Firebase.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/config/env_config.dart';
import 'core/utils/app_logger.dart';
import 'app/main_navigation.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/screens/home_screen_figma.dart';

// TODO: Add firebase_options.dart file
// Generate with: flutterfire configure
// import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // 1. Initialize environment variables
    await EnvConfig.initialize(
      fileName: EnvConfig.isProduction ? '.env.production' : '.env',
    );
    AppLogger.info('Environment variables loaded', tag: 'App');

    // 2. Validate environment variables
    try {
      EnvConfig.validateEnvironment();
      AppLogger.info('Environment validation passed', tag: 'App');
    } catch (e) {
      AppLogger.warning(
        'Environment validation failed (non-critical)',
        tag: 'App',
        error: e,
      );
    }

    // 3. Initialize Firebase
    // TODO: Replace with actual firebase_options.dart after running `flutterfire configure`
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    // Temporary: Initialize Firebase without options (will fail without firebase_options.dart)
    try {
      await Firebase.initializeApp();
      AppLogger.info('Firebase initialized successfully', tag: 'App');
    } catch (e) {
      AppLogger.error(
        'Firebase initialization failed - run "flutterfire configure" first',
        tag: 'App',
        error: e,
      );
    }

    // 4. Initialize Kakao SDK
    try {
      KakaoSdk.init(nativeAppKey: EnvConfig.kakaoNativeAppKey);
      AppLogger.info('Kakao SDK initialized', tag: 'App');
    } catch (e) {
      AppLogger.warning(
        'Kakao SDK initialization failed (non-critical)',
        tag: 'App',
        error: e,
      );
    }

    // 5. Setup Crashlytics (Production only)
    if (EnvConfig.isProduction) {
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      AppLogger.info('Crashlytics enabled for production', tag: 'App');
    } else {
      AppLogger.info('Crashlytics disabled for development', tag: 'App');
    }

    // 6. Run the app
    runApp(
      const ProviderScope(
        child: MathLabApp(),
      ),
    );
  } catch (e, st) {
    AppLogger.error('App initialization failed', tag: 'App', error: e, stackTrace: st);

    // Run minimal app to show error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    '앱 초기화 실패',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MathLabApp extends StatelessWidget {
  const MathLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathLab',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1CB0F6),
          brightness: Brightness.light,
        ),

        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1CB0F6),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
      ),

      // Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1CB0F6),
          brightness: Brightness.dark,
        ),
      ),

      // Routes
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainNavigation(),
        '/home-figma': (context) => const HomeScreenFigma(),
      },

      // Error handling
      builder: (context, child) {
        // Handle errors in widget tree
        ErrorWidget.builder = (FlutterErrorDetails details) {
          AppLogger.error(
            'Widget error',
            tag: 'App',
            error: details.exception,
            stackTrace: details.stack,
          );

          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 24),
                    const Text(
                      '오류가 발생했습니다',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      EnvConfig.isProduction
                          ? '문제가 지속되면 고객센터로 문의해주세요.'
                          : details.exception.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}
