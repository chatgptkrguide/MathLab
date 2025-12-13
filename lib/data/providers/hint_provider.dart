import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/problem.dart';
import 'user_provider.dart';
import 'base/base_notifier.dart';

/// 힌트 상태
class HintState {
  final String? currentProblemId;
  final List<String> unlockedHints;
  final int totalHintsUsed;
  final bool canUseHint;

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

  Map<String, dynamic> toJson() => {
        'totalHintsUsed': totalHintsUsed,
      };

  factory HintState.fromJson(Map<String, dynamic> json) {
    return HintState(
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
    );
  }
}

/// 힌트 Provider (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - toJson/fromJson으로 직렬화 표준화
class HintProvider extends BaseNotifier<HintState> {
  final Ref _ref;

  static const String _storageKey = 'hint_usage';
  static const int hintCost = 10;

  HintProvider(this._ref) : super(const HintState(), 'HintProvider') {
    _loadState();
  }

  /// 상태 로드
  Future<void> _loadState() async {
    await executeWithErrorHandling(
      () async {
        final data = await loadFromStorage(_storageKey);
        if (data != null) {
          state = HintState.fromJson(data);
          logInfo('힌트 상태 로드 완료: ${state.totalHintsUsed}개 사용');
        }
      },
      errorMessage: '힌트 상태 로드 실패',
    );
  }

  /// 상태 저장
  Future<void> _saveState() async {
    await executeWithErrorHandling(
      () async {
        await saveToStorage(_storageKey, state.toJson());
        logInfo('힌트 상태 저장 완료');
      },
      errorMessage: '힌트 상태 저장 실패',
    );
  }

  /// 문제 시작 (힌트 초기화)
  void startProblem(String problemId) {
    state = state.copyWith(
      currentProblemId: problemId,
      unlockedHints: [],
      canUseHint: _checkCanUseHint(),
    );
    logInfo('문제 시작: $problemId');
  }

  /// 힌트 사용 가능 여부 확인
  bool _checkCanUseHint() {
    final user = _ref.read(userProvider);
    return (user?.xp ?? 0) >= hintCost;
  }

  /// 힌트 해제
  Future<bool> unlockHint(Problem problem, int hintIndex) async {
    if (hintIndex >= problem.hints.length) {
      logWarning('유효하지 않은 힌트 인덱스: $hintIndex');
      return false;
    }

    final hintKey = '${problem.id}_$hintIndex';
    if (state.unlockedHints.contains(hintKey)) {
      logWarning('이미 해제된 힌트: $hintKey');
      return false;
    }

    final user = _ref.read(userProvider);
    if ((user?.xp ?? 0) < hintCost) {
      logWarning('XP 부족: ${user?.xp} < $hintCost');
      return false;
    }

    final newXP = (user?.xp ?? 0) - hintCost;
    await _ref.read(userProvider.notifier).addXP(-hintCost);

    final updatedHints = [...state.unlockedHints, hintKey];
    final newTotalUsed = state.totalHintsUsed + 1;

    state = state.copyWith(
      unlockedHints: updatedHints,
      totalHintsUsed: newTotalUsed,
      canUseHint: newXP >= hintCost,
    );

    await _saveState();

    logInfo('힌트 해제: $hintKey (-$hintCost XP, 총 ${newTotalUsed}개)');

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
    logInfo('문제 종료, 힌트 초기화');
  }

  /// 통계 초기화 (테스트용)
  Future<void> resetStats() async {
    state = const HintState();
    await _saveState();
    logInfo('힌트 통계 초기화');
  }
}

/// Provider 정의
final hintProvider = StateNotifierProvider<HintProvider, HintState>((ref) {
  return HintProvider(ref);
});
