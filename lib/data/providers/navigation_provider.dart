import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네비게이션 탭 인덱스 관리
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(2); // 초기값: 홈(2)

  void setTab(int index) {
    state = index;
  }

  void goToLessons() {
    state = 0; // 학습 탭으로 이동
  }

  void goToHome() {
    state = 2; // 홈 탭으로 이동
  }

  void goToProfile() {
    state = 3; // 프로필 탭으로 이동
  }
}

/// 네비게이션 탭 인덱스 프로바이더
final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
