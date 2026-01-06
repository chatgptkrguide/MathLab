import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../services/mock_data_service.dart';
import '../../services/notification_service.dart';
import '../../services/heart_regeneration_service.dart';
import '../../repositories/user_repository.dart';
import '../../../shared/constants/game_constants.dart';
import '../base/base_notifier.dart';
import '../gamification/league_provider.dart';
import '../infrastructure/firebase_providers.dart';

/// 사용자 정보 상태 관리 (Firestore 연동 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - Firestore XP 동기화 (League와 연동)
class UserNotifier extends BaseNotifier<User?> {
  final UserRepository _userRepository;
  final Ref _ref;

  UserNotifier(this._userRepository, this._ref) : super(null, 'UserProvider') {
    _loadUser();
  }

  final MockDataService _dataService = MockDataService();

  /// 앱 시작 시 사용자 정보 로드
  Future<void> _loadUser() async {
    await executeWithErrorHandling(
      () async {
        final storageKey = _getStorageKey();
        logInfo('사용자 정보 로드 시작 (키: $storageKey)');

        // 1. 먼저 로컬 저장소 확인
        User? user = await _userRepository.get(storageKey);

        // 2. 로컬에 없고 ID가 있으면 Firestore에서 확인
        if (user == null && state?.id != null && state!.id.isNotEmpty && state!.id != 'default') {
          logInfo('로컬에 사용자 없음, Firestore 확인: ${state!.id}');
          user = await _userRepository.getFromFirebase(state!.id);

          // 3. Firestore에서 가져온 사용자 정보를 로컬에 저장
          if (user != null) {
            await _userRepository.saveToLocal(state!.id, user);
            logInfo('Firestore에서 기존 사용자 로드: ${user.name} (Level: ${user.level}, XP: ${user.xp})');
          }
        }

        if (user != null) {
          state = user;
          logInfo('사용자 정보 로드 성공: ${user.name} (키: $storageKey)');
          await checkAndUpdateStreak();
          await _updateHeartsBasedOnTime();

          // 백그라운드 하트 재생 서비스 시작
          if (user.id != 'default' && user.hearts < GameConstants.maxHearts) {
            await HeartRegenerationService.startBackgroundTask(user.id);
          }
        } else {
          // 4. Firestore에도 없는 경우에만 새 사용자 생성
          state = _dataService.getSampleUser();
          await _saveUser();
          logInfo('새 사용자 생성: ${state?.name} (키: $storageKey)');
        }
      },
      errorMessage: '사용자 정보 로드 실패',
      fallback: () {
        state = _dataService.getSampleUser();
      },
    );
  }

