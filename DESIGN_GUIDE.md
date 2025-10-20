# MathLab 디자인 가이드라인

수학 학습 앱 MathLab의 디자인 시스템 및 UI/UX 가이드라인

## 🎨 색상 팔레트 (실제 UI 기반)

### 주요 브랜드 색상
```
Primary Blue: #4285F4 (주요 버튼, 활성 상태)
Secondary Blue: #E3F2FD (배경 하이라이트)
Success Green: #34A853 (연속 학습, 성공 상태)
Warning Orange: #FF6B35 (스트릭, 주의사항)
Error Red: #EA4335 (오답, 경고)
Purple Accent: #9C27B0 (특별 기능, 가이드)
```

### 중성 색상
```
Background: #F8F9FA (전체 배경)
Surface White: #FFFFFF (카드 배경)
Text Primary: #202124 (주요 텍스트)
Text Secondary: #5F6368 (보조 텍스트)
Border Light: #DADCE0 (구분선, 테두리)
Disabled: #9AA0A6 (비활성 요소)
```

### 게이미피케이션 색상
```
XP Gold: #FFD700
Streak Orange: #FF6B35
Level Bronze: #CD7F32
Level Silver: #C0C0C0
Level Gold: #FFD700
Level Diamond: #B9F2FF
```

## 📝 타이포그래피

### 폰트 계층 구조
```dart
// Flutter 타이포그래피 예시
TextTheme(
  displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
  headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
  headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
)
```

### 수학 공식 폰트
- **수식 렌더링**: KaTeX, MathJax 스타일
- **모노스페이스**: Courier New (코드, 좌표)
- **기호**: Unicode 수학 기호 지원

## 🧩 UI 컴포넌트

### 버튼 스타일
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    elevation: 2,
  )
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: primaryBlue),
    borderRadius: BorderRadius.circular(12),
  )
)
```

### 카드 컴포넌트
```dart
Card(
  elevation: 4,
  borderRadius: BorderRadius.circular(16),
  child: Padding(
    padding: EdgeInsets.all(16),
    // 내용
  )
)
```

### 진행률 표시
```dart
LinearProgressIndicator(
  value: progress,
  backgroundColor: Colors.grey[300],
  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
  borderRadius: BorderRadius.circular(8),
)
```

## 📐 레이아웃 구조

### 그리드 시스템
- **모바일**: 4컬럼 그리드
- **태블릿**: 8컬럼 그리드
- **기본 여백**: 16dp
- **컴포넌트 간격**: 8dp, 16dp, 24dp

### 화면 영역 분할
```
┌─────────────────┐
│   Status Bar    │ 24dp
├─────────────────┤
│   App Bar       │ 56dp
├─────────────────┤
│                 │
│   Main Content  │ flexible
│                 │
├─────────────────┤
│  Bottom Nav     │ 56dp (선택적)
└─────────────────┘
```

## 🎮 게이미피케이션 UI

### XP 바 디자인
```dart
Container(
  height: 8,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(4),
    gradient: LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]
    )
  )
)
```

### 스트릭 표시
- **아이콘**: 🔥 불꽃 이모지 또는 커스텀 아이콘
- **색상**: 주황색 그라데이션
- **애니메이션**: 펄스 효과

### 레벨 뱃지
```dart
// Bronze, Silver, Gold, Diamond 레벨별 색상
Map<String, Color> levelColors = {
  'bronze': Color(0xFFCD7F32),
  'silver': Color(0xFFC0C0C0),
  'gold': Color(0xFFFFD700),
  'diamond': Color(0xFFB9F2FF),
};
```

## 📱 실제 화면별 레이아웃

### 홈 화면 (메인 대시보드)
```
┌─────────────────────────────────────┐
│ 안녕하세요, 학습자님!           🔥 0일 │
│ 중1 수학을 학습하고 있어요              │
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │  ⚡ XP  │ │  ⭐ 레벨 │ │ 🎯 연속 │ │
│ │    0    │ │    1    │ │  0일   │ │
│ └─────────┘ └─────────┘ └─────────┘ │
├─────────────────────────────────────┤
│ 오늘의 목표               0/100 XP   │
│ ████████████████████████░░░░░░░░░░   │
├─────────────────────────────────────┤
│ 레슨 1                              │
│ 다음 레슨까지              0/100 XP │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
├─────────────────────────────────────┤
│            학습 시작하기              │
├─────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────┐ │
│ │  📚 교과과정 학습  │ │  ❗ 오답노트 │ │
│ └─────────────────┘ └─────────────┘ │
└─────────────────────────────────────┘
```

### 학습 로드맵
```
┌─────────────────────────────────────┐
│ ┌─────┐ ┌─────┐ ┌─────┐             │
│ │ 중1 │ │ 중2 │ │ 고1 │             │
│ └─────┘ └─────┘ └─────┘             │
├─────────────────────────────────────┤
│ 🔢  1. 소인수분해              ▶    │
│ 1,2  자연수의 성질과 소인수분해를... │
│      진행률                    0%   │
│      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
├─────────────────────────────────────┤
│ ➕  2. 정수와 유리수            ▶    │
│ +    정수와 유리수의 개념과 연산을... │
│      진행률                    0%   │
│      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
├─────────────────────────────────────┤
│ 💡 학습 가이드                       │
│ 각 에피소드는 개념 학습 → 문제 풀이  │
└─────────────────────────────────────┘
```

### 오답 노트
```
┌─────────────────────────────────────┐
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │  0  │ │  0  │ │  0  │ │  0  │     │
│ │총오답││미복습││1회복습││2회이상│     │
│ └─────┘ └─────┘ └─────┘ └─────┘     │
├─────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │ 전체 │ │미복습││  1회 ││ 2회+│     │
│ └─────┘ └─────┘ └─────┘ └─────┘     │
├─────────────────────────────────────┤
│              📈                     │
│         오답이 없습니다!              │
│   완벽한 학습을 이어가고 계시네요 🎉   │
├─────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────┐ │
│ │  🔄 선택문제복습  │ │ 📚 맞춤복습세트│ │
│ │     (0)         │ │    만들기    │ │
│ └─────────────────┘ └─────────────┘ │
└─────────────────────────────────────┘
```

## 🎨 수학 특화 컴포넌트

### 수식 입력 키보드
```dart
// 수학 기호 키보드 레이아웃
Row(
  children: [
    MathKeyButton('÷'),
    MathKeyButton('×'),
    MathKeyButton('+'),
    MathKeyButton('-'),
    MathKeyButton('='),
  ]
)
```

### 드래그 앤 드롭 영역
```dart
DragTarget<String>(
  builder: (context, candidateData, rejectedData) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.dashed),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text('Drop Here')),
    );
  },
)
```

### 그래프/차트 영역
```dart
Container(
  height: 200,
  child: FlChart(
    // 수학 그래프 렌더링
  )
)
```

## ⚡ 애니메이션 가이드

### 전환 애니메이션
- **Duration**: 200-300ms
- **Curve**: Curves.easeInOut
- **Type**: Fade, Slide, Scale

### 피드백 애니메이션
```dart
// 정답 시 성공 애니메이션
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  decoration: BoxDecoration(
    color: successGreen,
    borderRadius: BorderRadius.circular(12),
  ),
)

