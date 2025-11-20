import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/problem.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../../data/services/local_storage_service.dart';

/// 힌트 상태
class HintState {
  final String? currentProblemId;
  final List<String> unlockedHints; // 해제된 힌트 인덱스
  final int totalHintsUsed; // 총 사용한 힌트 수
  final bool canUseHint; // 힌트 사용 가능 여부 (XP 충분한지)

  const HintState({
    this.currentProblemId,
    this.unlockedHints = const [],
    this.totalHintsUsed = 0,
    this.canUseHint = true,
  });

  HintState copyWith({
    String? currentProblemId,
    List<String>? unlockedHints,
    int? totalHintsUsed,
    bool? canUseHint,
  }) {
    return HintState(
      currentProblemId: currentProblemId ?? this.currentProblemId,
      unlockedHints: unlockedHints ?? this.unlockedHints,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      canUseHint: canUseHint ?? this.canUseHint,
    );
  }
}

/// 힌트 Provider
class HintProvider extends StateNotifier<HintState> {
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();

  static const String _storageKey = 'hint_usage';
  static const int hintCost = 10; // 힌트 1개당 10 XP

  HintProvider(this._ref) : super(const HintState()) {
    _loadState();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        final totalHintsUsed = data['totalHintsUsed'] ?? 0;

        state = state.copyWith(
          totalHintsUsed: totalHintsUsed,
        );

        Logger.info('Hint state loaded: $totalHintsUsed hints used');
      }
    } catch (e) {
      Logger.error('Failed to load hint state', error: e);
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      await _storage.saveMap(_storageKey, {
        'totalHintsUsed': state.totalHintsUsed,
      });

      Logger.info('Hint state saved');
    } catch (e) {
      Logger.error('Failed to save hint state', error: e);
    }
  }

  /// 문제 시작 (힌트 초기화)
  void startProblem(String problemId) {
    state = state.copyWith(
      currentProblemId: problemId,
      unlockedHints: [],
      canUseHint: _checkCanUseHint(),
    );

    Logger.info('Started problem: $problemId');
  }

  /// 힌트 사용 가능 여부 확인
  bool _checkCanUseHint() {
    final user = _ref.read(userProvider);
    return (user?.xp ?? 0) >= hintCost;
  }

  /// 힌트 해제
  Future<bool> unlockHint(Problem problem, int hintIndex) async {
    // 힌트가 있는지 확인
    if (hintIndex >= problem.hints.length) {
      Logger.warning('Invalid hint index: $hintIndex');
      return false;
    }

    // 이미 해제된 힌트인지 확인
    final hintKey = '${problem.id}_$hintIndex';
    if (state.unlockedHints.contains(hintKey)) {
      Logger.warning('Hint already unlocked: $hintKey');
      return false;
    }

    // XP 확인
    final user = _ref.read(userProvider);
    if ((user?.xp ?? 0) < hintCost) {
      Logger.warning('Not enough XP for hint: ${user?.xp}');
      return false;
    }

    // XP 차감
    final newXP = (user?.xp ?? 0) - hintCost;
    await _ref.read(userProvider.notifier).addXP(-hintCost);

    // 힌트 해제
    final updatedHints = [...state.unlockedHints, hintKey];
    final newTotalUsed = state.totalHintsUsed + 1;

    state = state.copyWith(
      unlockedHints: updatedHints,
      totalHintsUsed: newTotalUsed,
      canUseHint: newXP >= hintCost,
    );

    await _saveState();

    Logger.info('Unlocked hint: $hintKey (-$hintCost XP, total hints: $newTotalUsed)');

    return true;
  }

  /// 힌트 해제 여부 확인
  bool isHintUnlocked(String problemId, int hintIndex) {
    final hintKey = '${problemId}_$hintIndex';
    return state.unlockedHints.contains(hintKey);
  }

  /// 다음 힌트 인덱스 (다음에 해제할 힌트)
  int? getNextHintIndex(Problem problem) {
    if (problem.hints.isEmpty) return null;

    for (int i = 0; i < problem.hints.length; i++) {
      if (!isHintUnlocked(problem.id, i)) {
        return i;
      }
    }

    return null; // 모든 힌트 해제됨
  }

  /// 문제 종료 (힌트 초기화)
  void endProblem() {
    state = state.copyWith(
      currentProblemId: null,
      unlockedHints: [],
    );

    Logger.info('Problem ended, hints cleared');
  }

  /// 통계 초기화 (테스트용)
  Future<void> resetStats() async {
    state = const HintState();
    await _saveState();

    Logger.info('Hint stats reset');
  }
}

/// Provider 정의
final hintProvider = StateNotifierProvider<HintProvider, HintState>((ref) {
  return HintProvider(ref);
});
