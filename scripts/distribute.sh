#!/bin/bash

# ========================================
# MathLab - Test Distribution Script
# ========================================
#
# Firebase App Distribution으로 테스터에게 앱 배포
#
# Usage:
#   ./scripts/distribute.sh android          # Android APK 배포
#   ./scripts/distribute.sh ios              # iOS IPA 배포
#   ./scripts/distribute.sh both             # 둘 다 배포
#
# Prerequisites:
#   - Firebase CLI: npm install -g firebase-tools
#   - Firebase Login: firebase login
#   - Testers group 'testers' created in Firebase Console

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Firebase App IDs
ANDROID_APP_ID="1:421762663548:android:8819363bb6b0f241ff35f9"
IOS_APP_ID="1:421762663548:ios:ec47fb21b270e08dff35f9"
TESTERS_GROUP="testers"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# ========================================
# Android Distribution
# ========================================
distribute_android() {
    print_header "Android 테스트 배포 (Shorebird release)"

    echo -e "${YELLOW}Building Android APK via Shorebird...${NC}"
    export PATH="$HOME/.shorebird/bin:$PATH"
    yes | shorebird release android --artifact apk --build-number="$BUILD_NUMBER"

    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

    if [ ! -f "$APK_PATH" ]; then
        echo -e "${RED}APK not found: $APK_PATH${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Uploading to Firebase App Distribution...${NC}"
    firebase appdistribution:distribute "$APK_PATH" \
        --app "$ANDROID_APP_ID" \
        --groups "$TESTERS_GROUP" \
        --release-notes "Build #$BUILD_NUMBER - $(git log -1 --pretty=%s 2>/dev/null || echo 'New build')"

    echo -e "${GREEN}Android 배포 완료!${NC}"
    echo -e "테스터들에게 이메일 알림이 발송되었습니다."
}

# ========================================
# iOS Distribution
# ========================================
distribute_ios() {
    print_header "iOS 테스트 배포"

    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}iOS 빌드는 macOS에서만 가능합니다.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Building iOS IPA via Shorebird...${NC}"
    export PATH="$HOME/.shorebird/bin:$PATH"
    yes | shorebird release ios --build-number="$BUILD_NUMBER" --export-method=ad-hoc

    IPA_PATH=$(find build/ios/ipa -name "*.ipa" -type f | head -1)

    if [ -z "$IPA_PATH" ]; then
        echo -e "${RED}IPA not found in build/ios/ipa/${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Uploading to Firebase App Distribution...${NC}"
    firebase appdistribution:distribute "$IPA_PATH" \
        --app "$IOS_APP_ID" \
        --groups "$TESTERS_GROUP" \
        --release-notes "Build #$BUILD_NUMBER - $(git log -1 --pretty=%s 2>/dev/null || echo 'New build')"

    echo -e "${GREEN}iOS 배포 완료!${NC}"
    echo -e "테스터들에게 이메일 알림이 발송되었습니다."
}

# ========================================
# Main
# ========================================
main() {
    local PLATFORM="${1:-both}"

    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║   MathLab - Test Distribution            ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"

    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        echo -e "${RED}Firebase CLI not found. Install: npm install -g firebase-tools${NC}"
        exit 1
    fi

    case "$PLATFORM" in
        android)
            distribute_android
            ;;
        ios)
            distribute_ios
            ;;
        both)
            distribute_android
            distribute_ios
            ;;
        *)
            echo -e "${RED}Invalid platform: $PLATFORM${NC}"
            echo "Usage: $0 [android|ios|both]"
            exit 1
            ;;
    esac

    echo -e "\n${GREEN}배포 완료!${NC}"
}

main "$@"
