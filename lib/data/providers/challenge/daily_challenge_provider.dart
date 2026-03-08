// 🏆 Daily Challenge Provider
//
// Manages daily challenge data from Firestore.
// Loads today's challenge, tracks user progress, and handles completion.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../infrastructure/firebase_providers.dart';
// user_provider not directly imported; user UID comes via currentUserProvider

// ========================================
// Challenge Types
// ========================================

enum ChallengeType {
  /// Solve N problems in a row correctly
  streak,

  /// Achieve N% accuracy in a session
  accuracy,

  /// Solve N problems within time limit
  speed,

  /// Solve N total problems today
  count;

  String get displayName {
    switch (this) {
      case ChallengeType.streak:
        return '연속 정답';
      case ChallengeType.accuracy:
        return '정확도 달성';
      case ChallengeType.speed:
        return '빠른 풀이';
      case ChallengeType.count:
        return '문제 풀기';
    }
  }

  String descriptionFor(int target) {
    switch (this) {
      case ChallengeType.streak:
        return '$target문제 연속 정답 달성하기!';
      case ChallengeType.accuracy:
        return '정확도 $target% 이상 달성하기!';
      case ChallengeType.speed:
        return '$target초 안에 문제 풀기!';
      case ChallengeType.count:
        return '오늘 $target문제 풀기!';
    }
  }
}

// ========================================
// Daily Challenge State
// ========================================

class DailyChallengeState {
  final ChallengeType challengeType;
  final int targetValue;
  final int currentValue;
  final int rewardXp;
  final String description;
  final bool completed;
  final DateTime? completedAt;
  final bool isLoading;
  final String? error;

  const DailyChallengeState({
    this.challengeType = ChallengeType.count,
    this.targetValue = 5,
    this.currentValue = 0,
    this.rewardXp = 30,
    this.description = '',
    this.completed = false,
    this.completedAt,
    this.isLoading = true,
    this.error,
  });

  /// Progress ratio (0.0 ~ 1.0)
  double get progress {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Formatted progress text (e.g., "2/5 완료")
  String get progressText => '$currentValue/$targetValue 완료';

  DailyChallengeState copyWith({
    ChallengeType? challengeType,
    int? targetValue,
    int? currentValue,
    int? rewardXp,
    String? description,
    bool? completed,
    DateTime? completedAt,
    bool? isLoading,
    String? error,
  }) {
    return DailyChallengeState(
      challengeType: challengeType ?? this.challengeType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewardXp: rewardXp ?? this.rewardXp,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ========================================
// Daily Challenge Notifier
// ========================================

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  final FirebaseFirestore _firestore;
  final String? _userId;

  DailyChallengeNotifier(this._firestore, this._userId)
      : super(const DailyChallengeState()) {
    if (_userId != null) {
      loadTodayChallenge();
    } else {
      state = const DailyChallengeState(isLoading: false);
    }
  }

  /// Today's date as string key (e.g., "2026-03-08")
  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Load today's challenge from Firestore (or generate one)
  Future<void> loadTodayChallenge() async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Try to load today's challenge definition
      final challengeDoc = await _firestore
          .collection('daily_challenges')
          .doc(_todayKey)
          .get();

      ChallengeType type;
      int targetValue;
      int rewardXp;
      String description;

      if (challengeDoc.exists) {
        final data = challengeDoc.data()!;
        type = ChallengeType.values.firstWhere(
          (t) => t.name == data['challengeType'],
          orElse: () => ChallengeType.count,
        );
        targetValue = data['targetValue'] as int? ?? 5;
        rewardXp = data['rewardXp'] as int? ?? 30;
        description =
            data['description'] as String? ?? type.descriptionFor(targetValue);
      } else {
        // Generate a random challenge for today
        final generated = _generateRandomChallenge();
        type = generated['type'] as ChallengeType;
        targetValue = generated['target'] as int;
        rewardXp = generated['xp'] as int;
        description = type.descriptionFor(targetValue);

        // Save the generated challenge so all users get the same one
        await _firestore.collection('daily_challenges').doc(_todayKey).set({
          'challengeType': type.name,
          'targetValue': targetValue,
          'rewardXp': rewardXp,
          'description': description,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      // 2. Load user's progress for today
      final progressDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_challenge_progress')
          .doc(_todayKey)
          .get();

      int currentValue = 0;
      bool completed = false;
      DateTime? completedAt;

      if (progressDoc.exists) {
        final progressData = progressDoc.data()!;
        currentValue = progressData['currentValue'] as int? ?? 0;
        completed = progressData['completed'] as bool? ?? false;
        final completedTs = progressData['completedAt'] as Timestamp?;
        completedAt = completedTs?.toDate();
      }

      state = DailyChallengeState(
        challengeType: type,
        targetValue: targetValue,
        currentValue: currentValue,
        rewardXp: rewardXp,
        description: description,
        completed: completed,
        completedAt: completedAt,
        isLoading: false,
      );

      AppLogger.info('Daily challenge loaded', tag: 'DailyChallenge', data: {
        'type': type.name,
        'target': targetValue,
        'current': currentValue,
        'completed': completed,
      });
    } catch (e, st) {
      AppLogger.error('Failed to load daily challenge',
          tag: 'DailyChallenge', error: e, stackTrace: st);
      state = DailyChallengeState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update progress toward the daily challenge
  Future<void> updateProgress(int newValue) async {
    if (_userId == null || state.completed) return;

    try {
      final clampedValue = newValue.clamp(0, state.targetValue);
      final isNowCompleted = clampedValue >= state.targetValue;
      final now = DateTime.now();

      final progressData = <String, dynamic>{
        'currentValue': clampedValue,
        'completed': isNowCompleted,
        'updatedAt': Timestamp.fromDate(now),
      };

      if (isNowCompleted) {
        progressData['completedAt'] = Timestamp.fromDate(now);
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_challenge_progress')
          .doc(_todayKey)
          .set(progressData, SetOptions(merge: true));

      state = state.copyWith(
        currentValue: clampedValue,
        completed: isNowCompleted,
        completedAt: isNowCompleted ? now : null,
      );

      if (isNowCompleted) {
        AppLogger.info('Daily challenge completed!',
            tag: 'DailyChallenge', data: {'rewardXp': state.rewardXp});
      }
    } catch (e, st) {
      AppLogger.error('Failed to update challenge progress',
          tag: 'DailyChallenge', error: e, stackTrace: st);
    }
  }

  /// Increment progress by 1
  Future<void> incrementProgress() async {
    await updateProgress(state.currentValue + 1);
  }

  /// Generate a random daily challenge
  Map<String, dynamic> _generateRandomChallenge() {
    final random = Random();
    final types = ChallengeType.values;
    final type = types[random.nextInt(types.length)];

    int target;
    int xp;

    switch (type) {
      case ChallengeType.streak:
        target = [3, 5, 7, 10][random.nextInt(4)];
        xp = target * 6;
        break;
      case ChallengeType.accuracy:
        target = [70, 80, 90, 95][random.nextInt(4)];
        xp = (target * 0.4).round();
        break;
      case ChallengeType.speed:
        target = [30, 45, 60][random.nextInt(3)];
        xp = (90 - target) + 10;
        break;
      case ChallengeType.count:
        target = [5, 8, 10, 15][random.nextInt(4)];
        xp = target * 4;
        break;
    }

    return {
      'type': type,
      'target': target,
      'xp': xp,
    };
  }
}

// ========================================
// Providers
// ========================================

/// Daily challenge state provider
final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final currentUser = ref.watch(currentUserProvider);
  return DailyChallengeNotifier(firestore, currentUser?.uid);
});
