# MathLab 프로젝트 구조

## 📁 전체 구조

```
MathLab/
├── lib/                        # Flutter 앱 소스코드
│   ├── app/                    # 앱 코어 (라우팅, 네비게이션)
│   ├── data/                   # 데이터 레이어
│   │   ├── models/            # 데이터 모델
│   │   ├── providers/         # Riverpod 상태관리
│   │   └── services/          # API 서비스
│   ├── features/              # 기능별 모듈
│   └── shared/                # 공유 컴포넌트
├── backend/                    # Node.js + TypeScript 백엔드
├── assets/                     # 이미지, 아이콘 등 리소스
└── docs/                       # 프로젝트 문서
```

## 🏗️ 아키텍처 원칙

### Clean Architecture
- **Presentation Layer**: UI 컴포넌트 (features/)
- **Business Logic Layer**: Providers (data/providers/)
- **Data Layer**: Models, Services (data/models/, data/services/)

### Feature-First Organization
각 기능은 독립적인 모듈로 구성되며, 다음과 같은 구조를 따릅니다:

```
features/[feature_name]/
├── [feature_name]_screen.dart    # 메인 화면
├── figma/                         # Figma 디자인 버전 (선택사항)
│   └── [feature_name]_figma.dart
└── widgets/                       # 기능별 위젯 (선택사항)
```

## 📂 lib/ 디렉토리 상세

### app/ - 앱 코어
```
app/
├── main_navigation.dart      # 하단 네비게이션 바 관리
├── auth_wrapper.dart         # 인증 상태 라우팅
└── routes.dart              # 앱 라우팅 설정
```

### data/ - 데이터 레이어
```
data/
├── models/                   # 데이터 모델 (16개)
│   ├── user.dart
│   ├── problem.dart
│   ├── lesson.dart
│   └── ...
├── providers/                # Riverpod 상태관리 (15개)
│   ├── user_provider.dart
│   ├── auth_provider.dart
│   └── ...
└── services/                 # API 서비스 (5개)
    ├── api_service.dart
    ├── storage_service.dart
    └── ...
```

### features/ - 기능 모듈

