# Provider 최적화 가이드

## 📊 현재 상황

### 중복 코드 통계
- **Logger 호출**: 326회 (27개 파일)
- **try-catch 블록**: 225회 (30개 파일)
- **save 패턴**: 130회 (25개 파일)

### 최적화 대상 파일 (줄 수 기준)
1. `auth_provider.dart` - 823줄
2. `achievement_provider.dart` - 606줄
3. `all_users_provider.dart` - 558줄
4. `user_provider.dart` - 549줄
5. `problem_provider.dart` - 513줄

## 🎯 최적화 전략

### 1. BaseNotifier 사용

**Before (hint_provider.dart - 181줄):**
```dart
class HintProvider extends StateNotifier<HintState> {
  final LocalStorageService _storage = LocalStorageService();

  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        state = state.copyWith(totalHintsUsed: data['totalHintsUsed']);
        Logger.info('Hint state loaded: ${state.totalHintsUsed} hints used');
      }
    } catch (e) {
      Logger.error('Failed to load hint state', error: e);
    }
  }

  Future<void> _saveState() async {
    try {
      await _storage.saveMap(_storageKey, {'totalHintsUsed': state.totalHintsUsed});
      Logger.info('Hint state saved');
    } catch (e) {
      Logger.error('Failed to save hint state', error: e);
    }
  }
}
```

**After (hint_provider_optimized.dart - 158줄, 12.7% 감소):**
```dart
class HintProviderOptimized extends BaseNotifier<HintState> {
  HintProviderOptimized(this._ref) : super(const HintState(), 'HintProvider') {
    _loadState();
  }

  Future<void> _loadState() async {
    final data = await loadFromStorage(_storageKey);
    if (data != null) {
      state = HintState.fromJson(data);
      logInfo('힌트 상태 로드 완료: ${state.totalHintsUsed}회 사용');
    }
  }

  Future<void> _saveState() async {
    await updateAndSave(state, saveKey: _storageKey, toJson: (s) => s.toJson());
  }
}
```

### 2. executeWithErrorHandling 사용

**Before:**
```dart
Future<bool> unlockHint(Problem problem, int hintIndex) async {
  try {
    // 비즈니스 로직
    if (hintIndex >= problem.hints.length) {
      Logger.warning('Invalid hint index: $hintIndex');
      return false;
    }

    // ... 나머지 로직

    Logger.info('Unlocked hint: $hintKey');
    return true;
  } catch (e, stackTrace) {
    Logger.error('Failed to unlock hint', error: e, stackTrace: stackTrace);
    return false;
  }
}
```

**After:**
```dart
Future<bool> unlockHint(Problem problem, int hintIndex) async {
  return await executeWithErrorHandling(
    () async {
      // 비즈니스 로직만 집중
      if (hintIndex >= problem.hints.length) {
        logWarning('잘못된 힌트 인덱스: $hintIndex');
        return false;
      }

      // ... 나머지 로직

      logInfo('힌트 해제: $hintKey');
      return true;
    },
    errorMessage: '힌트 해제 실패',
    fallback: () => false,
  ) ?? false;
}
```

## 📋 단계별 마이그레이션 가이드

### Step 1: State 모델에 toJson/fromJson 추가

```dart
class MyState {
  // 기존 필드들...

  // 추가
  Map<String, dynamic> toJson() => {
    'field1': field1,
    'field2': field2,
  };

  factory MyState.fromJson(Map<String, dynamic> json) {
    return MyState(
      field1: json['field1'],
      field2: json['field2'],
    );
  }
}
```

### Step 2: StateNotifier를 BaseNotifier로 변경

```dart
// Before
class MyProvider extends StateNotifier<MyState> {
  MyProvider() : super(MyState.initial());

  final LocalStorageService _storage = LocalStorageService();
}

// After
class MyProvider extends BaseNotifier<MyState> {
  MyProvider() : super(MyState.initial(), 'MyProvider');

  // storage는 BaseNotifier에 포함되어 있음
}
```

### Step 3: 로깅 메서드 교체

```dart
// Before
Logger.info('메시지', tag: 'MyProvider');
Logger.error('에러', error: e, tag: 'MyProvider');

// After
logInfo('메시지');
logError('에러', error: e);
```

