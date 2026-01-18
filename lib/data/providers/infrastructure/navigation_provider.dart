import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네비게이션 탭 인덱스 관리
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0); // 초기값: 홈(0) - 새로운 순서

  void setTab(int index) {
    state = index;
  }

  void goToLessons() {
    state = 1; // 학습 탭으로 이동 (새로운 위치)
  }

  void goToHome() {
    state = 0; // 홈 탭으로 이동 (새로운 위치)
  }

  void goToProfile() {
    state = 4; // 프로필 탭으로 이동 (새로운 위치)
  }

  void goToLeague() {
    state = 2; // 리그 탭으로 이동 (가운데 위치)
  }

  void goToWrongAnswer() {
    state = 3; // 오답 탭으로 이동 (새로운 위치)
  }
}

/// 네비게이션 탭 인덱스 프로바이더
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
