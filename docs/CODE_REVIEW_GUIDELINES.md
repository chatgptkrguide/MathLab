# 코드 리뷰 가이드라인

## 목차
1. [개요](#개요)
2. [프로젝트 구조](#프로젝트-구조)
3. [코딩 규칙](#코딩-규칙)
4. [파일 구조 규칙](#파일-구조-규칙)
5. [Flutter & Dart 베스트 프랙티스](#flutter--dart-베스트-프랙티스)
6. [Riverpod 패턴](#riverpod-패턴)
7. [UI/UX 가이드라인](#uiux-가이드라인)
8. [테스팅 요구사항](#테스팅-요구사항)
9. [성능 최적화](#성능-최적화)
10. [보안 체크리스트](#보안-체크리스트)
11. [일반적인 안티패턴](#일반적인-안티패턴)

---

## 개요

이 문서는 MathLab 프로젝트의 코드 품질을 유지하고 일관성을 보장하기 위한 가이드라인입니다.

### 핵심 원칙
- **가독성**: 코드는 작성하는 시간보다 읽는 시간이 더 많습니다
- **일관성**: 프로젝트 전체에서 동일한 패턴을 사용합니다
- **단순성**: 복잡한 해결책보다 단순한 해결책을 선호합니다
- **테스트 가능성**: 모든 코드는 테스트 가능해야 합니다

---

## 프로젝트 구조

### Feature-First 아키텍처

```
lib/
├── app/                    # 앱 설정 및 라우팅
├── features/              # 기능별 모듈
│   ├── auth/
│   ├── home/
│   ├── profile/
│   └── [feature]/
│       ├── [feature]_screen.dart
│       ├── widgets/
│       └── ...
├── data/                  # 데이터 레이어
│   ├── models/           # 데이터 모델 (카테고리별)
│   │   ├── user/
│   │   ├── learning/
│   │   ├── gamification/
│   │   └── ...
│   ├── providers/        # 상태 관리 (카테고리별)
│   │   ├── auth/
│   │   ├── user/
│   │   ├── learning/
│   │   └── ...
│   ├── repositories/     # 데이터 저장소
│   └── services/         # 외부 서비스
└── shared/               # 공통 코드
    ├── constants/
    ├── utils/
    └── widgets/
```

### 폴더 구성 규칙

#### ✅ 좋은 예
```dart
// features/profile/widgets/user_profile_card.dart
// features/profile/widgets/premium_badge.dart
// features/profile/widgets/streak_card.dart
```

#### ❌ 나쁜 예
```dart
// features/profile/user_profile_card_widget.dart  (중복 표현)
// features/widgets/profile_card.dart              (feature 밖에 위치)
```

---

## 코딩 규칙

### 1. 파일 크기 제한

**목표**: 파일당 **500줄 이하**

#### ✅ 파일이 500줄 이상일 때 리팩토링 방법

**1) 위젯 추출**
```dart
// ❌ 나쁜 예 - 하나의 거대한 Screen 위젯
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 100줄의 헤더 코드
          Container(...),
          // 150줄의 프로필 카드 코드
          Container(...),
          // 100줄의 통계 카드 코드
          Container(...),
        ],
      ),
    );
  }
}

// ✅ 좋은 예 - 위젯 추출
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ProfileHeader(),       // widgets/profile_header.dart
          ProfileCard(),         // widgets/profile_card.dart
          ProfileStats(),        // widgets/profile_stats.dart
        ],
      ),
    );
  }
}
```

**2) 로직 분리**
```dart
// ❌ 나쁜 예 - 화면에 모든 비즈니스 로직
class ProblemScreen extends ConsumerStatefulWidget {
  Future<void> _submitAnswer() async {
    // 100줄의 복잡한 검증 및 처리 로직
  }
}

// ✅ 좋은 예 - Provider로 로직 분리
class ProblemScreen extends ConsumerStatefulWidget {
  Future<void> _submitAnswer() async {
    await ref.read(problemProvider.notifier).submitAnswer(_userAnswer);
  }
}

// providers/problem_provider.dart
class ProblemNotifier extends StateNotifier<ProblemState> {
  Future<void> submitAnswer(String answer) async {
    // 검증 및 처리 로직
  }
}
```

### 2. 네이밍 규칙

#### 파일명
- **Snake case**: `user_profile_card.dart`
- **의미 있는 이름**: `profile_card.dart` (✅) vs `card1.dart` (❌)

#### 클래스명
- **PascalCase**: `UserProfileCard`
- **명확한 목적**: `LoginButton` (✅) vs `Button1` (❌)

#### 변수 및 함수명
- **camelCase**: `userName`, `fetchUserData()`
- **의도가 드러나는 이름**:
  ```dart
  // ✅ 좋은 예
  final int maxAttempts = 3;
  bool isUserLoggedIn = false;

  // ❌ 나쁜 예
  final int max = 3;
  bool flag = false;
  ```

#### Private 멤버
```dart
class UserService {
  String _userId;           // Private 변수
  void _validateUser() {}   // Private 메서드
}
```

### 3. 코드 주석

#### Documentation Comments (///)
```dart
/// 사용자 프로필 정보를 표시하는 카드 위젯
///
/// [user] 매개변수는 필수이며, null일 경우 게스트 상태를 표시합니다.
class UserProfileCard extends StatelessWidget {
  /// 표시할 사용자 정보
  final User? user;

  const UserProfileCard({
    super.key,
    required this.user,
  });
}
```

#### Implementation Comments (//)
```dart
Future<void> _submitAnswer() async {
  // 답안 제출 전 유효성 검사
  if (_userAnswer.trim().isEmpty) return;

  // 햅틱 피드백 제공
  await AppHapticFeedback.lightImpact();

  // Provider를 통해 답안 제출
  await ref.read(problemProvider.notifier).submitAnswer(_userAnswer);
}
```

#### 주석 작성 시 피해야 할 것
```dart
// ❌ 자명한 내용 주석
// 변수 i를 1씩 증가
i++;

// ❌ 불필요하게 긴 주석
// This function is used to calculate the total sum of all the numbers
// in the provided list by iterating through each element...
int calculateSum(List<int> numbers) => numbers.reduce((a, b) => a + b);

// ✅ 의미 있는 주석
// 망각 곡선 알고리즘: 1일, 3일, 7일, 14일 간격으로 복습 스케줄 생성
final reviewSchedule = [1, 3, 7, 14];
```

---

## 파일 구조 규칙

### 1. Import 순서

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:math';

// 2. Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 4. Project imports (절대 경로)
import '../../data/models/user/user.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../shared/constants/app_colors.dart';
```

### 2. 클래스 구조 순서

```dart
class MyWidget extends ConsumerStatefulWidget {
  // 1. Static 상수
  static const double padding = 16.0;

  // 2. Final 필드 (생성자 매개변수)
  final String title;
  final VoidCallback? onTap;

  // 3. 생성자
  const MyWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  // 4. 오버라이드 메서드
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  // 1. State 변수
  String _userInput = '';
  bool _isLoading = false;

  // 2. Lifecycle 메서드
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // 3. Build 메서드
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // 4. Private 헬퍼 메서드
  Future<void> _initialize() async {
    // ...
  }

  void _handleSubmit() {
    // ...
  }
}
```

### 3. Barrel File 사용

#### ✅ 각 widgets 폴더에 barrel file 생성

```dart
// features/profile/widgets/widgets.dart
export 'user_profile_card.dart';
export 'premium_badge.dart';
export 'streak_card.dart';
```

#### ✅ Import 시 간결하게 사용
```dart
// ✅ 좋은 예
import '../widgets/widgets.dart';

// ❌ 나쁜 예
import '../widgets/user_profile_card.dart';
import '../widgets/premium_badge.dart';
import '../widgets/streak_card.dart';
```

---

## Flutter & Dart 베스트 프랙티스

### 1. const 생성자 사용

```dart
// ✅ 좋은 예 - const 사용으로 성능 최적화
const Text('Hello');
const SizedBox(height: 16);
const EdgeInsets.all(16);

// ❌ 나쁜 예
Text('Hello');
SizedBox(height: 16);
```

### 2. Widget 분리

#### 위젯을 분리해야 하는 경우
- **재사용 가능한 UI 컴포넌트**
- **복잡한 UI (50줄 이상)**
- **독립적인 상태를 가진 UI**

```dart
// ❌ 나쁜 예 - build 메서드 내 로컬 위젯
@override
Widget build(BuildContext context) {
  Widget buildHeader() {
    return Container(
      // 50줄의 헤더 코드
    );
  }

  return Column(
    children: [buildHeader()],
  );
}

// ✅ 좋은 예 - 별도 위젯으로 분리
@override
Widget build(BuildContext context) {
  return Column(
    children: [ProfileHeader()],
  );
}

// widgets/profile_header.dart
class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // 헤더 코드
    );
  }
}
```

### 3. Null Safety

```dart
// ✅ 좋은 예 - Null safety 활용
String? optionalName;

// Null 체크
if (optionalName != null) {
  print(optionalName.length);
}

// Null-aware operator
final length = optionalName?.length ?? 0;

// Non-null assertion (확실한 경우에만)
final name = optionalName!;

// ❌ 나쁜 예 - 불필요한 null 체크
if (optionalName != null) {
  if (optionalName != null) {  // 중복
    print(optionalName.length);
  }
}
```

### 4. Async/Await 패턴

```dart
// ✅ 좋은 예
Future<void> fetchUserData() async {
  try {
    setState(() => _isLoading = true);

    final user = await _userRepository.getUser();

    setState(() {
      _user = user;
      _isLoading = false;
    });
  } catch (error) {
    setState(() => _isLoading = false);
    _showErrorMessage(error.toString());
  }
}

// ❌ 나쁜 예 - then() 체인
void fetchUserData() {
  setState(() => _isLoading = true);

  _userRepository.getUser().then((user) {
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }).catchError((error) {
    setState(() => _isLoading = false);
    _showErrorMessage(error.toString());
  });
}
```

### 5. BuildContext 사용

```dart
// ✅ 좋은 예 - async 후 context 유효성 검사
Future<void> _handleSubmit() async {
  await _submitData();

  if (!mounted) return;  // Widget이 dispose되었는지 확인

  Navigator.of(context).pop();
}

// ❌ 나쁜 예
Future<void> _handleSubmit() async {
  await _submitData();
  Navigator.of(context).pop();  // BuildContext 오류 발생 가능
}
```

---

## Riverpod 패턴

### 1. Provider 구조

#### StateNotifier 패턴
```dart
// models/counter_state.dart
@freezed
class CounterState with _$CounterState {
  const factory CounterState({
    @Default(0) int count,
    @Default(false) bool isLoading,
  }) = _CounterState;
}

// providers/counter_provider.dart
class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier() : super(const CounterState());

  void increment() {
    state = state.copyWith(count: state.count + 1);
  }

  Future<void> incrementAsync() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      count: state.count + 1,
      isLoading: false,
    );
  }
}

final counterProvider = StateNotifierProvider<CounterNotifier, CounterState>((ref) {
  return CounterNotifier();
});
```

### 2. Provider 사용

#### ConsumerWidget 사용
```dart
class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterProvider);

    return Column(
      children: [
        Text('Count: ${state.count}'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

#### ConsumerStatefulWidget 사용
```dart
class CounterScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> {
  @override
  void initState() {
    super.initState();
    // Provider 초기화 로직
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(counterProvider);
    return Text('Count: ${state.count}');
  }
}
```

### 3. Provider 의존성

```dart
// ✅ 좋은 예 - Provider 의존성 명시
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final authState = ref.watch(authProvider);
  return UserNotifier(authState.userId);
});

// ❌ 나쁜 예 - 전역 변수 사용
String? globalUserId;

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(globalUserId);
});
```

---

## UI/UX 가이드라인

### 1. 반응형 디자인

```dart
// ✅ 좋은 예 - MediaQuery 사용
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;

  return Container(
    padding: EdgeInsets.all(isTablet ? 32 : 16),
    child: Text(
      'Hello',
      style: TextStyle(
        fontSize: isTablet ? 24 : 16,
      ),
    ),
  );
}

// ❌ 나쁜 예 - 고정된 크기
return Container(
  width: 300,  // 작은 화면에서 문제 발생
  padding: const EdgeInsets.all(16),
);
```

### 2. 테마 시스템 사용

```dart
// ✅ 좋은 예 - 테마 색상 사용
Container(
  color: Theme.of(context).primaryColor,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)

// 또는 AppColors 사용
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: AppTextStyles.headlineMedium,
  ),
)

// ❌ 나쁜 예 - 하드코딩된 색상
Container(
  color: const Color(0xFF2196F3),
  child: const Text(
    'Hello',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  ),
)
```

### 3. 접근성

```dart
// ✅ 좋은 예 - Semantic 정보 제공
Semantics(
  label: '프로필 사진',
  button: true,
  child: GestureDetector(
    onTap: _editProfile,
    child: CircleAvatar(
      backgroundImage: NetworkImage(user.photoUrl),
    ),
  ),
)

// ✅ 터치 영역 확보 (최소 48x48)
InkWell(
  onTap: _handleTap,
  child: Container(
    width: 48,
    height: 48,
    child: Icon(Icons.favorite),
  ),
)
```

### 4. 로딩 및 에러 상태

```dart
// ✅ 좋은 예 - 모든 상태 처리
@override
Widget build(BuildContext context, WidgetRef ref) {
  final asyncValue = ref.watch(userProvider);

  return asyncValue.when(
    data: (user) => UserProfile(user: user),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(error: error),
  );
}

// ❌ 나쁜 예 - 로딩/에러 상태 무시
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider).value;
  return UserProfile(user: user!);  // null 에러 발생 가능
}
```

---

## 테스팅 요구사항

### 1. Unit Tests

```dart
// test/providers/counter_provider_test.dart
void main() {
  group('CounterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('초기값은 0이어야 함', () {
      final state = container.read(counterProvider);
      expect(state.count, 0);
    });

    test('increment() 호출 시 카운트 증가', () {
      container.read(counterProvider.notifier).increment();
      final state = container.read(counterProvider);
      expect(state.count, 1);
    });
  });
}
```

### 2. Widget Tests

```dart
// test/widgets/counter_widget_test.dart
void main() {
  testWidgets('카운터 증가 버튼 동작 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CounterScreen(),
        ),
      ),
    );

    // 초기 상태 확인
    expect(find.text('Count: 0'), findsOneWidget);

    // 버튼 탭
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // 증가된 값 확인
    expect(find.text('Count: 1'), findsOneWidget);
  });
}
```

### 3. 테스트 커버리지

**목표**:
- **Unit Tests**: 80% 이상
- **Widget Tests**: 주요 화면 커버리지
- **Integration Tests**: 핵심 사용자 플로우

---

## 성능 최적화

### 1. 불필요한 Rebuild 방지

```dart
// ✅ 좋은 예 - Consumer로 필요한 부분만 rebuild
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileHeader(),  // rebuild 안 됨
        Consumer(builder: (context, ref, child) {
          final user = ref.watch(userProvider);
          return UserInfo(user: user);  // user 변경 시에만 rebuild
        }),
      ],
    );
  }
}

// ❌ 나쁜 예 - 전체 화면 rebuild
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Column(
      children: [
        const ProfileHeader(),  // user 변경 시 불필요하게 rebuild
        UserInfo(user: user),
      ],
    );
  }
}
```

### 2. 이미지 최적화

```dart
// ✅ 좋은 예 - 캐싱 및 크기 지정
CachedNetworkImage(
  imageUrl: user.photoUrl,
  width: 100,
  height: 100,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)

// ❌ 나쁜 예 - 크기 미지정
Image.network(user.photoUrl)  // 원본 크기로 로드
```

### 3. 리스트 최적화

```dart
// ✅ 좋은 예 - ListView.builder 사용
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// ❌ 나쁜 예 - ListView(children: ...) 사용
ListView(
  children: items.map((item) => ListTile(title: Text(item))).toList(),
)
```

---

## 보안 체크리스트

### 1. 민감 정보 보호

```dart
// ✅ 좋은 예 - 환경 변수 사용
final apiKey = const String.fromEnvironment('API_KEY');

// ❌ 나쁜 예 - 하드코딩
final apiKey = 'sk_live_abc123...';  // 절대 금지!
```

### 2. 입력 검증

```dart
// ✅ 좋은 예 - 입력 검증
Future<void> _submitEmail(String email) async {
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    throw Exception('Invalid email format');
  }
  await _authService.sendPasswordReset(email);
}

// ❌ 나쁜 예 - 검증 없이 사용
Future<void> _submitEmail(String email) async {
  await _authService.sendPasswordReset(email);
}
```

### 3. 에러 메시지

```dart
// ✅ 좋은 예 - 일반적인 에러 메시지
catch (error) {
  _showError('로그인에 실패했습니다. 다시 시도해주세요.');
}

// ❌ 나쁜 예 - 상세한 에러 노출
catch (error) {
  _showError('Database connection failed at 192.168.1.100:5432');
}
```

---

## 일반적인 안티패턴

### 1. God Object

```dart
// ❌ 나쁜 예 - 하나의 클래스가 모든 것을 처리
class UserManager {
  void login() {}
  void logout() {}
  void updateProfile() {}
  void uploadPhoto() {}
  void sendMessage() {}
  void processPayment() {}
  void generateReport() {}
}

// ✅ 좋은 예 - 책임 분리
class AuthService {
  void login() {}
  void logout() {}
}

class UserService {
  void updateProfile() {}
  void uploadPhoto() {}
}

class MessageService {
  void sendMessage() {}
}
```

### 2. Magic Numbers

```dart
// ❌ 나쁜 예
if (user.level >= 10) {
  showBadge();
}

// ✅ 좋은 예
static const int minimumLevelForBadge = 10;

if (user.level >= minimumLevelForBadge) {
  showBadge();
}
```

### 3. Deep Nesting

```dart
// ❌ 나쁜 예 - 깊은 중첩
void processData(Data? data) {
  if (data != null) {
    if (data.isValid) {
      if (data.hasPermission) {
        if (data.isNotExpired) {
          // 처리 로직
        }
      }
    }
  }
}

// ✅ 좋은 예 - Early return
void processData(Data? data) {
  if (data == null) return;
  if (!data.isValid) return;
  if (!data.hasPermission) return;
  if (data.isNotExpired) return;

  // 처리 로직
}
```

### 4. Mutable Global State

```dart
// ❌ 나쁜 예 - 전역 가변 상태
String? currentUserId;

void login(String userId) {
  currentUserId = userId;
}

// ✅ 좋은 예 - Provider로 상태 관리
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
```

---

## 코드 리뷰 체크리스트

### Pull Request 전 자가 점검

- [ ] 모든 테스트가 통과하는가?
- [ ] lint 경고가 없는가?
- [ ] 새로운 기능에 대한 테스트가 작성되었는가?
- [ ] 주석과 문서가 업데이트되었는가?
- [ ] 하드코딩된 값이 없는가?
- [ ] 파일 크기가 500줄 이하인가?
- [ ] 코드가 프로젝트 컨벤션을 따르는가?
- [ ] 불필요한 코드나 주석이 제거되었는가?
- [ ] 성능에 영향을 주는 변경사항이 있는가?

### 리뷰어 체크리스트

- [ ] 코드가 요구사항을 충족하는가?
- [ ] 코드 로직이 명확하고 이해하기 쉬운가?
- [ ] 에러 처리가 적절한가?
- [ ] 보안 취약점이 없는가?
- [ ] 성능 이슈가 없는가?
- [ ] 테스트 커버리지가 충분한가?
- [ ] UI/UX가 디자인 가이드라인을 따르는가?
- [ ] 접근성이 고려되었는가?

---

## 참고 자료

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)

---

**마지막 업데이트**: 2024-12-28
**버전**: 1.0.0
