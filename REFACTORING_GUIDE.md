# MathLab 프로젝트 대규모 리팩토링 가이드

## 개요

이 문서는 MathLab Flutter 프로젝트의 전체적인 리팩토링 전략과 구현 가이드를 제공합니다.

## 리팩토링 목표

### 1. 코드 품질 개선
- 일관된 패턴 적용
- 중복 코드 제거
- Type-safe 구현
- 테스트 가능한 구조

### 2. 성능 최적화
- 불필요한 리빌드 방지
- 메모리 효율성 개선
- 캐싱 전략 구현

### 3. 유지보수성 향상
- 명확한 책임 분리
- 의존성 주입
- 에러 처리 통합

## 핵심 개선사항

### ✅ 1. BaseRepository 생성 완료

**위치:** `lib/data/repositories/base/base_repository.dart`

**기능:**
- 표준화된 CRUD 작업
- 자동 캐싱 시스템
- 에러 처리 및 로깅
- 페이지네이션 지원
- 일괄 작업 (Batch operations)
- 실시간 스트림

**사용 예시:**
```dart
class UserRepository extends BaseRepository<User> {
  UserRepository() : super(
    collectionPath: 'users',
    fromFirestore: User.fromFirestore,
    repositoryName: 'UserRepository',
  );

  // 커스텀 메서드 추가 가능
  Future<RepositoryResult<List<User>>> getUsersByGrade(String grade) async {
    return query((ref) => ref.where('currentGrade', isEqualTo: grade));
  }
}
```

### 🔄 2. 모델 클래스 리팩토링 패턴

**개선 포인트:**
- `BaseDataModel` 상속
- `EquatableMixin` 적용으로 안전한 동등성 비교
- `SafeParser` extension 활용
- 불변 객체 패턴 (immutable)

**Before:**
```dart
class User {
  final String id;
  final String name;
  // ...

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,  // 위험: null이나 타입 오류 가능
      name: json['name'] as String,
      // ...
    );
  }

  @override
  bool operator ==(Object other) {  // 수동 구현 필요
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
}
```

**After:**
```dart
class User extends BaseDataModel with EquatableMixin, TimestampMixin {
  final String name;
  // ...

  const User({
    required super.id,
    required this.name,
    // ...
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json.getValue('id', ''),  // 안전한 파싱
      name: json.getValue('name', ''),
      // ...
    );
  }

  @override
  List<Object?> get props => [id, name, /* ... */];  // Equatable 자동 처리
}
```

### 🔄 3. Provider 패턴 개선

**개선 포인트:**
- `BaseNotifier` 확장
- 일관된 에러 처리
- 자동 로깅
- 스토리지 헬퍼 메서드

**Before:**
```dart
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  Future<void> loadUser(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();
      state = User.fromFirestore(doc);
    } catch (e) {
      print('Error: $e');  // 일관성 없는 에러 처리
    }
  }
}
```

**After:**
```dart
class UserNotifier extends BaseNotifier<User?> {
  UserNotifier() : super(null, 'UserNotifier');

  final UserRepository _repository = UserRepository();

  Future<void> loadUser(String id) async {
    await executeWithErrorHandling(
      () async {
        final result = await _repository.getById(id);
        if (result.isSuccess && result.data != null) {
          state = result.data;
          logInfo('User loaded: ${result.data!.name}');
        }
      },
      errorMessage: 'Failed to load user',
    );
  }
}
```

### 🔄 4. Repository 구현 패턴

모든 Repository는 `BaseRepository`를 확장해야 합니다:

