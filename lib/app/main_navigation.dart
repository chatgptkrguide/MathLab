import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../shared/widgets/layout/custom_bottom_nav.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/wrong_answer/wrong_answer_screen.dart';
import '../features/profile/profile_detail_screen.dart';
import '../features/team/team_screen.dart';
import '../data/providers/infrastructure/navigation_provider.dart';
import '../data/providers/communication/fcm_provider.dart';
import '../data/services/deep_link_service.dart';
import '../core/utils/app_logger.dart';
import '../shared/widgets/coach_mark/coach_mark_controller.dart';
import '../shared/widgets/coach_mark/coach_mark_overlay.dart';

/// 메인 네비게이션 위젯
/// 피그마 탭 순서: 학습(0), 오답(1), Home(2), 프로필(3), 팀(4)
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {

  DeepLinkService? _deepLinkServiceInstance;
  StreamSubscription<RemoteMessage>? _deepLinkSub;
  bool _coachMarkChecked = false;

  DeepLinkService get _deepLinkService {
    _deepLinkServiceInstance ??= DeepLinkService(ref);
    return _deepLinkServiceInstance!;
  }

  @override
  void initState() {
    super.initState();
    _setupDeepLinkListeners();
    _checkAndShowCoachMark();
  }

  /// 첫 진입 시 코치마크 온보딩 표시
  Future<void> _checkAndShowCoachMark() async {
    if (_coachMarkChecked) return;
    _coachMarkChecked = true;

    final isCompleted = await CoachMarkController.isCompleted();
    if (isCompleted || !mounted) return;

    // 홈 화면이 완전히 빌드된 후 코치마크 표시 (약간의 지연)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final steps = [
      // ──── 홈 화면 (탭 2) ────
      CoachMarkStep(
        targetKey: HomeScreenFigma.todayGoalKey,
        title: '오늘의 학습 목표',
        description: '하루 목표 XP를 달성하면 스트릭이 유지됩니다.\n진행률 바에서 달성도를 확인하세요.',
        arrowDirection: ArrowDirection.up,
      ),
      CoachMarkStep(
        targetKey: HomeScreenFigma.startButtonKey,
        title: '학습 시작하기',
        description: '이 버튼을 눌러 오늘의 수학 학습을 시작하세요.\n단계별 커리큘럼으로 쉽게 배울 수 있어요.',
        arrowDirection: ArrowDirection.down,
      ),
      CoachMarkStep(
        targetKey: HomeScreenFigma.statsRowKey,
        title: 'XP · 레벨 · 스트릭',
        description: '문제를 풀면 XP를 획득하고, XP가 쌓이면\n레벨이 올라갑니다. 스트릭으로 꾸준함을 확인하세요.',
        arrowDirection: ArrowDirection.down,
      ),

      // ──── 학습 화면 (탭 0) ────
      CoachMarkStep(
        targetKey: LessonsScreenFigma.lessonPathKey,
        title: '학습 경로',
        description: '단계별로 구성된 학습 노드입니다.\n잠금 해제된 노드를 탭하면 문제 풀이가 시작돼요.',
        arrowDirection: ArrowDirection.up,
        tabIndex: 0,
      ),

      // ──── 하단 메뉴 (홈 복귀) ────
      CoachMarkStep(
        targetKey: CustomBottomNavigation.bottomNavKey,
        title: '탭으로 자유롭게 이동',
        description: '학습, 오답노트, 홈, 프로필, 팀\n5개 탭을 자유롭게 오갈 수 있어요.',
        arrowDirection: ArrowDirection.down,
        tooltipOffset: const EdgeInsets.only(top: -60),
        tabIndex: 2,
      ),
    ];

    if (mounted) {
      CoachMarkController.show(
        context: context,
        steps: steps,
        onTabChange: (tabIndex) {
          ref.read(navigationProvider.notifier).setTab(tabIndex);
        },
        onComplete: () {
          // 온보딩 완료 후 일일 보상은 HomeScreen에서 자동 표시됨
          // 여기서 중복 호출하지 않음
        },
      );
    }
  }

  /// 딥링크 리스너 설정 (지연 초기화로 메인 로딩 블로킹 방지)
  void _setupDeepLinkListeners() {
    // 지연 실행으로 UI 로딩 완료 후 처리
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // 1. 포그라운드 메시지 오픈 리스너
      _deepLinkSub?.cancel();
      _deepLinkSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    // 탭 순서: 학습(0), 오답(1), Home(2), 프로필(3), 팀(4)
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
        currentScreen = const TeamScreen();
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
