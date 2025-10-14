import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

/// 사용자 정보 상태 관리
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  final MockDataService _dataService = MockDataService();

  /// 앱 시작 시 사용자 정보 로드
  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        // 저장된 사용자 정보가 있으면 로드
        final userData = jsonDecode(userJson);
        state = User.fromJson(userData);
      } else {
        // 없으면 샘플 사용자 생성
        state = _dataService.getSampleUser();
        await _saveUser();
      }
    } catch (e) {
      // 에러 시 샘플 사용자로 폴백
      state = _dataService.getSampleUser();
    }
  }

  /// 특정 계정의 사용자 정보 로드
  Future<void> loadUserByAccount(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_$accountId');

    if (userJson != null) {
      // 저장된 사용자 정보가 있으면 로드
      final userData = jsonDecode(userJson);
      state = User.fromJson(userData);
    } else {
      // 없으면 새 사용자 생성
      state = _dataService.getSampleUser().copyWith(id: accountId);
      await _saveUser();
    }
  }

  /// 현재 계정 변경 시 호출
  Future<void> switchToAccount(String accountId) async {
    await loadUserByAccount(accountId);
  }

  /// 사용자 정보 저장
  Future<void> _saveUser() async {
    if (state == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(state!.toJson());
    await prefs.setString('user', userJson);
  }

  /// XP 추가
  Future<void> addXP(int xp) async {
    if (state == null) return;

    final currentXP = state!.xp + xp;
    final currentLevel = state!.level;

    // 레벨업 체크 (100 XP = 1 레벨)
    final newLevel = (currentXP ~/ 100) + 1;
    final leveledUp = newLevel > currentLevel;

    state = state!.copyWith(
      xp: currentXP,
      level: newLevel,
    );

    await _saveUser();

    // 레벨업 시 알림
    if (leveledUp) {
      await _onLevelUp(newLevel);
    }
  }

  /// 레벨업 처리
  Future<void> _onLevelUp(int newLevel) async {
    // TODO: 레벨업 애니메이션 표시 (글로벌 오버레이)
    print('🎉 레벨 업! 새 레벨: $newLevel');

    // 레벨업 햅틱 피드백 (import 필요 시)
    try {
      // await AppHapticFeedback.levelUp();
    } catch (e) {
      // 햅틱 미지원 디바이스 대응
    }
  }

  /// 스트릭 업데이트 (매일 학습 시 호출)
  Future<void> updateStreak() async {
    if (state == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // SharedPreferences에서 마지막 학습 날짜 확인
    final prefs = await SharedPreferences.getInstance();
    final lastStudyDateString = prefs.getString('lastStudyDate');

    DateTime? lastStudyDate;
    if (lastStudyDateString != null) {
      lastStudyDate = DateTime.parse(lastStudyDateString);
      lastStudyDate = DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
    }

    int newStreakDays = state!.streakDays;

    if (lastStudyDate == null) {
      // 첫 학습
      newStreakDays = 1;
    } else if (lastStudyDate.isAtSameMomentAs(today)) {
      // 오늘 이미 학습함 - 스트릭 유지
      return;
    } else if (lastStudyDate.add(const Duration(days: 1)).isAtSameMomentAs(today)) {
      // 어제 학습했음 - 스트릭 증가
      newStreakDays = state!.streakDays + 1;
    } else {
      // 스트릭 끊김 - 새로 시작
      newStreakDays = 1;
    }

    state = state!.copyWith(streakDays: newStreakDays);

    // 마지막 학습 날짜 저장
    await prefs.setString('lastStudyDate', today.toIso8601String());
    await _saveUser();
  }

  /// 사용자 이름 변경
  Future<void> updateUserName(String newName) async {
    if (state == null) return;

    state = state!.copyWith(name: newName);
    await _saveUser();
  }

  /// 현재 학년 변경
  Future<void> updateCurrentGrade(String grade) async {
    if (state == null) return;

    state = state!.copyWith(currentGrade: grade);
    await _saveUser();
  }

  /// 사용자 초기화 (테스트용)
  Future<void> resetUser() async {
    state = _dataService.getSampleUser();
    await _saveUser();

    // SharedPreferences 클리어
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastStudyDate');
  }

  /// 일일 XP 목표 달성 여부
  bool get hasReachedDailyGoal {
    if (state == null) return false;
    const dailyGoal = 100;
    final todayXP = _getTodayXP();
    return todayXP >= dailyGoal;
  }

  /// 오늘 획득한 XP (실제로는 서버에서 계산해야 함)
  int _getTodayXP() {
    // 임시로 전체 XP의 일부로 계산
    return state?.xp.remainder(100) ?? 0;
  }

  /// 다음 레벨까지 필요한 XP
  int get xpToNextLevel {
    if (state == null) return 0;
    return state!.xpToNextLevel;
  }

  /// 현재 레벨 진행률
  double get levelProgress {
    if (state == null) return 0.0;
    return state!.levelProgress;
  }
}

/// 사용자 정보 프로바이더
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

/// 사용자 정보를 감시하는 편의 프로바이더들
final userXPProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  return user?.xp ?? 0;
});

final userLevelProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  return user?.level ?? 1;
});

final userStreakProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  return user?.streakDays ?? 0;
});

final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.name ?? '학습자';
});

final userGradeProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.currentGrade ?? '중1';
});