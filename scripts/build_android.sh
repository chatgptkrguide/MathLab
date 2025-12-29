#!/bin/bash

# Android Release 빌드 스크립트
# 사용법: ./scripts/build_android.sh [apk|aab]

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MathLab Android Release Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 빌드 타입 확인 (기본값: apk)
BUILD_TYPE=${1:-apk}

if [[ "$BUILD_TYPE" != "apk" && "$BUILD_TYPE" != "aab" ]]; then
    echo -e "${RED}❌ 잘못된 빌드 타입입니다. 'apk' 또는 'aab'를 사용하세요.${NC}"
    exit 1
fi

# key.properties 파일 확인
if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}⚠️  경고: android/key.properties 파일이 없습니다.${NC}"
    echo -e "${YELLOW}⚠️  Debug signing으로 빌드됩니다.${NC}"
    echo -e "${YELLOW}⚠️  프로덕션 배포를 위해서는 key.properties를 생성하세요.${NC}"
    echo ""
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 1. Clean
echo -e "${BLUE}[1/5] 이전 빌드 정리 중...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean 완료${NC}"
echo ""

# 2. Get dependencies
echo -e "${BLUE}[2/5] 의존성 패키지 다운로드 중...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies 완료${NC}"
echo ""

# 3. Run tests
echo -e "${BLUE}[3/5] 테스트 실행 중...${NC}"
flutter test
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 테스트 실패. 빌드를 중단합니다.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 테스트 통과${NC}"
echo ""

# 4. Analyze
echo -e "${BLUE}[4/5] 코드 정적 분석 중...${NC}"
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  경고: 분석 중 이슈가 발견되었습니다.${NC}"
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo -e "${GREEN}✓ 분석 완료${NC}"
echo ""

# 5. Build
echo -e "${BLUE}[5/5] Release 빌드 시작...${NC}"
if [ "$BUILD_TYPE" == "apk" ]; then
    echo -e "${BLUE}빌드 타입: APK${NC}"
    flutter build apk --release

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}✓ APK 빌드 성공!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo -e "📦 출력 파일:"
        echo -e "   ${BLUE}build/app/outputs/flutter-apk/app-release.apk${NC}"
        echo ""

        # 파일 크기 표시
        APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo -e "📊 APK 크기: ${YELLOW}$APK_SIZE${NC}"
    fi
else
    echo -e "${BLUE}빌드 타입: App Bundle (AAB)${NC}"
    flutter build appbundle --release

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}✓ AAB 빌드 성공!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo -e "📦 출력 파일:"
        echo -e "   ${BLUE}build/app/outputs/bundle/release/app-release.aab${NC}"
        echo ""

        # 파일 크기 표시
        AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
        echo -e "📊 AAB 크기: ${YELLOW}$AAB_SIZE${NC}"
        echo ""
        echo -e "${BLUE}📝 참고: Google Play에 업로드하려면 AAB 파일을 사용하세요.${NC}"
    fi
fi

echo ""
echo -e "${BLUE}다음 단계:${NC}"
if [ "$BUILD_TYPE" == "aab" ]; then
    echo -e "  1. Google Play Console에 로그인"
    echo -e "  2. '릴리스 만들기' 선택"
    echo -e "  3. AAB 파일 업로드"
else
    echo -e "  1. 기기에서 테스트"
    echo -e "  2. 정상 작동 확인 후 AAB로 빌드"
    echo -e "     ${YELLOW}./scripts/build_android.sh aab${NC}"
fi
echo ""
