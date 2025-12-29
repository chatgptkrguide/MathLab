import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/gamification/heart_config.dart';
import '../../../shared/utils/logger.dart';

/// 하트 시스템 상태 관리 Provider
class HeartNotifier extends StateNotifier<HeartConfig> {
  Timer? _recoveryTimer;
  static const String _heartStorageKey = 'heart_config';

  HeartNotifier() : super(const HeartConfig()) {
    _loadHeartState();
    _startRecoveryTimer();
  }

  /// 로컬 저장소에서 하트 상태 로드
  Future<void> _loadHeartState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heartJson = prefs.getString(_heartStorageKey);

      if (heartJson != null) {
        final heartData = Map<String, dynamic>.from(
          // JSON decode 필요 시 json.decode 사용
          {}..addAll({'data': heartJson}),
        );

        state = HeartConfig.fromJson(heartData);
        Logger.info('하트 상태 로드 완료: ${state.currentHearts}/${state.maxHearts}', tag: 'Heart');
      }
    } catch (e, stackTrace) {
      Logger.error('하트 상태 로드 실패', error: e, stackTrace: stackTrace, tag: 'Heart');
    }
  }

  /// 로컬 저장소에 하트 상태 저장
  Future<void> _saveHeartState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heartJson = state.toJson();
      await prefs.setString(_heartStorageKey, heartJson.toString());

      Logger.info('하트 상태 저장 완료', tag: 'Heart');
    } catch (e, stackTrace) {
      Logger.error('하트 상태 저장 실패', error: e, stackTrace: stackTrace, tag: 'Heart');
    }
  }

  /// 하트 복구 타이머 시작
  void _startRecoveryTimer() {
    _recoveryTimer?.cancel();

    _recoveryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isFull) {
        timer.cancel();
        return;
      }

      _updateRecoveryState();
    });
  }

  /// 하트 복구 상태 업데이트
  void _updateRecoveryState() {
    if (state.lastHeartLostAt == null || state.isFull) return;

    final now = DateTime.now();
    final timeSinceLastLost = now.difference(state.lastHeartLostAt!);
    final minutesSinceLastLost = timeSinceLastLost.inMinutes;

    // 복구할 하트 개수 계산
    final heartsToRecover = (minutesSinceLastLost / state.heartRecoveryMinutes).floor();

    if (heartsToRecover > 0) {
      final newHearts = (state.currentHearts + heartsToRecover).clamp(0, state.maxHearts);
      final isFullyRecovered = newHearts >= state.maxHearts;

      state = state.copyWith(
        currentHearts: newHearts,
        lastHeartLostAt: isFullyRecovered
            ? null
            : state.lastHeartLostAt!.add(Duration(minutes: heartsToRecover * state.heartRecoveryMinutes)),
        clearLastHeartLostAt: isFullyRecovered,
      );

      _saveHeartState();

      Logger.info('하트 복구: ${state.currentHearts}/${state.maxHearts}', tag: 'Heart');
    }

    // 다음 하트 복구까지 남은 시간 계산
    if (!state.isFull && state.lastHeartLostAt != null) {
      final nextRecoveryTime = state.lastHeartLostAt!.add(
        Duration(minutes: state.heartRecoveryMinutes),
      );
      final secondsUntilNext = nextRecoveryTime.difference(now).inSeconds;

      state = state.copyWith(
        secondsUntilNextHeart: secondsUntilNext > 0 ? secondsUntilNext : 0,
      );
    }
  }

  /// 하트 감소 (문제를 틀렸을 때)
  Future<bool> loseHeart() async {
    if (state.isEmpty) {
      Logger.warning('하트가 이미 0개입니다', tag: 'Heart');
      return false;
    }

    final newHearts = state.currentHearts - 1;
    final now = DateTime.now();

    state = state.copyWith(
      currentHearts: newHearts,
      lastHeartLostAt: now,
    );

    await _saveHeartState();

    // 하트가 0이 되었을 때 타이머 시작
    if (state.isEmpty) {
      _startRecoveryTimer();
    }

    Logger.info('하트 감소: ${state.currentHearts}/${state.maxHearts}', tag: 'Heart');
    return true;
  }

  /// 하트 획득 (광고 시청, 구매 등)
  Future<void> gainHeart(int amount) async {
    final newHearts = (state.currentHearts + amount).clamp(0, state.maxHearts);

    state = state.copyWith(
      currentHearts: newHearts,
      clearLastHeartLostAt: newHearts >= state.maxHearts,
    );

    await _saveHeartState();

    Logger.info('하트 획득: ${state.currentHearts}/${state.maxHearts}', tag: 'Heart');
  }

  /// 하트 전체 복구 (프리미엄 기능 등)
  Future<void> refillHearts() async {
    state = state.copyWith(
      currentHearts: state.maxHearts,
      clearLastHeartLostAt: true,
    );

    await _saveHeartState();

    Logger.info('하트 전체 복구: ${state.currentHearts}/${state.maxHearts}', tag: 'Heart');
  }

  /// 하트 초기화 (디버그/테스트용)
  Future<void> resetHearts() async {
    state = const HeartConfig();
    await _saveHeartState();

    Logger.info('하트 초기화 완료', tag: 'Heart');
  }

  @override
  void dispose() {
    _recoveryTimer?.cancel();
    super.dispose();
  }
}

/// 하트 Provider
final heartProvider = StateNotifierProvider<HeartNotifier, HeartConfig>((ref) {
  return HeartNotifier();
});
