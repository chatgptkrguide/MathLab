# MathLab - 게이미피케이션 수학 학습 앱 (Flutter)

## 개요
듀오링고 스타일의 게이미피케이션 수학 학습 모바일 앱. XP, 스트릭, 리그, 업적 등 게임 요소로 꾸준한 수학 학습 동기를 부여. Flutter로 iOS/Android/Web 크로스플랫폼 지원.

## 기술 스택
- **프레임워크**: Flutter 3.24.0+ / Dart 3.5.0+
- **UI**: Material Design 3 (커스텀 듀오링고 스타일)
- **상태관리**: Flutter Riverpod 2.6.1 + Generator
- **백엔드**: Firebase (Auth, Firestore, Storage, Messaging, Analytics, Crashlytics)
- **Cloud Functions**: Node.js 20, TypeScript, Firebase Admin SDK
- **수식 렌더링**: Flutter Math Fork 0.7.2 (LaTeX)
- **차트**: FL Chart 0.69.0
- **애니메이션**: Lottie 3.2.0, Confetti, Shimmer
- **소셜 로그인**: Google Sign-In, Apple Sign-In
- **보안**: Flutter Secure Storage, Hive, HTTP Certificate Pinning

## 배포
- **iOS**: App Store (준비 완료)
- **Android**: Play Store (준비 완료)
- **Web**: Flutter Web 지원

## 주요 기능
1. **커리큘럼**: 산술, 대수, 기하, 통계, 미적분
2. **문제 유형**: 객관식, 드래그앤드롭, 주관식, 단계별 힌트
3. **XP 시스템**: 경험치 → 레벨업 (Bronze → Silver → Gold → Diamond)
4. **일일 스트릭**: 연속 학습 보상
5. **주간 리그**: 경쟁 랭킹
6. **업적 배지**: 조건 달성 시 획득
7. **하트 시스템**: 틀림 허용 횟수 제한
8. **오답 노트**: 틀린 문제 추적 및 복습
9. **개념 카드**: 미니 레슨
10. **프리미엄 구독**: 인앱 결제

## 디렉토리 구조
```
lib/
├── main.dart                  # 앱 엔트리
├── app/                       # 앱 설정 & 네비게이션
│   ├── app.dart / auth_wrapper.dart / main_navigation.dart
│   └── splash_screen.dart
├── core/                      # 핵심 인프라
│   ├── config/                # 환경 설정
│   ├── error/                 # 에러 처리
│   ├── network/               # 네트워크 관리
│   ├── security/              # 보안 & 암호화
│   └── utils/                 # 유틸리티
├── data/
│   ├── models/                # 데이터 모델 (16개 디렉토리)
│   │   ├── achievement_model / concept_card_model / daily_reward_model
│   │   ├── friend_model / league_model / practice_session_model
│   │   ├── wrong_answer_model / learning/ / lesson/ / problem/
│   │   └── rank/ / subscription/ / user/
│   ├── providers/             # Riverpod 프로바이더 (21개)
│   │   ├── auth/ / achievement/ / curriculum/ / gamification/
│   │   ├── league/ / lesson/ / problem/ / user/ / subscription/
│   │   └── wrong_answer/ / ...
│   ├── repositories/          # 데이터 접근 계층
│   └── services/              # Firebase 서비스
├── features/                  # 기능 모듈 (16개)
│   ├── auth/                  # 로그인/회원가입
│   ├── onboarding/            # 레벨 테스트
│   ├── home/                  # 홈 화면
│   ├── lessons/               # 레슨 목록
│   ├── problems/              # 문제 풀기 UI
│   ├── profile/               # 프로필
│   ├── challenges/            # 일일 챌린지
│   ├── league/                # 주간 리그
│   ├── leaderboard/           # 랭킹
│   ├── premium/               # 프리미엄 구독
│   ├── settings/              # 설정
│   └── wrong_answer/          # 오답 노트
└── shared/
    ├── constants/             # 상수 (색상, 문자열)
    ├── themes/                # Material Design 3 테마
    └── widgets/               # 재사용 UI 위젯 (13개)

functions/                     # Firebase Cloud Functions
├── src/
│   ├── index.ts               # 엔트리
│   ├── services/              # 비즈니스 로직
│   ├── triggers/              # Firestore 트리거
│   ├── webhooks/              # 결제 웹훅
│   └── config/                # 플랫폼 설정
└── package.json               # Node.js 20

scripts/                       # 빌드 자동화
├── build_release.sh           # 릴리스 빌드
├── create_keystore.sh         # Android 키스토어 생성
├── health_check.sh            # 프로젝트 상태 확인
└── code_quality.sh            # 코드 품질 분석
```

## 코드 통계
- Dart 파일: 327개
- 총 코드 라인: 81,231줄
- 기능 모듈: 16개
- Riverpod 프로바이더: 21개

## 환경변수
```env
API_BASE_URL=                  # 백엔드 API
GOOGLE_WEB_CLIENT_ID=          # Google OAuth
FCM_WEB_PUSH_KEY=              # Firebase Cloud Messaging
APP_ENV=development            # 환경 (dev/staging/prod)
ENABLE_LOGGING=true
```

## Firestore 보안 규칙
- 사용자는 자기 데이터만 읽기/쓰기 가능
- 문제/레슨은 읽기 전용 (관리자만 쓰기)
- 업적은 전체 목록 읽기 가능
- 구독은 구매 타임스탬프 검증

## 새 프로젝트에서 참고할 포인트
- **Flutter Clean Architecture** (core → data → features → shared)
- **Riverpod 상태관리** + Code Generation
- **Firebase 풀스택** (Auth + Firestore + Storage + FCM + Analytics + Crashlytics)
- **Cloud Functions** (Node.js 20, TypeScript)
- **게이미피케이션 시스템** (XP, 레벨, 스트릭, 리그, 배지)
- **인앱 결제** (iOS/Android)
- **LaTeX 수식 렌더링** (Flutter Math Fork)
- **Lottie 애니메이션**
- **빌드 자동화 스크립트** (scripts/ 폴더)

## 실행 방법
```bash
flutter pub get
cp .env.example .env          # 환경변수 설정
flutter run                   # 디버그 실행
flutter build apk --release   # Android 릴리스
flutter build ios --release   # iOS 릴리스
```