// XP 획득 애니메이션
AnimatedDefaultTextStyle(
  duration: Duration(milliseconds: 500),
  style: TextStyle(
    fontSize: isAnimating ? 24 : 16,
    color: Colors.gold,
  ),
  child: Text('+10 XP'),
)
```

## 🔊 사운드 피드백
- **정답**: 성공 사운드 (따단!)
- **오답**: 부드러운 오류 사운드
- **레벨업**: 팡파레 사운드
- **XP 획득**: 코인 사운드

## 📐 반응형 디자인

### 브레이크포인트
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}
```

### 적응형 레이아웃
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < Breakpoints.mobile) {
      return MobileLayout();
    } else if (constraints.maxWidth < Breakpoints.tablet) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  }
)
```

## 🎯 사용성 가이드라인

### 터치 타겟
- **최소 크기**: 44x44dp
- **권장 크기**: 48x48dp
- **간격**: 8dp 이상

### 가독성
- **대비비**: WCAG 2.1 AA 기준 (4.5:1)
- **폰트 크기**: 최소 16sp
- **줄 간격**: 1.4배

### 접근성
- **Screen Reader 지원**
- **고대비 모드 지원**
- **큰 텍스트 지원**
- **색상 의존성 최소화**

## 🎨 아이콘 시스템

### 스타일 가이드
- **스타일**: Outlined, Filled
- **크기**: 16dp, 24dp, 32dp, 48dp
- **색상**: Primary, Secondary, Surface

### 주요 아이콘
```
홈: home
프로필: account_circle
설정: settings
통계: bar_chart
하트: favorite
스타: star
불꽃: local_fire_department
```

이 디자인 가이드를 Flutter 개발 시 참고하여 일관성 있고 사용자 친화적인 수학 학습 앱을 구축하시기 바랍니다.