### Step 4: try-catch 블록을 executeWithErrorHandling로 교체

```dart
// Before
try {
  final result = await someOperation();
  Logger.info('완료');
  return result;
} catch (e, stackTrace) {
  Logger.error('실패', error: e, stackTrace: stackTrace);
  return null;
}

// After
return await executeWithErrorHandling(
  () async {
    final result = await someOperation();
    logInfo('완료');
    return result;
  },
  errorMessage: '실패',
  fallback: () => null,
);
```

### Step 5: 저장 로직 간소화

```dart
// Before
Future<void> _saveData() async {
  try {
    await _storage.saveJson(key, state.toJson());
    Logger.info('저장 완료');
  } catch (e) {
    Logger.error('저장 실패', error: e);
  }
}

Future<void> updateSomething(String value) async {
  state = state.copyWith(field: value);
  await _saveData();
}

// After
Future<void> updateSomething(String value) async {
  await updateAndSave(
    state.copyWith(field: value),
    saveKey: 'storage_key',
    toJson: (s) => s.toJson(),
  );
}
```

## 🎁 추가 믹스인 활용

### ValidationMixin 사용

```dart
class MyProvider extends BaseNotifier<MyState> with ValidationMixin {
  Future<void> setAge(int? age) async {
    // null 체크 자동화
    final validAge = requireNonNull(age, '나이');

    // 범위 체크 자동화
    final safeAge = requireInRange(validAge, 0, 150, '나이');

    state = state.copyWith(age: safeAge);
  }
}
```

### CachingMixin 사용

```dart
class MyProvider extends BaseNotifier<MyState> with CachingMixin {
  Future<List<Item>> getItems() async {
    // 캐시 확인
    final cached = getCachedData<List<Item>>('items');
    if (cached != null) return cached;

    // API 호출
    final items = await apiCall();

    // 캐시에 저장 (5분 TTL)
    cacheData('items', items, ttl: Duration(minutes: 5));

    return items;
  }
}
```

### BatchOperationMixin 사용

```dart
class MyProvider extends BaseNotifier<MyState> with BatchOperationMixin {
  Future<void> processMultipleItems(List<Item> items) async {
    final result = await executeBatch(
      items,
      (item) async => await processItem(item),
      onProgress: (current, total) {
        logInfo('진행률: $current/$total');
      },
    );

    logInfo('완료: ${result.successCount}개 성공, ${result.failureCount}개 실패');
  }
}
```

## 📈 예상 개선 효과

### hint_provider 예제
- **Before**: 181줄
- **After**: 158줄
- **감소율**: 12.7%
- **코드 품질**: ⭐⭐⭐⭐⭐
  - 중복 제거
  - 에러 처리 일관성
  - 가독성 향상

### 전체 프로젝트 예상
- **현재 Provider 총 줄 수**: ~10,317줄
- **예상 감소**: ~15-20% (1,500-2,000줄 감소)
- **에러 처리 통일**: 225개 try-catch → 자동 처리
- **로깅 통일**: 326개 Logger 호출 → 통합 메서드

## 🚀 우선순위

1. **단순한 provider부터 시작** (hint_provider, settings_provider)
2. **중간 크기 provider** (daily_reward, lesson_provider)
3. **큰 provider** (auth, user, achievement)

## ⚠️ 주의사항

1. **Repository 패턴 사용 중인 provider**는 별도 처리 필요
   - user_provider.dart
   - problem_provider.dart

2. **외부 의존성이 많은 provider**는 신중하게 마이그레이션
   - auth_provider.dart (소셜 로그인)
   - premium_providers.dart (IAP)

3. **테스트 필수**
   - 각 provider 마이그레이션 후 기능 테스트
   - flutter analyze 통과 확인
   - 실제 앱 동작 확인

## 📚 참고 자료

- [BaseNotifier 소스](/lib/data/providers/base/base_notifier.dart)
- [Provider Mixins 소스](/lib/data/providers/base/provider_mixins.dart)
- [최적화 예제](/lib/data/providers/hint_provider_optimized.dart)