#### 주요 기능 (메인 네비게이션)
1. **home/** - 홈 화면
   - `home_screen_figma.dart` ✅ 활성
   - 9개 인터랙티브 요소 (스트릭, 로봇, XP/레벨/스트릭 카드 등)

2. **lessons/** - 학습 화면
   - `figma/lessons_screen_figma.dart` ✅ 활성
   - Quick Action 버튼 (연습 모드, 레벨 테스트)

3. **errors/** - 오답 노트
   - 틀린 문제 자동 저장 및 복습

4. **profile/** - 프로필
   - `figma/profile_screen_figma.dart` ✅ 활성 (메인 프로필)
   - `figma/profile_detail_screen_v3_new.dart` (상세 프로필)
   - `figma/profile_screen_v2.dart` (대체 디자인)
   - `edit_profile_screen.dart`

5. **history/** - 학습 이력
   - 30일 챌린지 달력

#### 게이미피케이션 기능
- **achievements/** - 업적 시스템
- **daily_challenge/** - 데일리 챌린지
- **daily_reward/** - 일일 보상
- **leaderboard/** - 리더보드
- **league/** - 리그 시스템

#### 학습 기능
- **practice/** - 연습 모드
- **level_test/** - 레벨 테스트
- **problem/** - 문제 풀이
- **onboarding/** - 온보딩
- **wrong_answer/** - 오답 복습

#### 기타 기능
- **auth/** - 인증 (로그인/회원가입)
- **settings/** - 설정

### shared/ - 공유 컴포넌트

#### constants/ - 상수
```
constants/
├── app_colors.dart          # 앱 컬러 팔레트
├── app_text_styles.dart     # 텍스트 스타일
├── figma_colors.dart        # Figma 디자인 컬러
└── ...
```

#### figma_components/ - Figma 전용 컴포넌트
```
figma_components/
├── figma_top_bar.dart       # 상단 바
├── figma_user_info_bar.dart # 사용자 정보 바
└── figma_components.dart    # Export file
```

#### widgets/ - 재사용 가능한 위젯
```
widgets/
├── badges/                  # 뱃지 위젯
│   └── rank_badge.dart
├── buttons/                 # 버튼 위젯
├── cards/                   # 카드 위젯
│   ├── daily_goal_card.dart
│   ├── figma_achievement_card.dart
│   └── ...
├── dialogs/                 # 다이얼로그
├── drawers/                 # Drawer 위젯
│   └── learning_calendar_drawer.dart
├── feedback/                # 피드백 위젯
├── images/                  # 이미지 위젯
├── indicators/              # 진행 표시 위젯
│   ├── circular_level_badge.dart
│   ├── circular_progress_ring.dart
│   └── ...
└── layout/                  # 레이아웃 위젯
```

## 🎨 디자인 시스템

### Figma 통합
프로젝트는 Figma 디자인을 기반으로 하며, 다음과 같이 구성됩니다:

1. **Figma Colors** (`shared/constants/figma_colors.dart`)
   - 브랜드 컬러
   - 그라디언트
   - 상태별 컬러

2. **Figma Components** (`shared/figma_components/`)
   - 재사용 가능한 Figma 디자인 컴포넌트
   - 일관된 UI/UX 제공

3. **Figma 화면 버전**
   - `features/*/figma/` 디렉토리에 Figma 디자인 버전 위치
   - 메인 네비게이션은 모두 Figma 버전 사용

### 디자인 레퍼런스
- `assets/images/figma_*_reference.png` 파일 참조
- 각 화면별 Figma 디자인 스크린샷 제공

## 🔄 상태 관리

### Riverpod
- **Provider 타입**:
  - `StateNotifierProvider` - 복잡한 상태 로직
  - `FutureProvider` - 비동기 데이터 로딩
  - `StreamProvider` - 실시간 데이터 스트림

- **주요 Providers**:
  - `userProvider` - 사용자 정보
  - `authProvider` - 인증 상태
  - `lessonProvider` - 레슨 데이터
  - `problemProvider` - 문제 데이터

## 🌐 Backend 구조

```
backend/
├── src/
│   ├── controllers/         # API 엔드포인트 핸들러
│   ├── services/           # 비즈니스 로직
│   ├── models/             # 데이터베이스 모델
│   ├── routes/             # API 라우팅
│   ├── middlewares/        # 미들웨어 (인증 등)
│   ├── config/             # 설정 (DB, Redis)
│   └── utils/              # 유틸리티 (JWT, Logger)
├── database/
│   ├── schema.sql          # 데이터베이스 스키마
│   └── seed.sql            # 초기 데이터
└── docker-compose.yml      # 개발 환경 설정
```

### API 엔드포인트
- `/api/auth/*` - 인증 관련
- `/api/users/*` - 사용자 관리
- `/api/lessons/*` - 레슨 관리
- `/api/problems/*` - 문제 관리
- `/api/leaderboard/*` - 리더보드

## 📱 네비게이션 구조

### 메인 네비게이션 (하단 탭바)
1. **홈** (HomeScreenFigma)
2. **학습** (LessonsScreenFigma)
3. **오답** (ErrorsScreen)
4. **프로필** (ProfileScreenFigma)
5. **이력** (HistoryScreen)

### 화면 연결 (Navigator.push)
```
HomeScreen
├── → ProfileDetailScreen (스트릭 뱃지, XP/스트릭 카드 클릭)
├── → LeaderboardScreen (레벨 카드 클릭)
├── → LessonsScreen (일일 목표, 학습 시작 버튼)
└── → DailyRewardScreen (데일리 챌린지 배너)

LessonsScreen
├── → PracticeScreen (연습 모드 버튼)
└── → LevelTestScreen (레벨 테스트 버튼)

LeaderboardScreen
└── → LeagueScreen (트로피 아이콘)

ProfileDetailScreen
├── → PracticeScreen (Quick Access)
├── → LevelTestScreen (Quick Access)
├── → AchievementsScreen (Quick Access)
└── → DailyChallengeScreen (Quick Access)
```

## 🎯 네이밍 컨벤션

### 파일명
- **Screens**: `[feature_name]_screen.dart`
- **Widgets**: `[widget_name].dart` (소문자 + 언더스코어)
- **Models**: `[model_name].dart`
- **Providers**: `[name]_provider.dart`
- **Services**: `[name]_service.dart`

### 클래스명
- **Screens**: `[FeatureName]Screen` (예: `HomeScreen`)
- **Widgets**: `[WidgetName]` (예: `RankBadge`)
- **Models**: `[ModelName]` (예: `User`)
- **Providers**: `[name]Provider` (예: `userProvider`)

### Figma 버전
- **파일**: `[name]_figma.dart` 또는 `figma/[name].dart`
- **클래스**: `[Name]Figma` (예: `HomeScreenFigma`)

## 📝 코드 스타일

### Widget 구성
```dart
class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stateProvider);

    return Scaffold(
      // UI 구현
    );
  }

  // Private helper methods
  Widget _buildSection() { ... }
}
```

### State Management
```dart
final stateProvider = StateNotifierProvider<StateNotifier, State>((ref) {
  return StateNotifier();
});
```

## 🚀 향후 개선 사항

### 구조 개선
- [ ] figma/ 서브디렉토리 vs _figma.dart 접미사 통일
- [ ] widgets/ 디렉토리 구조 최적화
- [ ] 테스트 코드 추가 (test/ 디렉토리)

### 기능 개선
- [ ] 오프라인 모드 지원
- [ ] 푸시 알림 구현
- [ ] 소셜 로그인 통합
- [ ] 다국어 지원 (i18n)

## 📖 참고 문서

- [Figma 디자인 시스템](FIGMA_DESIGN_SYSTEM.md)
- [게이미피케이션 분석](FIGMA_GAMIFICATION_ANALYSIS.md)
- [프로젝트 개요](../CLAUDE.md)
- [디자인 가이드](../DESIGN_GUIDE.md)

---

**Last Updated**: 2024-11-19
**Maintainer**: MathLab Development Team
