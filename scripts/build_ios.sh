#!/bin/bash

# iOS Release 빌드 스크립트
# 사용법: ./scripts/build_ios.sh

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MathLab iOS Release Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# macOS 환경 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ iOS 빌드는 macOS에서만 가능합니다.${NC}"
    exit 1
fi

# GoogleService-Info.plist 확인
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${RED}❌ ios/Runner/GoogleService-Info.plist 파일이 없습니다.${NC}"
    echo -e "${YELLOW}Firebase Console에서 다운로드하여 추가해주세요.${NC}"
    exit 1
fi

# Xcode 설치 확인
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}App Store에서 Xcode를 설치해주세요.${NC}"
    exit 1
fi

# CocoaPods 설치 확인
if ! command -v pod &> /dev/null; then
    echo -e "${RED}❌ CocoaPods가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}다음 명령어로 설치하세요: sudo gem install cocoapods${NC}"
    exit 1
fi

# 1. Clean
echo -e "${BLUE}[1/6] 이전 빌드 정리 중...${NC}"
flutter clean
rm -rf ios/Pods ios/Podfile.lock
echo -e "${GREEN}✓ Clean 완료${NC}"
echo ""

# 2. Get dependencies
echo -e "${BLUE}[2/6] 의존성 패키지 다운로드 중...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies 완료${NC}"
echo ""

# 3. Install CocoaPods
echo -e "${BLUE}[3/6] CocoaPods 설치 중...${NC}"
cd ios
pod install
cd ..
echo -e "${GREEN}✓ CocoaPods 완료${NC}"
echo ""

# 4. Run tests
echo -e "${BLUE}[4/6] 테스트 실행 중...${NC}"
flutter test
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 테스트 실패. 빌드를 중단합니다.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 테스트 통과${NC}"
echo ""

# 5. Analyze
echo -e "${BLUE}[5/6] 코드 정적 분석 중...${NC}"
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

# 6. Build
echo -e "${BLUE}[6/6] Release 빌드 시작...${NC}"
echo -e "${YELLOW}⚠️  참고: Archive는 Xcode에서 수동으로 진행해야 합니다.${NC}"
echo ""

flutter build ios --release --no-codesign

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ iOS 빌드 성공!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}다음 단계 (Xcode에서 진행):${NC}"
    echo -e "  1. ${YELLOW}ios/Runner.xcworkspace${NC} 파일을 Xcode로 열기"
    echo -e "  2. Product > Archive 선택"
    echo -e "  3. Signing & Capabilities에서 팀 선택"
    echo -e "  4. Archive 완료 후 'Distribute App' 선택"
    echo -e "  5. App Store Connect 또는 Ad Hoc 배포 선택"
    echo ""
    echo -e "${BLUE}📝 필수 설정:${NC}"
    echo -e "  • Apple Developer 계정"
    echo -e "  • Provisioning Profile"
    echo -e "  • Distribution Certificate"
    echo -e "  • App Store Connect에 앱 등록"
    echo ""
    echo -e "${BLUE}💡 Xcode로 열기:${NC}"
    echo -e "  ${YELLOW}open ios/Runner.xcworkspace${NC}"
    echo ""
else
    echo -e "${RED}❌ 빌드 실패${NC}"
    exit 1
fi
