# MathLab 아키텍처 다이어그램

## 현재 의존성 구조

```mermaid
graph TD
    subgraph "app/"
        A[app.dart]
        B[main_navigation.dart]
        C[auth_wrapper.dart]
    end

    subgraph "features/"
        F1[home_screen]
        F2[lessons_screen]
        F3[problem_screen]
        F4[profile_screen]
        F5[leaderboard_screen]
        F6[errors_screen]
        F7[history_screen]
        F8[auth_screen]
    end

    subgraph "data/providers/"
        P1[user_provider]
        P2[lesson_provider]
        P3[problem_provider]
        P4[achievement_provider]
        P5[learning_stats_provider]
        P6[error_note_provider]
        P7[leaderboard_provider]
        P8[auth_provider]
    end

    subgraph "data/models/"
        M1[User]
        M2[Lesson]
        M3[Problem]
        M4[Achievement]
        M5[LearningStats]
        M6[ErrorNote]
        M7[LeaderboardEntry]
        M8[UserAccount]
    end

    subgraph "data/services/"
        S1[mock_data_service]
    end

    subgraph "shared/"
        SW[widgets]
        SC[constants]
        SU[utils]
        ST[themes]
    end

    %% App dependencies
    A --> B
    B --> F1
    B --> F2
    B --> F5
    B --> F6
    B --> F4
    C --> F8
    C --> P8

    %% Feature dependencies
    F1 --> P1
    F1 --> P3
    F2 --> P1
    F2 --> P2
    F2 --> P3
    F3 --> P3
    F4 --> P1
    F4 --> P4
    F5 --> P7
    F6 --> P1
    F6 --> P6
    F6 --> P3
    F7 --> P5

    %% Provider dependencies
    P1 --> M1
    P1 --> S1
    P2 --> M2
    P2 --> P1
    P2 --> P3
    P3 --> M3
    P4 --> M4
    P5 --> M5
    P6 --> M6
    P7 --> M7
    P8 --> M8

    %% Shared dependencies
    F1 --> SW
    F2 --> SW
    F3 --> SW
    F4 --> SW
    F5 --> SW
    F6 --> SW
    F7 --> SW

    F1 --> SC
    F2 --> SC
    F3 --> SC
    F4 --> SC

    SW --> SC
    SW --> SU

    style P2 fill:#ff9999
    style P3 fill:#ff9999
```

## 문제점 표시

```
🔴 P2 (lesson_provider) → P1, P3 (교차 의존성)
⚠️  shared/widgets (24개 파일 과밀)
⚠️  features (구조화 부족)
```

## 권장 구조 (Feature-First)

```mermaid
graph TD
    subgraph "app/"
        A[app.dart]
        B[main_navigation.dart]
    end

    subgraph "core/"
        CW[widgets/]
        CC[constants/]
        CU[utils/]
        CT[themes/]
    end

    subgraph "features/home/"
        H_UI[presentation/]
        H_P[providers/]
        H_M[models/]
    end

    subgraph "features/lessons/"
        L_UI[presentation/]
        L_P[providers/]
        L_M[models/]
    end

    subgraph "features/problem/"
        PR_UI[presentation/]
        PR_P[providers/]
        PR_M[models/]
    end

    subgraph "features/profile/"
        PF_UI[presentation/]
        PF_P[providers/]
        PF_M[models/]
    end

    subgraph "services/"
        SVC[mock_data_service]
    end

    %% App dependencies
    A --> B
    B --> H_UI
    B --> L_UI
    B --> PR_UI
    B --> PF_UI

    %% Feature internal dependencies
    H_UI --> H_P
    H_P --> H_M
    L_UI --> L_P
    L_P --> L_M
    PR_UI --> PR_P
    PR_P --> PR_M
    PF_UI --> PF_P
    PF_P --> PF_M

    %% Service dependencies
    H_P --> SVC
    L_P --> SVC
    PR_P --> SVC
    PF_P --> SVC

    %% Core dependencies
    H_UI --> CW
    L_UI --> CW
    PR_UI --> CW
    PF_UI --> CW

    H_UI --> CC
    L_UI --> CC
    PR_UI --> CC
    PF_UI --> CC

    style H_UI fill:#90EE90
    style L_UI fill:#90EE90
    style PR_UI fill:#90EE90
    style PF_UI fill:#90EE90
```