```dart
class LessonRepository extends BaseRepository<Lesson> {
  LessonRepository() : super(
    collectionPath: 'lessons',
    fromFirestore: Lesson.fromFirestore,
    repositoryName: 'LessonRepository',
    enableCache: true,
    cacheDuration: Duration(minutes: 10),
  );

  // 커스텀 쿼리 메서드
  Future<RepositoryResult<List<Lesson>>> getLessonsByGrade(String grade) async {
    return query((ref) => ref
        .where('grade', isEqualTo: grade)
        .orderBy('order'));
  }

  // 스트림 메서드
  Stream<List<Lesson>> watchLessonsByGrade(String grade) {
    return watchAll(
      queryBuilder: (query) => query
          .where('grade', isEqualTo: grade)
          .orderBy('order'),
    );
  }
}
```

### 🔄 5. 서비스 인터페이스 패턴

**위치:** `lib/data/services/base/`

```dart
/// 인증 서비스 인터페이스
abstract class IAuthService {
  Future<User?> getCurrentUser();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Stream<User?> get userStream;
}

/// 구현
class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<User?> getCurrentUser() async {
    // 구현...
  }

  // ...
}
```

### 🔄 6. UI 컴포넌트 최적화

**개선 포인트:**
- const 생성자 활용
- Keys 사용으로 위젯 식별
- 재사용 가능한 컴포넌트 추출
- 반응형 레이아웃

**Before:**
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

**After:**
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;

  const CustomButton({
    Key? key,  // Key 추가
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
```

### 🔄 7. 에러 처리 통합

**위치:** `lib/shared/utils/error_handler.dart` (기존 파일 개선)

```dart
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    }
    if (error is AppException) {
      return error.message;
    }
    return '알 수 없는 오류가 발생했습니다';
  }

  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return '권한이 없습니다';
      case 'not-found':
        return '데이터를 찾을 수 없습니다';
      case 'already-exists':
        return '이미 존재하는 데이터입니다';
      default:
        return '서버 오류가 발생했습니다';
    }
  }
}
```

### 🔄 8. Riverpod Provider 최적화

**개선 포인트:**
- 불필요한 리빌드 방지
- Provider 분리
- Family/AutoDispose 활용

**Before:**
```dart
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
```

**After:**
```dart
// 리빌드 방지를 위한 세분화
final userIdProvider = StateProvider<String?>((ref) => null);

final userProvider = StateNotifierProvider.autoDispose<UserNotifier, User?>((ref) {
  final userId = ref.watch(userIdProvider);
  final notifier = UserNotifier();

  if (userId != null) {
    notifier.loadUser(userId);
  }

  return notifier;
});

