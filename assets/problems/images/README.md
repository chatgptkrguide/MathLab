# 문제 이미지 저장소

## 이미지 파일 저장 안내

이 폴더에 문제와 답안 이미지를 저장하세요.

### 현재 필요한 이미지

1. **polynomial_001_question.png**
   - 설명: 다항식 문제 본문 이미지
   - 크기 권장: 최대 1920x1080
   - 형식: PNG (투명 배경 권장)

2. **polynomial_001_answer.png**
   - 설명: 다항식 문제 정답 및 힌트 이미지
   - 크기 권장: 최대 1920x1080
   - 형식: PNG (투명 배경 권장)

### 이미지 저장 방법

1. 제공받은 이미지 파일을 다운로드
2. 파일명을 위의 이름으로 변경
3. 이 폴더(`assets/problems/images/`)에 복사

### pubspec.yaml 설정

이미지를 사용하려면 `pubspec.yaml`에 다음을 추가해야 합니다:

```yaml
flutter:
  assets:
    - assets/problems/images/
```

## 이미지 명명 규칙

- 형식: `{문제ID}_{question|answer}.png`
- 예시:
  - `polynomial_001_question.png` - 문제 이미지
  - `polynomial_001_answer.png` - 답안 이미지
  - `geometry_005_question.png` - 기하 문제 이미지

## 파일 크기 최적화

- PNG 압축 도구 사용 권장 (TinyPNG, ImageOptim 등)
- 목표: 이미지당 500KB 이하
- 해상도: 모바일 화면에 적합한 크기 유지
