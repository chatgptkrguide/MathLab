# 스토어 에셋 준비 가이드

MathLab 앱을 앱스토어와 플레이스토어에 등록하기 위해 필요한 모든 이미지 에셋을 준비하는 가이드입니다.

## 📱 iOS App Store 필수 에셋

### 1. 앱 아이콘 (App Icon)

iOS는 다양한 크기의 아이콘이 필요합니다. 모든 아이콘은 **투명도 없는 PNG** 형식이어야 합니다.

#### 필수 아이콘 사이즈
| 사이즈 | 용도 | 파일명 |
|--------|------|--------|
| 1024x1024 | App Store | AppIcon-1024.png |
| 180x180 | iPhone (3x) | AppIcon-180.png |
| 120x120 | iPhone (2x) | AppIcon-120.png |
| 167x167 | iPad Pro | AppIcon-167.png |
| 152x152 | iPad (2x) | AppIcon-152.png |
| 76x76 | iPad | AppIcon-76.png |
| 40x40 | Spotlight | AppIcon-40.png |
| 29x29 | Settings | AppIcon-29.png |
| 20x20 | Notifications | AppIcon-20.png |

#### 아이콘 디자인 가이드라인
- ✅ 단순하고 명확한 디자인
- ✅ 앱의 정체성을 잘 나타냄
- ✅ 작은 크기에서도 인식 가능
- ❌ 투명 배경 사용 금지
- ❌ 텍스트를 너무 많이 사용 금지
- ❌ 다른 앱 아이콘과 너무 유사하지 않게

### 2. 스크린샷 (Screenshots)

앱스토어에 표시될 스크린샷입니다. **PNG 또는 JPG** 형식.

#### iPhone 스크린샷
- **6.7" Display (iPhone 15 Pro Max, 14 Plus 등)**
  - 크기: 1290 x 2796 픽셀
  - 최소 1장, 최대 10장

- **6.5" Display (iPhone 11 Pro Max, XS Max 등)**
  - 크기: 1242 x 2688 픽셀
  - 최소 1장, 최대 10장

#### iPad 스크린샷
- **12.9" Display (iPad Pro 12.9")**
  - 크기: 2048 x 2732 픽셀
  - 최소 1장, 최대 10장

#### 스크린샷 구성 추천
1. **온보딩/환영 화면** - 앱의 첫인상
2. **메인 화면** - 주요 기능이 보이는 홈 화면
3. **문제 풀이 화면** - 학습 중인 모습
4. **진행률 화면** - XP, 레벨, 스트릭 표시
5. **게이미피케이션** - 리그, 업적, 뱃지
6. **프로필 화면** - 사용자의 학습 통계

#### 스크린샷 디자인 팁
- ✅ 실제 기기에서 캡처
- ✅ 밝고 깔끔한 UI
- ✅ 텍스트 오버레이로 기능 설명 추가 가능
- ✅ 앱의 핵심 가치를 보여줌
- ❌ 로딩 화면 사용 금지
- ❌ 빈 상태나 에러 화면 금지

### 3. 앱 미리보기 영상 (Optional)

- **형식**: MP4 (H.264)
- **길이**: 15-30초
- **크기**: 스크린샷과 동일한 해상도
- **수**: 최대 3개

## 🤖 Android Play Store 필수 에셋

### 1. 앱 아이콘 (App Icon)

Android는 적응형 아이콘(Adaptive Icon)을 사용합니다.

#### 필수 아이콘 구성
| 구성 요소 | 크기 | 파일 위치 |
|-----------|------|-----------|
| Foreground | 432x432 | res/mipmap-xxxhdpi/ic_launcher_foreground.png |
| Background | 432x432 | res/mipmap-xxxhdpi/ic_launcher_background.png |
| Round | 192x192 | res/mipmap-xxxhdpi/ic_launcher_round.png |
| 레거시 | 192x192 | res/mipmap-xxxhdpi/ic_launcher.png |

#### 밀도별 아이콘 크기
| 밀도 | Foreground/Background | Round/Legacy |
|------|----------------------|--------------|
| ldpi (120dpi) | 81x81 | 36x36 |
| mdpi (160dpi) | 108x108 | 48x48 |
| hdpi (240dpi) | 162x162 | 72x72 |
| xhdpi (320dpi) | 216x216 | 96x96 |
| xxhdpi (480dpi) | 324x324 | 144x144 |
| xxxhdpi (640dpi) | 432x432 | 192x192 |

#### Play Store 아이콘
- **크기**: 512x512
- **형식**: PNG (32비트)
- **투명도**: 없음

### 2. 스크린샷

#### Phone 스크린샷
- **최소 크기**: 320 픽셀
- **최대 크기**: 3840 픽셀
- **종횡비**: 16:9 ~ 9:16
- **필수 개수**: 최소 2장, 최대 8장
- **추천 크기**: 1080 x 1920 (FHD)

#### 7-inch Tablet 스크린샷 (Optional)
- **크기**: 1200 x 1920
- **개수**: 최소 1장, 최대 8장

#### 10-inch Tablet 스크린샷 (Optional)
- **크기**: 1600 x 2560
- **개수**: 최소 1장, 최대 8장

### 3. 그래픽 이미지 (Feature Graphic)

플레이스토어 상단에 표시되는 대형 배너 이미지입니다.

- **크기**: 1024 x 500 픽셀 (정확히)
- **형식**: PNG 또는 JPG
- **최대 파일 크기**: 1MB
- **필수**: ✅

#### 디자인 가이드라인
- ✅ 앱 이름, 아이콘, 핵심 가치 포함
- ✅ 밝고 매력적인 디자인
- ✅ 텍스트는 최소화
- ❌ 스크린샷을 그대로 넣지 않기
- ❌ 너무 복잡한 디자인 지양

