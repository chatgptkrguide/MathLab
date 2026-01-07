import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base/base_notifier.dart';

import '../auth/auth_provider.dart';

/// 레슨 진행 상태 관리
class LessonProgressNotifier extends BaseNotifier<Map<String, int>> {
  final Ref ref;

  LessonProgressNotifier(this.ref) : super({}, 'LessonProgressNotifier') {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      return null;
    }
    return 'lesson_progress_${currentAccount.id}';
  }

  /// 초기화 및 데이터 로드
  Future<void> _initialize() async {
    await _loadProgress();
  }

  /// 진행 상태 로드
  Future<void> _loadProgress() async {
    try {
      final key = _storageKey;
      if (key == null) {
        // 로그인된 계정 없음 - 빈 상태로 초기화
        state = {};
        return;
      }

      final progressData = await storage.getString(key);
      if (progressData != null && progressData.isNotEmpty) {
        // JSON 형태로 저장된 진행 상태 파싱
        final Map<String, dynamic> parsed = {};
        progressData.split(',').forEach((entry) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            parsed[parts[0]] = int.tryParse(parts[1]) ?? 0;
          }
        });
        state = Map<String, int>.from(parsed);
      } else {
        state = {};
      }
    } catch (e, stackTrace) {
      logError(
        '레슨 진행 상태 로드 실패',
        error: e,
        stackTrace: stackTrace,
      );
      state = {};
    }
  }

  /// 진행 상태 저장
  Future<void> _saveProgress() async {
    try {
      final key = _storageKey;
      if (key == null) {
        return;
      }

      // Map을 간단한 문자열 형태로 변환 (grade:index,grade:index,...)
      final progressString =
          state.entries.map((e) => '${e.key}:${e.value}').join(',');
      await storage.setString(key, progressString);
    } catch (e, stackTrace) {
      logError(
        '레슨 진행 상태 저장 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 특정 학년의 현재 진행중인 레슨 인덱스 가져오기
  int getCurrentLessonIndex(String grade) {
    return state[grade] ?? 0;
  }

  /// 레슨 완료 처리 (다음 레슨으로 진행)
  Future<void> completeLesson(String grade) async {
    final currentIndex = state[grade] ?? 0;
    final newState = Map<String, int>.from(state);
    newState[grade] = currentIndex + 1;
    state = newState;
    await _saveProgress();

    logInfo('레슨 완료: $grade - 레슨 ${currentIndex + 1}로 진행');
  }

  /// 진행 상태 초기화 (테스트용)
  Future<void> resetProgress() async {
    state = {};
    final key = _storageKey;
    if (key != null) {
      await storage.removeFromStorage(key);
    }
  }

  /// 특정 학년의 진행 상태 초기화
  Future<void> resetGradeProgress(String grade) async {
    final newState = Map<String, int>.from(state);
    newState[grade] = 0;
    state = newState;
    await _saveProgress();
  }
}

/// 레슨 진행 상태 프로바이더
final lessonProgressProvider =
    StateNotifierProvider<LessonProgressNotifier, Map<String, int>>((ref) {
  return LessonProgressNotifier(ref);
});

/// 특정 학년의 현재 레슨 인덱스 프로바이더
final currentLessonIndexProvider = Provider.family<int, String>((ref, grade) {
  final progress = ref.watch(lessonProgressProvider);
  return progress[grade] ?? 0;
});
