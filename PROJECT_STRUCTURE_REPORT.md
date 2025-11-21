# MathLab 프로젝트 구조 점검 보고서

생성일: 2025-11-21

## 📊 프로젝트 통계

- **총 Dart 파일**: 144개
- **총 디렉토리**: 52개
- **주요 기능 모듈**: 16개

## 📁 폴더 구조

### 1. `/lib/app` - 앱 진입점 및 라우팅
```
app/
├── app.dart              # 앱 설정
├── auth_wrapper.dart     # 인증 래퍼
├── main_navigation.dart  # 메인 네비게이션 (하단 탭바)
└── splash_screen.dart    # 스플래시 화면
```

### 2. `/lib/features` - 기능별 모듈 (16개)
```
features/
├── achievements/         # 업적 시스템
├── auth/                # 로그인/회원가입
│   └── figma/          # Figma 디자인 구현
├── daily_challenge/     # 일일 챌린지
├── daily_reward/        # 일일 보상
├── errors/              # 오답 노트
├── history/             # 학습 이력
├── home/                # 홈 화면
├── leaderboard/         # 리더보드
├── league/              # 리그 시스템
├── lessons/             # 학습 레슨
│   └── figma/          # Figma 디자인 구현
├── level_test/          # 레벨 테스트
├── onboarding/          # 온보딩
├── practice/            # 연습 모드
├── problem/             # 문제 풀이 (단일)
├── problems/            # 문제 풀이 세션
├── profile/             # 프로필
│   ├── figma/          # Figma 디자인 구현
│   └── widgets/        # 프로필 위젯
├── settings/            # 설정
└── wrong_answer/        # 오답 분석
```

### 3. `/lib/data` - 데이터 레이어
```
data/
├── models/              # 데이터 모델 (17개)
│   ├── achievement.dart
│   ├── daily_challenge.dart
│   ├── lesson.dart
│   ├── problem.dart
│   ├── user.dart
│   └── ...
├── providers/           # Riverpod 프로바이더 (18개)
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── navigation_provider.dart
│   ├── lesson_progress_provider.dart
│   └── ...
├── repositories/        # 데이터 저장소
│   └── problem_repository.dart
└── services/            # 서비스 레이어
    ├── firebase_auth_service.dart
    ├── korean_math_curriculum.dart
    ├── local_storage_service.dart
    └── mock_data_service.dart
```

### 4. `/lib/shared` - 공유 컴포넌트
```
shared/
├── constants/           # 상수 정의
│   ├── figma_colors.dart
│   ├── app_colors.dart
│   ├── app_dimensions.dart
│   └── game_constants.dart
├── figma_components/    # Figma 공통 컴포넌트
│   ├── figma_top_bar.dart
│   └── figma_user_info_bar.dart
├── themes/              # 테마
│   └── app_theme.dart
├── utils/               # 유틸리티
│   ├── haptic_feedback.dart
│   ├── logger.dart
│   ├── validators.dart
│   └── ...
└── widgets/             # 공통 위젯 (12개 카테고리)
    ├── animations/      # 애니메이션
    ├── badges/          # 뱃지
    ├── buttons/         # 버튼
    ├── cards/           # 카드
    ├── dialogs/         # 다이얼로그
    ├── drawers/         # 드로어
    ├── feedback/        # 피드백
    ├── images/          # 이미지
    ├── indicators/      # 인디케이터
    ├── inputs/          # 입력
    ├── layout/          # 레이아웃
    └── math/            # 수식 렌더링
```

## 🎨 Assets 구조

```
assets/
├── images/
│   ├── login/           # 로그인 화면 이미지
│   │   ├── logo.png
│   │   ├── math_is_text@3x.png
│   │   ├── fun_text@3x.png
│   │   └── chatbot.png
│   ├── figma_*_reference.png  # Figma 디자인 참조
│   └── *.png            # 일반 아이콘
└── icons/
```

## 🔍 발견된 문제점

### 1. 백업/임시 파일
```
❌ ./web/index.html.backup
❌ ./web/manifest.json.backup
❌ ./lib/features/auth/auth_screen.dart.backup
❌ ./lib/data/services/mock_data_service.dart-e
❌ ./build/web/index.html.backup
❌ ./build/web/manifest.json.backup
```
**권장사항**: 백업 파일 삭제 또는 .gitignore에 추가

### 2. 중복 가능성
- `problem_screen.dart` vs `problem_solving_screen.dart`
- `auth_screen.dart` vs `auth_screen_figma.dart`

**권장사항**: 사용하지 않는 파일 제거 또는 명확한 네이밍

## ✅ 잘 구성된 부분

### 1. 명확한 폴더 구조
- Feature-first 아키텍처
- 데이터/프레젠테이션 레이어 분리
- 공유 컴포넌트 재사용

### 2. Figma 디자인 구현
- `figma/` 폴더로 디자인 구현 분리
- 참조 이미지 포함 (`figma_*_reference.png`)

### 3. Provider 기반 상태 관리
- Riverpod 사용
- 18개의 명확한 Provider

### 4. 모듈화된 위젯
- 12개 카테고리로 분류
- 재사용 가능한 컴포넌트

## 📦 의존성

### 핵심 의존성
- `flutter_riverpod`: 상태 관리
- `shared_preferences`: 로컬 저장소
- `dio`: HTTP 클라이언트
- `cached_network_image`: 이미지 캐싱
- `confetti`: 애니메이션

### 개선 제안
1. 사용하지 않는 의존성 제거
2. 버전 업데이트 확인
3. 번들 크기 최적화

## 🎯 권장 개선사항

### 1. 즉시 조치 (High Priority)
- [ ] 백업 파일 삭제 또는 .gitignore 추가
- [ ] 사용하지 않는 중복 파일 제거
- [ ] .gitignore에 `*.backup`, `*.dart-e` 추가

### 2. 중기 개선 (Medium Priority)
- [ ] 코드 주석 및 문서화
- [ ] 테스트 코드 추가
- [ ] 에러 핸들링 강화

### 3. 장기 개선 (Low Priority)
- [ ] 성능 최적화
- [ ] 번들 크기 최적화
- [ ] 국제화 (i18n) 지원

## 📊 코드 품질 지표

- **파일당 평균 라인 수**: 적정 수준
- **폴더 깊이**: 3-4 레벨 (적절)
- **모듈화**: 우수
- **재사용성**: 우수

## 🚀 배포 상태

- **모바일**: Android (Samsung Galaxy S24) ✅
- **웹**: Vercel (https://mathlab-app.vercel.app) ✅
- **상태**: Production Ready

