import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/learning/problem.dart';
import '../base/base_notifier.dart';
import '../user/user_provider.dart';

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

/// 힌트 Provider (최적화된 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling으로 try-catch 자동화
/// - updateAndSave로 상태 업데이트 + 저장 단순화
class HintProviderOptimized extends BaseNotifier<HintState> {
  final Ref _ref;

  static const String _storageKey = 'hint_usage';
  static const int hintCost = 10;

  HintProviderOptimized(this._ref)
      : super(const HintState(), 'HintProvider') {
    _loadState();
  }

  // ==================== 초기화 ====================

  /// 상태 로드 (자동 에러 처리)
  Future<void> _loadState() async {
    final data = await loadFromStorage(_storageKey);
    if (data != null) {
      state = HintState.fromJson(data);
      logInfo('힌트 상태 로드 완료: ${state.totalHintsUsed}회 사용');
    }
  }

  /// 상태 저장 (자동 에러 처리)
  Future<void> _saveState() async {
    await updateAndSave(
      state,
      saveKey: _storageKey,
      toJson: (state) => state.toJson(),
    );
  }

  // ==================== 힌트 관리 ====================

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
    return await executeWithErrorHandling(
      () async {
        // 유효성 검증
        if (hintIndex >= problem.hints.length) {
          logWarning('잘못된 힌트 인덱스: $hintIndex');
          return false;
        }

        final hintKey = '${problem.id}_$hintIndex';
        if (state.unlockedHints.contains(hintKey)) {
          logWarning('이미 해제된 힌트: $hintKey');
          return false;
        }

        final user = _ref.read(userProvider);
        if ((user?.xp ?? 0) < hintCost) {
          logWarning('XP 부족: ${user?.xp}');
          return false;
        }

        // XP 차감 및 힌트 해제
        await _ref.read(userProvider.notifier).addXP(-hintCost);

        state = state.copyWith(
          unlockedHints: [...state.unlockedHints, hintKey],
          totalHintsUsed: state.totalHintsUsed + 1,
          canUseHint: (user?.xp ?? 0) - hintCost >= hintCost,
        );

        await _saveState();

        logInfo('힌트 해제: $hintKey (-$hintCost XP, 총 ${state.totalHintsUsed}회)');
        return true;
      },
      errorMessage: '힌트 해제 실패',
      fallback: () => false,
    ) ?? false;
  }

  /// 힌트 해제 여부 확인
  bool isHintUnlocked(String problemId, int hintIndex) {
    return state.unlockedHints.contains('${problemId}_$hintIndex');
  }

  /// 다음 힌트 인덱스
  int? getNextHintIndex(Problem problem) {
    if (problem.hints.isEmpty) return null;

    for (int i = 0; i < problem.hints.length; i++) {
      if (!isHintUnlocked(problem.id, i)) return i;
    }

    return null;
  }

  /// 문제 종료
  void endProblem() {
    state = state.copyWith(
      currentProblemId: null,
      unlockedHints: [],
    );
    logInfo('문제 종료, 힌트 초기화');
  }

  /// 통계 초기화
  Future<void> resetStats() async {
    state = const HintState();
    await _saveState();
    logInfo('힌트 통계 초기화');
  }
}

/// Provider 정의 (최적화 버전)
final hintProviderOptimized =
    StateNotifierProvider<HintProviderOptimized, HintState>((ref) {
  return HintProviderOptimized(ref);
});
