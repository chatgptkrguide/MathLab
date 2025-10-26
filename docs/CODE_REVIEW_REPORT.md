# 📊 MathLab 코드 리뷰 보고서

**리뷰 날짜**: 2025-01-22
**리뷰 범위**: 전체 Flutter 프로젝트
**총 파일 수**: 75개 Dart 파일

---

## 🎯 요약

전반적으로 잘 구조화된 Flutter 프로젝트이지만, 성능 최적화, 에러 처리, 코드 품질 개선이 필요한 부분이 발견되었습니다.

### 점수 평가
- **아키텍처**: 8/10 (Feature 기반 구조, Riverpod 사용)
- **코드 품질**: 6/10 (개선 필요)
- **성능**: 5/10 (최적화 필요)
- **보안**: 7/10 (양호, 일부 개선 필요)
- **유지보수성**: 7/10 (양호)

---

## 🚨 Critical Issues (즉시 수정 필요)

### 1. SharedPreferences 캐싱 부재
**위치**:
- `lib/data/providers/user_provider.dart`: 18-35, 59-65행
- `lib/data/providers/problem_provider.dart`: 102-111, 114-121행

**문제**:
```dart
// 현재 코드 - 매번 SharedPreferences.getInstance() 호출
final prefs = await SharedPreferences.getInstance();
final userJson = prefs.getString('user');
```

**영향**: 매번 SharedPreferences 인스턴스를 생성하여 성능 저하

**해결책**:
```dart
class UserNotifier extends StateNotifier<User?> {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _loadUser() async {
    try {
      final preferences = await prefs;
      final userJson = preferences.getString('user');
      // ...
    }
  }
}
```

---

### 2. 매직 넘버/문자열 하드코딩
**위치**: 전체 프로젝트

**발견된 항목**:
- `100` (XP per level) - user_provider.dart:75
- `5` (max hearts) - user_provider.dart:108, 215
- `"lesson001"` - home_screen.dart:424
- `0.7`, `0.9` (alpha values) - 여러 파일

**해결책**: Constants 파일에 정의
```dart
// lib/shared/constants/game_constants.dart (새 파일)
class GameConstants {
  // XP System
  static const int xpPerLevel = 100;
  static const int maxHearts = 5;
  static const int dailyGoalXP = 100;

  // Default values
  static const String defaultLessonId = 'lesson001';

  // UI Opacity values
  static const double highOpacity = 0.9;
  static const double mediumOpacity = 0.7;
  static const double lowOpacity = 0.5;
}
```

---

### 3. 에러 처리 개선 필요
**위치**:
- `lib/data/providers/user_provider.dart`: 31-34행
- `lib/data/providers/problem_provider.dart`: 26-31행

**현재 코드**:
```dart
try {
  // ...
} catch (e) {
  // 에러 시 샘플 사용자로 폴백
  state = _dataService.getSampleUser();
}
```

**문제**:
- 에러 로깅이 없음
- 사용자에게 에러 알림 없음
- 에러 타입 구분 없음

**해결책**:
```dart
try {
  // ...
} catch (e, stackTrace) {
  debugPrint('❌ User load failed: $e');
  debugPrint('Stack trace: $stackTrace');

  // 에러 로깅 서비스 호출 (향후)
  // await ErrorReportingService.report(e, stackTrace);

  // 사용자 알림 (향후)
  // _showErrorToUser('데이터 로드 실패');

  state = _dataService.getSampleUser();
}
```

---

## ⚠️ High Priority Issues

### 4. const 생성자 누락
**위치**: 여러 위젯 파일

**문제**: 성능 최적화를 위한 const 생성자 미사용

**발견 위치**:
- `lib/app/main_navigation.dart:22` - `_screens` 리스트
- 여러 커스텀 위젯들

**예시**:
```dart
// 현재
final List<Widget> _screens = [
  const HomeScreen(),
  const LessonsScreen(),
  // ...
];

// 개선
static const List<Widget> _screens = [
  HomeScreen(),
  LessonsScreen(),
  // ...
];
```

---

### 5. firstWhere 사용 시 orElse 누락
**위치**:
- `lib/data/providers/problem_provider.dart:64`
- `lib/features/problem/problem_screen.dart:551`

**현재 코드**:
```dart
Problem? getProblemById(String problemId) {
  try {
    return state.firstWhere((problem) => problem.id == problemId);
  } catch (e) {
    return null;
  }
}
```

**개선**:
```dart
Problem? getProblemById(String problemId) {
  try {
    return state.firstWhere(
      (problem) => problem.id == problemId,
      orElse: () => throw StateError('Problem not found: $problemId'),
    );
  } on StateError {
    debugPrint('⚠️ Problem not found: $problemId');
    return null;
  }
}
```

---

### 6. List.shuffle() 원본 변경
**위치**: `lib/data/providers/problem_provider.dart:57, 90`

**문제**: `shuffle()`이 원본 리스트를 변경함

**현재**:
```dart
filteredProblems.shuffle();
return filteredProblems.take(count).toList();
```

**개선**:
```dart
final shuffled = List<Problem>.from(filteredProblems)..shuffle();
return shuffled.take(count).toList();
```

---

### 7. 과도한 디버그 출력
**위치**: `lib/features/home/home_screen.dart:386-469`

**문제**: 프로덕션 빌드에서도 디버그 출력이 남을 수 있음

