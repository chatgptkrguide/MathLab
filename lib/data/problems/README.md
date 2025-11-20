# 문제 데이터 구조

## 폴더 구조

```
lib/data/problems/
├── README.md                    # 이 파일
├── polynomials/                 # 다항식 문제
│   ├── polynomial_001.json
│   ├── polynomial_002.json
│   └── ...
├── equations/                   # 방정식 문제
├── geometry/                    # 기하 문제
└── statistics/                  # 통계 문제

assets/problems/images/
├── polynomial_001_question.png  # 문제 이미지
├── polynomial_001_answer.png    # 답안 이미지
└── ...
```

## JSON 파일 형식

각 문제는 다음 형식을 따릅니다:

```json
{
  "id": "문제 고유 ID (예: polynomial_001)",
  "title": "문제 제목",
  "question": "문제 본문",
  "type": "문제 유형 (multipleChoice, shortAnswer, dragAndDrop, stepByStep)",
  "category": "카테고리 (algebra, geometry, statistics 등)",
  "difficulty": "난이도 (1-5)",
  "choices": ["선택지 1", "선택지 2", ...],
  "answer": "정답 (객관식: index, 주관식: string)",
  "hints": ["힌트 1", "힌트 2", ...],
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

## 문제 추가 방법

1. 해당 카테고리 폴더에 JSON 파일 생성
2. 문제 이미지를 `assets/problems/images/` 에 저장
3. JSON 파일에 문제 정보 입력
4. Problem 모델로 로드하여 사용

## 예시

```dart
// JSON 파일 로드
final jsonString = await rootBundle.loadString('lib/data/problems/polynomials/polynomial_001.json');
final jsonData = json.decode(jsonString);

// Problem 객체 생성
final problem = Problem.fromJson(jsonData);
```
