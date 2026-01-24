# MathLab Assets 가이드

## 📢 중요 안내

현재 프로젝트에는 사운드와 애니메이션 에셋이 **포함되어 있지 않습니다**. 아래 가이드를 참고하여 무료 에셋을 다운로드하거나 직접 제작하세요.

---

## 🎵 사운드 에셋 (assets/sounds/)

### 필수 사운드 파일 목록

다음 파일들을 `assets/sounds/` 디렉토리에 추가하세요:

#### 정답/오답
- `correct.mp3` - 정답 사운드 (긍정적, 밝은 소리)
- `wrong.mp3` - 오답 사운드 (부드러운 오류음)

#### XP 및 레벨
- `xp_gain.mp3` - XP 획득 효과음 (코인 소리)
- `level_up.mp3` - 레벨업 효과음 (팡파레)

#### 업적 및 보상
- `achievement.mp3` - 업적 달성 (성공 효과음)
- `reward_claim.mp3` - 보상 획득 (아이템 획득 소리)

#### 스트릭
- `streak_maintain.mp3` - 스트릭 유지 (긍정적 알림)
- `streak_break.mp3` - 스트릭 끊김 (유감 효과음)

#### UI 상호작용
- `button_click.mp3` - 버튼 클릭 (경쾌한 클릭음)
- `button_hover.mp3` - 버튼 호버 (부드러운 효과음)

#### 하트
- `heart_lose.mp3` - 하트 소진 (아쉬움 표현)
- `heart_recover.mp3` - 하트 회복 (회복 효과음)

#### 문제 풀이
- `problem_start.mp3` - 문제 시작 (시작 신호음)
- `problem_complete.mp3` - 문제 완료 (완료 효과음)
- `hint_used.mp3` - 힌트 사용 (알림 소리)

#### 축하
- `celebration.mp3` - 축하 효과음 (큰 성취)
- `confetti.mp3` - Confetti 효과음 (폭죽 소리)

#### 배경 음악 (선택사항)
- `background_music.mp3` - 배경 음악 (부드럽고 집중력 향상 음악)

### 무료 사운드 소스

추천 웹사이트:

1. **Freesound.org** (https://freesound.org)
   - 무료 CC 라이선스 사운드
   - 검색어: "click", "success", "coin", "level up", "achievement"

2. **Pixabay Music** (https://pixabay.com/music)
   - 로열티 프리 사운드 효과
   - MP3 다운로드 가능

3. **Zapsplat** (https://www.zapsplat.com)
   - 게임 효과음 전문
   - 무료 계정으로 다운로드 가능

4. **Mixkit** (https://mixkit.co/free-sound-effects)
   - 고품질 무료 효과음
   - 상업적 사용 가능

### 사운드 포맷 권장사항

- **포맷**: MP3 (Flutter에서 가장 호환성 좋음)
- **샘플링 레이트**: 44.1kHz
- **비트레이트**: 128kbps (파일 크기 최적화)
- **길이**:
  - UI 효과음: 0.1-0.5초
  - 성공 효과음: 0.5-2초
  - 배경 음악: 30-120초 (루프 가능)

---

## 🎨 Lottie 애니메이션 (assets/lottie/)

### 필수 Lottie 파일 목록

다음 파일들을 `assets/lottie/` 디렉토리에 추가하세요:

- `confetti.json` - Confetti 축하 애니메이션
- `star_burst.json` - 별 터지는 효과
- `heart_break.json` - 하트 깨지는 애니메이션

### 무료 Lottie 애니메이션 소스

1. **LottieFiles** (https://lottiefiles.com)
   - 세계 최대 Lottie 애니메이션 라이브러리
   - 무료 다운로드 (로그인 필요)
   - 검색어: "confetti", "celebration", "star burst", "heart break", "success", "achievement"

2. **GitHub Lottie Collections**
   - 오픈소스 Lottie 애니메이션
   - MIT 라이선스

### Lottie 애니메이션 권장사항

- **파일 크기**: < 100KB (최적화 필수)
- **프레임 레이트**: 30-60fps
- **포맷**: JSON (Lottie 기본 포맷)
- **최적화 도구**: https://lottiefiles.com/tools/lottie-optimizer

---

## 🚀 에셋 추가 방법

### 1. 사운드 파일 추가

```bash
# 1. assets/sounds/ 디렉토리 확인 (이미 생성됨)
ls assets/sounds/

# 2. 다운로드한 MP3 파일들을 assets/sounds/에 복사
cp ~/Downloads/correct.mp3 assets/sounds/
cp ~/Downloads/wrong.mp3 assets/sounds/
# ... 나머지 파일들도 동일하게 복사

# 3. pubspec.yaml에 이미 포함되어 있는지 확인
cat pubspec.yaml | grep "assets/sounds/"
```

### 2. Lottie 애니메이션 추가

```bash
# 1. assets/lottie/ 디렉토리 확인 (이미 생성됨)
ls assets/lottie/

# 2. 다운로드한 JSON 파일들을 assets/lottie/에 복사
cp ~/Downloads/confetti.json assets/lottie/
cp ~/Downloads/star_burst.json assets/lottie/
cp ~/Downloads/heart_break.json assets/lottie/

# 3. pubspec.yaml에 이미 포함되어 있는지 확인
cat pubspec.yaml | grep "assets/lottie/"
```

### 3. Flutter pub get 실행

```bash
flutter pub get
```

---

## 🎮 동작 확인

### 사운드 테스트

앱을 실행하고 다음 기능들을 테스트하세요:

1. **문제 정답**: `SoundEffects.playCorrect()` 호출
2. **문제 오답**: `SoundEffects.playWrong()` 호출
3. **XP 획득**: `SoundEffects.playXPGain()` 호출
4. **레벨업**: `SoundEffects.playLevelUp()` 호출

### 애니메이션 테스트

1. **레슨 완료 시**: Confetti 애니메이션 자동 재생
2. **XP 획득 시**: XP Gain 애니메이션 표시
3. **하트 소진 시**: Heart Break 애니메이션 표시

---

## 📝 대체 방안 (에셋이 없을 경우)

### 코드에 이미 적용된 대체 처리

- **Lottie 파일이 없으면**: `errorBuilder`에서 기본 Flutter 아이콘으로 대체
- **사운드 파일이 없으면**: 로그만 출력하고 앱은 정상 작동

### 직접 제작

1. **사운드**: Audacity (무료 오디오 편집 프로그램)로 간단한 효과음 제작
2. **애니메이션**: Adobe After Effects + Bodymovin 플러그인으로 Lottie 제작

---

## 🔗 참고 자료

- [Freesound.org](https://freesound.org)
- [LottieFiles](https://lottiefiles.com)
- [Flutter Audio](https://docs.flutter.dev/development/packages-and-plugins/using-packages#audio)
- [Lottie Flutter](https://pub.dev/packages/lottie)

---

**마지막 업데이트**: 2024-01-16