## shared/widgets 카테고리화 구조

```
shared/widgets/
├── buttons/                    (3 files)
│   ├── primary_button.dart
│   ├── animated_button.dart
│   └── duolingo_button.dart
│
├── cards/                      (5 files)
│   ├── duolingo_card.dart
│   ├── progress_card.dart
│   ├── special_progress_card.dart
│   ├── stat_card.dart
│   └── achievement_card.dart
│
├── dialogs/                    (3 files)
│   ├── level_up_dialog.dart
│   ├── badge_unlock_dialog.dart
│   └── daily_reward_dialog.dart
│
├── indicators/                 (3 files)
│   ├── duolingo_circular_progress.dart
│   ├── loading_widgets.dart
│   └── xp_animation_widget.dart
│
├── animations/                 (3 files)
│   ├── fade_in_widget.dart
│   ├── xp_animation.dart
│   └── xp_gain_animation.dart
│
├── layout/                     (4 files)
│   ├── responsive_wrapper.dart
│   ├── custom_bottom_nav.dart
│   ├── empty_state.dart
│   └── grade_tab_bar.dart
│
├── inputs/                     (1 file)
│   └── short_answer_input.dart
│
└── feature_specific/          (2 files)
    ├── lesson_card.dart
    └── league_widget.dart

Total: 24 files → 7 categories
```

## Provider 간 의존성 그래프

```mermaid
graph LR
    subgraph "독립 Providers"
        P1[user_provider]
        P4[achievement_provider]
        P5[learning_stats_provider]
        P6[error_note_provider]
        P7[leaderboard_provider]
        P8[auth_provider]
    end

    subgraph "의존 Providers"
        P2[lesson_provider]
        P3[problem_provider]
    end

    P2 --> P1
    P2 --> P3

    style P2 fill:#ffcccc
    style P3 fill:#ffcccc
```

**해결 방안:**
1. lesson_provider에서 user와 problem 로직 분리
2. 이벤트 기반 통신으로 전환 (Riverpod Ref.listen)
3. 공통 비즈니스 로직은 별도 Service로 추출

## 복잡도 히트맵

```
📁 lib/
├── 📊 shared/widgets/        🔴 복잡도: 0.85 (24 files) ← 우선 개선 대상
├── 📊 data/models/           🟡 복잡도: 0.60 (12 files)
├── 📊 data/providers/        🟢 복잡도: 0.40 (8 files)
├── 📊 features/problem/      🟢 복잡도: 0.20 (4 files)
├── 📊 shared/constants/      🟢 복잡도: 0.20 (4 files)
└── 📊 shared/utils/          🟢 복잡도: 0.20 (4 files)

범례:
🔴 0.7-1.0: 즉시 개선 필요
🟡 0.5-0.7: 주의 필요
🟢 0.0-0.5: 양호
```

## 리팩토링 로드맵

```mermaid
gantt
    title 아키텍처 리팩토링 타임라인
    dateFormat  YYYY-MM-DD
    section Phase 1
    Widgets 카테고리화           :p1, 2025-10-21, 2d
    Barrel 파일 추가            :p2, after p1, 1d

    section Phase 2
    Features 구조화             :p3, after p2, 5d
    위젯 분리 (공통 vs 전용)      :p4, after p3, 3d

    section Phase 3
    Provider 분산               :p5, after p4, 7d
    의존성 재설계                :p6, after p5, 3d

    section Testing
    테스트 코드 작성             :p7, after p6, 5d
```

## 개선 효과 예측

```
현재 상태 → Phase 1 → Phase 2 → Phase 3

파일 검색 시간:
  30초 → 20초 → 15초 → 10초

Import 길이:
  ~60자 → ~50자 → ~45자 → ~35자

코드 리뷰 시간:
  60분 → 50분 → 40분 → 30분

전체 건강도:
  72/100 → 78/100 → 85/100 → 92/100
```

---

**참고:**
- 이 다이어그램은 Mermaid를 사용하여 작성되었습니다
- GitHub, Notion, VS Code 등에서 렌더링 가능
- 온라인 뷰어: https://mermaid.live/
