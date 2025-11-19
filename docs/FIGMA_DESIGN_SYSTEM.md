# Figma 디자인 시스템 완벽 가이드

> MathLab 앱의 모든 디자인 요소를 정의한 완벽한 디자인 시스템 문서
>
> **마지막 업데이트**: 2025-11-18
> **버전**: 1.0.0

---

## 📋 목차

1. [색상 시스템](#색상-시스템)
2. [타이포그래피](#타이포그래피)
3. [컴포넌트 라이브러리](#컴포넌트-라이브러리)
4. [레이아웃 패턴](#레이아웃-패턴)
5. [아이콘 시스템](#아이콘-시스템)
6. [애니메이션 가이드](#애니메이션-가이드)
7. [스페이싱 시스템](#스페이싱-시스템)

---

## 🎨 색상 시스템

### Primary Colors (주요 색상)

```dart
// 그라디언트 블루 (메인 배경)
LinearGradient homeGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF6BA3D8),  // 밝은 블루
    Color(0xFF4A90E2),  // 메인 블루
  ],
);

// 메인 블루 (활성 카드, 버튼)
Color primaryBlue = Color(0xFF4A90E2);
Color primaryBlueDark = Color(0xFF0000FF);  // 진한 파란색 (학습 시작 버튼)
```

### Secondary Colors (보조 색상)

```dart
// 잠금 카드 색상
Color lockedCardBlue = Color(0xFFD8E7F3);  // 밝은 파란색 (잠긴 상태)

// 레벨 뱃지
Color levelBadgeRed = Color(0xFFC62828);  // 빨간색 배경

// 챌린지 카드
Color challengeOrange = Color(0xFFFFB74D);  // 주황색 배경

// 배경색
Color backgroundGray = Color(0xFFF5F5F5);  // 밝은 회색 배경
Color backgroundWhite = Color(0xFFFFFFFF); // 흰색 배경
```

### Status Colors (상태 색상)

```dart
// 프로그레스 바
Color progressTeal = Color(0xFF26A69A);      // 청록색 (진행 중)
Color progressPink = Color(0xFFEC407A);      // 핑크색 (레벨 진행)
Color progressOrange = Color(0xFFFF9800);    // 주황색 (레벨 진행 끝)
Color progressBackground = Color(0xFFE0E0E0); // 회색 (배경)

// 달력 완료 표시
Color calendarCompletedBlue = Color(0xFF4A90E2); // 완료된 날짜 파란색
```

### Text Colors (텍스트 색상)

```dart
Color textPrimary = Color(0xFF1A1A1A);    // 주요 텍스트 (거의 검정)
Color textSecondary = Color(0xFF757575);  // 보조 텍스트 (회색)
Color textWhite = Color(0xFFFFFFFF);      // 흰색 텍스트
Color textLink = Color(0xFF4A90E2);       // 링크 텍스트 (파란색)
```

### Shadow & Overlay

```dart
// 카드 그림자
BoxShadow cardShadow = BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 10,
  offset: Offset(0, 4),
);

// 모달 오버레이
Color modalOverlay = Colors.black.withOpacity(0.5);
```

---

## 📝 타이포그래피

### Font Family

```dart
// 기본 폰트
String defaultFont = 'Pretendard';  // 또는 시스템 기본 폰트

// 대체 폰트
String fallbackFont = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto';
```

### Text Styles

#### Headings (제목)

```dart
// 대형 제목 (페이지 타이틀)
TextStyle headingLarge = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A1A),
  height: 1.3,
);

// 중형 제목 (섹션 제목)
TextStyle headingMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A1A),
  height: 1.4,
);

// 소형 제목 (카드 제목)
TextStyle headingSmall = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A1A),
  height: 1.4,
);
```

#### Body Text (본문)

```dart
// 일반 본문
TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Color(0xFF1A1A1A),
  height: 1.5,
);

// 중간 본문
TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: Color(0xFF1A1A1A),
  height: 1.5,
);

// 작은 본문
TextStyle bodySmall = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.normal,
  color: Color(0xFF757575),
  height: 1.5,
);
```

#### Labels & Captions (라벨 & 캡션)

```dart
// 버튼 라벨
TextStyle buttonLabel = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFFFFFFFF),
  letterSpacing: 0.5,
);

// 네비게이션 라벨
TextStyle navLabel = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  color: Color(0xFF757575),
  height: 1.2,
);

// 캡션
TextStyle caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: Color(0xFF757575),
  height: 1.3,
);
```

---

## 🧩 컴포넌트 라이브러리

### 1. Top Bar (상단 바)

**위치**: `lib/shared/figma_components/figma_top_bar.dart`

#### 구조
```
┌─────────────────────────────────────────┐
│ [←]  Title                    [Logo]    │
└─────────────────────────────────────────┘
```

#### 스펙
- **높이**: 110px (상단 패딩 포함)
- **배경**: 그라디언트 블루 (homeGradient)
- **모서리**: 하단 좌우 30px 둥근 모서리
- **패딩**: horizontal 24px, vertical 16px

#### 사용 예시
```dart
FigmaTopBar(
  title: 'Home',           // 페이지 제목
  showBackButton: false,   // 뒤로가기 버튼 표시 여부
  onBackPressed: () {},    // 뒤로가기 콜백 (옵션)
  trailing: Widget,        // 오른쪽 커스텀 위젯 (옵션)
)
```

---

### 2. User Info Bar (사용자 정보 바)

**위치**: `lib/shared/figma_components/figma_user_info_bar.dart`

#### 구조
```
┌─────────────────────────────────────────────────────────┐
│ [👤] 소인수분해    [🔥 6]  [💎 549]  [🏆 HLv1]          │
└─────────────────────────────────────────────────────────┘
```

#### 스펙
- **높이**: 약 60px
- **배경**: 그라디언트 블루 (Top Bar와 동일)
- **마진**: top 16px
- **패딩**: horizontal 24px, vertical 12px

#### 배지 디자인
```dart
// 배지 공통 스타일
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.25),  // 반투명 흰색
    borderRadius: BorderRadius.circular(12),
  ),
)

// 레벨 배지 (특별 스타일)
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: Color(0xFFC62828),  // 빨간색 배경
    borderRadius: BorderRadius.circular(12),
  ),
)
```

#### 아이콘
- **스트릭**: 🔥 (이모지) 또는 불꽃 아이콘
- **XP**: 💎 (이모지) 또는 다이아몬드 아이콘
- **레벨**: `assets/images/winner.png` (18x18px)

#### 사용 예시
```dart
FigmaUserInfoBar(
  userName: '소인수분해',
  streakDays: 6,
  xp: 549,
  level: 'HLv1',
  profileImageUrl: null,  // 옵션
)
```

---

### 3. Lesson Card (레슨 카드)

**위치**: `lib/features/lessons/figma/lessons_screen_figma.dart`

#### 구조
```
┌──────────────┐
│              │
│   [이미지]    │
│              │
│   "START!"   │
│              │
└──────────────┘
```

#### 스펙
- **크기**: 가변 (높이 140px ~ 180px)
- **배경**:
  - 활성: `Color(0xFF4A90E2)` (진한 파란색)
  - 잠김: `Color(0xFFD8E7F3)` (밝은 파란색)
- **모서리**: 20px 둥근 모서리
- **그림자**:
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 10,
  offset: Offset(0, 4),
)
```

#### 잠금 오버레이
```dart
// 잠긴 카드에 추가되는 오버레이
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.3),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Center(
    child: Icon(
      Icons.lock,
      size: 36,
      color: Colors.white,
    ),
  ),
)
```

#### 레이아웃 패턴
```
행1: [카드 1 (큼)] [카드 2 (큼)]
행2: [카드 3 (중)] [빈 공간]
행3:     [카드 4 (중, 센터)]
행4: [카드 5] [카드 6] [카드 7]
행5:     [카드 8 (중, 센터)]
행6: [카드 9] [카드 10]
```

---

### 4. Progress Bar (진행 바)

**위치**: 여러 화면에서 사용

#### 일일 목표 진행 바
```dart
Container(
  height: 12,
  decoration: BoxDecoration(
    color: Color(0xFFE0E0E0),  // 배경
    borderRadius: BorderRadius.circular(6),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: LinearProgressIndicator(
      value: 0.8,  // 80% 진행
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation(Color(0xFF26A69A)),
    ),
  ),
)
```

#### 레벨 진행 바 (그라디언트)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: LinearProgressIndicator(
    value: 0.5,  // 50% 진행
    minHeight: 12,
    backgroundColor: Color(0xFFE0E0E0),
    valueColor: AlwaysStoppedAnimation(
      // 핑크-주황 그라디언트 효과
      Color(0xFFEC407A),
    ),
  ),
)
```

---

### 5. Stat Card (통계 카드)

**위치**: `lib/features/profile/figma/profile_screen_figma.dart`

#### 구조
```
┌──────────────┐
│     🔥       │
│              │
│Challenge Done│
│   6 Days     │
└──────────────┘
```

#### 스펙
- **배경**: `Color(0xFFF5F5F5)` 또는 흰색
- **테두리**: `Color(0xFFE0E0E0)` 1px
- **모서리**: 16px 둥근 모서리
- **패딩**: 20px (전체)
- **그림자**: cardShadow

#### 구조
```dart
Column(
  children: [
    Text('🔥', style: TextStyle(fontSize: 40)),
    SizedBox(height: 8),
    Text('Challenge Done', style: caption),
    SizedBox(height: 4),
    Text('6 Days', style: heading),
  ],
)
```

---

### 6. Calendar (달력)

**위치**: `lib/features/profile/figma/profile_screen_figma.dart`

#### 구조
```
December 2022                    [VIEW]
Mon  Tue  Wed  Thu  Fri  Sat  Sun
          1    2    3    4
 5    6    7    8    9   10   11
12   ⓮   ⓯   ⓰   ⓱   ⓲   ⓳
19   20   21   22   23   24   25
26   27   28   29   30   31
```

#### 스펙
- **배경**: 흰색
- **모서리**: 16px 둥근 모서리
- **패딩**: 16px
- **그림자**: cardShadow

#### 날짜 셀 스타일
```dart
// 일반 날짜
Container(
  width: 40,
  height: 40,
  child: Center(
    child: Text(
      '$day',
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1A1A),
      ),
    ),
  ),
)

// 완료된 날짜
Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFF4A90E2),  // 파란색 원
    shape: BoxShape.circle,
  ),
  child: Center(
    child: Text(
      '$day',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
)
```

---

### 7. Button (버튼)

#### Primary Button (학습 시작 버튼)
```dart
Container(
  width: double.infinity,
  height: 56,
  decoration: BoxDecoration(
    color: Color(0xFF0000FF),  // 진한 파란색
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF0000FF).withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.play_arrow, color: Colors.white),
      SizedBox(width: 8),
      Text(
        '학습 시작하기',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  ),
)
```

#### Secondary Button (정답 확인)
```dart
Container(
  width: double.infinity,
  height: 56,
  decoration: BoxDecoration(
    color: Color(0xFF4A90E2),  // 메인 블루
    borderRadius: BorderRadius.circular(28),
  ),
  child: Center(
    child: Text(
      '정답 확인',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ),
)
```

#### Text Button (VIEW)
```dart
TextButton(
  onPressed: () {},
  child: Text(
    'VIEW',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFF4A90E2),
    ),
  ),
)
```

---

### 8. Bottom Navigation (하단 네비게이션)

**위치**: `lib/shared/widgets/layout/custom_bottom_nav.dart`

#### 구조
```
┌─────┬─────┬─────┬─────┬─────┐
│학습  │오답  │ [🏠] │프로필│학습이력│
└─────┴─────┴─────┴─────┴─────┘
```

#### 스펙
- **높이**: 75px + bottom padding
- **배경**: 흰색
- **상단 테두리**: 0.5px, 밝은 회색
- **그림자**: 상단 그림자

#### 아이템 스펙
- **아이콘 크기**: 22px
- **폰트 크기**: 10px
- **활성 색상**: `Color(0xFF4A90E2)`
- **비활성 색상**: `Color(0xFF757575).withOpacity(0.6)`

#### 홈 버튼 (중앙 특별 버튼)
```dart
Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF4A90E2), Color(0xFF2196F3)],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF4A90E2).withOpacity(0.4),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: Icon(Icons.home, color: Colors.white, size: 26),
)
```

---

### 9. Answer Choice Chip (답안 선택 칩)

**위치**: 문제 풀이 화면

#### 구조
```
┌──────────────┐
│   semper     │
└──────────────┘
```

#### 스펙
```dart
// 일반 상태
Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Color(0xFFE0E0E0), width: 2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'semper',
    style: TextStyle(
      fontSize: 16,
      color: Color(0xFF1A1A1A),
    ),
  ),
)

// 선택된 상태
Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  decoration: BoxDecoration(
    color: Color(0xFF4A90E2).withOpacity(0.1),
    border: Border.all(color: Color(0xFF4A90E2), width: 2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'semper',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF4A90E2),
    ),
  ),
)
```

---

## 📐 레이아웃 패턴

### Screen Layout (화면 레이아웃)

#### 기본 구조
```
┌─────────────────────────────┐
│      Top Bar (110px)         │
│  User Info Bar (60px)        │
├─────────────────────────────┤
│                              │
│      Main Content            │
│      (Scrollable)            │
│                              │
│                              │
├─────────────────────────────┤
│   Bottom Nav (75px + safe)   │
└─────────────────────────────┘
```

#### 코드 구조
```dart
Scaffold(
  body: Column(
    children: [
      FigmaTopBar(...),
      FigmaUserInfoBar(...),
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: // 메인 컨텐츠
        ),
      ),
    ],
  ),
  bottomNavigationBar: CustomBottomNavigation(...),
)
```

---

### Grid Layout (그리드 레이아웃)

#### 2열 그리드
```dart
Row(
  children: [
    Expanded(child: Card1()),
    SizedBox(width: 16),
    Expanded(child: Card2()),
  ],
)
```

#### 3열 그리드
```dart
Row(
  children: [
    Expanded(child: Card1()),
    SizedBox(width: 12),
    Expanded(child: Card2()),
    SizedBox(width: 12),
    Expanded(child: Card3()),
  ],
)
```

#### 센터 정렬 단일 카드
```dart
Center(
  child: SizedBox(
    width: MediaQuery.of(context).size.width * 0.45,
    child: Card(),
  ),
)
```

---

## 🎭 아이콘 시스템

### App Icons (앱 아이콘)

#### 교육 관련 아이콘
- `assets/images/book_pencil.png` - 책과 연필 (START!)
- `assets/images/book.png` - 노트북
- `assets/images/rulers.png` - 자와 각도기
- `assets/images/blackboard.png` - 칠판
- `assets/images/microscope.png` - 현미경

#### 오브젝트 아이콘
- `assets/images/bag.png` - 가방
- `assets/images/clock.png` - 시계
- `assets/images/winner.png` - 트로피 (레벨 뱃지용)
- `assets/images/laptop.png` - 노트북
- `assets/images/globe.png` - 지구본

#### 캐릭터
- `assets/images/robot_character.png` - 로봇 캐릭터 (홈 화면)

#### 로고
- GoMath 로고 - 상단 우측에 배치
- 하단 브랜딩: "Design Driven Mathematics"

### Navigation Icons (네비게이션 아이콘)

```dart
// Material Icons 사용
Icons.home          // 홈
Icons.school        // 학습
Icons.error_outline // 오답
Icons.person        // 프로필
Icons.history_edu   // 학습이력
```

---

## 🎬 애니메이션 가이드

### Transitions (전환 효과)

#### 페이지 전환
```dart
Duration transitionDuration = Duration(milliseconds: 300);
Curves transitionCurve = Curves.easeInOut;
```

#### 버튼 애니메이션
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  // 상태 변화
)
```

#### 네비게이션 아이템
```dart
AnimatedScale(
  duration: Duration(milliseconds: 200),
  scale: isSelected ? 1.1 : 1.0,
  child: Icon(...),
)
```

### Hover & Press States

```dart
// 버튼 눌림 상태
onTapDown: (_) => setState(() => isPressed = true),
onTapUp: (_) => setState(() => isPressed = false),
onTapCancel: () => setState(() => isPressed = false),

// 스케일 변화
Transform.scale(
  scale: isPressed ? 0.95 : 1.0,
  child: Container(...),
)
```

---

## 📏 스페이싱 시스템

### Padding Values

```dart
// 화면 전체 패딩
const double screenPadding = 24.0;

// 카드 내부 패딩
const double cardPadding = 20.0;
const double cardPaddingSmall = 16.0;

// 섹션 간격
const double sectionSpacing = 24.0;
const double sectionSpacingLarge = 32.0;

// 아이템 간격
const double itemSpacing = 16.0;
const double itemSpacingSmall = 12.0;
const double itemSpacingTiny = 8.0;
```

### Margin Values

```dart
// 상단 마진
const double topMargin = 16.0;
const double topMarginLarge = 24.0;

// 하단 마진 (네비게이션 바 공간)
const double bottomMargin = 100.0;
```

### Gap Sizes

```dart
SizedBox(height: 8),   // 작은 간격
SizedBox(height: 12),  // 중간 간격
SizedBox(height: 16),  // 기본 간격
SizedBox(height: 24),  // 큰 간격
SizedBox(height: 32),  // 매우 큰 간격
```

---

## 🔧 사용 예시

### 새 화면 만들기 템플릿

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/figma_components/figma_components.dart';
import '../../../data/providers/user_provider.dart';

class NewScreenFigma extends ConsumerWidget {
  const NewScreenFigma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // 상단 바
          const FigmaTopBar(
            title: '페이지 제목',
            showBackButton: true,
          ),

          // 사용자 정보 바
          FigmaUserInfoBar(
            userName: '소인수분해',
            streakDays: user?.streakDays ?? 6,
            xp: user?.xp ?? 549,
            level: 'HLv${user?.level ?? 1}',
          ),

          const SizedBox(height: 24),

          // 메인 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 여기에 컨텐츠 추가

                  const SizedBox(height: 100), // 네비게이션 바 공간
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📱 반응형 가이드

### Breakpoints

```dart
// 작은 화면 (iPhone SE)
double smallScreen = 375;

// 중간 화면 (일반 폰)
double mediumScreen = 414;

// 큰 화면 (Plus/Max 폰)
double largeScreen = 428;
```

### 반응형 패딩

```dart
double responsivePadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 375) return 16.0;
  if (width < 414) return 20.0;
  return 24.0;
}
```

---

## ✅ 체크리스트

새 화면/컴포넌트 개발 시 확인사항:

- [ ] 색상 팔레트에서 정의된 색상 사용
- [ ] 타이포그래피 가이드 준수
- [ ] 스페이싱 시스템 따르기
- [ ] 그림자 효과 일관성 유지
- [ ] 모서리 반경 일관성 (12px, 16px, 20px, 28px)
- [ ] 애니메이션 duration 일관성 (200ms, 300ms)
- [ ] 하단 네비게이션 공간 확보 (100px)
- [ ] Safe Area 처리
- [ ] 다크모드 대응 (향후)

---

## 📚 참고 자료

### Figma 디자인 파일
- 홈 화면: `assets/images/figma_home_reference.png`
- 학습 페이지: `assets/images/figma_01_lessons_reference.png`
- 오답 페이지: `assets/images/figma_02_errors_reference.png`
- 프로필 페이지: `assets/images/figma_03_profile_reference.png`
- 문제 풀이: `assets/images/figma_04_history_reference.png`

### 구현된 컴포넌트
- `lib/shared/figma_components/` - 공통 컴포넌트
- `lib/features/*/figma/` - 페이지별 Figma 구현

---

**Last Updated**: 2025-11-18
**Version**: 1.0.0
**Maintained by**: Claude Code
