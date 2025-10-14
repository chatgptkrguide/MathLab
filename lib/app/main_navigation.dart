import 'package:flutter/material.dart';
import '../shared/constants/app_colors.dart';
import '../shared/constants/app_text_styles.dart';
import '../shared/widgets/custom_bottom_nav.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/errors/errors_screen.dart';
import '../features/history/history_screen.dart';
import '../features/profile/profile_screen.dart';

/// 메인 네비게이션 위젯
/// 하단 네비게이션 바와 각 화면들을 관리
class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LessonsScreen(),
    const ErrorsScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: '홈',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.school_outlined),
      activeIcon: Icon(Icons.school),
      label: '학습',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.error_outline),
      activeIcon: Icon(Icons.error),
      label: '오답',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history_outlined),
      activeIcon: Icon(Icons.history),
      label: '이력',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: '프로필',
    ),
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
    // TODO: 햅틱 피드백 추가 (HapticFeedback.lightImpact())
  }
}