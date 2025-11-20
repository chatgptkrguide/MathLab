import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/widgets/layout/custom_bottom_nav.dart';
import '../features/home/home_screen_figma.dart';
import '../features/lessons/figma/lessons_screen_figma.dart';
import '../features/errors/errors_screen.dart';
import '../features/profile/figma/profile_detail_screen_v3_new.dart';
import '../features/history/history_screen.dart';

/// 메인 네비게이션 위젯
/// 하단 네비게이션 바와 각 화면들을 관리
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2; // 초기 화면을 홈(가운데)으로 설정

  final List<Widget> _screens = [
    const LessonsScreenFigma(),         // 0: 학습
    const ErrorsScreen(),               // 1: 오답
    const HomeScreenFigma(),            // 2: 홈 (가운데)
    const ProfileDetailScreenV3New(),   // 3: 프로필 (학습자 상세)
    const HistoryScreen(),              // 4: 학습이력
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