### 4. 앱 영상 (Optional)

- **플랫폼**: YouTube
- **길이**: 30초 ~ 2분
- **형식**: YouTube 링크 제공
- **개수**: 최대 1개

## 🎨 에셋 생성 도구 추천

### 온라인 도구
1. **Figma** - UI 디자인 및 프로토타이핑
2. **Canva** - 마케팅 이미지 제작
3. **App Icon Generator** - makeappicon.com
4. **Screenshot Frame** - screenshots.pro

### 오프라인 도구
1. **Adobe Photoshop** - 전문 이미지 편집
2. **Sketch** - macOS 전용 디자인 도구
3. **Affinity Designer** - 저렴한 대안

### Flutter 스크린샷 자동화
```yaml
# pubspec.yaml에 추가
dev_dependencies:
  screenshots: ^2.7.0
```

```yaml
# screenshots.yaml 파일 생성
devices:
  android:
    - Pixel 6
  ios:
    - iPhone 15 Pro Max
    - iPad Pro (12.9-inch) (6th generation)

locales:
  - ko-KR
  - en-US

tests:
  - test/screenshots_test.dart

staging: screenshots/staging
```

## 📋 스토어 리스팅 텍스트

### iOS App Store

#### 앱 이름
- **최대 길이**: 30자
- **추천**: "MathLab - 재미있는 수학 학습"

#### 부제목 (Subtitle)
- **최대 길이**: 30자
- **추천**: "게임처럼 즐기는 매일의 수학"

#### 설명
- **최대 길이**: 4000자
- 상세 내용은 `STORE_DEPLOYMENT_GUIDE.md` 참조

#### 키워드
- **최대 길이**: 100자 (쉼표로 구분)
- **추천**: "수학,학습,교육,게이미피케이션,듀오링고,문제풀이,초등,중등,고등,수학게임"

#### 카테고리
- **주 카테고리**: Education
- **부 카테고리**: Games

### Android Play Store

#### 앱 제목
- **최대 길이**: 50자
- **추천**: "MathLab - 재미있는 수학 학습"

#### 간단한 설명
- **최대 길이**: 80자
- **추천**: "게임처럼 즐기는 매일의 수학! 레벨업하며 수학 실력을 키워보세요."

#### 전체 설명
- **최대 길이**: 4000자
- 상세 내용은 `STORE_DEPLOYMENT_GUIDE.md` 참조

#### 카테고리
- **추천**: Education

## ✅ 체크리스트

### iOS 에셋 체크리스트
- [ ] 앱 아이콘 (모든 사이즈)
- [ ] iPhone 6.7" 스크린샷 (최소 1장)
- [ ] iPhone 6.5" 스크린샷 (최소 1장)
- [ ] iPad 12.9" 스크린샷 (최소 1장, iPad 지원 시)
- [ ] 앱 미리보기 영상 (선택사항)

### Android 에셋 체크리스트
- [ ] 적응형 아이콘 (Foreground/Background)
- [ ] Play Store 512x512 아이콘
- [ ] Phone 스크린샷 (최소 2장)
- [ ] Feature Graphic (1024x500)
- [ ] 7" Tablet 스크린샷 (선택사항)
- [ ] 10" Tablet 스크린샷 (선택사항)
- [ ] 앱 영상 YouTube 링크 (선택사항)

### 공통 체크리스트
- [ ] 모든 이미지가 선명하고 고품질
- [ ] 텍스트가 읽기 쉬움
- [ ] 앱의 핵심 기능을 잘 보여줌
- [ ] 브랜드 일관성 유지
- [ ] 저작권 문제 없음
- [ ] 적절한 해상도와 파일 형식

## 🎯 에셋 준비 우선순위

### 1단계: 필수 에셋 (출시 전 반드시 필요)
1. iOS: 1024x1024 앱 아이콘
2. Android: 512x512 Play Store 아이콘
3. Android: Feature Graphic (1024x500)
4. iOS: iPhone 6.7" 스크린샷 최소 1장
5. Android: Phone 스크린샷 최소 2장

### 2단계: 권장 에셋 (더 나은 전환율)
1. 각 플랫폼별 스크린샷 3-5장
2. 모든 사이즈의 앱 아이콘
3. 매력적인 Feature Graphic
4. 텍스트 오버레이가 있는 스크린샷

### 3단계: 최적화 에셋 (선택사항)
1. 앱 미리보기 영상
2. Tablet 스크린샷
3. 현지화된 스크린샷
4. A/B 테스트용 대체 에셋

## 💡 ASO (App Store Optimization) 팁

### 아이콘 최적화
- 경쟁 앱과 차별화된 색상과 디자인
- 작은 크기에서도 명확하게 인식 가능
- 트렌드를 따르되 시대를 초월하는 디자인

### 스크린샷 최적화
- 첫 번째 스크린샷이 가장 중요 (전환율 최대 30% 영향)
- 텍스트 오버레이로 핵심 가치 강조
- 실제 사용자 시나리오 보여주기
- 밝고 긍정적인 색상 사용

### Feature Graphic 최적화
- 앱 이름과 아이콘 포함
- 핵심 기능 3가지 강조
- 감성적이고 매력적인 비주얼
- 브랜드 컬러 활용

## 📞 도움이 필요하신가요?

에셋 준비에 어려움이 있다면:
- **디자이너 고용**: Fiverr, Upwork, 크몽
- **에셋 팩 구매**: GraphicRiver, CreativeMarket
- **템플릿 사용**: Canva Pro, Figma Community

---

**마지막 업데이트**: 2025년 1월 15일
