import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/widgets/layout/custom_bottom_nav.dart';
import '../features/home/home_screen_figma.dart';
import '../features/lessons/figma/lessons_screen_figma.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/errors/errors_screen.dart';
import '../features/profile/figma/profile_screen_figma.dart';
import '../features/history/history_screen.dart';

/// 메인 네비게이션 위젯
/// 하단 네비게이션 바와 각 화면들을 관리
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenFigma(),       // 피그마 디자인 홈 화면
    const LessonsScreenFigma(),    // 피그마 디자인 학습 화면
    const ErrorsScreen(),          // 오답
    const ProfileScreenFigma(),    // 피그마 디자인 프로필 화면
    const HistoryScreen(),         // 학습이력 (5번째 탭 추가)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 탭 변경 시 햅틱 피드백
    _provideFeedback();
  }

  void _provideFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // 햅틱 피드백이 지원되지 않는 디바이스에서는 무시
    }
  }
}