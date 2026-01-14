#!/bin/bash

# MathLab 릴리즈 빌드 자동화 스크립트
# iOS와 Android 릴리즈 빌드를 자동으로 실행합니다.

set -e  # 오류 발생 시 스크립트 중단

echo "=========================================="
echo "  MathLab 릴리즈 빌드 도구"
echo "=========================================="
echo ""

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/.."

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 에러 메시지 출력
error() {
    echo -e "${RED}❌ 오류: $1${NC}"
    exit 1
}

# 함수: 성공 메시지 출력
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 경고 메시지 출력
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 함수: 정보 메시지 출력
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 빌드 타입 선택
echo "빌드할 플랫폼을 선택하세요:"
echo "  1) Android (App Bundle)"
echo "  2) Android (APK)"
echo "  3) iOS"
echo "  4) 모두 (Android + iOS)"
echo ""
read -p "선택 (1-4): " BUILD_TYPE

case $BUILD_TYPE in
    1)
        PLATFORM="android-bundle"
        ;;
    2)
        PLATFORM="android-apk"
        ;;
    3)
        PLATFORM="ios"
        ;;
    4)
        PLATFORM="all"
        ;;
    *)
        error "잘못된 선택입니다."
        ;;
esac

echo ""
info "선택된 플랫폼: $PLATFORM"
echo ""

# Flutter 버전 확인
info "Flutter 버전 확인 중..."
flutter --version || error "Flutter가 설치되어 있지 않습니다."
echo ""

# 의존성 업데이트
info "의존성 업데이트 중..."
flutter pub get || error "의존성 업데이트 실패"
success "의존성 업데이트 완료"
echo ""

# 코드 분석
info "코드 분석 중..."
if flutter analyze --no-pub; then
    success "코드 분석 완료: 문제 없음"
else
    warning "코드에 경고 또는 오류가 있습니다."
    read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "빌드가 취소되었습니다."
    fi
fi
echo ""

# 빌드 번호 확인
info "현재 버전 정보:"
VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo "  버전: $VERSION"
echo ""

# Android 빌드
build_android() {
    local BUILD_MODE=$1  # "bundle" 또는 "apk"

    info "Android $BUILD_MODE 빌드 시작..."

    # key.properties 파일 확인
    if [ ! -f "android/key.properties" ]; then
        warning "key.properties 파일이 없습니다."
        echo "  릴리즈 서명을 위해 키스토어를 생성하시겠습니까?"
        read -p "키스토어 생성 스크립트를 실행하시겠습니까? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ./scripts/create_keystore.sh || error "키스토어 생성 실패"
        else
            warning "Debug 서명으로 빌드됩니다. (스토어 업로드 불가)"
        fi
    fi

    # 빌드 실행
    if [ "$BUILD_MODE" = "bundle" ]; then
        flutter build appbundle --release || error "App Bundle 빌드 실패"
        OUTPUT_FILE="build/app/outputs/bundle/release/app-release.aab"
    else
        flutter build apk --release || error "APK 빌드 실패"
        OUTPUT_FILE="build/app/outputs/flutter-apk/app-release.apk"
    fi

    # 빌드 결과 확인
    if [ -f "$OUTPUT_FILE" ]; then
        success "Android $BUILD_MODE 빌드 완료!"
        info "파일 위치: $OUTPUT_FILE"

        # 파일 크기 출력
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
        info "파일 크기: $FILE_SIZE"

        # 빌드 정보 저장
        BUILD_INFO_DIR="build_info"
        mkdir -p "$BUILD_INFO_DIR"

        BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')
        BUILD_INFO_FILE="$BUILD_INFO_DIR/android_${BUILD_MODE}_$(date '+%Y%m%d_%H%M%S').txt"

        cat > "$BUILD_INFO_FILE" << EOF
========================================
  MathLab Android $BUILD_MODE 빌드 정보
========================================

빌드 날짜: $BUILD_DATE
버전: $VERSION
플랫폼: Android
타입: Release $BUILD_MODE
파일: $OUTPUT_FILE
크기: $FILE_SIZE

Flutter 버전: $(flutter --version | head -1)

========================================
EOF

        success "빌드 정보 저장: $BUILD_INFO_FILE"
    else
        error "빌드 파일을 찾을 수 없습니다."
    fi

    echo ""
}

# iOS 빌드
build_ios() {
    # macOS 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "iOS 빌드는 macOS에서만 가능합니다."
    fi

    info "iOS 빌드 시작..."

    # Xcode 설치 확인
    if ! command -v xcodebuild &> /dev/null; then
        error "Xcode가 설치되어 있지 않습니다."
    fi

    # CocoaPods 설치 확인
    if ! command -v pod &> /dev/null; then
        warning "CocoaPods가 설치되어 있지 않습니다."
        info "CocoaPods 설치 중..."
        sudo gem install cocoapods || error "CocoaPods 설치 실패"
    fi

    # Pod 의존성 설치
    info "iOS 의존성 설치 중..."
    cd ios
    pod install || warning "Pod 설치 중 경고가 발생했습니다."
    cd ..

    # iOS 빌드
    flutter build ios --release || error "iOS 빌드 실패"

    success "iOS 빌드 완료!"
    info "다음 단계:"
    echo "  1. Xcode를 열어주세요: open ios/Runner.xcworkspace"
    echo "  2. Product > Archive를 선택하여 아카이브를 생성하세요."
    echo "  3. Organizer에서 App Store Connect로 업로드하세요."

    # 빌드 정보 저장
    BUILD_INFO_DIR="build_info"
    mkdir -p "$BUILD_INFO_DIR"

    BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    BUILD_INFO_FILE="$BUILD_INFO_DIR/ios_$(date '+%Y%m%d_%H%M%S').txt"

    cat > "$BUILD_INFO_FILE" << EOF
========================================
  MathLab iOS 빌드 정보
========================================

빌드 날짜: $BUILD_DATE
버전: $VERSION
플랫폼: iOS
타입: Release

Flutter 버전: $(flutter --version | head -1)

다음 단계:
1. Xcode를 열어주세요: open ios/Runner.xcworkspace
2. Product > Archive를 선택하여 아카이브를 생성하세요.
3. Organizer에서 App Store Connect로 업로드하세요.

========================================
EOF

    success "빌드 정보 저장: $BUILD_INFO_FILE"
    echo ""
}

# 빌드 실행
case $PLATFORM in
    android-bundle)
        build_android "bundle"
        ;;
    android-apk)
        build_android "apk"
        ;;
    ios)
        build_ios
        ;;
    all)
        build_android "bundle"
        build_ios
        ;;
esac

# 완료 메시지
echo ""
echo "=========================================="
success "빌드 프로세스 완료!"
echo "=========================================="
echo ""

# 배포 체크리스트
echo "📋 배포 체크리스트:"
echo ""
echo "[ ] 1. 빌드 파일 확인"
echo "[ ] 2. 스토어 에셋 준비 (아이콘, 스크린샷)"
echo "[ ] 3. 스토어 리스팅 작성"
echo "[ ] 4. 개인정보 처리방침 URL 설정"
echo "[ ] 5. 서비스 이용약관 URL 설정"
echo "[ ] 6. 스토어에 업로드"
echo "[ ] 7. 심사 제출"
echo ""

info "자세한 배포 가이드는 docs/STORE_DEPLOYMENT_GUIDE.md를 참조하세요."
echo ""