// Family 활용
final lessonProvider = FutureProvider.family<Lesson, String>((ref, lessonId) async {
  final repository = ref.read(lessonRepositoryProvider);
  final result = await repository.getById(lessonId);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.error ?? 'Lesson not found');
});
```

## 리팩토링 체크리스트

### Phase 1: Core Infrastructure (완료)
- [x] BaseRepository 생성
- [x] BaseModel, BaseNotifier 검토 및 개선
- [x] SafeParser extension 활용 가이드

### Phase 2: Models (진행 중)
- [ ] User 모델 리팩토링
- [ ] Lesson 모델 리팩토링
- [ ] Problem 모델 리팩토링
- [ ] Achievement 모델 리팩토링
- [ ] 나머지 모델들 (39개) 리팩토링

### Phase 3: Repositories (대기)
- [ ] UserRepository 리팩토링
- [ ] LessonRepository 리팩토링
- [ ] ProblemRepository 리팩토링
- [ ] 나머지 Repository들 리팩토링

### Phase 4: Providers (대기)
- [ ] AuthProvider 리팩토링
- [ ] UserProvider 리팩토링
- [ ] LessonProvider 리팩토링
- [ ] 나머지 Provider들 (38개) 리팩토링

### Phase 5: Services (대기)
- [ ] Service 인터페이스 정의
- [ ] AuthService 리팩토링
- [ ] SyncManager 리팩토링
- [ ] 나머지 Service들 리팩토링

### Phase 6: UI Components (대기)
- [ ] 공통 위젯 추출 및 최적화
- [ ] const 생성자 적용
- [ ] Keys 추가
- [ ] 반응형 레이아웃 개선

### Phase 7: Testing & Documentation (대기)
- [ ] 단위 테스트 추가
- [ ] 통합 테스트 추가
- [ ] API 문서화
- [ ] 코드 주석 개선

## 우선순위 가이드

### 높음 (즉시 적용)
1. ✅ BaseRepository 패턴
2. 핵심 모델 리팩토링 (User, Lesson, Problem)
3. 주요 Repository 리팩토링
4. 주요 Provider 리팩토링

### 중간 (점진적 적용)
1. 나머지 모델들 리팩토링
2. UI 컴포넌트 최적화
3. Service 인터페이스 구현
4. 에러 처리 통합

### 낮음 (장기 계획)
1. 테스트 커버리지 향상
2. 성능 최적화
3. 문서화 개선
4. 코드 스타일 통일

## 마이그레이션 전략

### 점진적 마이그레이션
1. 새로운 패턴으로 구현된 파일 생성
2. 기존 파일과 병행 사용
3. 테스트 후 기존 파일 교체
4. 참조 업데이트

### 하위 호환성 유지
- 기존 API 유지
- Deprecated 마크 추가
- 마이그레이션 가이드 제공

## 코딩 컨벤션

### 네이밍
- **Models:** PascalCase (User, Lesson)
- **Providers:** camelCase + Provider (userProvider)
- **Repositories:** PascalCase + Repository (UserRepository)
- **Services:** PascalCase + Service (AuthService)
- **상수:** UPPER_SNAKE_CASE

### 파일 구조
```
lib/
├── data/
│   ├── models/
│   │   ├── base/
│   │   │   └── base_model.dart
│   │   ├── user/
│   │   │   ├── user.dart
│   │   │   └── user_account.dart
│   │   └── models.dart
│   ├── repositories/
│   │   ├── base/
│   │   │   └── base_repository.dart
│   │   ├── user_repository.dart
│   │   └── repositories.dart
│   ├── providers/
│   │   ├── base/
│   │   │   └── base_notifier.dart
│   │   └── ...
│   └── services/
│       ├── base/
│       │   └── base_service.dart
│       └── ...
```

### 주석 스타일
```dart
/// 클래스/함수 설명 (문서화 주석)
///
/// **기능:**
/// - 항목 1
/// - 항목 2
///
/// **사용 예:**
/// ```dart
/// final user = User(id: '123', name: 'John');
/// ```
class User extends BaseDataModel {
  // 구현...
}
```

## 성능 최적화 가이드

### 1. const 생성자 사용
```dart
const Text('Hello');  // ✅ 재생성 없음
Text('Hello');        // ❌ 매번 재생성
```

### 2. Provider 최적화
```dart
// ❌ 나쁜 예: 전체 리빌드
final user = ref.watch(userProvider);
final userName = user.name;

// ✅ 좋은 예: 필요한 부분만 watch
final userName = ref.watch(userProvider.select((user) => user?.name));
```

### 3. ListView.builder 사용
```dart
// ❌ 나쁜 예: 모든 아이템 생성
ListView(children: items.map((item) => ItemWidget(item)).toList())

// ✅ 좋은 예: 필요한 아이템만 생성
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

## 테스트 가이드

### 단위 테스트
```dart
test('User.fromJson should parse correctly', () {
  final json = {
    'id': '123',
    'name': 'John',
    'email': 'john@example.com',
  };

  final user = User.fromJson(json);

  expect(user.id, '123');
  expect(user.name, 'John');
  expect(user.email, 'john@example.com');
});
```

### Widget 테스트
```dart
testWidgets('CustomButton should display text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        text: 'Click me',
        onPressed: () {},
      ),
    ),
  );

  expect(find.text('Click me'), findsOneWidget);
});
```

## 참고 자료

- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## 문의 및 기여

리팩토링 관련 질문이나 제안사항은 팀 채널을 통해 공유해주세요.
