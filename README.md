# 🧮 GoMath - 게이미피케이션 수학 학습 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.27.1-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Deploy](https://github.com/chatgptkrguide/MathLab/actions/workflows/deploy.yml/badge.svg)](https://github.com/chatgptkrguide/MathLab/actions/workflows/deploy.yml)

듀오링고 스타일의 게이미피케이션을 적용한 **재미있는 수학 학습 모바일 앱**입니다.
매일 짧은 시간 동안 꾸준히 수학을 학습하며 동기를 유지할 수 있도록 설계되었습니다.

## 🌐 데모

**웹 버전**: [https://chatgptkrguide.github.io/MathLab/](https://chatgptkrguide.github.io/MathLab/)

## ✨ 주요 기능

### 📚 학습 시스템
- **레벨 테스트**: 초기 진단 평가로 사용자 실력 파악
- **적응형 학습**: AI 기반 난이도 조절 및 취약 영역 집중 학습
- **다양한 문제 유형**: 객관식, 드래그 앤 드롭, 단답형
- **단계별 힌트**: 막힐 때 단계별 도움말 제공

### 🎮 게이미피케이션
- **경험치(XP) 시스템**: 문제를 풀면서 XP 획득
- **연속 학습 스트릭**: 매일 학습하여 스트릭 유지
- **레벨 시스템**: Bronze → Silver → Gold → Diamond
- **업적 뱃지**: 다양한 학습 성취 뱃지
- **리그 경쟁**: 주간 리그 시스템으로 친구들과 경쟁

### 📊 학습 관리
- **일일 목표**: 개인 맞춤형 일일 XP 목표 설정
- **학습 통계**: 상세한 학습 진행 상황 및 통계
- **오답 노트**: 틀린 문제 자동 저장 및 복습
- **학습 리마인더**: 알림을 통한 학습 습관 형성

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter 3.27.1 (크로스 플랫폼)
- **상태관리**: Riverpod 2.4.9
- **로컬 저장**: SharedPreferences, Hive
- **애니메이션**: Lottie, Confetti

### Backend & Authentication
- **인증**: Firebase Authentication
- **소셜 로그인**: Google, Kakao, Apple Sign-in
- **데이터베이스**: Local Storage (향후 PostgreSQL + Redis)

### 주요 라이브러리
```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # 상태 관리
  shared_preferences: ^2.2.2     # 로컬 저장
  lottie: ^2.7.0                 # 애니메이션
  confetti: ^0.7.0               # 축하 효과
  firebase_core: ^3.10.0         # Firebase
  firebase_auth: ^5.3.4          # 인증
  google_sign_in: ^6.2.1         # Google 로그인
  kakao_flutter_sdk: ^1.9.5      # Kakao 로그인
  sign_in_with_apple: ^6.1.3     # Apple 로그인
```

## 📱 지원 플랫폼

- ✅ **iOS** (iPhone, iPad)
- ✅ **Android** (스마트폰, 태블릿)
- ✅ **Web** (데스크톱 브라우저)
- 🚧 macOS (개발 중)
- 🚧 Windows (개발 중)

## 🚀 시작하기

### 요구사항

- Flutter SDK 3.27.1 이상
- Dart 3.5.0 이상
- Android Studio / Xcode (모바일 빌드용)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone https://github.com/chatgptkrguide/MathLab.git
   cd MathLab
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android

   # Web
   flutter run -d chrome
   ```

### 빌드

```bash
# Android APK
flutter build apk --release

# iOS (macOS 필요)
flutter build ios --release

# Web
flutter build web --release
```

## 📖 커리큘럼

### 기초 과정
- 사칙연산 (덧셈, 뺄셈, 곱셈, 나눗셈)
- 분수와 소수
- 비와 비율

### 중급 과정
- 대수 (방정식, 부등식, 함수)
- 기하 (도형, 각도, 면적, 부피)
- 통계와 확률

### 고급 과정 (예정)
- 미적분 (극한, 미분, 적분)
- 선형대수
- 고급 통계

## 🎨 디자인 시스템

프로젝트는 **Figma 디자인 시스템**을 기반으로 구축되었습니다.

- **색상**: 밝고 친근한 GoMath 브랜드 색상 팔레트
- **타이포그래피**: 가독성 중심의 폰트 계층 구조
- **애니메이션**: 부드럽고 자연스러운 전환 효과
- **레이아웃**: 모바일 우선 반응형 디자인

자세한 내용은 [DESIGN_GUIDE.md](DESIGN_GUIDE.md)를 참조하세요.

## 📂 프로젝트 구조

```
lib/
├── app/                    # 앱 설정 및 라우팅
├── data/
│   ├── models/            # 데이터 모델
│   ├── providers/         # Riverpod 상태 관리
│   └── services/          # API 및 저장소 서비스
├── features/              # 기능별 화면
│   ├── auth/             # 인증
│   ├── home/             # 홈 화면
│   ├── lessons/          # 레슨
│   ├── problem/          # 문제 풀이
│   ├── profile/          # 프로필
│   └── ...
├── shared/
│   ├── constants/        # 상수 (색상, 스타일 등)
│   ├── widgets/          # 공통 위젯
│   ├── utils/            # 유틸리티
│   └── themes/           # 테마
└── main.dart             # 앱 진입점
```

## 🎯 로드맵

### Phase 1 (MVP) - ✅ 완료
- [x] 기초 UI/UX 구현
- [x] 게이미피케이션 시스템
- [x] 레벨 테스트
- [x] 기본 문제 풀이 시스템
- [x] 소셜 로그인 연동

### Phase 2 - 🚧 진행 중
- [ ] 백엔드 API 구축
- [ ] 실시간 데이터 동기화
- [ ] 친구 시스템
- [ ] 그룹 학습 기능

### Phase 3 - 📋 계획
- [ ] AI 튜터 모드
- [ ] 오프라인 모드
- [ ] 부모 모드 (자녀 학습 추적)
- [ ] 다국어 지원

## 🤝 기여하기

기여를 환영합니다! 다음 단계를 따라주세요:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 문의

프로젝트 관련 문의사항은 [Issues](https://github.com/chatgptkrguide/MathLab/issues)에 등록해 주세요.

---

**Made with ❤️ by GoMath Team**

🤖 Enhanced with [Claude Code](https://claude.com/claude-code)
