import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'app/app.dart';
import 'shared/constants/app_colors.dart';
import 'data/services/notification_service.dart';
import 'data/services/sound_service.dart';
import 'shared/utils/logger.dart';

// Export initializeTimezone from notification_service
export 'data/services/notification_service.dart' show initializeTimezone;

/// MathLab 앱의 진입점
void main() async {
  // Flutter 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Logger.info('Firebase initialized successfully', tag: 'Main');
  } catch (e) {
    Logger.error('Failed to initialize Firebase', error: e, tag: 'Main');
  }

  // Timeago 한국어 로케일 설정
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  // 백그라운드에서 초기화 작업 수행 (메인 스레드 블로킹 방지)
  Future.microtask(() async {
    try {
      // Timezone 초기화 (알림 스케줄링용)
      await initializeTimezone();
      Logger.info('Timezone initialized', tag: 'Main');
    } catch (e) {
      Logger.error('Failed to initialize Timezone', error: e, tag: 'Main');
    }

    try {
      // 알림 서비스 초기화
      await NotificationService().initialize();
      Logger.info('NotificationService initialized successfully', tag: 'Main');
    } catch (e) {
      Logger.error('Failed to initialize NotificationService', error: e, tag: 'Main');
    }

    try {
      // 사운드 서비스 초기화
      await SoundService().initialize();
      Logger.info('SoundService initialized successfully', tag: 'Main');
    } catch (e) {
      Logger.error('Failed to initialize SoundService', error: e, tag: 'Main');
    }
  });

  // 시스템 UI 설정
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 시스템 UI 오버레이 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 앱 실행 (Riverpod ProviderScope로 래핑)
  runApp(
    const ProviderScope(
      child: MathLabApp(),
    ),
  );
}