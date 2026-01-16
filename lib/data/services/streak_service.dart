import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user.dart';
import '../../shared/utils/logger.dart';

/// 스트릭 자동 업데이트 서비스
///
/// **역할:**
/// - 매일 자정에 스트릭 상태 체크
/// - 학습하지 않은 날 스트릭 초기화
/// - 연속 학습 기록 관리
///
/// **동작 방식:**
/// 1. 앱 시작 시 초기화
/// 2. 매일 자정(00:00)에 체크
/// 3. lastStudyDate가 어제보다 이전이면 스트릭 초기화
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  Timer? _dailyCheckTimer;
  bool _isInitialized = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.debug('Streak service already initialized', tag: 'StreakService');
      return;
    }

    try {
      // 앱 시작 시 모든 사용자의 스트릭 체크
      await _checkAllUsersStreak();

      // 매일 자정 체크 타이머 시작
      _startDailyCheckTimer();

      _isInitialized = true;
      Logger.info('Streak service initialized successfully', tag: 'StreakService');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize streak service',
          error: e, stackTrace: stackTrace, tag: 'StreakService');
    }
  }

  /// 매일 자정 체크 타이머 시작
  void _startDailyCheckTimer() {
    // 다음 자정까지의 시간 계산
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    Logger.debug(
        'Next streak check in ${timeUntilMidnight.inHours}h ${timeUntilMidnight.inMinutes % 60}m',
        tag: 'StreakService');

    // 자정에 실행되도록 타이머 설정
    _dailyCheckTimer = Timer(timeUntilMidnight, () {
      _checkAllUsersStreak();

      // 다음 날 자정을 위한 24시간 주기 타이머 시작
      _dailyCheckTimer = Timer.periodic(const Duration(days: 1), (timer) {
        _checkAllUsersStreak();
      });
    });
  }

  /// 모든 사용자의 스트릭 체크
  Future<void> _checkAllUsersStreak() async {
    try {
      Logger.info('Starting daily streak check for all users', tag: 'StreakService');

      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      // 모든 사용자 조회
      final usersSnapshot = await _firestore.collection('users').get();

      int resetCount = 0;
      int maintainedCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        try {
          final data = userDoc.data();
          final lastStudyDate = (data['lastStudyDate'] as Timestamp?)?.toDate();
          final currentStreak = data['streak'] as int? ?? 0;

          // 스트릭이 없으면 스킵
          if (currentStreak == 0) {
            continue;
          }

          // lastStudyDate가 어제보다 이전이면 스트릭 초기화
          if (lastStudyDate == null ||
              lastStudyDate.isBefore(yesterday)) {
            await _resetUserStreak(userDoc.id);
            resetCount++;
          } else {
            maintainedCount++;
          }
        } catch (e, stackTrace) {
          Logger.error('Failed to check streak for user ${userDoc.id}',
              error: e, stackTrace: stackTrace, tag: 'StreakService');
        }
      }

      Logger.info(
          'Daily streak check completed: $resetCount reset, $maintainedCount maintained',
          tag: 'StreakService');
    } catch (e, stackTrace) {
      Logger.error('Failed to check all users streak',
          error: e, stackTrace: stackTrace, tag: 'StreakService');
    }
  }

  /// 특정 사용자의 스트릭 체크
  Future<void> checkUserStreak(String userId) async {
    try {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        Logger.warning('User not found: $userId', tag: 'StreakService');
        return;
      }

      final data = userDoc.data()!;
      final lastStudyDate = (data['lastStudyDate'] as Timestamp?)?.toDate();
      final currentStreak = data['streak'] as int? ?? 0;

      // 스트릭이 없으면 스킵
      if (currentStreak == 0) {
        return;
      }

      // lastStudyDate가 어제보다 이전이면 스트릭 초기화
      if (lastStudyDate == null ||
          lastStudyDate.isBefore(yesterday)) {
        await _resetUserStreak(userId);
        Logger.info('Streak reset for user $userId', tag: 'StreakService');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to check user streak',
          error: e, stackTrace: stackTrace, tag: 'StreakService');
    }
  }

  /// 사용자 스트릭 초기화
  Future<void> _resetUserStreak(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'streak': 0,
        'streakDays': 0,
        'lastStreakResetAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Streak reset for user: $userId', tag: 'StreakService');
    } catch (e, stackTrace) {
      Logger.error('Failed to reset user streak',
          error: e, stackTrace: stackTrace, tag: 'StreakService');
    }
  }

  /// 사용자 스트릭 증가 (오늘 처음 학습 시)
  Future<void> incrementStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        Logger.warning('User not found: $userId', tag: 'StreakService');
        return;
      }

      final data = userDoc.data()!;
      final lastStudyDate = (data['lastStudyDate'] as Timestamp?)?.toDate();
      final currentStreak = data['streak'] as int? ?? 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 오늘 이미 학습했는지 체크
      if (lastStudyDate != null) {
        final lastStudyDay = DateTime(
          lastStudyDate.year,
          lastStudyDate.month,
          lastStudyDate.day,
        );

        if (lastStudyDay.isAtSameMomentAs(today)) {
          Logger.debug('Already studied today, streak not incremented',
              tag: 'StreakService');
          return;
        }
      }

      // 스트릭 증가
      final newStreak = currentStreak + 1;

      await _firestore.collection('users').doc(userId).update({
        'streak': newStreak,
        'streakDays': newStreak,
        'lastStudyDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Streak incremented to $newStreak for user: $userId',
          tag: 'StreakService');
    } catch (e, stackTrace) {
      Logger.error('Failed to increment streak',
          error: e, stackTrace: stackTrace, tag: 'StreakService');
    }
  }

  /// 서비스 종료
  void dispose() {
    _dailyCheckTimer?.cancel();
    _dailyCheckTimer = null;
    _isInitialized = false;
    Logger.info('Streak service disposed', tag: 'StreakService');
  }
}