**개선**: 디버그 로깅 유틸리티 사용
```dart
// lib/shared/utils/logger.dart (새 파일)
class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}

// 사용
Logger.debug('🚀 학습하기 버튼 클릭됨');
```

---

## 📋 Medium Priority Issues

### 8. 긴 메서드 리팩토링
**위치**:
- `lib/features/home/home_screen.dart:385-470` (_startLearning 메서드)
- `lib/features/problem/problem_screen.dart:484-537` (_submitAnswer 메서드)

**권장**: 100줄 이상의 메서드는 작은 메서드로 분리

**개선 예시**:
```dart
void _startLearning(...) async {
  if (!_validatePreconditions()) return;

  final selectedProblems = _getSelectedProblems();
  if (selectedProblems.isEmpty) {
    _showNoProblemsError();
    return;
  }

  await _navigateToProblemScreen(selectedProblems);
}
```

---

### 9. 중복 코드 (DRY 위반)
**위치**: 여러 Provider 파일에서 SharedPreferences 저장/로드 로직 반복

**해결책**: 공통 Storage Service 생성
```dart
// lib/data/services/local_storage_service.dart
class LocalStorageService {
  static Future<T?> load<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    final jsonData = jsonDecode(jsonString);
    return fromJson(jsonData);
  }

  static Future<void> save<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(toJson(data));
    await prefs.setString(key, jsonString);
  }
}
```

---

### 10. 임시 구현 제거
**위치**: `lib/data/providers/user_provider.dart:186-189`

**현재**:
```dart
/// 오늘 획득한 XP (실제로는 서버에서 계산해야 함)
int _getTodayXP() {
  // 임시로 전체 XP의 일부로 계산
  return state?.xp.remainder(100) ?? 0;
}
```

**해결책**: LearningStats에서 실제 값 추적
```dart
// lib/data/models/learning_stats.dart에 추가
class LearningStats {
  final Map<String, int> dailyXP; // 날짜별 XP

  int getTodayXP() {
    final today = DateTime.now().toString().split(' ')[0];
    return dailyXP[today] ?? 0;
  }
}
```

---

## 💡 Low Priority Issues

### 11. 일관성 없는 주석
- 일부는 한글, 일부는 영어
- **권장**: 한글로 통일 (팀 내 한국인 개발자)

### 12. 접근성 개선
- Semantic labels 추가 필요
- Screen reader 지원 미흡

### 13. 테스트 코드 부재
- 단위 테스트 없음
- 위젯 테스트 없음
- **권장**: 최소 Provider 로직에 대한 테스트 추가

---

## 🎨 Best Practices 권장사항

### 1. Provider 명명 규칙 개선
```dart
// 현재
final userProvider = StateNotifierProvider<UserNotifier, User?>(...);

// 권장 (명시적)
final userStateProvider = StateNotifierProvider<UserNotifier, User?>(...);
final userNotifierProvider = Provider<UserNotifier>((ref) => ref.watch(userStateProvider.notifier));
```

### 2. 에러 상태 관리
```dart
// lib/data/models/app_state.dart (새 파일)
@freezed
class AppState<T> with _$AppState<T> {
  const factory AppState.initial() = Initial;
  const factory AppState.loading() = Loading;
  const factory AppState.data(T data) = Data<T>;
  const factory AppState.error(String message) = Error;
}
```

### 3. 환경 변수 분리
```dart
// lib/config/env.dart
class Env {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableLogging = !isProduction;
}
```

---

## 🔧 수정 우선순위

### 즉시 수정 (1-2일)
1. ✅ SharedPreferences 캐싱
2. ✅ 매직 넘버/문자열 상수화
3. ✅ 에러 처리 개선

### 단기 수정 (1주)
4. ✅ const 생성자 추가
5. ✅ List.shuffle() 원본 보호
6. ✅ 디버그 로깅 유틸리티

### 중기 개선 (2-4주)
7. ⏳ 긴 메서드 리팩토링
8. ⏳ Storage Service 추출
9. ⏳ 테스트 코드 작성

---

## 📈 성능 개선 제안

### 1. 위젯 리빌드 최적화
```dart
// Consumer 대신 select 사용
final userName = ref.watch(userProvider.select((user) => user?.name));
```

### 2. 이미지 캐싱
```dart
// cached_network_image 패키지 사용 권장
```

### 3. ListView.builder 사용
```dart
// Column에서 ListView.builder로 변경 (긴 리스트)
```

---

## ✅ 잘된 점

1. ✅ Feature 기반 폴더 구조
2. ✅ Riverpod을 통한 상태 관리
3. ✅ 일관된 디자인 시스템 (AppColors, AppTextStyles)
4. ✅ 반응형 레이아웃 고려 (ResponsiveWrapper)
5. ✅ 게이미피케이션 요소 잘 구현됨
6. ✅ IndexedStack 사용으로 화면 상태 유지

---

## 📝 다음 단계

1. 이 보고서를 바탕으로 이슈 트래킹 (GitHub Issues, Jira 등)
2. Critical/High Priority 이슈부터 수정 시작
3. PR(Pull Request) 생성 및 코드 리뷰
4. 테스트 코드 작성 계획 수립
5. CI/CD 파이프라인 설정 (자동 린트, 테스트)

---

**리뷰어**: Claude Code
**다음 리뷰 예정**: 2주 후
