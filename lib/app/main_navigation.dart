import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/widgets/layout/custom_bottom_nav.dart';
import '../features/home/home_screen_figma.dart';
import '../features/lessons/figma/lessons_screen_figma.dart';
import '../features/errors/errors_screen.dart';
import '../features/profile/figma/profile_detail_screen_v3_new.dart';
import '../features/history/history_screen.dart';
import '../data/providers/navigation_provider.dart';

/// 메인 네비게이션 위젯
/// 하단 네비게이션 바와 각 화면들을 관리
class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final List<Widget> screens = [
      const LessonsScreenFigma(),         // 0: 학습
      const ErrorsScreen(),               // 1: 오답
      const HomeScreenFigma(),            // 2: 홈 (가운데)
      const ProfileDetailScreenV3New(),   // 3: 프로필 (학습자 상세)
      const HistoryScreen(),              // 4: 학습이력
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 홈 탭이 아닌 경우 홈으로 돌아가기
        if (currentIndex != 2) {
          ref.read(navigationProvider.notifier).goToHome();
          _provideFeedback();
          return;
        }

        // 홈 탭인 경우 종료 확인 다이얼로그 표시
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
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
        content: const Text('GoMath Lab을 종료하시겠습니까?'),
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
    ) ?? false;
  }
}