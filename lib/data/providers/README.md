# Riverpod Providers — 컨벤션 가이드

MathLab 의 상태관리는 Riverpod 을 쓰며, **두 가지 패턴이 의도적으로 혼재**한다.
새 provider 를 추가할 때 어느 쪽을 선택해야 하는지 명확히 한다.

## 두 패턴

### 1) `@Riverpod(keepAlive: true)` — 앱 수명 전체 유지

```dart
@Riverpod(keepAlive: true)
class User extends _$User {
  @override
  UserModel? build() => null;
  // ...
}
```

**언제 쓰나**:
- 앱 진입부터 종료까지 항상 살아 있어야 하는 도메인 상태.
- AutoDispose 가 되면 화면 전환마다 재로딩되어 깜빡임/추가 RTT 가 사용자에게 노출되는 경우.

**현재 적용 대상**:
- `auth/auth_provider.dart` — 인증 상태. 미로그인 ↔ 로그인 전환을 AuthWrapper 가 구독.
- `user/user_provider.dart` — 현재 사용자 프로필. 전 화면이 의존.

**주의**: `@riverpod` (소문자 r, keepAlive 미지정) 은 **AutoDispose 가 기본**이다.
auth/user 가 화면 이동 시 사라지면 UI 가 깜빡이거나 다시 로그인 화면으로
빠지는 버그가 생긴다. 이 두 provider 는 반드시 대문자 `@Riverpod(keepAlive: true)`.

### 2) 수동 `StateNotifierProvider` — 명시 호출 소유권

```dart
final friendProvider =
    StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  return FriendNotifier(ref);
});
```

**언제 쓰나**:
- 특정 화면/기능에 종속된 상태 — 그 영역을 떠나면 메모리에서 내려가도 무방.
- `family` 인자(예: `wrongAnswerProvider(userId)`) 가 필요한 경우.
- legacy 코드와 호환을 유지해야 하는 경우.

**현재 적용 대상**:
- `friend/`, `streak/`, `team/`, `gamification/`, `challenge/`, `lesson/`,
  `learning/`, `wrong_answer/`, `subscription/`, `communication/`,
  `infrastructure/` 등 대부분.

## 새 provider 를 추가할 때

다음 두 질문에 답해 어느 쪽을 쓸지 결정한다.

1. **이 상태가 앱 전체에서 항상 필요한가?** → YES 면 `@Riverpod(keepAlive: true)`.
2. **여러 화면에서 비동기 fetch 결과를 캐시 공유해야 하나?** → 그래도 keepAlive
   대신 `@Riverpod(keepAlive: true)` 사용 (annotation 방식 통일 위해).

NO/NO 면 수동 `StateNotifierProvider` 가 자연스럽다.

## 코드 생성 (annotation 방식 변경 시)

```bash
dart run build_runner build --delete-conflicting-outputs
```

`@Riverpod` annotation 을 추가/변경하면 위 명령을 반드시 실행해 `.g.dart`
파일을 갱신해야 한다. 미실행 시 컴파일 실패.

## 패턴 단일화 검토 이력

진단 리포트 (#21) 에서 두 패턴 혼재를 지적했다. 단일화 옵션:
- A) 전체 `@Riverpod` annotation 으로 통일 → 코드 일관성 ↑, build_runner 부담 ↑.
- B) 현재 혼재 유지 + 본 문서로 분류 기준 명시 (현재 채택).
- C) auth/user 만 annotation, 나머지는 모두 수동.

B 를 채택한 이유: 11 + 1 개 모듈 단위로 흩어진 provider 를 한꺼번에 변환하면
회귀 위험이 크고, 현재 동작 중인 코드의 ROI 가 낮다. 새 코드는 위 가이드를
따르고, 변환은 해당 모듈을 어차피 손볼 때 같이 수행한다.
