import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네비게이션 탭 인덱스 관리
/// 탭 순서: 학습(0), 오답(1), Home(2), 프로필(3), 팀(4)
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(2); // 초기값: Home(2) - 가운데 탭

  void setTab(int index) {
    state = index;
  }

  void goToLessons() {
    state = 0; // 학습 탭
  }

  void goToWrongAnswer() {
    state = 1; // 오답 탭
  }

  void goToHome() {
    state = 2; // Home 탭 (가운데)
  }

  void goToProfile() {
    state = 3; // 프로필 탭
  }

  void goToTeam() {
    state = 4; // 팀 탭
  }

  // Legacy compatibility
  void goToLeague() {
    state = 2; // Home으로 리디렉트
  }
}

/// 네비게이션 탭 인덱스 프로바이더
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
