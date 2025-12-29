# 문제 데이터 구조 분석 보고서

생성일: 2025-11-21

## 📊 현재 문제 데이터 현황

### 문제 저장 위치
```
lib/data/problems/
├── README.md                          # 문제 데이터 구조 설명
└── polynomials/                       # 다항식 문제
    ├── polynomial_001.json           # 다항식 덧셈/뺄셈 오류 계산
    └── polynomial_002.json           # 두 다항식의 사칙연산
```

**현재 저장된 문제**: 2개 (JSON 파일)

### 계획된 문제 카테고리
```
lib/data/problems/
├── polynomials/      # 다항식 (2개 파일 존재 ✅)
├── equations/        # 방정식 (미생성 ❌)
├── geometry/         # 기하 (미생성 ❌)
└── statistics/       # 통계 (미생성 ❌)
```

## 📁 문제 데이터 구조

### 1. JSON 파일 형식

```json
{
  "id": "문제 고유 ID",
  "title": "문제 제목",
  "question": "문제 본문",
  "type": "multipleChoice|shortAnswer|dragAndDrop|stepByStep",
  "category": "카테고리",
  "difficulty": 1-5,
  "choices": ["선택지1", "선택지2", ...],
  "answer": 0, // 또는 문자열
  "hints": ["힌트1", "힌트2", ...],
  "explanation": "풀이 설명",
  "imageUrl": "문제 이미지 경로",
  "answerImageUrl": "답안 이미지 경로",
  "metadata": {
    "lessonId": "연결된 레슨 ID",
    "tags": ["태그1", "태그2"],
    "estimatedTime": 300,
    "xpReward": 20
  }
}
```

### 2. 실제 문제 예시

#### polynomial_001.json
```json
{
  "id": "polynomial_001",
  "title": "다항식 덧셈과 뺄셈 오류 계산",
  "question": "다항식 4x³+2x-1에 어떤 식을 더해야 할 것을...",
  "type": "multipleChoice",
  "category": "algebra",
  "difficulty": 3,
  "choices": [
    "① 7x³+x²+x",
    "② 7x³-x²+x",
    "③ 7x³+x²-x",
    "④ 3x³+x²+5x-3",
    "⑤ 3x³-x²+5x-3"
  ],
  "answer": 1,
  "hints": [
    "먼저 어떤 식을 A라고 하자.",
    "문제에서 '더해야 할 것을 잘못하여 뺐다'는...",
    ...
  ],
  "metadata": {
    "lessonId": "lesson001",
    "tags": ["다항식", "덧셈", "뺄셈", "실수 계산"],
    "estimatedTime": 300,
    "xpReward": 20
  }
}
```

## 🔧 문제 관리 시스템

### 1. Problem 모델 (`lib/data/models/problem.dart`)

**핵심 필드**:
```dart
class Problem {
  final String id;              // 문제 고유 ID
  final String title;           // 문제 제목
  final String question;        // 문제 본문
  final ProblemType type;       // 문제 유형
  final String category;        // 카테고리
  final int difficulty;         // 난이도 (1-5)
  final List<String> choices;   // 객관식 선택지
  final dynamic answer;         // 정답
  final List<String> hints;     // 힌트 목록
  final String? explanation;    // 풀이 설명
  final Map<String, dynamic>? metadata;
}
```

**문제 유형 (ProblemType)**:
```dart
enum ProblemType {
  multipleChoice,  // 객관식 ✅
  shortAnswer,     // 주관식
  dragAndDrop,     // 드래그 앤 드롭
  stepByStep,      // 단계별 풀이
  calculation,     // 계산 문제
}
```

### 2. ProblemRepository (`lib/data/repositories/problem_repository.dart`)

**주요 기능**:
```dart
class ProblemRepository {
  // JSON 파일에서 문제 로드
  Future<Problem> loadProblem(String path);
  
  // 카테고리별 문제 목록 로드
  Future<List<Problem>> loadProblemsByCategory(String category);
  
  // 레슨 ID로 문제 목록 로드
  Future<List<Problem>> loadProblemsByLesson(String lessonId);
  
  // 난이도별 필터링
  List<Problem> filterByDifficulty(List<Problem> problems, int difficulty);
  
  // 태그별 필터링
  List<Problem> filterByTag(List<Problem> problems, String tag);
}
```

### 3. 임시 문제 생성 시스템

현재 `ProblemRepository`에는 **5개의 샘플 문제**가 하드코딩되어 있음:
1. 기본 덧셈 (2 + 2 = 4)
2. 곱셈 계산 (5 × 3 = 15)
3. 뺄셈 계산 (10 - 4 = 6)
4. 수 비교 (가장 큰 수 찾기)
5. 나눗셈 계산 (8 ÷ 2 = 4)

