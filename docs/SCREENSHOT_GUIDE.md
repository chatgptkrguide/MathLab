# 📸 MathLab 스크린샷 촬영 가이드

## 📋 목차
1. [요구사항](#요구사항)
2. [촬영 계획](#촬영-계획)
3. [기술 사양](#기술-사양)
4. [촬영 방법](#촬영-방법)
5. [편집 가이드](#편집-가이드)
6. [업로드 방법](#업로드-방법)

---

## 📱 요구사항

### iOS App Store
- **필수 개수**: 최소 1장, 최대 10장
- **권장 개수**: 4-5장
- **디바이스 크기**:
  - iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max 등): **1290 x 2796 pixels**
  - iPhone 6.5" (iPhone 11 Pro Max, XS Max 등): 1242 x 2688 pixels
  - iPhone 5.5" (iPhone 8 Plus 등): 1242 x 2208 pixels
- **포맷**: PNG 또는 JPEG
- **색상 공간**: sRGB 또는 Display P3

### Android Play Store
- **필수 개수**: 최소 2장, 최대 8장
- **권장 개수**: 4-5장
- **크기**:
  - Phone: **1080 x 1920 pixels** 이상
  - Tablet: 1200 x 1920 pixels 이상
- **비율**: 16:9 또는 9:16
- **포맷**: PNG 또는 JPEG
- **최대 파일 크기**: 8MB

### Feature Graphic (Android 전용)
- **크기**: **1024 x 500 pixels**
- **포맷**: PNG 또는 JPEG
- **용도**: Play Store 상단 배너
- **필수**: Yes

---

## 🎯 촬영 계획

### 스크린샷 구성 (5장 권장)

#### 1번: 메인 홈 화면 (Welcome Screen)
**목적**: 첫인상 + 게이미피케이션 요소 강조
**포함 요소**:
- 현재 레벨 및 XP
- 학습 진행 상황
- 일일 스트릭 표시
- 밝고 친근한 UI

**메시지**:
- "게임처럼 재미있는 수학 학습"
- "매일 10분, 수학 실력 UP!"

#### 2번: 문제 풀이 화면
**목적**: 핵심 기능 - 학습 경험 보여주기
**포함 요소**:
- 수학 문제 (LaTeX 렌더링)
- 답안 선택지
- 힌트 버튼
- 진행률 바

**메시지**:
- "다양한 문제 유형과 단계별 힌트"
- "쉽게 이해하는 수학 개념"

#### 3번: 성과/리워드 화면
**목적**: 게이미피케이션 + 동기부여
**포함 요소**:
- XP 획득 애니메이션
- 레벨 업 또는 배지 획득
- 축하 애니메이션/Confetti

**메시지**:
- "성취감을 느끼는 학습"
- "배지와 레벨로 동기부여"

#### 4번: 학습 통계 화면
**목적**: 진도 추적 기능 강조
**포함 요소**:
- 주간/월간 학습 그래프
- 학습 시간 통계
- 문제 풀이 개수

**메시지**:
- "내 학습 현황 한눈에"
- "데이터로 보는 성장"

#### 5번: 친구/리더보드 화면
**목적**: 소셜 기능 + 경쟁 요소
**포함 요소**:
- 친구 목록
- 리더보드 순위
- 리그 시스템

**메시지**:
- "친구들과 함께 즐기는 수학"
- "순위 경쟁으로 더 재미있게"

---

## 🛠️ 기술 사양

### iOS 시뮬레이터 설정
```bash
# 6.7" 디바이스 (iPhone 15 Pro Max 권장)
flutter run -d "iPhone 15 Pro Max"

# 시뮬레이터에서 스크린샷
Cmd + S (자동 저장 위치: ~/Desktop)
```

### Android 에뮬레이터 설정
```bash
# Pixel 6 Pro (1080 x 2400) 권장
flutter run -d <emulator-id>

# 에뮬레이터에서 스크린샷
하드웨어 버튼 또는 스크린샷 툴 사용
```

### 해상도 확인
```
iOS 6.7": 1290 x 2796 (정확히 맞춰야 함)
Android: 1080 x 1920 (최소 크기)
```

---

## 📷 촬영 방법

### 방법 1: Flutter 앱 실행 후 직접 촬영 (권장)

#### iOS
```bash
# 1. 시뮬레이터 실행
open -a Simulator

# 2. 올바른 디바이스 선택
# Simulator > Device > iPhone 15 Pro Max

# 3. Flutter 앱 실행
flutter run -d "iPhone 15 Pro Max"

# 4. 각 화면에서 스크린샷
Cmd + S (Desktop에 자동 저장됨)

# 5. 파일명 정리
iPhone 15 Pro Max - MathLab - 1.png
iPhone 15 Pro Max - MathLab - 2.png
...
```

#### Android
```bash
# 1. 에뮬레이터 실행
flutter emulators --launch Pixel_6_Pro_API_33

# 2. Flutter 앱 실행
flutter run

# 3. 스크린샷 촬영
에뮬레이터 우측 툴바 > 카메라 아이콘
또는 Ctrl + S (Windows) / Cmd + S (Mac)

# 4. 저장 위치 확인
~/Desktop 또는 에뮬레이터 설정에 따라 다름
```

### 방법 2: 실제 기기에서 촬영

#### iOS (권장)
```bash
# 1. 실제 iPhone 연결
flutter run -d <device-id>

# 2. 스크린샷 촬영
사이드 버튼 + 볼륨 올리기 버튼 동시에 누르기

# 3. AirDrop으로 Mac에 전송
사진 앱 > 선택 > 공유 > AirDrop
```

#### Android
```bash
# 1. 실제 Android 기기 연결 (USB 디버깅 활성화)
flutter run

# 2. 스크린샷 촬영
전원 버튼 + 볼륨 내리기 버튼 동시에 누르기

# 3. PC로 전송
USB 케이블로 연결 후 파일 탐색기에서 복사
```

---

## 🎨 편집 가이드

### 편집 도구 추천

#### 무료 도구
1. **Preview (Mac 기본 앱)**
   - 간단한 크기 조정
   - 포맷 변환

2. **GIMP** (https://gimp.org)
   - 무료 고급 편집
   - Windows/Mac/Linux

3. **Canva** (https://canva.com)
   - 온라인 편집
   - 텍스트 오버레이

#### 유료 도구
1. **Adobe Photoshop**
   - 전문가용

2. **Sketch** (Mac)
   - UI/UX 디자인

3. **Figma** (웹)
   - 협업 가능

### 편집 작업 단계

#### 1. 크기 조정 (Resize)
```
iOS: 정확히 1290 x 2796
Android: 1080 x 1920 이상 (16:9 비율 유지)
```

**Preview (Mac)에서**:
```
1. 이미지 열기
2. Tools > Adjust Size
3. 1290 x 2796 입력 (iOS) 또는 1080 x 1920 (Android)
4. "Scale proportionally" 체크 해제
5. OK
```

#### 2. 텍스트 오버레이 추가 (선택사항)
**권장하지 않음** - 앱 스토어가 자동으로 텍스트 추가 영역 제공

단, 추가하려면:
- 상단 10%: 타이틀
- 하단 10%: 설명 텍스트
- 폰트 크기: 최소 50px (가독성)
- 색상: 화면과 대비되는 색

#### 3. 포맷 최적화
```bash
# PNG로 저장 (고품질)
파일 > Export > PNG

# JPEG로 저장 (용량 절약)
파일 > Export > JPEG (Quality 90%)
```

---

## 📤 업로드 방법

### iOS - App Store Connect

#### 1. App Store Connect 로그인
```
https://appstoreconnect.apple.com
```

#### 2. 앱 선택 후 스크린샷 업로드
```
1. My Apps > MathLab 선택
2. App Store 탭
3. 스크린샷 섹션
4. "+" 버튼 클릭
5. 파일 선택 (1290x2796)
6. 순서 드래그하여 조정
7. 저장
```

#### 3. 다른 기기 크기 (선택)
App Store Connect가 자동으로 다른 크기를 생성하지만, 최적화하려면:
- 6.5" (1242 x 2688) 별도 제작
- 5.5" (1242 x 2208) 별도 제작

### Android - Google Play Console

#### 1. Play Console 로그인
```
https://play.google.com/console
```

#### 2. 앱 선택 후 스크린샷 업로드
```
1. 앱 선택
2. Store presence > Main store listing
3. Phone screenshots 섹션
4. "Add images" 클릭
5. 파일 선택 (1080x1920 이상)
6. 최소 2장, 최대 8장 업로드
7. Save
```

#### 3. Feature Graphic 업로드
```
1. Feature graphic 섹션
2. "Upload" 클릭
3. 1024 x 500 이미지 선택
4. Save
```

---

## ✅ 체크리스트

### 촬영 전
- [ ] 앱이 정상 작동하는지 확인
- [ ] 데모 계정 또는 테스트 데이터 준비
- [ ] 시뮬레이터/에뮬레이터 올바른 크기로 설정
- [ ] 화면 밝기 최대로 설정
- [ ] 테마 설정 (라이트 모드 권장)

### 촬영 중
- [ ] 각 화면 완전히 로드된 후 캡처
- [ ] 개인정보 포함 여부 확인 (마스킹 필요)
- [ ] 상태바 시간 적절한지 확인 (10:00, 14:00 등)
- [ ] 배터리 아이콘 100% 표시
- [ ] 네트워크 연결 표시 확인

### 촬영 후
- [ ] 이미지 크기 정확한지 확인 (iOS: 1290x2796, Android: 1080x1920+)
- [ ] 포맷 확인 (PNG 또는 JPEG)
- [ ] 파일 이름 정리 (screenshot-1.png, screenshot-2.png 등)
- [ ] 최소 요구 개수 충족 (iOS: 1장+, Android: 2장+)
- [ ] Feature Graphic 준비 (Android 전용, 1024x500)

### 업로드 전
- [ ] 모든 이미지 품질 검토
- [ ] 오타 확인 (텍스트 오버레이 사용 시)
- [ ] 브랜드 가이드라인 준수
- [ ] 경쟁 앱 스크린샷과 비교

---

## 💡 추가 팁

### 좋은 스크린샷의 조건
- ✅ **선명함**: 텍스트가 읽기 쉬움
- ✅ **관련성**: 앱의 핵심 기능 보여줌
- ✅ **일관성**: 모든 스크린샷이 동일한 스타일
- ✅ **간결함**: 너무 많은 정보 피하기
- ✅ **매력적**: 시각적으로 아름답고 깔끔함

### 피해야 할 것
- ❌ 흐릿하거나 해상도가 낮은 이미지
- ❌ 개인정보가 포함된 화면
- ❌ 에러 메시지나 로딩 화면
- ❌ 너무 복잡하거나 어지러운 화면
- ❌ 텍스트가 너무 작아서 읽기 어려운 경우

### 스토어 최적화 (ASO) 팁
1. **첫 번째 스크린샷이 가장 중요**: 가장 매력적인 화면을 첫 번째로
2. **스토리텔링**: 스크린샷 순서가 사용자 여정을 보여주도록
3. **차별화**: 경쟁 앱과 다른 점 강조
4. **A/B 테스팅**: 다양한 스크린샷 조합 실험

---

## 🎬 Feature Graphic 디자인 가이드 (Android)

### 크기 및 사양
```
크기: 1024 x 500 pixels
포맷: PNG 또는 JPEG
최대 용량: 1MB
```

### 디자인 요소
```
배경: 브랜드 컬러 그라데이션 (#3B82F6)
로고: MathLab 로고 중앙 배치
텍스트:
  - "게임처럼 즐기는 수학 학습"
  - "매일 10분으로 실력 UP!"
그래픽: 수학 기호, 캐릭터 등
```

### 제작 방법
1. **Canva 템플릿 사용**
   - Canva에서 "YouTube Thumbnail" 템플릿 선택
   - 크기를 1024x500으로 조정
   - 디자인 후 PNG 다운로드

2. **Figma/Sketch 사용**
   - 1024x500 아트보드 생성
   - 디자인 완성
   - Export as PNG

3. **온라인 도구**
   - https://makeappicon.com (Feature Graphic 생성기)
   - 파일 업로드 후 자동 생성

---

## 📞 도움말

### 문제 해결

**Q: 스크린샷 크기가 정확하지 않음**
```bash
# ImageMagick으로 정확한 크기 조정 (Mac/Linux)
brew install imagemagick
convert input.png -resize 1290x2796! output.png
```

**Q: 파일 크기가 너무 큼 (8MB 초과)**
```bash
# 압축 (품질 90%)
convert input.png -quality 90 output.jpg
```

**Q: 시뮬레이터에서 촬영한 이미지 크기가 다름**
- 시뮬레이터 설정 확인: Window > Physical Size
- 또는 편집 도구로 정확한 크기로 조정

### 참고 자료
- Apple 스크린샷 가이드: https://developer.apple.com/app-store/product-page/
- Google Play 스크린샷 가이드: https://support.google.com/googleplay/android-developer/answer/9866151

---

**최종 업데이트**: 2025년 1월 18일
**문서 버전**: 1.0
