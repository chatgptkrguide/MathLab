import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../../shared/constants/game_constants.dart';
import '../../shared/utils/logger.dart';

/// 사용자 정보 상태 관리
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  final MockDataService _dataService = MockDataService();
  final LocalStorageService _storage = LocalStorageService();

  /// 앱 시작 시 사용자 정보 로드
  Future<void> _loadUser() async {
    try {
      Logger.info('사용자 정보 로드 시작', tag: 'UserProvider');

      final user = await _storage.loadSecureObject<User>(
        key: GameConstants.userStorageKey,
        fromJson: User.fromJson,
      );

      if (user != null) {
        // 저장된 사용자 정보가 있으면 로드
        state = user;
        Logger.info('사용자 정보 로드 성공: ${user.name}', tag: 'UserProvider');

        // 스트릭 확인 및 업데이트
        await checkAndUpdateStreak();

        // 하트 경과 시간 기반 재생
        await _updateHeartsBasedOnTime();
      } else {
        // 없으면 샘플 사용자 생성
        state = _dataService.getSampleUser();
        await _saveUser();
        Logger.info('새 사용자 생성: ${state?.name}', tag: 'UserProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 정보 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserProvider',
      );

      // 에러 시 샘플 사용자로 폴백
      state = _dataService.getSampleUser();
    }
  }

  /// 경과 시간 기반 하트 재생 (30분마다 1개)
  Future<void> _updateHeartsBasedOnTime() async {
    if (state == null || state!.hearts >= GameConstants.maxHearts) return;

    final now = DateTime.now();
    final lastHeartUpdate = state!.lastHeartUpdateTime ?? now;

    // 경과 시간 계산 (분 단위)
    final minutesPassed = now.difference(lastHeartUpdate).inMinutes;

    // 재생할 하트 수 계산 (30분마다 1개)
    final heartsToRegenerate = minutesPassed ~/ GameConstants.heartRecoveryMinutes;

    if (heartsToRegenerate > 0) {
      final newHearts = (state!.hearts + heartsToRegenerate).clamp(0, GameConstants.maxHearts);
      final actualRegenerated = newHearts - state!.hearts;

      if (actualRegenerated > 0) {
        state = state!.copyWith(
          hearts: newHearts,
          lastHeartUpdateTime: now,
        );
        await _saveUser();

        Logger.info(
          '하트 자동 재생: +$actualRegenerated (현재: $newHearts/${GameConstants.maxHearts})',
          tag: 'UserProvider',
        );
      }
    }
  }

  /// 하트 전체 구매 (광고 시청 또는 IAP)
  Future<void> purchaseFullHearts() async {
    if (state == null) return;

    state = state!.copyWith(hearts: GameConstants.maxHearts);
    await _saveUser();

    Logger.info('하트 전체 구매 완료: ${GameConstants.maxHearts}개', tag: 'UserProvider');
  }

  /// 특정 계정의 사용자 정보 로드
  Future<void> loadUserByAccount(String accountId) async {
    try {
      final user = await _storage.loadSecureObject<User>(
        key: 'user_$accountId',
        fromJson: User.fromJson,
      );

      if (user != null) {
        // 저장된 사용자 정보가 있으면 로드
        state = user;
        Logger.info('계정 로드 성공: $accountId', tag: 'UserProvider');
      } else {
        // 없으면 새 사용자 생성
        state = _dataService.getSampleUser().copyWith(id: accountId);
        await _saveUser();
        Logger.info('새 계정 생성: $accountId', tag: 'UserProvider');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '계정 로드 실패: $accountId',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserProvider',
      );
    }
  }

  /// 현재 계정 변경 시 호출
  Future<void> switchToAccount(String accountId) async {
    await loadUserByAccount(accountId);
  }

  /// 사용자 정보 저장
  Future<void> _saveUser() async {
    if (state == null) return;

    try {
      await _storage.saveSecureObject<User>(
        key: GameConstants.userStorageKey,
        data: state!,
        toJson: (user) => user.toJson(),
      );
      Logger.debug('사용자 정보 저장 완료', tag: 'UserProvider');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 정보 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserProvider',
      );
    }
  }

  /// 학년 업데이트
  Future<void> updateGrade(String newGrade) async {
    if (state == null) return;

    state = state!.copyWith(currentGrade: newGrade);
    await _saveUser();

    Logger.info('학년 변경: $newGrade', tag: 'UserProvider');
  }

  /// XP 추가
  Future<void> addXP(int xp) async {
    if (state == null) return;

    // 날짜가 바뀌었으면 일일 XP 리셋
    _checkAndResetDailyXP();

    final currentXP = state!.xp + xp;
    final currentLevel = state!.level;
    final currentDailyXP = state!.dailyXP + (xp > 0 ? xp : 0); // 음수 XP는 일일 XP에 반영하지 않음

    // 레벨업 체크
    final newLevel = (currentXP ~/ GameConstants.xpPerLevel) + 1;
    final leveledUp = newLevel > currentLevel;

    state = state!.copyWith(
      xp: currentXP,
      level: newLevel,
      dailyXP: currentDailyXP,
    );

    await _saveUser();

    Logger.info(
      'XP 추가: +$xp XP (총 $currentXP XP, 오늘 $currentDailyXP XP, 레벨 $newLevel)',
      tag: 'UserProvider',
    );

    // 레벨업 시 알림
    if (leveledUp) {
      await _onLevelUp(newLevel);
    }
  }

  /// 레벨업 처리
  Future<void> _onLevelUp(int newLevel) async {
    Logger.info('🎉 레벨 업! 새 레벨: $newLevel', tag: 'UserProvider');

    // 레벨업 햅틱 피드백
    try {
      // await AppHapticFeedback.levelUp();
    } catch (e) {
      Logger.warning(
        '햅틱 피드백 실패',
        tag: 'UserProvider',
      );
    }

    // 레벨업 시 하트 완전 회복
    state = state!.copyWith(hearts: GameConstants.maxHearts);
    await _saveUser();
  }

  /// 앱 시작 시 스트릭 확인 및 업데이트
  Future<void> checkAndUpdateStreak() async {
    if (state == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudyDate = state!.lastStudyDate;

    if (lastStudyDate == null) {
      // 처음 사용하는 경우 - 아무것도 하지 않음
      Logger.info('첫 사용자, 스트릭 대기 중', tag: 'UserProvider');
      return;
    }

    final lastStudyDateOnly = DateTime(
      lastStudyDate.year,
      lastStudyDate.month,
      lastStudyDate.day,
    );

    // 오늘 이미 학습했으면 아무것도 하지 않음
    if (_isSameDay(lastStudyDateOnly, today)) {
      Logger.debug('오늘 이미 학습 완료', tag: 'UserProvider');
      return;
    }

    // 어제 학습했으면 유지, 그 이전이면 리셋
    if (!_isConsecutiveDay(lastStudyDateOnly, today)) {
      // 스트릭 끊김
      final oldStreak = state!.streakDays;
      if (oldStreak > 0) {
        Logger.warning(
          '🔥 스트릭 끊김! 이전: $oldStreak일 → 0일로 리셋',
          tag: 'UserProvider',
        );
        state = state!.copyWith(streakDays: 0, lastStudyDate: null);
        await _saveUser();
      }
    }
  }

  /// 학습 완료 시 스트릭 증가
  Future<void> incrementStreakOnStudy() async {
    if (state == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudyDate = state!.lastStudyDate;

    int newStreakDays = state!.streakDays;

    if (lastStudyDate == null) {
      // 첫 학습
      newStreakDays = 1;
      Logger.info('🔥 첫 학습 시작! 스트릭: 1일', tag: 'UserProvider');
    } else {
      final lastStudyDateOnly = DateTime(
        lastStudyDate.year,
        lastStudyDate.month,
        lastStudyDate.day,
      );

      if (_isSameDay(lastStudyDateOnly, today)) {
        // 오늘 이미 학습함 - 스트릭 유지
        Logger.debug('오늘 이미 학습 완료, 스트릭 유지', tag: 'UserProvider');
        return;
      } else if (_isConsecutiveDay(lastStudyDateOnly, today)) {
        // 어제 학습했음 - 스트릭 증가
        newStreakDays = state!.streakDays + 1;
        Logger.info('🔥 스트릭 증가! 현재: $newStreakDays일', tag: 'UserProvider');
      } else {
        // 스트릭 끊김 - 새로 시작
        final oldStreak = state!.streakDays;
        newStreakDays = 1;
        Logger.warning(
          '🔥 스트릭 끊김! 이전: $oldStreak일 → 새로 시작: 1일',
          tag: 'UserProvider',
        );
      }
    }

    state = state!.copyWith(
      streakDays: newStreakDays,
      lastStudyDate: now,
    );

    await _saveUser();

    // 스트릭 유지 알림 스케줄링 (매일 저녁 8시)
    try {
      await NotificationService().scheduleStreakReminder(
        currentStreak: newStreakDays,
      );
      Logger.info('스트릭 알림 스케줄링 완료: $newStreakDays일', tag: 'UserProvider');
    } catch (e) {
      Logger.error('스트릭 알림 스케줄링 실패', error: e, tag: 'UserProvider');
    }
  }

  /// 스트릭 리셋 (관리자용 또는 테스트용)
  Future<void> resetStreak() async {
    if (state == null) return;

    Logger.warning('스트릭 강제 리셋', tag: 'UserProvider');
    state = state!.copyWith(
      streakDays: 0,
      lastStudyDate: null,
    );
    await _saveUser();
  }

  /// 연속된 날짜인지 확인 (어제 → 오늘)
  bool _isConsecutiveDay(DateTime lastDate, DateTime currentDate) {
    final yesterday = currentDate.subtract(const Duration(days: 1));
    return _isSameDay(lastDate, yesterday);
  }

  /// 같은 날짜인지 확인 (년-월-일만 비교)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 스트릭 업데이트 (매일 학습 시 호출) - DEPRECATED: incrementStreakOnStudy 사용
  @Deprecated('Use incrementStreakOnStudy instead')
  Future<void> updateStreak() async {
    await incrementStreakOnStudy();
  }

  /// 사용자 정보 전체 업데이트
  Future<void> updateUser(User updatedUser) async {
    state = updatedUser;
    await _saveUser();
    Logger.info('사용자 정보 업데이트 완료: ${updatedUser.name}', tag: 'UserProvider');
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

  /// 게스트 사용자 생성
  Future<void> createGuestUser() async {
    Logger.info('게스트 사용자 생성 시작', tag: 'UserProvider');

    // 게스트 ID 생성 (현재 시간 기반)
    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';

    // 샘플 사용자 기반으로 게스트 생성
    state = _dataService.getSampleUser().copyWith(
      id: guestId,
      name: '게스트',
    );

    await _saveUser();

    Logger.info('게스트 사용자 생성 완료: $guestId', tag: 'UserProvider');
  }

  /// 사용자 초기화 (테스트용)
  Future<void> resetUser() async {
    Logger.warning('사용자 데이터 초기화 시작', tag: 'UserProvider');

    state = _dataService.getSampleUser();
    await _saveUser();

    // Storage 클리어
    await _storage.remove(GameConstants.lastStudyDateKey);

    Logger.info('사용자 데이터 초기화 완료', tag: 'UserProvider');
  }

  /// 일일 XP 목표 달성 여부
  bool get hasReachedDailyGoal {
    if (state == null) return false;
    final todayXP = _getTodayXP();
    return todayXP >= GameConstants.dailyGoalXP;
  }

  /// 오늘 획득한 XP
  int _getTodayXP() {
    if (state == null) return 0;

    // 날짜가 바뀌었는지 확인
    _checkAndResetDailyXP();

    return state!.dailyXP;
  }

  /// 일일 XP 리셋 필요 여부 확인 및 실행
  void _checkAndResetDailyXP() {
    if (state == null) return;

    final now = DateTime.now();
    final lastReset = state!.lastXPResetDate;

    // 날짜가 바뀌었는지 확인 (년-월-일만 비교)
    final isSameDay = now.year == lastReset.year &&
                      now.month == lastReset.month &&
                      now.day == lastReset.day;

    if (!isSameDay) {
      // 날짜가 바뀌었으면 일일 XP 리셋
      state = state!.copyWith(
        dailyXP: 0,
        lastXPResetDate: now,
      );
      _saveUser();
      Logger.info('일일 XP 리셋 완료', tag: 'UserProvider');
    }
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

  /// 하트 감소 (오답 시)
  Future<void> decreaseHeart() async {
    if (state == null || state!.hearts <= 0) return;

    state = state!.copyWith(hearts: state!.hearts - 1);
    await _saveUser();
  }

  /// 하트 추가
  Future<void> addHearts(int amount) async {
    if (state == null) return;

    final newHearts = (state!.hearts + amount).clamp(0, GameConstants.maxHearts);
    state = state!.copyWith(hearts: newHearts);
    await _saveUser();

    Logger.info('하트 추가: +$amount (현재: $newHearts개)', tag: 'UserProvider');
  }

  /// 하트 복구 (시간 경과 또는 구매)
  Future<void> restoreHearts() async {
    if (state == null) return;

    state = state!.copyWith(hearts: GameConstants.maxHearts);
    await _saveUser();

    Logger.info('하트 복구 완료: ${GameConstants.maxHearts}개', tag: 'UserProvider');
  }

  /// 레벨 설정 (레벨 테스트 결과 반영)
  Future<void> setLevel(int level) async {
    if (state == null) return;

    final clampedLevel = level.clamp(1, 100); // 1-100 사이로 제한
    state = state!.copyWith(level: clampedLevel);
    await _saveUser();

    Logger.info('레벨 설정 완료: Level $clampedLevel', tag: 'UserProvider');
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