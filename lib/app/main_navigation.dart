import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../shared/widgets/layout/custom_bottom_nav.dart';
import '../features/home/home_screen_figma.dart';
import '../features/lessons/figma/lessons_screen_figma.dart';
import '../features/wrong_answer/wrong_answer_screen.dart';
import '../features/profile/figma/profile_detail_screen.dart';
import '../features/challenges/challenge_history_screen.dart';
import '../data/providers/infrastructure/navigation_provider.dart';
import '../data/providers/communication/fcm_provider.dart';
import '../data/services/deep_link_service.dart';
import '../core/utils/app_logger.dart';

/// 메인 네비게이션 위젯
/// 피그마 탭 순서: 학습(0), 오답(1), Home(2), 프로필(3), 학습이력(4)
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {

  DeepLinkService? _deepLinkServiceInstance;

  DeepLinkService get _deepLinkService {
    _deepLinkServiceInstance ??= DeepLinkService(ref);
    return _deepLinkServiceInstance!;
  }

  @override
  void initState() {
    super.initState();
    _setupDeepLinkListeners();
  }

  /// 딥링크 리스너 설정 (지연 초기화로 메인 로딩 블로킹 방지)
  void _setupDeepLinkListeners() {
    // 지연 실행으로 UI 로딩 완료 후 처리
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // 1. 포그라운드 메시지 오픈 리스너
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.info('백그라운드 메시지 오픈: ${message.data}', tag: 'DeepLink');
        if (message.data.isNotEmpty && mounted) {
          _deepLinkService.handleNotification(context, message.data);
        }
      });

      // 2. 앱 종료 상태에서 알림 탭하여 실행된 경우
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null && message.data.isNotEmpty && mounted) {
          AppLogger.info('앱 종료 상태에서 알림으로 실행: ${message.data}', tag: 'DeepLink');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _deepLinkService.handleNotification(context, message.data);
            }
          });
        }
      });

      // 3. FCM Service의 대기 중인 딥링크 처리
      final fcmService = ref.read(fcmServiceProvider);
      fcmService.processPendingDeepLink(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    // 피그마 탭 순서: 학습(0), 오답(1), Home(2), 프로필(3), 학습이력(4)
    // 현재 탭만 빌드하여 초기 로딩 시 5개 화면 동시 빌드로 인한 과부하 방지
    Widget currentScreen;
    switch (currentIndex) {
      case 0:
        currentScreen = const LessonsScreenFigma();
      case 1:
        currentScreen = const WrongAnswerScreen();
      case 2:
        currentScreen = const HomeScreenFigma();
      case 3:
        currentScreen = const ProfileDetailScreen();
      case 4:
        currentScreen = const ChallengeHistoryScreen();
      default:
        currentScreen = const HomeScreenFigma();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Home 탭이 아닌 경우 Home으로 돌아가기
        if (currentIndex != 2) {
          ref.read(navigationProvider.notifier).goToHome();
          _provideFeedback();
          return;
        }

        // Home 탭인 경우 종료 확인 다이얼로그 표시
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: currentScreen,
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(navigationProvider.notifier).setTab(index);
            _provideFeedback();
          },
        ),
      ),
    );
  }

  void _provideFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // 햅틱 피드백이 지원되지 않는 디바이스에서는 무시
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('앱 종료'),
            content: const Text('MathLab을 종료하시겠습니까?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '종료',
                  style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
