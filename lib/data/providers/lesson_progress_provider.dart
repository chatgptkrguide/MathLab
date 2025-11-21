import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../../shared/utils/logger.dart';

/// 레슨 진행 상태 관리
class LessonProgressNotifier extends StateNotifier<Map<String, int>> {
  LessonProgressNotifier() : super({}) {
    _loadProgress();
  }

  final LocalStorageService _storage = LocalStorageService();
  static const String _storageKey = 'lesson_progress';

  /// 진행 상태 로드
  Future<void> _loadProgress() async {
    try {
      final progressData = await _storage.getString(_storageKey);
      if (progressData != null) {
        // JSON 형태로 저장된 진행 상태 파싱
        final Map<String, dynamic> parsed = {};
        progressData.split(',').forEach((entry) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            parsed[parts[0]] = int.tryParse(parts[1]) ?? 0;
          }
        });
        state = Map<String, int>.from(parsed);
        Logger.info('레슨 진행 상태 로드 완료', tag: 'LessonProgress');
      }
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 진행 상태 로드 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonProgress',
      );
    }
  }

  /// 진행 상태 저장
  Future<void> _saveProgress() async {
    try {
      // Map을 간단한 문자열 형태로 변환 (grade:index,grade:index,...)
      final progressString = state.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      await _storage.setString(_storageKey, progressString);
      Logger.debug('레슨 진행 상태 저장 완료', tag: 'LessonProgress');
    } catch (e, stackTrace) {
      Logger.error(
        '레슨 진행 상태 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'LessonProgress',
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

    Logger.info(
      '레슨 완료: $grade - 레슨 ${currentIndex + 1}로 진행',
      tag: 'LessonProgress',
    );
  }

  /// 진행 상태 초기화 (테스트용)
  Future<void> resetProgress() async {
    state = {};
    await _storage.remove(_storageKey);
    Logger.warning('레슨 진행 상태 초기화', tag: 'LessonProgress');
  }

  /// 특정 학년의 진행 상태 초기화
  Future<void> resetGradeProgress(String grade) async {
    final newState = Map<String, int>.from(state);
    newState[grade] = 0;
    state = newState;
    await _saveProgress();
    Logger.info('$grade 진행 상태 초기화', tag: 'LessonProgress');
  }
}

/// 레슨 진행 상태 프로바이더
final lessonProgressProvider =
    StateNotifierProvider<LessonProgressNotifier, Map<String, int>>((ref) {
  return LessonProgressNotifier();
});

/// 특정 학년의 현재 레슨 인덱스 프로바이더
final currentLessonIndexProvider = Provider.family<int, String>((ref, grade) {
  final progress = ref.watch(lessonProgressProvider);
  return progress[grade] ?? 0;
});