  /// 경과 시간 기반 하트 재생 (30분마다 1개)
  Future<void> _updateHeartsBasedOnTime() async {
    if (state == null || state!.hearts >= GameConstants.maxHearts) return;

    final now = DateTime.now().toUtc(); // UTC 시간 사용
    final lastHeartUpdate = (state!.lastHeartUpdateTime ?? now).toUtc(); // UTC로 변환
    final minutesPassed = now.difference(lastHeartUpdate).inMinutes;
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
        logInfo('하트 자동 재생: +$actualRegenerated (현재: $newHearts/${GameConstants.maxHearts})');
      }
    }
  }

  /// 하트 전체 구매 (광고 시청 또는 IAP)
  Future<void> purchaseFullHearts() async {
    if (state == null) return;

    state = state!.copyWith(hearts: GameConstants.maxHearts);
    await _saveUser();
    logInfo('하트 전체 구매 완료: ${GameConstants.maxHearts}개');
  }

  /// 스토리지 키 생성 헬퍼 메서드
  String _getStorageKey([String? accountId]) {
    final targetId = accountId ?? state?.id;

    if (targetId == null || targetId.isEmpty || targetId == 'default') {
      return GameConstants.userStorageKey;
    }

    return 'user_$targetId';
  }

  /// 특정 계정의 사용자 정보 로드
  Future<void> loadUserByAccount(String accountId) async {
    await executeWithErrorHandling(
      () async {
        final storageKey = _getStorageKey(accountId);

        // 1. 먼저 로컬 저장소 확인
        User? user = await _userRepository.get(storageKey);

        // 2. 로컬에 없으면 Firestore에서 확인 (임시 비활성화 - Firebase 권한 문제)
        // TODO: Firebase Security Rules 설정 후 활성화
        // if (user == null) {
        //   logInfo('로컬에 사용자 없음, Firestore 확인: $accountId');
        //   try {
        //     user = await _userRepository.getFromFirebase(accountId);
        //     if (user != null) {
        //       await _userRepository.saveToLocal(accountId, user);
        //       logInfo('Firestore에서 기존 사용자 로드: ${user.name} (Level: ${user.level}, XP: ${user.xp})');
        //     }
        //   } catch (e) {
        //     logError('Firestore 접근 실패, 로컬 전용 모드로 실행', error: e);
        //   }
        // }

        if (user != null) {
          state = user;
          logInfo('계정 로드 성공: $accountId (키: $storageKey)');

          // 스트릭과 하트 업데이트
          await checkAndUpdateStreak();
          await _updateHeartsBasedOnTime();
        } else {
          // 3. 로컬에 없는 경우 새 사용자 생성 (로컬 전용)
          state = _dataService.getSampleUser().copyWith(id: accountId);
          await _saveUser();

          // Firebase 저장 비활성화 (권한 문제)
          // TODO: Firebase Security Rules 설정 후 활성화
          // try {
          //   await _userRepository.saveToFirebase(accountId, state!);
          // } catch (e) {
          //   logError('Firebase 저장 실패, 로컬만 저장됨', error: e);
          // }
          logInfo('새 계정 생성 (로컬): $accountId (키: $storageKey)');
        }
      },
      errorMessage: '계정 로드 실패: $accountId',
    );
  }

  /// 현재 계정 변경 시 호출
  Future<void> switchToAccount(String accountId) async {
    await loadUserByAccount(accountId);
  }

  /// 사용자 정보 저장
  Future<void> _saveUser() async {
    if (state == null) return;

    await executeWithErrorHandling(
      () async {
        final storageKey = _getStorageKey();
        await _userRepository.save(storageKey, state!);
        logInfo('사용자 정보 저장 완료 (키: $storageKey)');
      },
      errorMessage: '사용자 정보 저장 실패',
    );
  }

  /// 학년 업데이트
  Future<void> updateGrade(String newGrade) async {
    if (state == null) return;

    state = state!.copyWith(currentGrade: newGrade);
    await _saveUser();
    logInfo('학년 변경: $newGrade');
  }

  /// 프로필 전체 업데이트
  Future<void> updateProfile(User updatedUser) async {
    try {
      logInfo('프로필 업데이트 시작');

      // 로컬 상태 업데이트
      state = updatedUser;

      // 로컬 스토리지에 저장
      await _saveUser();

      // Firestore에 저장
      await _userRepository.saveToFirebase(updatedUser.id, updatedUser);

      logInfo('프로필 업데이트 완료: ${updatedUser.name} (완성도: ${updatedUser.isProfileComplete})');
    } catch (e, stackTrace) {
      logError('프로필 업데이트 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// XP 추가 (Firestore 및 League 동기화)
  Future<void> addXP(int xp) async {
    if (state == null) return;

    _checkAndResetDailyXP();

    final currentXP = state!.xp + xp;
    final currentLevel = state!.level;
    final currentDailyXP = state!.dailyXP + (xp > 0 ? xp : 0);

    final newLevel = (currentXP ~/ GameConstants.xpPerLevel) + 1;
    final leveledUp = newLevel > currentLevel;

    // 로컬 state 즉시 업데이트
    state = state!.copyWith(
      xp: currentXP,
      level: newLevel,
      dailyXP: currentDailyXP,
    );

    await _saveUser();
    logInfo('XP 추가: +$xp XP (총 $currentXP XP, 오늘 $currentDailyXP XP, 레벨 $newLevel)');

    // Firestore 동기화 (백그라운드)
    _syncXPToFirestore(xp).catchError((error, stackTrace) {
      logError('Firestore XP 동기화 실패', error: error, stackTrace: stackTrace);
    });

    // League 동기화 (백그라운드)
    _syncXPToLeague(xp).catchError((error, stackTrace) {
      logError('League XP 동기화 실패', error: error, stackTrace: stackTrace);
    });

    if (leveledUp) {
      await _onLevelUp(newLevel);
    }
  }

  /// Firestore XP 동기화
  Future<void> _syncXPToFirestore(int xpGained) async {
    if (state == null) return;

    await executeWithErrorHandling(
      () async {
        await _userRepository.updateXP(state!.id, xpGained);
        logInfo('Firestore XP 동기화 완료: +$xpGained');
      },
      errorMessage: 'Firestore XP 동기화 실패',
    );
  }

  /// League XP 동기화
  Future<void> _syncXPToLeague(int xpGained) async {
    await executeWithErrorHandling(
      () async {
        final leagueNotifier = _ref.read(leagueProvider.notifier);
        await leagueNotifier.updateUserXP(xpGained);
        logInfo('League XP 동기화 완료: +$xpGained');
      },
      errorMessage: 'League XP 동기화 실패',
    );
  }

  /// 레벨업 처리
  Future<void> _onLevelUp(int newLevel) async {
    logInfo('🎉 레벨 업! 새 레벨: $newLevel');

    try {
      // await AppHapticFeedback.levelUp();
    } catch (e) {
      logWarning('햅틱 피드백 실패');
    }

    state = state!.copyWith(hearts: GameConstants.maxHearts);
    await _saveUser();
  }

  /// 앱 시작 시 스트릭 확인 및 업데이트
  Future<void> checkAndUpdateStreak() async {
    if (state == null) return;

    final now = DateTime.now().toUtc(); // UTC 시간 사용
    final today = DateTime.utc(now.year, now.month, now.day); // UTC 날짜만
    final lastStudyDate = state!.lastStudyDate?.toUtc(); // UTC로 변환

    if (lastStudyDate == null) {
      logInfo('첫 사용자, 스트릭 대기 중');
      return;
    }

    final lastStudyDateOnly = DateTime(
      lastStudyDate.year,
      lastStudyDate.month,
      lastStudyDate.day,
    );

    if (_isSameDay(lastStudyDateOnly, today)) {
      logInfo('오늘 이미 학습 완료');
      return;
    }

    if (!_isConsecutiveDay(lastStudyDateOnly, today)) {
      final oldStreak = state!.streakDays;
      if (oldStreak > 0) {
        logWarning('🔥 스트릭 끊김! 이전: $oldStreak일 → 0일로 리셋');
        state = state!.copyWith(streakDays: 0, lastStudyDate: null);
        await _saveUser();
      }
    }
  }

  /// 학습 완료 시 스트릭 증가
  Future<void> incrementStreakOnStudy() async {
    if (state == null) return;

    final now = DateTime.now().toUtc(); // UTC 시간 사용
    final today = DateTime.utc(now.year, now.month, now.day); // UTC 날짜만
    final lastStudyDate = state!.lastStudyDate?.toUtc(); // UTC로 변환

    int newStreakDays = state!.streakDays;

    if (lastStudyDate == null) {
      newStreakDays = 1;
      logInfo('🔥 첫 학습 시작! 스트릭: 1일');
    } else {
      final lastStudyDateOnly = DateTime.utc(
        lastStudyDate.year,
        lastStudyDate.month,
        lastStudyDate.day,
      );

      if (_isSameDay(lastStudyDateOnly, today)) {
        logInfo('오늘 이미 학습 완료, 스트릭 유지');
        return;
      } else if (_isConsecutiveDay(lastStudyDateOnly, today)) {
        newStreakDays = state!.streakDays + 1;
        logInfo('🔥 스트릭 증가! 현재: $newStreakDays일');
      } else {
        final oldStreak = state!.streakDays;
        newStreakDays = 1;
        logWarning('🔥 스트릭 끊김! 이전: $oldStreak일 → 새로 시작: 1일');
      }
    }

    state = state!.copyWith(
      streakDays: newStreakDays,
      lastStudyDate: now,
    );

    await _saveUser();

    try {
      await NotificationService().scheduleStreakReminder(
        currentStreak: newStreakDays,
      );
      logInfo('스트릭 알림 스케줄링 완료: $newStreakDays일');
    } catch (e) {
      logError('스트릭 알림 스케줄링 실패', error: e);
    }
  }

  /// 스트릭 리셋 (관리자용 또는 테스트용)
  Future<void> resetStreak() async {
    if (state == null) return;

    logWarning('스트릭 강제 리셋');
    state = state!.copyWith(
      streakDays: 0,
      lastStudyDate: null,
    );
    await _saveUser();
  }

  /// 연속된 날짜인지 확인 (어제 → 오늘) - UTC 기준
  bool _isConsecutiveDay(DateTime lastDate, DateTime currentDate) {
    // 모두 UTC로 변환
    final lastUtc = lastDate.toUtc();
    final currentUtc = currentDate.toUtc();

    // UTC 기준으로 어제 날짜 계산
    final yesterday = DateTime.utc(
      currentUtc.year,
      currentUtc.month,
      currentUtc.day,
    ).subtract(const Duration(days: 1));

    // UTC 기준으로 같은 날짜인지 비교
    return lastUtc.year == yesterday.year &&
           lastUtc.month == yesterday.month &&
           lastUtc.day == yesterday.day;
  }

  /// 같은 날짜인지 확인 (년-월-일만 비교) - UTC 기준
  bool _isSameDay(DateTime date1, DateTime date2) {
    // 모두 UTC로 변환
    final utc1 = date1.toUtc();
    final utc2 = date2.toUtc();

    return utc1.year == utc2.year &&
           utc1.month == utc2.month &&
           utc1.day == utc2.day;
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
    logInfo('사용자 정보 업데이트 완료: ${updatedUser.name}');
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
    logInfo('게스트 사용자 생성 시작');

    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';

    state = _dataService.getSampleUser().copyWith(
      id: guestId,
      name: '게스트',
    );

    await _saveUser();
    logInfo('게스트 사용자 생성 완료: $guestId');
  }

  /// 사용자 초기화 (테스트용)
  Future<void> resetUser() async {
    logWarning('사용자 데이터 초기화 시작');

    state = _dataService.getSampleUser();
    await _saveUser();

    logInfo('사용자 데이터 초기화 완료');
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
    _checkAndResetDailyXP();
    return state!.dailyXP;
  }

  /// 일일 XP 리셋 필요 여부 확인 및 실행
  void _checkAndResetDailyXP() {
    if (state == null) return;

    final now = DateTime.now().toUtc(); // UTC 시간 사용
    final lastReset = state!.lastXPResetDate.toUtc(); // UTC로 변환

    final isSameDay = now.year == lastReset.year &&
                      now.month == lastReset.month &&
                      now.day == lastReset.day;

    if (!isSameDay) {
      state = state!.copyWith(
        dailyXP: 0,
        lastXPResetDate: now,
      );
      _saveUser();
      logInfo('일일 XP 리셋 완료');
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

    final newHearts = state!.hearts - 1;
    state = state!.copyWith(
      hearts: newHearts,
      lastHeartUpdateTime: DateTime.now().toUtc(), // UTC 시간으로 기록
    );
    await _saveUser();

    // 백그라운드 서비스에 하트 업데이트 알림
    await HeartRegenerationService.updateHearts(newHearts);

    // 하트가 0이 되면 백그라운드 타이머 시작
    if (newHearts == 0 && state!.id != 'default') {
      await HeartRegenerationService.startBackgroundTask(state!.id);
      logInfo('하트 소진 - 백그라운드 재생 타이머 시작');
    }

    logInfo('하트 감소: ${newHearts}/${GameConstants.maxHearts}');
  }

  /// 하트 추가
  Future<void> addHearts(int amount) async {
    if (state == null) return;

    final newHearts = (state!.hearts + amount).clamp(0, GameConstants.maxHearts);
    state = state!.copyWith(
      hearts: newHearts,
      lastHeartUpdateTime: DateTime.now().toUtc(), // UTC 시간으로 기록
    );
    await _saveUser();

    // 백그라운드 서비스에 하트 업데이트 알림
    await HeartRegenerationService.updateHearts(newHearts);

    // 하트가 최대치가 되면 백그라운드 타이머 중지
    if (newHearts >= GameConstants.maxHearts && state!.id != 'default') {
      await HeartRegenerationService.stopBackgroundTask();
      logInfo('하트 최대치 도달 - 백그라운드 타이머 중지');
    }

    logInfo('하트 추가: +$amount (현재: $newHearts/${GameConstants.maxHearts})');
  }

  /// 하트 복구 (시간 경과 또는 구매)
  Future<void> restoreHearts() async {
    if (state == null) return;

    state = state!.copyWith(hearts: GameConstants.maxHearts);
    await _saveUser();

    logInfo('하트 복구 완료: ${GameConstants.maxHearts}개');
  }

  /// 레벨 설정 (레벨 테스트 결과 반영)
  Future<void> setLevel(int level) async {
    if (state == null) return;

    final clampedLevel = level.clamp(1, 100);
    state = state!.copyWith(level: clampedLevel);
    await _saveUser();

    logInfo('레벨 설정 완료: Level $clampedLevel');
  }
}

/// 사용자 정보 프로바이더
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepository, ref);
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