**동작 방식**:
- 각 레슨당 1개 문제만 할당
- 레슨 번호에 따라 5개 문제를 순환 할당
- 예: Lesson 1 → 문제1, Lesson 2 → 문제2, Lesson 6 → 문제1 (순환)

## 🎯 개선 필요 사항

### 1. 즉시 조치 (High Priority)

#### A. 문제 데이터 확장
- [ ] 각 카테고리별 폴더 생성
  ```
  lib/data/problems/
  ├── polynomials/     ✅ (2개 존재)
  ├── equations/       ❌ 생성 필요
  ├── geometry/        ❌ 생성 필요
  ├── statistics/      ❌ 생성 필요
  ├── functions/       ❌ 생성 필요
  └── calculus/        ❌ 생성 필요
  ```

#### B. JSON 파일 대신 실제 DB 사용
현재는 JSON 파일로 관리하지만, 확장성을 위해 다음 고려:
- [ ] Firebase Firestore 연동
- [ ] SQLite 로컬 DB
- [ ] API 서버에서 동적 로드

#### C. 이미지 리소스 준비
```
assets/problems/images/
├── polynomial_001_question.png   ❌ 미생성
├── polynomial_001_answer.png     ❌ 미생성
├── polynomial_002_question.png   ❌ 미생성
└── polynomial_002_answer.png     ❌ 미생성
```
**현재 상태**: JSON에 경로만 정의됨, 실제 이미지 없음

### 2. 중기 개선 (Medium Priority)

#### A. 문제 유형 다양화
현재는 객관식(multipleChoice)만 구현됨
- [ ] shortAnswer (주관식) 구현
- [ ] dragAndDrop (드래그 앤 드롭) 구현
- [ ] stepByStep (단계별 풀이) 구현

#### B. 문제 난이도 시스템
- [ ] 난이도별 문제 분류 (1-5)
- [ ] 사용자 레벨에 따른 문제 추천
- [ ] 적응형 난이도 조절

#### C. 힌트 시스템 강화
- [ ] 단계별 힌트 표시
- [ ] 힌트 사용 시 XP 감소
- [ ] 힌트 잠금/해금 시스템

### 3. 장기 개선 (Low Priority)

#### A. AI 문제 생성
- [ ] OpenAI API를 활용한 문제 자동 생성
- [ ] 사용자 맞춤형 문제 생성
- [ ] 오답 기반 유사 문제 생성

#### B. 문제 풀 관리
- [ ] 문제 버전 관리
- [ ] 문제 품질 관리
- [ ] 문제 피드백 시스템

## 📊 현재 시스템 동작 방식

### 문제 로드 플로우

```
1. 사용자가 레슨 선택
   ↓
2. ProblemSolvingScreen 실행
   ↓
3. ProblemRepository.loadProblemsByLesson(lessonId) 호출
   ↓
4. _generateSingleProblem(lessonId) 실행
   ↓
5. 레슨 번호에 따라 5개 샘플 문제 중 1개 선택
   ↓
6. Problem 객체 반환
   ↓
7. 화면에 문제 표시
```

### 문제 데이터 소스

**우선순위**:
1. **JSON 파일** (`lib/data/problems/`) - 2개 존재 ✅
2. **하드코딩된 샘플** (`ProblemRepository`) - 5개 존재 ✅
3. **동적 생성** - 미구현 ❌

## 🚀 권장 구현 순서

### Phase 1: 문제 데이터 확장 (1-2주)
1. 각 학년별/단원별 JSON 문제 파일 생성
2. 문제 이미지 리소스 준비
3. Korean Math Curriculum과 연동

### Phase 2: 문제 유형 다양화 (2-3주)
1. 주관식 문제 UI/UX 구현
2. 드래그 앤 드롭 문제 구현
3. 단계별 풀이 문제 구현

### Phase 3: DB 연동 (3-4주)
1. Firebase Firestore 설정
2. 문제 데이터 마이그레이션
3. 실시간 문제 업데이트 시스템

### Phase 4: AI 문제 생성 (4-6주)
1. OpenAI API 연동
2. 문제 생성 템플릿 개발
3. 품질 검증 시스템 구축

## 📈 성장 가능성

**현재**: 2개 JSON + 5개 샘플 = **7개 문제**

**목표**:
- 1개월 후: 100개 문제 (수동 생성)
- 3개월 후: 500개 문제 (반자동 생성)
- 6개월 후: 5,000개 문제 (AI 자동 생성)

