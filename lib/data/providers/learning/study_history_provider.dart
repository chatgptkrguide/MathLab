import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base/base_notifier.dart';

import '../auth/auth_provider.dart';

/// 학습 이력 상태 관리 (날짜별 학습 완료 기록)
class StudyHistoryNotifier extends BaseNotifier<Set<DateTime>> {
  final Ref ref;

  StudyHistoryNotifier(this.ref) : super({}, 'StudyHistoryNotifier') {
    _initialize();
  }

  /// 현재 계정 ID 기반 저장소 키
  String? get _storageKey {
    final currentAccount = ref.read(currentAccountProvider);
    if (currentAccount == null) {
      return null;
    }
    return 'study_history_${currentAccount.id}';
  }

  /// 초기화 및 데이터 로드
  Future<void> _initialize() async {
    await _loadHistory();
  }

  /// 학습 이력 로드
  Future<void> _loadHistory() async {
    try {
      final key = _storageKey;
      if (key == null) {
        // 로그인된 계정 없음 - 빈 상태로 초기화
        state = {};
        return;
      }

      final historyString = await storage.getString(key);
      if (historyString != null && historyString.isNotEmpty) {
        // 쉼표로 구분된 날짜 문자열 파싱 (예: "2025-01-15,2025-01-16,2025-01-17")
        final dateStrings = historyString.split(',');
        final dates = dateStrings
            .where((s) => s.isNotEmpty)
            .map((s) {
              try {
                return DateTime.parse(s);
              } catch (e) {
                return null;
              }
            })
            .whereType<DateTime>()
            .toSet();

        state = dates;
      } else {
        state = {};
      }
    } catch (e, stackTrace) {
      logError(
        '학습 이력 로드 실패',
        error: e,
        stackTrace: stackTrace,
      );
      state = {};
    }
  }

  /// 학습 이력 저장
  Future<void> _saveHistory() async {
    try {
      final key = _storageKey;
      if (key == null) {
        return;
      }

      // DateTime을 날짜만 문자열로 변환 (시간 제거)
      final dateStrings = state
          .map((date) => _dateOnlyString(date))
          .toList()
        ..sort(); // 정렬

      final historyString = dateStrings.join(',');
      await storage.setString(key, historyString);
    } catch (e, stackTrace) {
      logError(
        '학습 이력 저장 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 오늘 날짜를 학습 완료로 표시
  Future<void> markTodayAsCompleted() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 이미 오늘 기록이 있으면 중복 추가하지 않음
    if (!state.any((date) => _isSameDay(date, today))) {
      final newState = Set<DateTime>.from(state)..add(today);
      state = newState;
      await _saveHistory();
    }
  }

  /// 특정 날짜를 학습 완료로 표시 (테스트용)
  Future<void> markDateAsCompleted(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (!state.any((d) => _isSameDay(d, dateOnly))) {
      final newState = Set<DateTime>.from(state)..add(dateOnly);
      state = newState;
      await _saveHistory();
    }
  }

  /// 특정 날짜의 학습 완료 여부 확인
  bool isDateCompleted(DateTime date) {
    return state.any((completedDate) => _isSameDay(completedDate, date));
  }

  /// 현재 월의 완료한 날짜들 가져오기 (day 숫자 리스트)
  List<int> getCompletedDaysInMonth(int year, int month) {
    return state
        .where((date) => date.year == year && date.month == month)
        .map((date) => date.day)
        .toList()
      ..sort();
  }

  /// 학습 이력 초기화 (테스트용)
  Future<void> resetHistory() async {
    state = {};
    final key = _storageKey;
    if (key != null) {
      await storage.removeFromStorage(key);
    }
  }

  /// 같은 날짜인지 확인 (년-월-일만 비교)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 날짜를 문자열로 변환 (YYYY-MM-DD 형식)
  String _dateOnlyString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 총 학습 일수
  int get totalStudyDays => state.length;

  /// 이번 달 학습 일수
  int get thisMonthStudyDays {
    final now = DateTime.now();
    return state
        .where((date) => date.year == now.year && date.month == now.month)
        .length;
  }

  /// 오늘 학습 완료 여부
  bool get isTodayCompleted {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.any((date) => _isSameDay(date, today));
  }
}

/// 학습 이력 프로바이더
final studyHistoryProvider =
    StateNotifierProvider<StudyHistoryNotifier, Set<DateTime>>((ref) {
  return StudyHistoryNotifier(ref);
});

/// 오늘 학습 완료 여부 프로바이더
final isTodayCompletedProvider = Provider<bool>((ref) {
  final history = ref.watch(studyHistoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return history.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day);
});

/// 이번 달 학습 일수 프로바이더
final thisMonthStudyDaysProvider = Provider<int>((ref) {
  final history = ref.watch(studyHistoryProvider);
  final now = DateTime.now();
  return history
      .where((date) => date.year == now.year && date.month == now.month)
      .length;
});
