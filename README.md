# 🧮 MathLab - 게이미피케이션 수학 학습 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/chatgptkrguide/MathLab/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/chatgptkrguide/MathLab/actions)

듀오링고 스타일의 게이미피케이션을 적용한 **재미있는 수학 학습 모바일 앱**입니다.
매일 짧은 시간 동안 꾸준히 수학을 학습하며 동기를 유지할 수 있도록 설계되었습니다.

## 🚀 빠른 시작

### 배포 준비 완료! ✅

모든 코드 준비가 완료되었습니다. 지금 바로 배포할 수 있습니다!

```bash
# 1. 상태 점검
./scripts/health_check.sh

# 2. 릴리즈 빌드
./scripts/build_release.sh
```

📖 **자세한 배포 가이드**: [DEPLOYMENT_READY.md](DEPLOYMENT_READY.md)

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
- **학습 통계**: 일일/주간/월간 학습 데이터 시각화
- **오답 노트**: 틀린 문제 자동 저장 및 복습
- **진도 추적**: 실시간 학습 진도 확인

### 👥 소셜 기능
- **친구 시스템**: 친구 추가 및 학습 활동 공유
- **리더보드**: 전국 순위 및 친구 순위
- **그룹 학습**: 스터디 그룹 생성 및 참여

## 🛠️ 기술 스택

- **Framework**: Flutter 3.24.0
- **언어**: Dart 3.5.0
- **상태 관리**: Riverpod 2.4.9
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics)
- **디자인**: Material Design 3, Custom Duolingo-inspired UI
- **테스팅**: flutter_test, integration_test

## 📱 개발 환경 설정

### 요구사항
- Flutter SDK 3.24.0 이상
- Dart SDK 3.5.0 이상
- iOS: Xcode 15.0 이상 (macOS만 해당)
- Android: Android Studio, JDK 17

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/chatgptkrguide/MathLab.git
cd MathLab

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정
cp .env.example .env
# .env 파일에서 실제 값으로 교체

# 4. 앱 실행
flutter run
```

## 📦 배포

### Android

```bash
# 1. 키스토어 생성
./scripts/create_keystore.sh

# 2. App Bundle 빌드
./scripts/build_release.sh
# 또는
flutter build appbundle --release
```

### iOS

```bash
# 1. iOS 빌드
./scripts/build_release.sh
# 또는  
flutter build ios --release

# 2. Xcode에서 아카이브
open ios/Runner.xcworkspace
```

📖 **전체 배포 가이드**: [README_DEPLOYMENT.md](README_DEPLOYMENT.md)

## 🧪 테스트

```bash
# 단위 테스트
flutter test

# 커버리지 리포트
flutter test --coverage

# 코드 분석
flutter analyze
```

## 📖 문서

### 배포 관련
- [빠른 배포 가이드](DEPLOYMENT_READY.md) ⭐ 시작하기 좋음
- [상세 배포 가이드](docs/STORE_DEPLOYMENT_GUIDE.md)
- [스토어 에셋 가이드](docs/STORE_ASSETS_GUIDE.md)

### 법률 문서
- [개인정보 처리방침](docs/PRIVACY_POLICY.md)
- [서비스 이용약관](docs/TERMS_OF_SERVICE.md)

### 개발 문서
- [프로젝트 구조](CLAUDE.md)
- [디자인 가이드](DESIGN_GUIDE.md)

## 🔧 유틸리티 스크립트

```bash
# 프로젝트 상태 점검
./scripts/health_check.sh

# 키스토어 생성
./scripts/create_keystore.sh

# 릴리즈 빌드
./scripts/build_release.sh

# 앱 아이콘 생성
python3 scripts/generate_icon_placeholder.py

# Fastlane 설정
./fastlane_setup.sh
```

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스로 제공됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 문의

- **Email**: support@mathlab.com
- **Website**: https://mathlab.com

---

**Made with ❤️ using Flutter**
