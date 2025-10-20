# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MathLab은 듀오링고 스타일의 게이미피케이션을 적용한 수학 학습 모바일 앱입니다. 사용자가 매일 짧은 시간 동안 꾸준히 수학을 학습할 수 있도록 동기부여하는 시스템을 구축합니다.

## 기술 스택

### 선택된 기술 스택
- **Frontend**: Flutter (크로스 플랫폼) ✅
- **Backend**: Node.js + Express 또는 Python + FastAPI
- **Database**: PostgreSQL (사용자 데이터) + Redis (캐싱)
- **Authentication**: JWT 토큰 기반 인증
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Google Analytics 또는 Mixpanel

### Flutter 특화 라이브러리
```yaml
dependencies:
  # 수학 렌더링
  flutter_math_fork: ^0.7.2
  flutter_tex: ^4.0.9

  # 차트/그래프
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.2.7

  # 애니메이션
  lottie: ^2.7.0
  rive: ^0.12.4

  # 상태관리
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9

  # 네트워킹
  dio: ^5.4.0

  # 로컬 저장
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
```

## 핵심 기능 요구사항

### 1. 사용자 온보딩 및 레벨 테스트
- 초기 진단 평가를 통한 사용자 실력 파악
- 학습 목표 및 일일 학습 시간 목표 설정
- 학습 동기 선택

### 2. 커리큘럼 구조
- **기초 산술**: 사칙연산, 분수, 소수
- **대수**: 방정식, 부등식, 함수
- **기하**: 도형, 각도, 면적, 부피
- **통계**: 평균, 확률, 그래프 해석
- **미적분**: 극한, 미분, 적분 (고급 과정)

### 3. 문제 유형 및 상호작용
- 객관식 문제 (4지선다형)
- 드래그 앤 드롭 (수식 조립, 그래프 매칭)
- 손글씨 인식 (직접 수식 작성)
- 단계별 풀이 시스템
- 시각화 도구 (그래프, 도형 조작)

### 4. 게이미피케이션 요소
- 경험치(XP) 시스템
- 연속 학습 스트릭
- 레벨 시스템 (Bronze → Silver → Gold → Diamond)
- 업적 뱃지 시스템
- 리그 시스템 (주간 경쟁)
- 하트 시스템 (실수 허용 한도)

### 5. 학습 강화 기능
- 힌트 시스템 (단계별 힌트)
- 오답 노트 (틀린 문제 자동 저장)
- 개념 설명 카드
- 연습 모드
- 일일 챌린지

### 6. 개인화 및 적응형 학습
- AI 기반 난이도 조절
- 취약 영역 집중 학습
- 망각 곡선 기반 복습 스케줄

## MVP 범위 (최소 기능)

첫 번째 버전에 포함될 기능:
- 기초 산술과 대수 커리큘럼
- 객관식과 드래그 앤 드롭 문제 유형
- 기본 XP와 스트릭 시스템
- 5개 레슨으로 구성된 20개 유닛

## Phase 2 추가 기능
- 친구 시스템
- 그룹 학습
- AI 튜터 모드
- 오프라인 모드
- 부모 모드

## 성공 지표 (KPI)
- DAU/MAU (일일/월간 활성 사용자)
- 7일/30일 리텐션율
- 평균 세션 시간
- 일일 완료 문제 수
- 스트릭 유지율

## UI/UX 가이드라인
- 밝고 친근한 색상 팔레트
- 애니메이션과 사운드 효과로 즉각적 피드백
- 진행률 시각적 표시
- 깔끔한 문제 풀이 화면
- 직관적인 수학 키보드

## Development Setup

### Flutter 프로젝트 초기화

```bash
# Flutter 프로젝트 생성
flutter create mathlab
cd mathlab

# 의존성 설치
flutter pub get

# iOS 시뮬레이터 실행 (macOS)
flutter run -d ios

# Android 에뮬레이터 실행
flutter run -d android

# 웹에서 실행 (개발 중)
flutter run -d web

# 빌드
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### 프로젝트 구조
```
lib/
├── main.dart                 # 앱 진입점
├── app/
│   ├── app.dart             # 앱 설정
│   └── routes.dart          # 라우팅
├── features/
│   ├── auth/                # 인증
│   ├── onboarding/          # 온보딩
│   ├── home/                # 홈 화면
│   ├── lessons/             # 수업
│   ├── problems/            # 문제 풀이
│   ├── profile/             # 프로필
│   └── gamification/        # 게이미피케이션
├── shared/
│   ├── widgets/             # 공통 위젯
│   ├── utils/               # 유틸리티
│   ├── constants/           # 상수
│   └── themes/              # 테마
└── data/
    ├── models/              # 데이터 모델
    ├── repositories/        # 데이터 저장소
    └── services/            # API 서비스
```

## 디자인 시스템

상세한 디자인 가이드라인은 `DESIGN_GUIDE.md` 파일을 참조하세요.

### 주요 디자인 원칙
- **색상**: 밝고 친근한 색상 팔레트
- **타이포그래피**: 가독성과 계층 구조 중시
- **애니메이션**: 부드럽고 자연스러운 전환 효과
- **게이미피케이션**: 시각적 피드백과 성취감 제공

## Notes for Claude Code

- 이 프로젝트는 교육 목적의 게이미피케이션 앱입니다
- MVP를 먼저 구현한 후 점진적으로 기능을 확장합니다
- 사용자 경험(UX)과 학습 효과성을 최우선으로 고려합니다
- 모든 기능은 모바일 환경에 최적화되어야 합니다