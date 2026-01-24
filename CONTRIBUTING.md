# MathLab 기여 가이드

MathLab 프로젝트에 기여해주셔서 감사합니다! 🎉

## 개발 환경 설정

### 필수 요구사항
- Flutter SDK 3.24.0 이상
- Dart SDK 3.5.0 이상
- Android Studio 또는 VS Code
- Xcode (iOS 개발 시)

### 초기 설정

```bash
# 저장소 클론
git clone https://github.com/your-org/mathlab.git
cd mathlab

# 의존성 설치
flutter pub get

# Firebase 설정 (선택사항)
# 1. Firebase 프로젝트 생성
# 2. google-services.json (Android) 및 GoogleService-Info.plist (iOS) 다운로드
# 3. 각각 android/app 및 ios/Runner 폴더에 배치

# 환경 변수 설정
cp .env.example .env
# .env 파일을 열어 필요한 API 키 입력

# 앱 실행
flutter run
```

## 코드 스타일

### Dart 코드 스타일
- [Effective Dart](https://dart.dev/guides/language/effective-dart) 가이드 준수
- `flutter analyze` 명령으로 코드 분석 (경고 없어야 함)
- `dart format .` 명령으로 코드 포맷팅

### 명명 규칙
- **클래스**: PascalCase (예: `UserProfile`, `MathProblem`)
- **변수/함수**: camelCase (예: `calculateScore`, `userLevel`)
- **상수**: SCREAMING_SNAKE_CASE (예: `MAX_HEARTS`, `DEFAULT_XP`)
- **파일명**: snake_case (예: `user_profile_screen.dart`)

### 폴더 구조
```
lib/
├── app/              # 앱 설정 및 라우팅
├── data/             # 데이터 레이어
│   ├── models/       # 데이터 모델
│   ├── providers/    # Riverpod 프로바이더
│   ├── repositories/ # 데이터 저장소
│   └── services/     # 비즈니스 로직 서비스
├── features/         # 기능별 UI
│   └── [feature]/    # 각 기능 폴더
│       ├── [feature]_screen.dart
│       └── widgets/  # 기능별 위젯
└── shared/           # 공통 코드
    ├── constants/    # 상수
    ├── themes/       # 테마
    ├── utils/        # 유틸리티
    └── widgets/      # 공통 위젯
```

## 커밋 메시지 규칙

### 커밋 메시지 형식
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 타입
- **feat**: 새로운 기능 추가
- **fix**: 버그 수정
- **docs**: 문서 수정
- **style**: 코드 포맷팅, 세미콜론 누락 등
- **refactor**: 코드 리팩토링
- **test**: 테스트 코드 추가/수정
- **chore**: 빌드 프로세스, 보조 도구 변경

### 예시
```
feat(problem): 수학 문제 힌트 시스템 구현

- 단계별 힌트 제공 기능 추가
- 힌트 사용 시 XP 감소 로직 구현
- 힌트 UI 컴포넌트 디자인

Closes #42
```

## Pull Request 프로세스

### PR 생성 전 체크리스트
- [ ] `flutter analyze` 통과
- [ ] `flutter test` 통과 (모든 테스트)
- [ ] 코드 포맷팅 완료 (`dart format .`)
- [ ] 새로운 기능에 대한 테스트 작성
- [ ] CHANGELOG.md 업데이트 (주요 변경사항)
- [ ] 스크린샷 추가 (UI 변경 시)

### PR 템플릿
```markdown
## 변경 사항
- 주요 변경사항 설명

## 테스트 방법
1. 단계별 테스트 방법 설명
2. 예상 결과

## 스크린샷 (UI 변경 시)
[스크린샷 첨부]

## 관련 이슈
Closes #[이슈번호]
```

## 테스트 작성 가이드

### 단위 테스트
```dart
// test/data/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/data/models/user.dart';

void main() {
  group('User Model', () {
    test('should create user from JSON', () {
      final json = {
        'id': '123',
        'username': 'test_user',
        'level': 5,
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.username, 'test_user');
      expect(user.level, 5);
    });
  });
}
```

### 위젯 테스트
```dart
// test/features/home/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathlab/features/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays user streak', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('연속 학습'), findsOneWidget);
  });
}
```

## 이슈 보고

### 버그 리포트
버그를 발견하셨나요? GitHub Issues에 다음 정보와 함께 보고해주세요:

- **환경**: Flutter 버전, OS, 기기 정보
- **재현 단계**: 버그 재현 방법
- **예상 동작**: 정상적으로 작동해야 하는 방식
- **실제 동작**: 실제로 발생한 동작
- **스크린샷**: 가능하면 첨부
- **로그**: 에러 메시지나 로그

### 기능 제안
새로운 기능을 제안하고 싶으신가요?

1. 먼저 기존 이슈를 검색하여 중복 제안이 없는지 확인
2. GitHub Issues에 `enhancement` 라벨과 함께 제안
3. 다음 정보 포함:
   - 제안 배경 및 이유
   - 예상 동작 및 사용 사례
   - 가능한 구현 방법 (선택사항)

## 코드 리뷰 기준

리뷰어는 다음 사항을 확인합니다:

- [ ] 코드가 프로젝트 스타일 가이드를 따르는가?
- [ ] 모든 테스트가 통과하는가?
- [ ] 새로운 기능에 대한 테스트가 작성되었는가?
- [ ] 코드에 명확한 주석이 있는가?
- [ ] 문서가 업데이트되었는가?
- [ ] 성능 문제가 없는가?
- [ ] 보안 취약점이 없는가?

## 라이센스

이 프로젝트에 기여하는 모든 코드는 프로젝트의 라이센스 조건에 따라 배포됩니다.

## 질문이 있으신가요?

- GitHub Discussions에 질문 남기기
- 이슈에 `question` 라벨과 함께 문의
- 프로젝트 메인테이너에게 이메일 문의

---

**감사합니다!** 여러분의 기여가 MathLab을 더 나은 학습 도구로 만듭니다! 🚀
